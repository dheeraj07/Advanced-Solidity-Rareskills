// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakeNFT.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract StakeNFTTest is Test {
    StakeNFT public stakeNFT;
    bytes32 generatedMerkleRoot = 0xf69baaa2944c954e4d6569dd2592a64e62631517366e7bb8494667cfcd8abb56;
    address public stakingContract;

    function setUp() public {
        stakingContract = address(this);
        stakeNFT = new StakeNFT(generatedMerkleRoot, stakingContract);
    }

    function testInitialDeployment() public {
        assertEq(stakeNFT.name(), "MyNFT");
        assertEq(stakeNFT.symbol(), "MNFT");
        assertEq(stakeNFT.owner(), stakingContract);
    }

    function testMintRegular() public {
        stakeNFT.mint{value: 0.02 ether}(address(1));
        assertTrue(stakeNFT.ownerOf(1) == address(1));
    }

    function testFailMintRegularInsufficientFunds() public {
        stakeNFT.mint{value: 0.02 ether - 0.01 ether}(address(1));
    }

    function testFailMintRegularMaxSupplyReached() public {
        for (uint256 i = 0; i < 1000; i++) {
            stakeNFT.mint{value: 0.02 ether}(address(1));
        }
        stakeNFT.mint{value: 0.02 ether}(address(1));
    }

    function testMintWithDiscount() public {
        bytes32[] memory merkleProof = new bytes32[](2);
        merkleProof[0] = 0xd70731c4fc4bf9cd8fc2be4d898bd67fd357eb0135035bf4500364b4c42c4fa5;
        merkleProof[1] = 0xfa8d260207fe657f2346775cc7df9e07ba0a08e64ccd28972b30bb03ba9b295b;

        address account = 0x0000000000000000000000000000000000000001;
        uint256 accountId = 1;

        stakeNFT.mintWithDiscount{value: 0.01 ether}(account, accountId, merkleProof);
        assertTrue(stakeNFT.ownerOf(1) == account);
    }

    function testFailMintWithDiscountInvalidProof() public {
        bytes32[] memory proof;
        stakeNFT.mintWithDiscount{value: 0.02 ether}(address(2), 0, proof);
    }

    function testFailMintWithDiscountInsufficientFunds() public {
        bytes32[] memory proof;
        stakeNFT.mintWithDiscount{value: 0.02 ether - 0.005 ether}(address(2), 0, proof);
    }

    function testFailMintWithDiscountClaimedAccount() public {
        bytes32[] memory proof;
        stakeNFT.mintWithDiscount{value: 0.02 ether}(address(2), 0, proof);
        stakeNFT.mintWithDiscount{value: 0.02 ether}(address(2), 0, proof);
    }

    function testRoyaltyInfo() public {
        uint256 tokenId = 1;
        (address receiver, uint256 royaltyAmount) = stakeNFT.royaltyInfo(tokenId, 10000);

        assertEq(receiver, address(this));
        assertEq(royaltyAmount, 250);
    }

    /*function testSupportsERC721Interface() public {
        assertTrue(stakeNFT.supportsInterface(type(ERC721).interfaceId));
    }

     function testSupportsERC721RoyaltyInterface() public {
         assertTrue(stakeNFT.supportsInterface(type(ERC721Royalty).interfaceId));
     }*/

    function testWithdrawFunds() public {
        address buyer = address(1);
        vm.deal(buyer, 1 ether);
        vm.startPrank(buyer);
        stakeNFT.mint{value: 0.1 ether}(buyer);
        vm.stopPrank();

        uint256 contractBalance = address(stakeNFT).balance;
        assertEq(contractBalance, 0.1 ether);

        uint256 ownerInitialBalance = address(this).balance;
        stakeNFT.withdrawFunds();

        assertEq(address(stakeNFT).balance, 0);

        assertEq(address(this).balance, ownerInitialBalance + contractBalance);
    }

    function testFailWithdrawFundsNotOwner() public {
        address nonOwner = address(2);
        vm.prank(nonOwner);
        stakeNFT.withdrawFunds();
    }

    fallback() external {}

    receive() external payable {}
}
