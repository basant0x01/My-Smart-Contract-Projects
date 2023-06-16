// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SewaCrowdFundings {

    address manager;
    uint targetedAmount; 
    uint deadline;
    uint minRefundTime;
    uint minContribution;
    uint currentRaisedAmount;
    uint totalNumberOfContributors;

    // Used to findout the contributers balance
    mapping(address=>uint) public contributer;

    struct requestForProject{
        string projectDescription;
        uint projectBudget;
        address payable recipient;
        uint totalVotes;
        bool isRequestForProjectCompleted;
        mapping(address=>bool) voter;
    }

    uint public totalNumOfRequests;

    mapping(uint=>requestForProject) public Requests; // Search Requests by Index

    modifier onlyManager{
        require(msg.sender == manager,"You are not manager");
        _;
    }
    
    // This contructor will be set by the Manager/Admin
    constructor(uint _targetedAmount, uint _deadline, uint _minRefundTime){
        targetedAmount = _targetedAmount; // [100 ether targeted]
        deadline = block.timestamp + _deadline; // Deadline in second [ 7 days: 604800 Sec ]
        minRefundTime = block.timestamp + _minRefundTime; // [ Wait 30 days for refund: 2592000 Sec ]
        minContribution = 5 ether;
        manager = msg.sender;
    }

    function sendEther() public payable {
        require(block.timestamp < deadline,"Deadline has finished");
        require(msg.value >= minContribution,"Amount is not sufficent");

        // Only execute the condition, if the contributer balance is == 0 (Zero)
        if(contributer[msg.sender] == 0){ 
            totalNumberOfContributors +=1;
        }

        // Otherwise only the balace will update with the previous balance
        contributer[msg.sender] += msg.value;
        currentRaisedAmount += msg.value;
    }

    // Public cannot refund their balance untill the time reached to timeForInvestament.
    function reFundEther() external payable {
        require(contributer[msg.sender] > 0,"You do not have any contribution");
        require(block.timestamp > minRefundTime,"You cannnot refund at this time, wait minimum 30 days");

        address payable user = payable(msg.sender);
        user.transfer(contributer[msg.sender]);
        contributer[msg.sender] = 0; // Update balance to 0
    }

    function createRequestForProject(string memory _projectDescription, uint _projectBudget, address payable _recipient) 
    public onlyManager {
       requestForProject storage thisProject = Requests[totalNumOfRequests];
       thisProject.projectDescription = _projectDescription;
       thisProject.projectBudget = _projectBudget;
       thisProject.recipient = _recipient;
       thisProject.isRequestForProjectCompleted = false;
       thisProject.totalVotes=0;
       totalNumOfRequests +=1;
    }

    function vote(uint _IndexOfRequest) public {
        requestForProject storage thisProject = Requests[_IndexOfRequest];
        require(contributer[msg.sender] > 0,"Please contribute first");
        require(thisProject.voter[msg.sender] == false,"You have already voted");
        thisProject.voter[msg.sender] = true;
        thisProject.totalVotes +=1;
    }

    function fundMostVotedRequest(uint _IndexOfRequest) public onlyManager {
        requestForProject storage thisProject = Requests[_IndexOfRequest];
        require(currentRaisedAmount >= targetedAmount,"Target Amount not reached");
        require(thisProject.isRequestForProjectCompleted==false,"The Request for this Project already Completed");
        require(thisProject.totalVotes > totalNumberOfContributors/2,"Majority of Peoples do not support this Request");
        thisProject.recipient.transfer(thisProject.projectBudget);
        thisProject.isRequestForProjectCompleted=true;
    }

}