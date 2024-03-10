//import { ethers } from "hardhat";
import { ethers } from "hardhat";
import { utils } from "@vechain/web3-providers-connex";
import { getAvailable, getOwner, getExpiry, _getAddr, getRecords, getResolver  } from "@ensdomains/ensjs/public"
import ENSRegistry from "./typechain-types/contracts/token_registry/abi/registry.json";
import {ens_normalize} from '@adraffy/ens-normalize'; // or require()
import { exit } from "process";
import { Contract, keccak256, toUtf8Bytes,AbiCoder } from "ethers";
import { labelhash,namehash } from "viem";


const delay = (ms:any) => new Promise(res => setTimeout(res, ms));

async function main() {

  const [owner] = await ethers.getSigners();
  const ensRegistryAddress = "0xcBFB30c1F267914816668d53AcBA7bA7c9806D13"

  const node = namehash(ens_normalize('erc20.token-registry.vet'));  
  const subdomain = '0x' + require('js-sha3').keccak_256('test9')

  //await hashFunctionCall("0x4adC60A6eB584efdC499D2630ADa895d78148b71", "createSubdomain", [labelhash, "0x098F2b53460b382850A60Af179C0EF7084533FAa", "0xA6eFd130085a127D090ACb0b100294aD1079EA6f",0 ]);
  //exit()
  // Convert domain names to namehash (bytes32)
  
  const ENSTokenManager = await ethers.getContractFactory("ENSTokenManager");
  const ENSTokenManagerDeploy = await ENSTokenManager.deploy(ensRegistryAddress, node);
  const ENSTokenManagerAddress = await ENSTokenManagerDeploy.getAddress()
  console.log("TokenRegistry deployed to:", ENSTokenManagerAddress);
  


}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
