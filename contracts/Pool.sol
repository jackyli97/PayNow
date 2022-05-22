/*

constructor
    -employee address
    -employer address
    -monthly amount

global variables
    -balance
    -employee address
    -employer address
    -monthly amount

functions
    -withdraw
    -calculate max withdraw - do this on the frontend.
    -deposit
    -getBalance



*/

//should pool maintain a mapping from employeeAddress to balance?
// Will be useful for calling getBalance from employee smart contract.

pragma solidity ^0.8.0;

contract Pool {
    address employerAddress;
    address employeeAddress;
    uint256 monthlyAmount;
    uint256 balance;

    constructor(
        address _employerAddress,
        address _employeeAddress,
        uint256 _monthlyAmount
    ) {
        employerAddress = _employerAddress;
        employeeAddress = _employeeAddress;
        monthlyAmount = _monthlyAmount;
    }

    function deposit() public {
        require(
            msg.sender == employerAddress,
            "Only an employer can deposit money in the pool"
        );
        balance += monthlyAmount;
    }

    function withdraw(uint256 _amount) public {
        require(
            msg.sender == employeeAddress,
            "Only and employee can withdraw money from the pool"
        );
        balance -= _amount;
    }

    function getBalance() public view returns (uint256) {
        // require(msg.sender == employerAddress || employeeAddress);
        return balance;
    }
}
