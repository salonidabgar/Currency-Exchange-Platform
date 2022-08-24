// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "./TokenB.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Context.sol";


contract Vendor is Ownable {
  ERC20Basic yourToken;
  uint256 public tokensBPerTokensA = 100;
  event BuyTokens(address buyer, uint256 amountOfTokenA, uint256 amountOfTokens);
  constructor(address tokenAddress) {
    yourToken = ERC20Basic(tokenAddress);
  }

  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "You need to send some Token A to proceed");
    uint256 amountToBuy = msg.value * tokensBPerTokensA;

    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor has insufficient tokens");

    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    emit BuyTokens(msg.sender, msg.value, amountToBuy);
    return amountToBuy;
  }
  function sellTokens(uint256 tokenAmountToSell) public {

    require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "You have insufficient tokens");

    uint256 amountofTokenAtoTransfer = tokenAmountToSell / tokensBPerTokensA;
    uint256 ownerTokenABalance = address(this).balance;
    require(ownerTokenABalance >= amountofTokenAtoTransfer, "Vendor has insufficient funds");
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");

    (sent,) = msg.sender.call{value: amountofTokenAtoTransfer}("");
    require(sent, "Failed to send TokenA to the user");
  }

  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "No TokenA present in Vendor");
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to withdraw");
  }
}