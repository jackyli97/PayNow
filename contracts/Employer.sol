pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Employer is Ownable{
    string employerName;
    address employerAddress;
    uint32 private _numEmployees;
    mapping(address => uint256) private _salaries;
    // Employee status 0=not added by empployer, 1=added by employer,2=employee has created contract/account
    mapping(address => uint8) private _employeeStatus;


    constructor(string memory _employerName) {
        employerName = _employerName;
        employerAddress = msg.sender;
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

    function getSalary(address _employee) public view returns(uint256) {
        require(_employeeStatus[_employee] != 0, "Employer has not been added by employer");
        require(msg.sender == _employee || msg.sender == employerAddress, "Employees can only request their own salaries");
        return _salaries[_employee];
    }

    function updateSalary(address _employee, uint256 _salary) public onlyOwner {
        require(_employeeStatus[_employee] != 0, "Employer has not been added by employer");
        _salaries[_employee] = _salary;
    }

    function checkEmployeeStatus(address _employee) public view returns(uint8) {
        require(_employeeStatus[_employee] != 0, "Employer has not been added by employer");
        require(msg.sender == _employee || msg.sender == employerAddress, "Employees can only request their own statuses");
        return _employeeStatus[_employee];
    }

    /// @dev This method is called once an employee instansiates an Employee contract w/ their address
    function updateEmployeeStatus(address _employee) external {
        require(_employeeStatus[_employee] != 0, "Employer has not been added by employer");
         require(msg.sender == _employee, "Employees can only request their own statuses");
        _employeeStatus[_employee] = 2;
    }

    // Deposit function, has dependency to Pool contract
}