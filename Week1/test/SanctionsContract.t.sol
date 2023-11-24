// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SanctionsContract.sol";

contract SanctionTKNTest is Test {
    SanctionTKN token;
    address owner;
    address user1;
    address user2;
    address restrictedUser;

    function setUp() public {
        owner = address(this);
        user1 = address(1);
        user2 = address(2);
        restrictedUser = address(3);
        token = new SanctionTKN("MyToken", "MTK");
        token.mint(owner, 1000);
        token.mint(user1, 500);
        vm.startPrank(owner);
        token.approve(user1, 1e18 * 1000);
        vm.stopPrank();
    }

    function testBlockingAddress() public {
        token.blockAddress(restrictedUser);
        assertTrue(token.restrictedAddresses(restrictedUser));
    }

    function testFailTransferToBlockedAddress() public {
        token.blockAddress(user2);
        //vm.expectRevert("Address is blocked");
        vm.expectRevert(bytes(""));
        token.transfer(user2, 1e18 * 100);
    }

    function testFailTransferFromBlockedAddress() public {
        token.blockAddress(user1);
        vm.prank(user1);
        //vm.expectRevert(bytes("Address is blocked"));
        vm.expectRevert(bytes(""));
        token.transferFrom(user1, owner, 1e18 * 100);
    }

    function testSuccessfulTransfer() public {
        token.transfer(user2, 1e18 * 100);
        assertEq(token.balanceOf(user2), 1e18 * 100);
    }
}
