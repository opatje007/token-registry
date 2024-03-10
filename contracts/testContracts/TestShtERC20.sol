// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.7.4;

import './ERC20.sol';


contract TestShtERC20 is ERC20 {
    event TokenCreated(string indexed name, string indexed symbol);

    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
    {
        
        _mint(msg.sender, 20000000000 * 10 ** 18);
        _mint(0x522d7db12a4Fd983946770d61001DF85Ce6038D6, 20000000000000 * 10 ** 18);
        emit TokenCreated(name, symbol);

    }



    function   mint (address to, uint256 amount) external{
        _mint(to, amount);
    }


}
