import { Test, Test__factory } from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";
import { mineBlocks, convertWithDecimal } from "./utilities/utilities";
import { expect } from "chai";
import { CustomError } from "hardhat/internal/hardhat-network/stack-traces/model";
var BigNumber = require("big-number");

describe("Test", async () => {
  let test: Test;
  let owner: SignerWithAddress;

  beforeEach(async () => {
    [owner] = await ethers.getSigners();

    test = await new Test__factory(owner).deploy();
  });

  it("Owner's balance is updated", async () => {
    // await test.getError();

    await expect(test.getError()).to.revertedWithCustomError(test, "TestError");
  });
});
