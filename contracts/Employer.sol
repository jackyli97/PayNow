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
        uint64 dailyUnlockAmount;
        uint256 depositTime;
        uint256 lastUnlock;
    }

    string public employerName;
    address public employer;
    uint32 private _numEmployees;
    mapping(address => uint64) private _salaries; //Salaries are annual and should be whole numbers only
    // Employee status 0=not added by empployer, 1=added by employer,2=employee has created contract/account
    mapping(address => uint64) private _employeeDailyUnlockAmount;
    mapping(address => uint8) private _employeeStatus;
    mapping(address => Balance) private _balances;



    address public usdc;

    event EmployerCreated(address indexed _employerContract, string indexed _employerName);

    constructor(string memory _employerName, address _usdc) {
        employerName = _employerName;
        employer = msg.sender;
        usdc = _usdc;
        emit EmployerCreated(address(this), employerName);
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
        return _balances[_employee].locked;
    }


    
    function getUnlockedBalance(address _employee) public view employeeAdded(_employee) returns (uint64){
        require(tx.origin == _employee || msg.sender == employer, "Employees can only request their own balance");
        return _balances[_employee].unlocked;
    }

    /**
        * @dev First if logic checks if any amount has been unlocked yet, if not we take days since deposit days as amount to unlock
        * Other wise we calculate how much to unlock by taking difference between now and last unlock
        *
        * We also if more than 28 days has passed between any action(unlock or deposit), as in that case all funds should be unlocked
    **/
    function unlockBalance(address _employee) employeeAdded(_employee) external {
        require(tx.origin == _employee || msg.sender == employer, "Employees can only unlock their own balance");
        uint256 currentTime = block.timestamp;
         uint256 lastUnlock =  _balances[_employee].lastUnlock;
         uint256 daysPassed;
         if (lastUnlock == 0) {
             daysPassed = (currentTime -  _balances[_employee].depositTime) / 60 / 60 / 24;
         }
         else {
             daysPassed = (currentTime - lastUnlock) / 60 / 60 / 24;
         }

        /// @dev Need to remove this line before mainnet deploys, for dev purposes
         daysPassed = 28;

         if (daysPassed >= 28) {
               _balances[_employee].unlocked += _balances[_employee].locked;
               _balances[_employee].locked = 0;
         }
         else {
             uint64 unlockAmount =  _balances[_employee].dailyUnlockAmount * uint64(daysPassed);
            _balances[_employee].unlocked += unlockAmount;
            _balances[_employee].locked -= unlockAmount;
         }

         _balances[_employee].lastUnlock = currentTime;
    }

    function withdraw(address _employee, uint64 _amount) external employeeAdded(_employee) {
         require(tx.origin == _employee, "Only employees can withdraw from their balance");
          IERC20(usdc).transferFrom(employer, _employee, uint256(_amount));
        _balances[_employee].unlocked = _balances[_employee].unlocked.sub(_amount);
    }

    /**
        * @dev Employers should only be able to deposit once a month, this can be assured by if 
        * one month has passed since last deposit date
        *
        *We also can use weeks passed, to see if there is any remaining locked balance left in an employee's balance, if so, then unlock
    **/
    function deposit(address _employee, uint64 _amount) public employeeAdded(_employee) onlyOwner {
         uint256 currentTime = block.timestamp;
        IERC20(usdc).approve(_employee, uint256(_amount));

        if (_balances[_employee].locked > 0) {
            uint256 weeksPassed = ((currentTime - _balances[_employee].depositTime) / 60 / 60 / 24 / 7);
            require(weeksPassed >= 4 weeks, "Can only deposit once a month");
            _balances[_employee].unlocked += _balances[_employee].locked;
            _balances[_employee].locked = 0;
        }
        _balances[_employee].dailyUnlockAmount = _amount / 28;
        _balances[_employee].locked = (_amount);
        _balances[_employee].depositTime = currentTime;
    }
}