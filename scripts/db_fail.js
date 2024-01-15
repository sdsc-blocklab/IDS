// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require("dotenv").config({ path: ".env" });

const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PW, // Replace with your actual password
    port: process.env.DB_PORT,
    ssl: {
        rejectUnauthorized: false
      }
  });
const ABI = require("../artifacts/contracts/IDS.sol/IDS.json"); // Update with the actual path
const provider = new hre.ethers.providers.JsonRpcProvider();

async function getData() {
try {
    // Connect to the database
    const client = await pool.connect();
    console.log("Connecting...")

    // Execute a query
    const res = await client.query('SELECT * FROM genomics'); // Replace with your actual table name

    // Log query results
    console.log("Results:");
    console.log(res.rows);

    // Release the client back to the pool
    client.release();
} catch (err) {
    console.error(err);
}
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });




async function addDataOwner(dataOwnerAddress, gender, age, dataType) {
    try {
        const tx = await this._ids.addDataOwner(dataOwnerAddress, gender, age, dataType);
        await tx.wait();
        console.log("Data owner added successfully");
    } catch (error) {
        console.error("Failed to add data owner", error);
    }
}

async function requestData(dataOwner, dataUser) {
    try {
        const [dataId, data] = await this._ids.requestData(dataOwner, dataUser);
        console.log(`Data ID: ${dataId}, Data: ${data}`);
        return { dataId, data };
    } catch (error) {
        console.error("Failed to request data", error);
        return null;
    }
}

async function checkApprovedQueryer(dataUserAddress) {
    try {
        const isApproved = await this._ids.checkApprovedQueryer(dataUserAddress);
        console.log(`Is Approved: ${isApproved}`);
        return isApproved;
    } catch (error) {
        console.error("Failed to check if user is an approved queryer", error);
        return false;
    }
}




// async function main() {
//   /*
//   A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
//   so verifyContract here is a factory for instances of our Verify contract.
//   */
//   // const verifyContract = await ethers.getContractFactory("Verify");

//   // deploy the contract
//   // const deployedVerifyContract = await verifyContract.deploy();

//   const IDS = await hre.ethers.getContractFactory("IDS");
//   const deployedVerifyContract = await IDS.deploy(["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"], ["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"], ["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"]);


//   await deployedVerifyContract.deployed();

//   // print the address of the deployed contract
//   console.log("Verify Contract Address:", deployedVerifyContract.address);

//   console.log("Sleeping.....");
//   // Wait for etherscan to notice that the contract has been deployed
//   await sleep(10000);

//   // Verify the contract after deploying
//   await hre.run("verify:verify", {
//     address: deployedVerifyContract.address,
//     constructorArguments: [["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"], ["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"], ["0xf80b3371535e8fe99d4940d6a5a529c1b168acc3"]],
//   });
// }


async function main() {
    console.log("Starting")
    const IDS = await hre.ethers.getContractFactory("IDS");
    const ids = await hre.ethers.getContractAt("IDS", "0xFd2536a54eb26e8399eBE9CF1F37A646649483CA");
    const signer = await hre.ethers.getSigner("0x10E0c14163610a27Da33336fb86962361b532070"); // Use a signer from Hardhat's local accounts
    const connectedContract = ids.connect(signer);

    const addressToCheck = "0x03014a937863f3d55E33817a7997760BB76aCe80";
    const isDataUser = await connectedContract.isDataUser(addressToCheck);
    console.log("Is data user:", isDataUser);
    
    if (isDataUser) {
    try {
        // Connect to the database
        const client = await pool.connect();
        console.log("Connecting...")
    
        // Execute a query
        const res = await client.query('SELECT * FROM genomics'); // Replace with your actual table name
    
        // Log query results
        console.log("Results:");
        console.log(res.rows);
    
        // Release the client back to the pool
        client.release();
    } catch (err) {
        console.error(err);
    }
}
else {
    console.log("Address does not have access");
}
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


