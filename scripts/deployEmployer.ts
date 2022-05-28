import { getEmployee, getEmployer } from "../lib/deploy.helpers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  Employee,
  Employee__factory as EmployeeFactory,
  Employer,
  Employer__factory as EmployerFactory
} from "../typechain";

export async function deployEmployee() {
    const fakeUSDC = "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b"

    let employerContract: Employer;
    let employerFactory: EmployerFactory
    let employer: SignerWithAddress;
    let employee: SignerWithAddress;

    [employer, employee] = await ethers.getSigners()

    employerFactory = await ethers.getContractFactory("Employer");

    employerContract = await employerFactory.connect(employer).deploy("Test Employer 2", fakeUSDC);

    const salary = ethers.utils.parseUnits("1200.0", 6)

    await employerContract.addEmployee(employee.address, salary);

    console.log(`Employer Contract Address: ${employerContract.address}`);

  return employerContract;
}

deployEmployee()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});