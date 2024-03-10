// SPDX-License-Identifier: UNKNOWN 
pragma solidity ^0.7.4;
abstract contract ResolverBase {
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceID) virtual public pure returns(bool) {
        return interfaceID == INTERFACE_META_ID;
    }

    function isAuthorisedAdmin(bytes32 node) internal virtual view returns(bool);

    modifier authorisedAdmin(bytes32 node) {
        require(isAuthorisedAdmin(node));
        _;
    }
    
    function isAuthorisedTokenOwner(bytes32 node) internal virtual view returns(bool);

    modifier authorisedTokenOwner(bytes32 node) {
        require(isAuthorisedTokenOwner(node));
        _;
    }

    function bytesToAddress(bytes memory b) internal pure returns(address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}