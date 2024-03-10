# token-registry-contracts
# token-registry-contracts
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import '@nomiclabs/hardhat-truffle5';
import '@vechain/hardhat-vechain'
import '@vechain/hardhat-ethers'

const LOW_OPTIMIZER_COMPILER_SETTINGS = {
  version: '0.8.20',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 2_000,
    },
    
  },
}

const ERC20_COMPILER_SETTINGS = {
  version: '0.7.4',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 2_000,
    },
    
  },
}

const CORE_OPTIMIZER_COMPILER_SETTINGS = {
  version: '0.7.4',
  settings: {
    optimizer: {
      enabled: true,
      runs: 800,
    },
  },
}
const LOWEST_OPTIMIZER_COMPILER_SETTINGS = {
  version: '0.6.12',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 1_000,
    },
  },
}

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.5.16',
  settings: {
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 1_000_000,
    },
  },
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [LOW_OPTIMIZER_COMPILER_SETTINGS,CORE_OPTIMIZER_COMPILER_SETTINGS,LOWEST_OPTIMIZER_COMPILER_SETTINGS,DEFAULT_COMPILER_SETTINGS],
  
  },
  mocha: {
    timeout: 180000,
  },
  networks: {
    vechain: {
      url: "https://sync-testnet.veblocks.net",
      //accounts:{
      //},
      gas: 25000000,
    },
  },
};

module.exports = {
  solidity: {
    compilers: [LOW_OPTIMIZER_COMPILER_SETTINGS,CORE_OPTIMIZER_COMPILER_SETTINGS,LOWEST_OPTIMIZER_COMPILER_SETTINGS,DEFAULT_COMPILER_SETTINGS],
    
  
  networks: {
    vechain: {
      url: "https://testnet.veblocks.net",
      restful: true,
      gas: 25000000,
      accounts:{
      },
    },
  },
};

