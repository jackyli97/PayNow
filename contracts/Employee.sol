pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


interface EmployerInterface {
    function getSalary(address employee) external view returns(uint256);

    function checkEmployeeStatus(address employee) external view returns(uint8);

    function updateEmployeeStatus(address employee) external view;
}

contract Employee is Ownable {
    address employee;
    address employer;
    string name;

    constructor(string memory _name, address _employer) {
        name = _name;
        employee = msg.sender;
        employer = _employer;
        // Call update function in Employer contract
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
