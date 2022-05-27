pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
    mapping(address => uint8) private _employeeStatus;
    mapping(address => Balance) private _balances;

    address public usdc;

    event EmployerCreated(address indexed _employerContract);

    constructor(string memory _employerName, address _usdc) {
        employerName = _employerName;
        employer = msg.sender;
        usdc = _usdc;
        emit EmployerCreated(address(this));
    }

    modifier employeeAdded(address _employee) {
        require(_employeeStatus[_employee] != 0, "Employee has not been added by employer");
        _;
    }

    function addEmployee(address _toAdd, uint64 _salary) public onlyOwner {
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

    function getSalary(address _employee) public view employeeAdded(_employee) returns(uint64) {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own salaries");
        return _salaries[_employee];
    }

    /// @notice Should only be able to be called yearly 
    function updateSalary(address _employee, uint64 _salary) public onlyOwner employeeAdded(_employee) {
        _salaries[_employee] = _salary;
    }

    function checkEmployeeStatus(address _employee) public view employeeAdded(_employee) returns(uint8) {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own statuses");
        return _employeeStatus[_employee];
    }

    /// @notice This method is called once an employee instansiates an Employee contract w/ their address
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
        require(_balances[_employee].locked > 0, "Insufficient balance");
        uint64 newLockedBalance = _balances[_employee].locked.sub(unlockedAmount); //Subtracted amount should not ever be more than the balance, assured b/c we are dividing into equal segments
        _balances[_employee].locked =  newLockedBalance;
        _balances[_employee].unlocked = unlockedAmount;
    }

    function withdraw(address _employee, uint64 _amount) external employeeAdded(_employee) {
         require(tx.origin == _employee, "Only employees can withdraw from their balance");
          IERC20(usdc).transferFrom(employer, _employee, _amount);
        _balances[_employee].unlocked = _balances[_employee].unlocked.sub(_amount);
    }

    /**
    * @notice Need to assert in frontend that this is only going to be called once monthly
        and need to require in frontend that this amount can't be less than the num of days in month
    **/
    function deposit(address _employee, uint64 _amount, uint8 _daysInMonth) public employeeAdded(_employee) onlyOwner {
        IERC20(usdc).approve(employer, _amount);
        _employeeDailyUnlockAmount[_employee] = _amount / _daysInMonth;
        uint64 oldBalance = _balances[_employee].locked;
        _balances[_employee].locked = oldBalance.add(_amount);
    }
}