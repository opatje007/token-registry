// SPDX-License-Identifier: MIT 
pragma solidity >=0.7.4;
pragma experimental ABIEncoderV2;

import "./Ownable.sol"; 

interface IExtendedERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns(uint8);
    function symbol() external view returns(string memory);
    function name() external view returns(string memory);
}

interface TokenResolver{
    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);
    /* Deprecated events */
    event ContentChanged(bytes32 indexed node, bytes32 hash);

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function addr(bytes32 node) external view returns (address);
    function addr(bytes32 node, uint coinType) external view returns(bytes memory);
    function contenthash(bytes32 node) external view returns (bytes memory);
    function dnsrr(bytes32 node) external view returns (bytes memory);
    function name(bytes32 node) external view returns (string memory);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns (string memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);
    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external;
    function setAddr(bytes32 node, address addr) external;
    function setAddr(bytes32 node, uint coinType, bytes calldata a) external;
    function setContenthash(bytes32 node, bytes calldata hash) external;
    function setDnsrr(bytes32 node, bytes calldata data) external;
    function setName(bytes32 node, string calldata _name) external;
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external;
    function setText(bytes32 node, string calldata key, string calldata value) external;
    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external;
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
    function multicall(bytes[] calldata data) external returns(bytes[] memory results);

    /* Deprecated functions */
    function content(bytes32 node) external view returns (bytes32);
    function multihash(bytes32 node) external view returns (bytes memory);
    function setContent(bytes32 node, bytes32 hash) external;
    function setMultihash(bytes32 node, bytes calldata hash) external;
}

interface ENSRegistry {
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function owner(bytes32 node) external view returns (address);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function recordExists(bytes32 node) external view returns (bool);

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

}

interface ENSRegistryWithResolver {
    function setResolver(bytes32 node, address resolver) external;
}

