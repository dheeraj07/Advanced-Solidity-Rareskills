// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/console.sol";

/// @title TokenSale
/// @author Dheeraj
/// @notice Implements a token sale with a linear bonding curve pricing model.
/// @dev When calling this contract, ensure the gas price is set to 50 gwei.
contract TokenSale {
    uint256 public totalSupply;
    uint256 public constant startPrice = 1 ether;
    uint256 public constant priceIncrement = 0.1 ether;
    uint256 public constant staticGasPrice = 50 gwei;
    bool private locked;

    mapping(address => uint256) public balances;

    /// @dev Modifier to check the gas price of a transaction.
    modifier checkGasPrice() {
        require(tx.gasprice == staticGasPrice, "Gas price exceeds limit");
        _;
    }

    /// @dev Modifier for avoding reentrancy
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Allows a user to buy tokens based on the current price.
    /// @dev Calculates the total ETH required for the given number of tokens and transfers tokens to the buyer account in this contract.
    /// @param _tokens The number of tokens to buy.
    function buy(uint256 _tokens) external payable checkGasPrice noReentrancy {
        uint256 preTradePrice = currentPrice();
        uint256 postTradePrice = preTradePrice + priceIncrement * (_tokens - 1);
        uint256 totalETHRequired = (preTradePrice + postTradePrice) * _tokens / 2;

        require(msg.value >= totalETHRequired, "Insufficient ETH sent");
        balances[msg.sender] += _tokens;
        totalSupply += _tokens;
    }

    /// @notice Allows a user to sell tokens back to the contract.
    /// @dev Calculates the total ETH to return to the seller and transfers tokens from the seller.
    /// @param _tokens The number of tokens to sell.
    function sell(uint256 _tokens) external checkGasPrice noReentrancy {
        uint256 preTradePrice = currentPrice() - (priceIncrement * (_tokens - 1));
        uint256 totalReturn = (preTradePrice + currentPrice()) * _tokens / 2;
        balances[msg.sender] -= _tokens;
        totalSupply -= _tokens;
        (bool success,) = payable(msg.sender).call{value: totalReturn}("");
        require(success, "Transaction failed");
    }

    /// @notice Retrieves the current price of tokens based on the total supply.
    /// @return The current price per token.
    function currentPrice() public view returns (uint256) {
        return startPrice + priceIncrement * totalSupply;
    }
}

/**
 * To avoid sandwich attacks, I have set a constant gas fee for interacting with this contract.
 */
