require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

const INFURA_KEY = process.env.INFURA_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
        blockNumber: 17093276
      },
      gas: 2100000
    }
  }
};
