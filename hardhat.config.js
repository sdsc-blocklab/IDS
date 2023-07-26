require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const GORLI_PRIVATE_KEY = process.env.GORLI_PRIVATE_KEY;

const ETHERSCAN_KEY = process.env.SCAN_KEY;

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/D31u3za0fuMzN5hvaJLHnQq8yEXhBofv",
      accounts: [GORLI_PRIVATE_KEY],
      chainId: 5,
    },
  },
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_KEY,
    },
  },
};