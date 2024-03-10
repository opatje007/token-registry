// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.7.4;
import "../ResolverBase.sol";

abstract contract LogoResolver is ResolverBase {
    bytes4 constant private LOGO_INTERFACE_ID = 0xdb58ea5e;

    event LogoChanged(bytes32 indexed node,  string key);

    mapping(bytes32=>string) logos;

    function setLogo(bytes32 node, string memory value) external authorisedTokenOwner(node) {
        logos[node] = value;
        emit LogoChanged(node, value);
    }

    function logo(bytes32 node) external view returns (string memory) {
        return logos[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == LOGO_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}