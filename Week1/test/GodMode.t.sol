// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GodMode.sol";

contract GodModeTKNTest is Test {
    GodModeTKN token;
    address owner;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        user1 = address(1);
        user2 = address(2);
        token = new GodModeTKN("GodMode Token", "GMTK");
        token.mint(owner, 1000);
        token.mint(user1, 500);
        vm.prank(owner);
        token.approve(user1, 1e18 * 1000);
    }

    function testTransferFromAsOwner() public {
        token.transferFrom(owner, user2, 1e18 * 100);

        assertEq(token.balanceOf(owner), 1e18 * 900);
        assertEq(token.balanceOf(user2), 1e18 * 100);
    }

    function testTransferFromAsNonOwner() public {
        vm.prank(user1);
        token.transferFrom(owner, user2, 1e18 * 100);

        assertEq(token.balanceOf(owner), 1e18 * 900);
        assertEq(token.balanceOf(user2), 1e18 * 100);
    }

    function testFailTransferFromNoApproval() public {
        vm.prank(user2);
        token.transferFrom(owner, user2, 1e18 * 100);
    }
}
