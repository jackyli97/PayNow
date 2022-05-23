import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import _ from "underscore";
import { getEmployee, getEmployer } from "../lib/deploy.helpers";
import {
    Employee,
    Employee__factory as EmployeeFactory,
    Employer,
    Employer__factory as EmployerFactory
} from "../typechain";

describe("Employee tests", () => {
// Instance of token
  let employeeContract: Employee;
  let employerContract: Employer;
  let employeeFactory: EmployeeFactory
  let employerFactory: EmployerFactory
  let deployer: SignerWithAddress;
  let employerDeployer: SignerWithAddress;
  let account1: SignerWithAddress;
  let account2: SignerWithAddress;


  beforeEach(async () => {
    // Default accounts that are used when local in memory nodes are running
    [deployer, employerDeployer, account1, account2] = await ethers.getSigners();
    employerFactory = await ethers.getContractFactory("Employer");
    employerContract = await employerFactory.connect(employerDeployer).deploy("Test Employer");
    await employerContract.addEmployee(deployer.address, 2000);
    employeeContract = await getEmployee({ contractName: "Employee", deployParams: [
        "Test Employee",
        employerContract.address
    ]});
  });

  describe("deploy", () => {
      it("Should check if deployer is the owner", async () => {
          expect(
              await employeeContract.owner()
          ).to.eq(deployer.address);
      })
  })

  describe("constructor", () => {
       it("Should update employee status if they are indeed part of employer", async () => {
        expect(
            await employerContract.checkEmployeeStatus(deployer.address)
            ).to.eq(2);
        })

        it("Should revert if an employee has not been added by employer", async () => {
            employeeFactory = await ethers.getContractFactory("Employee");
            await expect(
                employeeFactory.connect(account1).deploy("Employee", employerContract.address)
            ).to.be.revertedWith("Employee has not been added by employer");
        })

        it("Should not allow an employee to instantiate multiple contracts", async () => {
            employeeFactory = await ethers.getContractFactory("Employee");
            await expect(
                employeeFactory.connect(deployer).deploy("Employee", employerContract.address)
            ).to.be.revertedWith("Employee profile has already been created by employee");
        })
    })

    describe("get salary", () => {
        it("Should correctly return an employees' salary", async () => {
            expect(
               await employeeContract.getSalary()
            ).to.eq(2000);
        });
     })
});