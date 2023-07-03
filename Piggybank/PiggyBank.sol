// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/* Nature :
For withdraw all the deposited amount, owner should distroy the piggybank first
*/
contract piggyBank {

    address public owner; // after selfdestruct, the contract should distroy.

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender,"You are not owner");
        _;
    }

    receive() external payable {

    }

    function withdrawAllAmount() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

}