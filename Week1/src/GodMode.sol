// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title GodModeTKN with sanctions
/// @author Dheeraj
/// @notice Notes for non-technical readers
/// @dev Notes for people who understand Solidity
contract GodModeTKN is ERC20, Ownable2Step {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {}

    /// @notice Mints `amount` tokens to `owner`
    /// @dev Exposes the internal `_mint` function of the ERC20
    /// @param owner This ddress will receive the created tokens.
    /// @param amount Amount of tokens to be created
    function mint(address owner, uint256 amount) public {
        _mint(owner, amount * 10 ** decimals());
    }

    /// @notice Transfers GodModeTKN(ERC20)
    /// @dev checks if the sender is the deployer. If deployer, no restrictions on the token transfer between accounts
    /// @param sender The address from where the tokens will be deducted
    /// @param recipient The address of the recipient where the tokens has to be sent
    /// @param amount The amount of ERC20 tokens to deposit
    /// @return a boolean value depending on the transfer status
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (_msgSender() == owner()) {
            super._transfer(sender, recipient, amount);
        } else {
            super.transferFrom(sender, recipient, amount);
        }
        return true;
    }
}
