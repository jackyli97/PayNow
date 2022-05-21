pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Employer is Ownable{
    string employerName;
    address employerAddress;
    address[] employees;
    mapping(address => uint256) salaries;
    mapping(address => uint8) employeeStatus;


    constructor(string memory _employerName, address _employerAddress) {
        employerName = _employerName;
        employerAddress = _employerAddress;
    }

    function addEmployee(address _toAdd, uint256 _salary) public onlyOwner {
        //Check employee not in array
        //Check employee not alreardy enrolled.
        require(employeeStatus[_toAdd] == 0, "Employee has already been added to employees");
        employees.push(_toAdd);
        salaries[_toAdd] = _salary;
        employeeStatus[_toAdd] = 1;
    }

    function updateSalary(address _employee, uint256 _salary) public onlyOwner {
        salaries[_employee] = _salary;
    }

    function getSalary(address _employee) external view returns(uint256) {
        return salaries[_employee];
    }

    function getEmployees() public view returns (address[] memory){
        return employees;
    }

    function checkEmployeeStatus(address _employee) external view returns(uint8) {
        return employeeStatus[_employee];
    }

    function updateEmployeeStatus(address _employee) external {
        employeeStatus[_employee] = 2;
    }

    // Deposit
}