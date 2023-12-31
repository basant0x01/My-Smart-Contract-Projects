// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiSigWallet {

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    // ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"]

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        
        // 0x0121 Input
        // 0 Index = 1 Length
        // 1 Length > 0 Length = true [ Bug ]
        // Atleast length of 2 owner should requires for the confirmation
        require(_owners.length > 0, "owners required");
        // 1 > 0 (pass) && 1 <= 1 (0x0121) (pass)
        // That mean a single person can bypass the constructor requires
        require( _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,"invalid number of required confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        // for receiving ether to the contract
    }

    function submitTransaction(address _to,uint _value,bytes memory _data) public onlyOwner {
        transactions.push(Transaction({to: _to,value: _value,data: _data,executed: false,numConfirmations: 0}));
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

    }

    function executeTransaction( uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= numConfirmationsRequired,"cannot execute tx");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");
    }

    function revokeConfirmation(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)public view returns (address to,uint value,bytes memory data,bool executed,uint numConfirmations){
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to,transaction.value,transaction.data,transaction.executed,transaction.numConfirmations);
    }
}
