// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract malamalWeeklyLottery{

    address manager;
    address payable[] public participants;

    constructor(){
        manager = msg.sender;
    }

    modifier onlyManager(){
        require(msg.sender == manager,"You are not authorizaed, only manager can");
        _;
    }

    function totalLotteryPrice() public view onlyManager returns(uint){
        return address(this).balance;
    }

    receive() external payable {
        require(msg.value == 1 ether,"Malamal Weekly Lottery Price is 1 ether");
        participants.push(payable(msg.sender));
    }

    function chooseRandomWinner() public payable onlyManager{
        require(participants.length > 1,"Participants must greater than 1");
        // For generating randomness you must use Oracals, this is only for test example
        uint random = uint(keccak256(abi.encodePacked(block.timestamp,participants.length)));
        uint participantsIndex = (random % participants.length); // reminder will be less than the participants length.
        address payable randomWinner = participants[participantsIndex];
        randomWinner.transfer(totalLotteryPrice());
        participants  = new address payable[](0); // this will reset participants array 
    }

}