pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./SafeMath.sol";

contract Employer is Ownable{

    using SafeMath64 for uint64;

    struct Balance {
        uint64 unlocked;
        uint64 locked;
    }
    string employerName;
    address employer;
    uint32 private _numEmployees;
    mapping(address => uint64) private _salaries; //Salaries are annual and should be whole numbers only
    // Employee status 0=not added by empployer, 1=added by employer,2=employee has created contract/account
    mapping(address => uint64) private _employeeDailyUnlockAmount;
    mapping(address => uint64) private _employeeModuloUnlockAmount; //If dividing monthly by 30 is not a whole num
    mapping(address => uint8) private _employeeStatus;
    mapping(address => Balance) private _balances;
    bool firstDayOfMonth; // This bool helps us with instances where monthly/30 has a reminader
    // In these cases, if it's first day of the month, we will add the modulo result to the _employeeDailyUnlockAmount

    constructor(string memory _employerName) {
        employerName = _employerName;
        employer = msg.sender;
    }

    modifier employeeAdded(address _employee) {
        require(_employeeStatus[_employee] != 0, "Employee has not been added by employer");
        _;
    }

    function addEmployee(address _toAdd, uint64 _salary) public onlyOwner {
        require(_toAdd != address(0), "Can't add zero address to employees");
        // Since _employeeStatus default value is 0, an employee has not been added to employees yet if their address maps to 0
         require(_employeeStatus[_toAdd] == 0, "Employee has already been added to employees");
         uint64 monthly = _salary / 12;
         // Any amount smaller than this would not allow us to have a daily amount > 1 as Solidity does not support decimals
         require(monthly >= 31, "Salary is too low for application");
        _salaries[_toAdd] = _salary;
        _employeeStatus[_toAdd] = 1;
        _numEmployees += 1;
    }

    function getNumEmployees() public view onlyOwner returns (uint32) {
        return _numEmployees;
    }

    function getSalary(address _employee) public view employeeAdded(_employee) returns(uint64) {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own salaries");
        return _salaries[_employee];
    }

    /// @dev Should only be able to be called yearly 
    function updateSalary(address _employee, uint64 _salary) public onlyOwner employeeAdded(_employee) {
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

    function getLockedBalance(address _employee) public view employeeAdded(_employee) returns (uint64){
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own balance");
        Balance memory employeeBalance = _balances[_employee];
        return employeeBalance.locked;
    }

    function getUnlockedBalance(address _employee) public view employeeAdded(_employee) returns (uint64){
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own balance");
        Balance memory employeeBalance = _balances[_employee];
        return employeeBalance.unlocked;
    }

    function unlockBalance(address _employee) public employeeAdded(_employee) {
        uint64 unlockedAmount = _employeeDailyUnlockAmount[_employee];
        // Assures employee gets paid their full monthly pay
        if (firstDayOfMonth == true) {
            unlockedAmount += _employeeModuloUnlockAmount[_employee];
            firstDayOfMonth == false;
        }
        require(_balances[_employee].locked > 0, "Insufficient balance");
        uint64 newLockedBalance = _balances[_employee].locked.sub(unlockedAmount); //Subtracted amount should not ever be more than the balance, assured b/c we are dividing into equal segments
        _balances[_employee].locked =  newLockedBalance;
        _balances[_employee].unlocked = unlockedAmount;
    }

    function withdraw(address _employee, uint64 _amount) external employeeAdded(_employee) {
         require(tx.origin == _employee, "Only employees can withdraw from their balance");
        _balances[_employee].unlocked = _balances[_employee].unlocked.sub(_amount);
    }

    /// @dev Need to validate in frontend that deposit amount is a whole number, we can do this by
    /// using % operator when dividing salary by months in year, will result in higher 1st month pay
    /// @dev Need to assert in frontend that this is only going to be called once monthly
    /// @dev Need to require in frontend that this amount can't be less than the num of days in month
    function deposit(address _employee, uint64 _amount, uint8 _daysInMonth) public employeeAdded(_employee) onlyOwner {
        _employeeDailyUnlockAmount[_employee] = _amount / _daysInMonth;
        _employeeModuloUnlockAmount[_employee] = _amount %  _daysInMonth;
        firstDayOfMonth = true; //A deposit indicates first day of month
        uint64 oldBalance = _balances[_employee].locked;
        _balances[_employee].locked = oldBalance.add(_amount);
    }
}