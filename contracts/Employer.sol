pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// interface PoolInterface {
//         function deposit(address _to) external;
//     }

contract Employer is Ownable{
    string employerName;
    address employer;
    uint32 private _numEmployees;
    mapping(address => uint256) private _salaries;
    // Employee status 0=not added by empployer, 1=added by employer,2=employee has created contract/account
    mapping(address => uint8) private _employeeStatus;
    mapping(address=>uint256) private _balances;

    

    constructor(string memory _employerName) {
        employerName = _employerName;
        employer = msg.sender;
    }

    modifier employeeAdded(address _employee) {
        require(_employeeStatus[_employee] != 0, "Employee has not been added by employer");
        _;
    }

    function addEmployee(address _toAdd, uint256 _salary) public onlyOwner {
        require(_toAdd != address(0), "Can't add zero address to employees");
        // Since _employeeStatus default value is 0, an employee has not been added to employees yet if their address maps to 0
         require(_employeeStatus[_toAdd] == 0, "Employee has already been added to employees");
        _salaries[_toAdd] = _salary;
        _employeeStatus[_toAdd] = 1;
        _numEmployees += 1;
    }

    function getNumEmployees() public view onlyOwner returns (uint32) {
        return _numEmployees;
    }

    function getSalary(address _employee) public view employeeAdded(_employee) returns(uint256) {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own salaries");
        return _salaries[_employee];
    }

    function updateSalary(address _employee, uint256 _salary) public onlyOwner employeeAdded(_employee) {
        _salaries[_employee] = _salary;
    }

    function checkEmployeeStatus(address _employee) public view employeeAdded(_employee) returns(uint8) {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own statuses");
        return _employeeStatus[_employee];
    }

    /// @dev This method is called once an employee instansiates an Employee contract w/ their address
    function updateEmployeeStatus(address _employee) external employeeAdded(_employee) {
        require(_employeeStatus[_employee] != 2, "Employee profile has already been created by employee");
        require(tx.origin == _employee, "Employees can only update their own statuses");
        _employeeStatus[_employee] = 2;
    }

    // Deposit function, has dependency to Pool contract
    function deposit(address _employee) external employeeAdded(_employee){
        // PoolInterface().deposit(_employee);

    }
}