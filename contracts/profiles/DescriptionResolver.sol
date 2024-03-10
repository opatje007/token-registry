// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.7.4;
import "../ResolverBase.sol";

abstract contract DescriptionResolver is ResolverBase {
    bytes4 constant private DESCRIPTION_INTERFACE_ID = 0x32e7d359;

    event DescriptionChanged(bytes32 indexed node,  string key);

    mapping(bytes32=>string) descriptions;

    function setDescription(bytes32 node, string memory value) external authorisedTokenOwner(node) {
        descriptions[node] = value;
        emit DescriptionChanged(node, value);
    }

    function Description(bytes32 node) external view returns (string memory) {
        return descriptions[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == DESCRIPTION_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}