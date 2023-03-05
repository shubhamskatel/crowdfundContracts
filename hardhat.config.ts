import "@nomicfoundation/hardhat-toolbox";
import { task } from "hardhat/config";
import dotenv from "dotenv";

dotenv.config();
task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

export default {
  networks: {
    testnet: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545",
      chainId: 97,
      accounts: [process.env.PRIVATE_KEY],
    },
    hardhat: {
      accounts: {
        mnemonic: process.env.MNEMONIC,
        count: 1500,
      },
      chainId: 1337,
      allowUnlimitedContractSize: true,
    },
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_FOR_BSC,
  },

  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },

  gasReporter: {
    enabled: false,
  },

  mocha: {
    timeout: 2000000,
  },
};
