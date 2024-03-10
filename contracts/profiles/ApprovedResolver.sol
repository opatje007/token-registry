// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.7.4;
import "../ResolverBase.sol";

abstract contract ApprovedResolver is ResolverBase {
    bytes4 constant private DESCRIPTION_INTERFACE_ID = 0x2d197815;

    event ApprovedChanged(bytes32 indexed node,  bool isApproved);

    mapping(bytes32=>bool) isApproveds;

    function Approve(bytes32 node) external authorisedAdmin(node) {
        require(isApproveds[node] == false, "Node is already approved");
        isApproveds[node] = true;
        emit ApprovedChanged(node, true);
    }

    
    function UnApprove(bytes32 node) external authorisedAdmin(node) {
        require(isApproveds[node] == true, "Node is not approved");
        isApproveds[node] = false;
        emit ApprovedChanged(node, false);
    }

    function Approved(bytes32 node) external view returns (bool) {
        return isApproveds[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == DESCRIPTION_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}