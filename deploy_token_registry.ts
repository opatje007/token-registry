//import { ethers } from "hardhat";
import { ethers } from "hardhat";


async function main() {
  const ensRegistryAddress = "0xcBFB30c1F267914816668d53AcBA7bA7c9806D13"
  const managerAddress = "0xF5d807D4652C974b5b27F6cE83C3a068eE002568"

  
  const TokenRegistry = await ethers.getContractFactory("TokenRegistryResolver");
  const TokenRegistryDeploy = await TokenRegistry.deploy(ensRegistryAddress, managerAddress);
  const TokenRegistryAddress = await TokenRegistryDeploy.getAddress()
  console.log("TestErc20 deployed to:", TokenRegistryAddress);

  console.log(await TokenRegistryDeploy.getMaster());



}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
