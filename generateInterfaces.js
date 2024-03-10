const Web3 = require('web3');
const web3 = new Web3();

// Calculate the selectors for each function
const setLogoSelector = web3.utils.keccak256("setLogo(bytes32,string)").substr(0, 10);
const logoSelector = web3.utils.keccak256("logo(bytes32)").substr(0, 10);

// XOR the selectors to get the interface ID
const logoInterfaceID = web3.utils.toHex(web3.utils.toBN(setLogoSelector).xor(web3.utils.toBN(logoSelector)));

console.log(`setLogoSelector: ${setLogoSelector}`);
console.log(`logoSelector: ${logoSelector}`);
console.log(`Interface ID: ${logoInterfaceID}`);

const setDescriptionSelector = web3.utils.keccak256("setDescription(bytes32,string)").substr(0, 10);
const descriptionSelector = web3.utils.keccak256("Description(bytes32)").substr(0, 10);

const descriptionInterfaceID = web3.utils.toHex(web3.utils.toBN(setDescriptionSelector).xor(web3.utils.toBN(descriptionSelector)));

console.log(`setDescriptionSelector: ${setDescriptionSelector}`);
console.log(`descriptionSelector: ${descriptionSelector}`);
console.log(`Interface ID: ${descriptionInterfaceID}`);

const approveSelector = web3.utils.keccak256("Approve(bytes32)").substr(0, 10);
const unApproveSelector = web3.utils.keccak256("UnApprove(bytes32)").substr(0, 10);
const approvedSelector = web3.utils.keccak256("Approved(bytes32)").substr(0, 10);

// XOR the selectors to get the interface ID
const approveInterfaceID = web3.utils.toHex(
  web3.utils.toBN(approveSelector)
    .xor(web3.utils.toBN(unApproveSelector))
    .xor(web3.utils.toBN(approvedSelector))
);

console.log(`Approve Selector: ${approveSelector}`);
console.log(`UnApprove Selector: ${unApproveSelector}`);
console.log(`Approved Selector: ${approvedSelector}`);
console.log(`Interface ID: ${approveInterfaceID}`);