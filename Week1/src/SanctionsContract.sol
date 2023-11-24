// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title MyToken with sanctions
/// @author Dheeraj
/// @notice Notes for non-technical readers/
/// @dev Notes for people who understand Solidity
contract SanctionTKN is ERC20, Ownable2Step {
    mapping(address => bool) public restrictedAddresses;

    event BlockAddress(address culprit);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {}

    /// @notice Mints `amount` tokens to `owner`
    /// @dev Exposes the internal `_mint` function of the ERC20
    /// @param owner This ddress will receive the created tokens.
    /// @param amount Amount of tokens to be created
    function mint(address owner, uint256 amount) public {
        _mint(owner, amount * 10 ** decimals());
    }

    /// @notice Deposit ERC20 tokens
    /// @dev Adds an address to the blocklist
    /// @param culprit The address of the ERC20 token to be blocked from all the transfers
    function blockAddress(address culprit) public onlyOwner {
        restrictedAddresses[culprit] = true;
        emit BlockAddress(culprit);
    }

    /// @notice Transfers MyTokens(ERC20)
    /// @dev checks if the recipient is in the blocklist
    /// @param recipient The address of the recipient where the tokens has to be sent
    /// @param amount The amount of ERC20 tokens to deposit
    /// @return a boolean value depending on the transfer status
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!restrictedAddresses[recipient], "Address is blocked");
        return super.transfer(recipient, amount);
    }

    /// @notice Transfers MyTokens(ERC20)
    /// @dev checks if the sender/recipient is in the blocklist
    /// @param sender The address from where the tokens will be deducted
    /// @param recipient The address of the recipient where the tokens has to be sent
    /// @param amount The amount of ERC20 tokens to deposit
    /// @return a boolean value depending on the transfer status
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!restrictedAddresses[sender] && !restrictedAddresses[recipient], "Address is blocked");
        return super.transferFrom(sender, recipient, amount);
    }
}
