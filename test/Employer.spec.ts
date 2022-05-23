import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import _ from "underscore";
import { getEmployer } from "../lib/deploy.helpers";
import { Employer } from "../typechain";

describe("Employer tests", () => {
    // Instance of token
    let employerContract: Employer;
    let deployer: SignerWithAddress;
    let account1: SignerWithAddress;
    let account2: SignerWithAddress;
    /**
     * @dev As you may already know, Solidity doesn't support floating point numbers.
     * An Ether amount can have up to 18 decimals and ERC20 too (by default).
     * 10^18 wei = 1 Ether.
     * 10^18 "Camp Token wei" = 1 Camp Token.
     */
    const oneCampInWei = ethers.utils.parseEther("1");

    beforeEach(async () => {
        // Default accounts that are used when local in memory nodes are running
        [deployer, account1, account2] = await ethers.getSigners();
        employerContract = await getEmployer({ contractName: "Employer", deployParams: [
            "Test Employer",
        ]});
    });

    describe("deploy", () => {
        it("Should check if deployer is the owner", async () => {
            expect(
                await employerContract.owner()
            ).to.eq(deployer.address);
        });
    });

    describe("add employee", () => {
        it("Should successfully add an employee to an employer's employees", async () => {
            employerContract.addEmployee(account1.address, 2000);
            expect(
                await employerContract.getNumEmployees()
            ).to.eq(1);
            expect(
                await employerContract.checkEmployeeStatus(account1.address)
            ).to.eq(1);
        });

        it("Should revert if employee has already been added", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.addEmployee(account1.address, 5000)
            ).to.be.revertedWith("Employee has already been added to employees");
        });

        it("Should be able to add mulitple unique employees", async () => {
            employerContract.addEmployee(account1.address, 2000);
            employerContract.addEmployee(account2.address, 5000);
            expect(
                await employerContract.getNumEmployees()
            ).to.eq(2);
        });
        it("Doesn't allow a zero address to be added", async () => {
            await expect(
                employerContract.addEmployee("0x0000000000000000000000000000000000000000", 2000)
            ).to.be.revertedWith("Can't add zero address to employees");
        });

        it("Should revert if caller is not the owner", async () => {
            await expect(
                employerContract.connect(account1).addEmployee(account1.address, 2000)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("get number employees", () => {
        it("Should revert if caller is not the owner", async () => {
            await expect(
                employerContract.connect(account1).getNumEmployees()
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("get salary", () => {
        it("Should correctly return an employees' salary when requested by the employee", async () => {
            employerContract.addEmployee(account1.address, 2000);
            expect(
               await employerContract.connect(account1).getSalary(account1.address)
            ).to.eq(2000);
        });

        it("Should revert if employee has not been added", async () => {
            await expect(
                employerContract.connect(account1).getSalary(account1.address)
            ).to.be.revertedWith("Employee has not been added by employer");
        });

        it("Should revert if caller is not the requested employee", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.connect(account2).getSalary(account1.address)
            ).to.be.revertedWith("Employees can only request their own salaries");
        });

        it("Should allow employers to view an employee's salary", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.getSalary(account1.address)
            ).to.not.be.reverted;
        });
    });

    describe("update salary", () => {
        it("Should update an employees' salary", async () => {
            employerContract.addEmployee(account1.address, 2000);
            employerContract.updateSalary(account1.address, 3000);
            expect(
                await employerContract.getSalary(account1.address)
            ).to.eq(3000);
        });

        it("Should revert if employee has not been added", async () => {
            await expect(
                employerContract.updateSalary(account1.address, 3000)
            ).to.be.revertedWith("Employee has not been added by employer");
        });

        it("Should revert if caller is not the employer", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.connect(account1).updateSalary(account1.address, 10000)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });


    describe("check employee status", () => {
        it("Should correctly return an employees' status when requested by the employee", async () => {
            employerContract.addEmployee(account1.address, 2000);
            expect(
                await employerContract.connect(account1).checkEmployeeStatus(account1.address)
            ).to.eq(1);
        });

        it("Should revert if employee has not been added", async () => {
            await expect(
                employerContract.checkEmployeeStatus(account1.address)
            ).to.be.revertedWith("Employee has not been added by employer");
        });

        it("Should revert if caller is not the requested employee", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.connect(account2).checkEmployeeStatus(account1.address)
            ).to.be.revertedWith("Employees can only request their own statuses");
        });

        it("Should allow employers to view an employee's status", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.checkEmployeeStatus(account1.address)
            ).to.not.be.reverted;
        });
    });

    describe("update employee status", () => {
        it("Should revert if employee has not been added", async () => {
            await expect(
                employerContract.connect(account1).updateEmployeeStatus(account1.address)
            ).to.be.revertedWith("Employee has not been added by employer");
        });

        it("Should update an employees' status", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await employerContract.connect(account1).updateEmployeeStatus(account1.address);
            expect(
                await employerContract.checkEmployeeStatus(account1.address)
            ).to.eq(2);
        });

        it("Should revert if caller is not the requested employee", async () => {
            employerContract.addEmployee(account1.address, 2000);
            await expect(
                employerContract.updateEmployeeStatus(account1.address)
            ).to.be.revertedWith("Employees can only update their own statuses");
            await expect(
                employerContract.connect(account2).updateEmployeeStatus(account1.address)
            ).to.be.revertedWith("Employees can only update their own statuses");
        });
    });

});