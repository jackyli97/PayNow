import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import _ from "underscore";
import { getEmployee } from "../lib/deploy.helpers";
import { Employee } from "../typechain";

describe("Employee tests", () => {
// Instance of token
  let employeeContract: Employee;
  let deployer: SignerWithAddress;
  let account1: SignerWithAddress;
  /**
   * @dev As you may already know, Solidity doesn't support floating point numbers.
   * An Ether amount can have up to 18 decimals and ERC20 too (by default).
   * 10^18 wei = 1 Ether.
   * 10^18 "Camp Token wei" = 1 Camp Token.
   */
  const oneCampInWei = ethers.utils.parseEther("1");

  beforeEach(async () => {
    // Default accounts that are used when local in memory nodes are running
    [deployer, account1] = await ethers.getSigners();
    employeeContract = await getEmployee({ contractName: "Employee", deployParams: [
        "Test",
        `${account1.address}`,
    ]});
  });

  describe("deploy", () => {
      it("Should check if deployer is the owner", async () => {
          expect(
              await employeeContract.owner()
          ).to.eq(deployer.address);
      })
  })
});