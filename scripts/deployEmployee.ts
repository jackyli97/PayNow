import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  Employee,
  Employee__factory as EmployeeFactory,
  Employer,
  Employer__factory as EmployerFactory
} from "../typechain";

export async function deployEmployee() {

    let employeeContract: Employee;
    let employerContract: Employer;
    let employeeFactory: EmployeeFactory;
    let employee: SignerWithAddress;

    employerContract = await ethers.getContractAt("Employer", "0x57B1Aa378fA61a05a91dDBE5EEC5BF8Ecd7901Bf");

    [, employee] = await ethers.getSigners()

    employeeFactory = await ethers.getContractFactory("Employee");

    employeeContract = await employeeFactory.connect(employee).deploy("Test Employee 2", employerContract.address);

    

    console.log(`Employee Contract Address: ${employeeContract.address}`);

  return employeeContract;
}

deployEmployee()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});