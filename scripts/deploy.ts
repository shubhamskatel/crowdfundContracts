import {
  Token,
  Token__factory,
  Crowdfunding,
  Crowdfunding__factory,
  OwnedUpgradeabilityProxy,
  OwnedUpgradeabilityProxy__factory,
} from "../typechain";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
const hre = require("hardhat");

let token: Token;
let crowdfund: Crowdfunding;
let proxy: OwnedUpgradeabilityProxy;
let owner: SignerWithAddress;

async function main() {
  // ================ DEPLOYMENT ================ //

  console.log("Deployment Started..");

  [owner] = await ethers.getSigners();

  token = await new Token__factory(owner).deploy("Test Token", "TST", 8);
  await token.deployed();
  console.log("Token Deployed");

  crowdfund = await new Crowdfunding__factory(owner).deploy();
  await crowdfund.deployed();
  console.log("Crowdfund Deployed");

  proxy = await new OwnedUpgradeabilityProxy__factory(owner).deploy();
  proxy.deployed();
  console.log("Proxy Deployed\n \n");

  let initializeDataCron = await crowdfund.interface.encodeFunctionData(
    "initialize",
    [owner.address, token.address]
  );

  await proxy.upgradeToAndCall(crowdfund.address, initializeDataCron);

  // ================ Verification ================ //

  await hre.run("verify:verify", {
    //Deployed contract address
    address: token.address,

    //Pass arguments as string and comma seprated values
    constructorArguments: ["Test Token", "TST", 8],

    //Path of your main contract.
    contract: "contracts/ERC20.sol:Token",
  });
  console.log("Token Verified");

  await hre.run("verify:verify", {
    //Deployed contract address
    address: crowdfund.address,

    //Pass arguments as string and comma seprated values
    constructorArguments: [],

    //Path of your main contract.
    contract: "contracts/Crowdfunding.sol:Crowdfunding",
  });
  console.log("Crowdfund Deployed");

  await hre.run("verify:verify", {
    //Deployed contract address
    address: proxy.address,

    //Pass arguments as string and comma seprated values
    constructorArguments: [],

    //Path of your main contract.
    contract: "contracts/OwnedUpgradeabilityProxy.sol:OwnedUpgradeabilityProxy",
  });
  console.log("Proxy Deployed\n \n");

  console.log(`Sample Token Contract: ${token.address}`);
  console.log(`Crowdfund Contract: ${crowdfund.address}`);
  console.log(`Proxy/final Contract: ${proxy.address}`);
}

main()
  .then(async () => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
//npx hardhat run --network testnet scripts/deploy.ts
