// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@ensdomains/ens/contracts/ENS.sol";
import "./profiles/ABIResolver.sol";
import "./profiles/AddrResolver.sol";
import "./profiles/ContentHashResolver.sol";
import "./profiles/InterfaceResolver.sol";
import "./profiles/NameResolver.sol";
import "./profiles/PubkeyResolver.sol";
import "./profiles/DescriptionResolver.sol";
import "./profiles/LogoResolver.sol";
import "./profiles/ApprovedResolver.sol";
import "./profiles/TextResolver.sol";
import "./ENSTokenManager.sol";
import "./Prototype.sol";
import "./Ownable.sol";

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract TokenRegistryResolver is Ownable, ApprovedResolver, LogoResolver, DescriptionResolver, ABIResolver, AddrResolver, ContentHashResolver, InterfaceResolver, NameResolver, PubkeyResolver, TextResolver {
    ENS ens;
    ENSTokenManager manager;
    Prototype constant prototype = Prototype(0x000000000000000000000050726f746F74797065);

    mapping(address=>bool) admins;

    /**
     * A mapping of authorisations. An address that is authorised for a name
     * may make any changes to the name that the owner could, but may not update
     * the set of authorisations.
     * (node, owner, caller) => isAuthorised
     */
    mapping(bytes32=>mapping(address=>mapping(address=>bool))) public authorisations;

    event AuthorisationChanged(bytes32 indexed node, address indexed owner, address indexed target, bool isAuthorised);
    event ManagerChanged(address indexed oldManager, address indexed newManager);
    event AddAdmin(address admin);
    event RemoveAdmin(address admin);


    constructor(ENS _ens, ENSTokenManager _manager ) {
        ens = _ens;
        manager = _manager;
    }

    function setManager(ENSTokenManager _manager) external onlyOwner {
        emit ManagerChanged(address(manager), address(_manager));
        manager = _manager;
    }

    function addAdmin(address newAdmin) external onlyOwner{
        require(admins[newAdmin] == false, "Address is already an admin");
        admins[newAdmin] == true;
        emit AddAdmin(newAdmin);
    }
    
    function removeAdmin(address newAdmin) external onlyOwner{
        require(admins[newAdmin] == false, "Address is not an admin");
        admins[newAdmin] == false;
        emit RemoveAdmin(newAdmin);
    }

    function getMaster() public view returns(address) {
        return prototype.master(address(this));
    }

    function getTokenMaster(address token) public view returns(address) {
        return prototype.master(token);
    }

    /**
     * @dev Sets or clears an authorisation.
     * Authorisations are specific to the caller. Any account can set an authorisation
     * for any name, but the authorisation that is checked will be that of the
     * current owner of a name. Thus, transferring a name effectively clears any
     * existing authorisations, and new authorisations can be set in advance of
     * an ownership transfer if desired.
     *
     * @param node The name to change the authorisation on.
     * @param target The address that is to be authorised or deauthorised.
     * @param isAuthorised True if the address should be authorised, or false if it should be deauthorised.
     */
    function setAuthorisation(bytes32 node, address target, bool isAuthorised) external {
        authorisations[node][msg.sender][target] = isAuthorised;
        emit AuthorisationChanged(node, msg.sender, target, isAuthorised);
    }

    function isAuthorisedAdmin(bytes32 node) internal override view returns(bool) {
        address owner = ens.owner(node);
        return owner == msg.sender || admins[msg.sender] == true || address(manager) == msg.sender;
    }

    function isAuthorisedTokenOwner(bytes32 node) internal override view returns(bool) {
        address owner = ens.owner(node);
        return owner == msg.sender || admins[msg.sender] == true || msg.sender == getTokenMaster(addr(node)) || address(manager) == msg.sender;
    }

    function multicall(bytes[] calldata data) external returns(bytes[] memory results) {
        results = new bytes[](data.length);
        for(uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success);
            results[i] = result;
        }
        return results;
    }

    function supportsInterface(bytes4 interfaceID) virtual override(ApprovedResolver, LogoResolver, DescriptionResolver, ABIResolver, AddrResolver, ContentHashResolver, InterfaceResolver, NameResolver, PubkeyResolver, TextResolver) public pure returns(bool) {
        return super.supportsInterface(interfaceID);
    }
}