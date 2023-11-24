// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale tokenSale;
    uint256 startPrice = 1 ether;

    event testRefund();

    function setUp() public {
        tokenSale = new TokenSale();
        vm.txGasPrice(50 gwei);
    }

    function testInitialPrice() public {
        assertEq(tokenSale.currentPrice(), startPrice);
    }

    function testBuyTokens() public {
        uint256 tokensToBuy = 5;
        tokenSale.buy{value: 6 ether}(tokensToBuy);
        assertEq(tokenSale.balances(address(this)), tokensToBuy);
    }

    /* Not working as expected */
    function testFailBuyWithHighGasPrice() public {
        vm.txGasPrice(200 wei);
        //vm.expectRevert("Gas price exceeds limit");
        vm.expectRevert(bytes(""));
        tokenSale.buy{value: 1 ether}(2);
    }

    function testSellTokens() public {
        uint256 amountToBuy = 2.1 ether;
        tokenSale.buy{value: amountToBuy}(2);
        uint256 balanceBefore = address(this).balance;
        tokenSale.sell(1);
        uint256 balanceAfter = address(this).balance;
        assert(balanceAfter > balanceBefore);
    }

    fallback() external payable {
        emit testRefund();
    }

    receive() external payable {
        emit testRefund();
    }
}