contract ENSTokenManager is Ownable{
    ENSRegistry vnsRegistry;
    bytes32 rootNode; // The node of your domain
    address []tokens;
    address resolver;

    mapping(address => bool) tokensExist;
    event SetResolver(address indexed resolver);
    event TransferDomainOwnership(bytes32 indexed node, address indexed owner);
    event RemoveToken(bytes32 indexed node, address indexed addressToken);
    event AddToken(bytes32 indexed node, address indexed addressToken, string indexed name, string symbol, string addressName);
    event ChangeDefaultResolver(address indexed addressToken);
    event ChangeRegistry(ENSRegistry indexed registry);
    event ChangeRootnode(bytes32 indexed rootNode);

    constructor(ENSRegistry _vnsRegistry, bytes32 _rootNode) {
        vnsRegistry = _vnsRegistry;
        rootNode = _rootNode;
        emit ChangeRootnode(_rootNode);
        emit ChangeRegistry(_vnsRegistry);


    }

    function setResolver(address _resolver) external onlyOwner{
        resolver = _resolver;
        emit ChangeDefaultResolver(_resolver);
    }

    function setRootNode(bytes32 _rootNode) external onlyOwner{
        rootNode = _rootNode;
        emit ChangeRootnode(_rootNode);
    }

    function setVnsRegistry(ENSRegistry _registry) external onlyOwner{
        vnsRegistry = _registry;
        emit ChangeRegistry(_registry);
    }


    function getResolver() external view returns(address){
        return resolver;
    }

    function getRootNode() external view returns(bytes32){
        return rootNode;
    }

    function getVnsRegistry() external view returns(ENSRegistry){
        return vnsRegistry;
    }


    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    
    function checkERC20Metadata(address _token) internal view returns (bool) {
        if (!isContract(_token)) {
            return false;
        }

        return checkTotalSupply(_token) && checkBalanceOf(_token) && checkAllowance(_token) &&
               checkDecimals(_token) && checkSymbol(_token) && checkName(_token);
    }

    function checkTotalSupply(address _token) private view returns (bool) {
        try IExtendedERC20(_token).totalSupply() returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }

    function checkBalanceOf(address _token) private view returns (bool) {
        try IExtendedERC20(_token).balanceOf(address(this)) returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }

    function checkAllowance(address _token) private view returns (bool) {
        try IExtendedERC20(_token).allowance(address(this), address(this)) returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }

    function checkDecimals(address _token) private view returns (bool) {
        try IExtendedERC20(_token).decimals() returns (uint8) {
            return true;
        } catch {
            return false;
        }
    }

    function checkSymbol(address _token) private view returns (bool) {
        try IExtendedERC20(_token).symbol() returns (string memory) {
            return true;
        } catch {
            return false;
        }
    }

    function checkName(address _token) private view returns (bool) {
        try IExtendedERC20(_token).name() returns (string memory) {
            return true;
        } catch {
            return false;
        }
    }
    

    function getOwner() public view returns(address) {
        return vnsRegistry.owner(rootNode);
    }

    function transferDomainOwnership(bytes32 node, address newOwner) public onlyOwner{
        vnsRegistry.setOwner(node, newOwner);
        emit TransferDomainOwnership(node, newOwner);

    }

    function toHexString(address addr) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory data = abi.encodePacked(addr);
        bytes memory str = new bytes(data.length * 2);
        
        for (uint i = 0; i < data.length; i++) {
            str[i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1+i*2] = alphabet[uint(uint8(data[i] & 0x0F))];
        }
        return string(str);
    }

    function toLowerCase(string memory str) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function computeSubnode(bytes32 parentNode, string memory label) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(parentNode, keccak256(abi.encodePacked(label))));
    }

    function renderSpecs(address erc20Token) public view  returns (string memory symbolLowerCase, bytes32 symbolLabel,
        bytes32 subRoot,bytes32 subRoot2,  bytes32 subLabel, bytes32 addressLabel, string memory addressLower) {
        require(!tokensExist[erc20Token], "token already added");
        require(checkERC20Metadata(erc20Token), "Token not supporting the minimal interface");
        
        string memory symbol = IExtendedERC20(erc20Token).symbol();
        symbolLowerCase = toLowerCase(symbol);
        symbolLabel = keccak256(bytes(symbolLowerCase));
        addressLower = toHexString(erc20Token);

        addressLabel = keccak256(bytes(addressLower));

        subRoot = computeSubnode(rootNode, symbolLowerCase);
        subLabel = keccak256(bytes(toLowerCase(symbol)));
        subRoot2 = computeSubnode(subRoot, addressLower);


    }

    function nodeExists(address erc20Token) public view returns (bool exists) {
        
    (string memory symbolLowerCase, bytes32 symbolLabel, bytes32 subRoot,bytes32 subRoot2 ,
        bytes32 subLabel, bytes32 addressLabel, string memory addressLower) = renderSpecs(erc20Token);

    return vnsRegistry.recordExists(subRoot2);

    }

    function addTokenSubdomain(address erc20Token) public{
        //recordExist
        //require(!tokensExist[erc20Token], "token already added");
        require(checkERC20Metadata(erc20Token), "Token not supporting the minimal interface");
        require(resolver != 0x0000000000000000000000000000000000000000, "Please configure a default resolver");
        
        string memory symbol = IExtendedERC20(erc20Token).symbol();
        string memory name = IExtendedERC20(erc20Token).name();
        (string memory symbolLowerCase, bytes32 symbolLabel, bytes32 subRoot,bytes32 subRoot2 ,
        bytes32 subLabel, bytes32 addressLabel, string memory addressLower) = renderSpecs(erc20Token);


        //TODO do i want it beeing lowercased

        require(vnsRegistry.recordExists(subRoot2) == false, "This record already exits!");

        vnsRegistry.setSubnodeRecord(rootNode,  symbolLabel, address(this) , resolver, 0 );


        //set the different fast values
        TokenResolver(resolver).setAddr(subRoot2, erc20Token);
        TokenResolver(resolver).setName(subRoot2, addressLower);

        
        emit AddToken(subRoot2, address(erc20Token), name, symbol, addressLower);
        //TODO add the name and such
    }

    

    function removeToken(address erc20Token)  public onlyOwner{
        (string memory symbolLowerCase, bytes32 symbolLabel, bytes32 subRoot, bytes32 subRoot2 ,
        bytes32 subLabel, bytes32 addressLabel, string memory addressLower) = renderSpecs(erc20Token);

        emit RemoveToken(subRoot2, address(erc20Token));
        vnsRegistry.setOwner(subRoot2, 0x0000000000000000000000000000000000000000);
    }

    function setSubdomainResolver(bytes32 label, address _resolver) public onlyOwner {
        bytes32 subnode = keccak256(abi.encodePacked(rootNode, label));
        vnsRegistry.setResolver(subnode, _resolver);
        emit SetResolver(_resolver);

    }
}