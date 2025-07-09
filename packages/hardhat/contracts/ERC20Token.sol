// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ERC20Token
 * @notice Simple ERC20 token with public mint for testing and Scaffold-ETH integration.
 */
contract ERC20Token is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /// @notice Mints tokens to a specific address
    /// @param to The recipient address
    /// @param amount The amount to mint
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}