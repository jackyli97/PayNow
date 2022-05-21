pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


interface Employer {
    function getSalary(address employee) external view returns(uint256);

    function checkEmployeeStatus(address employee) external view returns(uint8);

    function updateEmployeeStatus(address employee) external view;
}

contract Employee is Ownable {
    address employee;
    address employer;
    string name;
    // address employerSmartContractAddress = 0x91c6B8b3B118d42A9a558FF5FdC29447E02f51Ae;

    constructor(string memory _name, address _employer) {
        name = _name;
        employee = msg.sender;
        employer = _employer;
        // Employer(employerSmartContractAddress).updateEmployeeStatus(msg.sender);
    }

    // function getSalary() public view onlyOwner returns (uint256) {
    //     return Employer(employerSmartContractAddress).getSalary(employeeAddress);
    // }

    // function getBalance(address _employee) public view onlyOwner returns (uint256) {
    //     // Returns balance by calling Pool getBalance func
    // }

    // function withdraw(uint256 _amount) public onlyOwner view {
    //     // Call withdraw function in Pool
    // }
}
