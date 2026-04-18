// SPDX-License-Identifier: MIT
// Compiler version: ^0.8.20 indicates version 0.8.20 and above, but below 0.9.0
pragma solidity ^0.8.20;

// Tip Jar Smart Contract
contract TipJar {
    // ********** State Variables **********
    // Address of the contract owner (deployer)
    address public owner;
    // Total amount of tips received (in wei, 1 ether = 1,000,000,000,000,000,000 wei)
    uint256 public totalTips;
    // Total number of unique tippers
    uint256 public totalTippers;

    // ********** Events **********
    // Event 1: Triggered when someone sends a tip
    event TipReceived(address indexed tipper, uint256 amount);
    // Event 2: Triggered when the owner withdraws tips
    event TipsWithdrawn(uint256 amount);

    // ********** Constructor **********
    // Automatically executed once when the contract is deployed to the blockchain
    constructor() {
        // Set the deployer as the owner
        owner = msg.sender;
    }

    // ********** Receive Ether Function **********
    // This function allows the contract to receive ether through direct transfers
    // (without calling the tip() function)
    receive() external payable {
        // When a plain ether transfer is received, automatically process it as a tip
        tip();
    }

    // ********** Write Function 1: Send a Tip **********
    // The `payable` modifier allows this function to receive ether
    function tip() public payable {
        // Basic validation: tip amount must be greater than 0
        require(msg.value > 0, "Tip amount must be greater than 0");
        
        // Update state variables
        totalTips += msg.value;      // Add to total tips
        totalTippers += 1;           // Increment tipper count
        
        // Emit event to log the tip
        emit TipReceived(msg.sender, msg.value);
    }

    // ********** Write Function 2: Withdraw Tips **********
    // This function is not `payable` because it sends ETH, not receives it
    function withdrawTips() public {
        // Only the contract owner can withdraw
        require(msg.sender == owner, "Only the owner can withdraw tips");
        
        // Get the current contract balance
        uint256 contractBalance = address(this).balance;
        
        // Ensure there are tips to withdraw
        require(contractBalance > 0, "No tips to withdraw");
        
        // CRITICAL: Update state BEFORE external call to prevent reentrancy
        // This follows the "checks-effects-interactions" pattern
        totalTips = 0;  // Reset total tips tracking
        
        // Send the entire contract balance to the owner
        (bool success, ) = owner.call{value: contractBalance}("");
        
        // Ensure the transfer was successful
        require(success, "Withdrawal failed");
        
        // Emit event to log the withdrawal
        emit TipsWithdrawn(contractBalance);
    }

    // ********** Read Function: Get Contract Balance **********
    // The `view` modifier indicates this function only reads state, doesn't modify it
    function getContractBalance() public view returns (uint256) {
        // Return the contract's current ether balance
        return address(this).balance;
    }
}