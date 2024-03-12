// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ERC20.sol";

contract customERC20 is ERC20 {

    // Constructor de Smart Contract

    constructor() ERC20("Expe", "EA"){}

    // Creacion de nuevos Tokens
    function createTokens () public {
        _mint(msg.sender, 1000);
    }
}