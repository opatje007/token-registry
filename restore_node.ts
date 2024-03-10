//import { ethers } from "hardhat";
import { ethers } from "hardhat";
//import TokenManagerArtifact from "./artifacts/contracts/token_registry/ENSTokenManager.sol/ENSTokenManager.json";
import { Contract } from "ethers";
import { ens_normalize } from '@adraffy/ens-normalize'; // or require()
import { labelhash, namehash } from "viem";

const { expect } = require("chai");

const ensRegistryAddress = "0xcBFB30c1F267914816668d53AcBA7bA7c9806D13"
const TokenRegistryAddress = "0xcBFB30c1F267914816668d53AcBA7bA7c9806D13"
const managerAddress = "0xF5d807D4652C974b5b27F6cE83C3a068eE002568"
const node = namehash(ens_normalize('erc20.token-registry.vet'));


function getRandomInt(max:number) {
  return Math.floor(Math.random() * max);
}

//transferDomainOwnership(bytes32 node, address newOwner)
//    function transferDomainOwnership(bytes32 node, address newOwner) public onlyOwner{

const tokenRegistryABI = [ "function transferDomainOwnership(bytes32 node, address newOwner) public" ]; // Simplified ABI for demonstration

//tokenManager.transferDomainOwnership(node, "0x098F2b53460b382850A60Af179C0EF7084533FAa"

async function main() {
    const [owner] = await ethers.getSigners();

    const tokenRegistry= new Contract("0x886864206419F3a2D0754521A3B22f186Fe6dDa1", tokenRegistryABI, owner);
    await tokenRegistry.transferDomainOwnership(node, "0x098F2b53460b382850A60Af179C0EF7084533FAa")  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
