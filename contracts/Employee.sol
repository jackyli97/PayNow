pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface EmployerInterface {
    function getSalary(address _employee) external view returns(uint256);

    function checkEmployeeStatus(address _employee) external view returns(uint8);

    function updateEmployeeStatus(address _employee) external;
}

contract Employee is Ownable {
    address employee;
    address employerContractAddress;
    string name;

    /// @dev Upon contract creation, the update function in Employer contract is called to update the Employee's status to 2 aka profile/contract created
    constructor(string memory _name, address _employerContractAddress) {
        name = _name;
        employee = msg.sender;
        employerContractAddress = _employerContractAddress;
        // Call update function in Employer contract
        EmployerInterface(_employerContractAddress).updateEmployeeStatus(msg.sender);
    }

    function getSalary() public view onlyOwner returns (uint256) {
        return EmployerInterface(employerContractAddress).getSalary(employee);
    }

    // function getBalance(address _employee) public view onlyOwner returns (uint256) {
    //     // Returns balance by calling Pool getBalance func
    // }

    // function withdraw(uint256 _amount) public onlyOwner view {
    //     // Call withdraw function in Pool
    // }
}
