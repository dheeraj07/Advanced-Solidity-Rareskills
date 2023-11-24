// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import "../src/MockERC20.sol";

contract EscrowTest is Test {
    Escrow escrow;
    MockERC20 token;
    address buyer;
    address seller;

    function setUp() public {
        buyer = address(1);
        seller = address(2);
        token = new MockERC20("Test Token", "T");
        escrow = new Escrow(buyer, seller, address(token));

        token.mint(buyer, 500);
        vm.startPrank(buyer);
        token.approve(address(escrow), 1e18 * 500);
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.prank(buyer);
        escrow.deposit(1e18 * 100);

        assertEq(token.balanceOf(address(escrow)), 1e18 * 100);
    }

    function testFailWithdraw() public {
        vm.prank(buyer);
        escrow.deposit(1e18 * 100);
        vm.warp(block.timestamp + 1 days);
        vm.prank(seller);
        vm.expectRevert(bytes(""));
        escrow.withdraw();
    }

    function testWithdraw() public {
        vm.prank(buyer);
        escrow.deposit(1e18 * 100);
        vm.warp(block.timestamp + 3 days);
        uint256 sellerBalanceBefore = token.balanceOf(seller);
        vm.prank(seller);
        escrow.withdraw();
        uint256 sellerBalanceAfter = token.balanceOf(seller);

        assertEq(sellerBalanceAfter, sellerBalanceBefore + 1e18 * 100);
    }
}
