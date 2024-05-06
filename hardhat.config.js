const { HardhatUserConfig } = require("hardhat/config");
require("@nomicfoundation/hardhat-toolbox");
require("@truffle/dashboard-hardhat-plugin");


// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

/** @type import('hardhat/config').HardhatUserConfig */

const config = {
  mocha: {
    timeout: 10000000000
  },
  solidity: "0.8.17",
  networks: {
    truffle: {
      url: "http://localhost:24012/rpc",
      allowUnlimitedContractSize:true,
    }
  }
}

module.exports = config;