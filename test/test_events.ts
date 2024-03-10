//import { ethers } from "hardhat";
import { ethers } from "hardhat";
//import TokenManagerArtifact from "./artifacts/contracts/token_registry/ENSTokenManager.sol/ENSTokenManager.json";
import ENSArtificat from "../artifacts/@ensdomains/ens/contracts/ENS.sol/ENS.json";
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


describe("TokenManager", function () {
  let tokenManager:any;
  let tokenRegistery:any;
  let ENSRegistry:any;
  let testErc20:any;
  let owner;
  let EnsRegistry;

  const node = namehash(ens_normalize('erc20.token-registry.vet'));  

  before(async function () {
    this.timeout(20000000)
    
    // Deploy the TokenManager contract before running tests
    let randomNumber:number = getRandomInt(100000);
    [owner] = await ethers.getSigners();
    const TestErc20 = await ethers.getContractFactory("TestShtERC20");
    console.log("deploying: ", "shtcoin" + randomNumber )
    testErc20 = await TestErc20.deploy("shtcoin" + randomNumber, "sht" + randomNumber);
    ENSRegistry = new Contract(ensRegistryAddress, ENSArtificat.abi, owner);

    const TokenManager = await ethers.getContractFactory("ENSTokenManager");
    const TokenRegistry = await ethers.getContractFactory("TokenRegistryResolver");

    console.log("deploying: ", "TokenManager" )
    tokenManager = await TokenManager.deploy(ensRegistryAddress, node);

    console.log("deploying: ", "tokenRegistery" )
    tokenRegistery = await TokenRegistry.deploy(ensRegistryAddress, await tokenManager.getAddress());
    await tokenManager.setResolver(await tokenRegistery.getAddress())


    
    //Deployed contracts
    console.log("exists ", await tokenManager.nodeExists("0xDC3Aa001FFa24764a2b7481824dD966A29b773Ff"))
    console.log("TokenManager ", await tokenManager.getAddress())
    console.log("TokenRegistry ", await tokenRegistery.getAddress())
    console.log("testErc20 shtcoin_" + randomNumber, await testErc20.getAddress())
    
    
    await ENSRegistry.setOwner(node, await tokenManager.getAddress())

  });

  after(async function () {
    await expect(tokenManager.transferDomainOwnership(node, "0x098F2b53460b382850A60Af179C0EF7084533FAa"))
    .to.emit(tokenManager, "TransferDomainOwnership") // Expect a TokenCreated event
    .withArgs(node, "0x098F2b53460b382850A60Af179C0EF7084533FAa");
    
    // Cleanup code after all tests have run
    // For example, tearing down deployed contracts or clearing test databases
  });

  it("Check some default values", async function () {
    console.log("Check some default values")
    this.timeout(20000000)

    let resolverAddr = await  tokenManager.getResolver()
    let rootNodeBytes = await tokenManager.getRootNode()
    let registryAddr = await tokenManager.getVnsRegistry()
    let tokenRegistryAddress = await tokenRegistery.getAddress();
    

    expect(resolverAddr).to.equal(await tokenRegistryAddress, 'Resolver address does not match expected value');
    expect(rootNodeBytes).to.equal(node, 'Root node value does not match expected value');
    expect(registryAddr).to.equal(TokenRegistryAddress, 'Registry address does not match expected value');

    await expect(tokenManager.setResolver("0x0000000000000000000000000000000000000000"))
      .to.emit(tokenManager, "ChangeDefaultResolver") // Expect a TokenCreated event
      .withArgs("0x0000000000000000000000000000000000000000"); // Use anyValue for the token address since it's unknown, and check the tokenSymbol


   await expect(tokenManager.setResolver(tokenRegistryAddress))
      .to.emit(tokenManager, "ChangeDefaultResolver") // Expect a TokenCreated event
      .withArgs(tokenRegistryAddress); // Use anyValue for the token address since it's unknown, and check the tokenSymbol

   });

  

  it("Add new token to the tokenManager", async function () {
    console.log("Add new token to the tokenManager")

    this.timeout(20000000)

    let shtCnAddr = await testErc20.getAddress()
    let name = await testErc20.name();
    let symbol = await testErc20.symbol();

    //renderSpecs(address erc20Token) public view  returns (string memory symbolLowerCase, bytes32 symbolLabel,
    //bytes32 subRoot,bytes32 subRoot2,  bytes32 subLabel, bytes32 addressLabel, string memory addressLower)

    console.log(await tokenManager.renderSpecs(shtCnAddr))
    console.log(await tokenManager.nodeExists(shtCnAddr))

    const domain = ens_normalize(shtCnAddr.toLowerCase() + '.erc20.token-registry.vet')
    const rootDomain = namehash('erc20.token-registry.vet')
    console.log("domain: ", domain)
    const newNode = namehash(domain);  
    console.log("newNode: ", newNode)


    //   emit AddToken(subRoot2, address(erc20Token), name, symbol, addressLower);
    //     event AddrChanged(bytes32 indexed node, address a);
    const subdomain = '0x'+require('js-sha3').keccak_256(shtCnAddr.toLowerCase())
    console.log(rootDomain, subdomain)

    const tokenManageraddress = await tokenManager.getAddress();

      
    await expect(tokenManager.removeToken(shtCnAddr))
    .to.be.revertedWith("This token does not exist!");

    await expect(tokenManager.addTokenSubdomain(shtCnAddr))
    .to.emit(tokenManager, "AddToken") 
    .withArgs(newNode,shtCnAddr,name, symbol, shtCnAddr.toLowerCase())
    .to.emit(tokenRegistery, "AddrChanged") 
    .withArgs(newNode,shtCnAddr)
    .to.emit(tokenRegistery, "NameChanged")
    .withArgs(newNode, shtCnAddr.toLowerCase())
    .to.emit(ENSRegistry, "NewOwner")
    .withArgs(rootDomain, subdomain, tokenManageraddress);

  //Expect the sametoken to fail
  await expect(tokenManager.addTokenSubdomain(shtCnAddr))
      .to.be.revertedWith("This record already exist!");

// /        emit RemoveToken(subRoot, address(erc20Token));

    await expect(tokenManager.removeToken(shtCnAddr))
    .to.emit(tokenManager, "RemoveToken") 
    .withArgs(newNode,shtCnAddr)

    
  await expect(tokenManager.removeToken(shtCnAddr))
  .to.be.revertedWith("This token does not exist!");
  
  await expect(tokenManager.addTokenSubdomain(shtCnAddr))
  .to.emit(tokenManager, "AddToken") 
  .withArgs(newNode,shtCnAddr,name, symbol, shtCnAddr.toLowerCase())
  .to.emit(tokenRegistery, "AddrChanged") 
  .withArgs(newNode,shtCnAddr)
  .to.emit(tokenRegistery, "NameChanged")
  .withArgs(newNode, shtCnAddr.toLowerCase())
  .to.emit(ENSRegistry, "NewOwner")
  .withArgs(rootDomain, subdomain, tokenManageraddress);

  });  
});

