// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// DES is the newly created decentrilized voting system that runs on the ethereum's blockchain Network.
// This system provides fully transparant and un-modifiable voting results which removes traditional untrusted votings.
// [Under-development]

// [developer: basant0x01]
// [contact: basant0x01@wearehackerone.com]

contract DElectionSewa{
 
    address chiefElectionCommissioner; // Controls Internal Voting managements

 struct party{
     string partyName;
     address partyAddress;
     string partyRepresentative;
     uint partySymbol;
     uint totalVotes;
     bool isElectionWinner;
 }

 struct voter{
     address voterAddress;
     bool alreadyVoted;
     uint votedTo;
 }

    constructor(address _chiefElectionCommissionerAddress){
        chiefElectionCommissioner = _chiefElectionCommissionerAddress;
    }
 
    mapping(uint=>party) public parties;
    mapping(address=>voter) public voters;
    uint public allTotalVoters;

 function registerParties(string memory _partyName,address _partyAddress,string memory _partyRepresentative,uint _partySymbol) public {
     party storage thisParty = parties[_partySymbol];
     thisParty.partyAddress = _partyAddress;
     thisParty.partyName = _partyName;
     thisParty.partyRepresentative = _partyRepresentative;
     thisParty.partySymbol = _partySymbol;
     thisParty.totalVotes = 0;
 }

 function voteYourParty(uint _partySymbol) public {
     party storage thisParty = parties[_partySymbol];
     voter storage thisVoter = voters[msg.sender];
     require(thisVoter.alreadyVoted == false,"You have already voted");
     thisVoter.voterAddress = msg.sender;
     thisVoter.votedTo = _partySymbol;
     thisVoter.alreadyVoted = true;
     thisParty.totalVotes +=1;
     allTotalVoters +=1;
 }

    // You have to input most voted party for the validation.
 function showElectionWinner(uint _partySymbol) public {
     party storage thisParty = parties[_partySymbol];
     // If this party has total 10 Votes then, more than 5 voters should vote this party to select as winner. 
     require(thisParty.totalVotes > allTotalVoters/2,"Majorty of voters do not support this party");
     thisParty.isElectionWinner = true;
 }

}