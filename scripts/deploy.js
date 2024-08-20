// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });

const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so verifyContract here is a factory for instances of our Verify contract.
  */
  // const verifyContract = await ethers.getContractFactory("Verify");

  // deploy the contract
  // const deployedVerifyContract = await verifyContract.deploy();

  const IDS = await hre.ethers.getContractFactory("IDS");

  const deployedVerifyContract = await IDS.deploy(
    ["0x10E0c14163610a27Da33336fb86962361b532070"],
    ["0x10E0c14163610a27Da33336fb86962361b532070"],
    ["0x10E0c14163610a27Da33336fb86962361b532070"]
  );

  await deployedVerifyContract.deployed();

  // print the address of the deployed contract
  console.log("Verify Contract Address:", deployedVerifyContract.address);

  console.log("Sleeping.....");
  // Wait for etherscan to notice that the contract has been deployed
  await sleep(10000);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: deployedVerifyContract.address,
    constructorArguments: [
      ["0x10E0c14163610a27Da33336fb86962361b532070"],
      ["0x10E0c14163610a27Da33336fb86962361b532070"],
      ["0x10E0c14163610a27Da33336fb86962361b532070"],
    ],
  });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
