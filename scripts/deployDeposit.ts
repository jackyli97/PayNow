import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  Employee,
  Employee__factory as EmployeeFactory,
  Employer,
  Employer__factory as EmployerFactory
} from "../typechain";

export async function deployEmployee() {

    let employerContract: Employer;
    let employee: SignerWithAddress;
    let employer: SignerWithAddress;

    employerContract = await ethers.getContractAt("Employer", "0x57B1Aa378fA61a05a91dDBE5EEC5BF8Ecd7901Bf");

    [employer, employee] = await ethers.getSigners()

    const oldBalance = await employerContract.connect(employer.address).getLockedBalance(employee.address)

    console.log(`Employee's old locked balance: ${oldBalance}`);

    const amount = ethers.utils.parseUnits("100.0", 6)

    await employerContract.connect(employer.address).deposit(employee.address, amount);

    const newBalance = await employerContract.connect(employer).getLockedBalance(employee.address)

    console.log(`Employee's new locked balance: ${newBalance}`);
}

deployEmployee()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});