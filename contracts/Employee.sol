pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface EmployerInterface {
    function getSalary(address _employee) external view returns(uint64);

    function checkEmployeeStatus(address _employee) external view returns(uint8);

    function updateEmployeeStatus(address _employee) external;

    function getLockedBalance(address _employee) external view returns(uint64);

    function unlockBalance(address _employee) external;

    function getUnlockedBalance(address _employee) external view returns(uint64);

    function withdraw(address _employee, uint64 _amount) external;
}

contract Employee is Ownable {
    address public employee;
    address public employerContractAddress;
    string public name;

    event EmployeeCreated(address indexed _employeeContract, string _name);

    /// @notice Upon contract creation, the update function in Employer contract is called to update the Employee's status to 2 aka profile/contract created
    constructor(string memory _name, address _employerContractAddress) {
        name = _name;
        employee = msg.sender;
        employerContractAddress = _employerContractAddress;
        EmployerInterface(_employerContractAddress).updateEmployeeStatus(msg.sender); // Call update function in Employer contract
        emit EmployeeCreated(address(this), name);
    }

    function getSalary() public view onlyOwner returns (uint64) {
        return EmployerInterface(employerContractAddress).getSalary(employee);
    }

    function getLockedBalance(address _employee) public view onlyOwner returns (uint64) {
        return EmployerInterface(employerContractAddress).getLockedBalance(_employee);
    }

    function unlockBalance(address _employee) public onlyOwner {
        return EmployerInterface(employerContractAddress).unlockBalance(_employee);
    }

    function getUnlockedBalance(address _employee) public view onlyOwner returns (uint64) {
        return EmployerInterface(employerContractAddress).getUnlockedBalance(_employee);
    }

    function requestWithdraw(uint64 _amount) public onlyOwner {
        return EmployerInterface(employerContractAddress).withdraw(employee, _amount);
    }
}
