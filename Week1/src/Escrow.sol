// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Untrusted Escrow
/// @author Dheeraj
/// @notice This contract acts as an escrow between two parties, allowing a buyer to deposit ERC20 tokens that a seller can withdraw after a lock period.
/// @dev Utilizes SafeERC20 from OpenZeppelin for secure token transfers and implements a custom reentrancy guard.
contract Escrow {
    using SafeERC20 for IERC20;

    address public buyer;
    address public seller;
    IERC20 public token;
    uint256 public lockedUntil;
    uint256 public constant lockDuration = 3 days;
    bool private locked;

    /// @notice Initializes the contract with buyer, seller, and ERC20 token addresses
    /// @dev Sets the state variables for buyer, seller, and token.
    /// @param _buyer The address of the buyer
    /// @param _seller The address of the seller
    /// @param _token The ERC20 token address
    constructor(address _buyer, address _seller, address _token) {
        buyer = _buyer;
        seller = _seller;
        token = IERC20(_token);
    }

    /// @notice Modifier to prevent reentrancy attacks
    /// @dev Toggles the state of the 'locked' variable to block reentrant calls
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Allows the buyer to deposit a specified amount of tokens into the escrow
    /// @dev Transfers tokens from the buyer to the contract and sets the lock period.
    /// @param _amount The amount of tokens to deposit
    function deposit(uint256 _amount) external noReentrancy {
        require(msg.sender == buyer, "Only buyer can deposit");
        require(lockedUntil == 0, "Deposit already made");

        lockedUntil = block.timestamp + lockDuration;
        token.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /// @notice Allows the seller to withdraw the tokens after the lock period has passed
    /// @dev Transfers the total balance of tokens held by the contract to the seller.
    function withdraw() external noReentrancy {
        require(msg.sender == seller, "Only seller can withdraw");
        require(block.timestamp >= lockedUntil, "Lock period not yet passed");
        require(lockedUntil != 0, "No deposit made");

        uint256 balance = token.balanceOf(address(this));
        lockedUntil = 0;
        token.safeTransfer(seller, balance);
    }
}

/**
 * Non-Standard ERC20 Tokens:
 *      - This is handled by using SafeERC20
 * Fee-on-Transfer Tokens:
 *      - Rather than storing the balance in this contract, we query the balance when sending tokens to the seller
 *        and then proceed with the transfer. This ensures that the transfer is successful, even in cases where there is a fee on the transfer.
 * Reentrancy:
 *      - noReentrancy modifier has been implemented to avoid any reentrancy calls
 */
