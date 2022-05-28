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
    let employee: SignerWithAddress;
    let employer: SignerWithAddress;


    employeeContract = await ethers.getContractAt("Employee", "0x687A17E04A0766448ba68c5C9d8AF9CB5dAee0e3");
    employerContract = await ethers.getContractAt("Employer", "0x57B1Aa378fA61a05a91dDBE5EEC5BF8Ecd7901Bf");


    [employer, employee] = await ethers.getSigners();

    const balance1 = await employerContract.connect(employer.address).getUnlockedBalance(employee.address)

    console.log(`Employee's unlocked balance after depositing and before unlocking: ${balance1}`);

    await employeeContract.connect(employee).unlockBalance(employee.address)

    const balance2 = await employerContract.connect(employer.address).getUnlockedBalance(employee.address)

    console.log(`Employee's unlocked balance after unlocked and before withdrawing: ${balance2}`);

    const amount = ethers.utils.parseUnits("10.0", 6)

    await employeeContract.connect(employee).requestWithdraw(amount);

    const balance3 = await employerContract.connect(employer).getUnlockedBalance(employee.address)

    console.log(`Employee's new unlocked balance after withdrawing: ${balance3}`);
}

deployEmployee()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});