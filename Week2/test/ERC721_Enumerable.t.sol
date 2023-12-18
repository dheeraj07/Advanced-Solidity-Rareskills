// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC721_Enumerable.sol";

contract CustomNFTCollectionTest is Test {
    CustomNFTCollection public nft;
    address public owner;

    function setUp() public {
        owner = address(this);
        nft = new CustomNFTCollection();
    }

    function testMintSuccess() public {
        uint256 tokenId = 50;
        nft.mint(address(1), tokenId);
        assertEq(nft.ownerOf(tokenId), address(1), "Minted NFT owner should match");
    }

    function testFailMintOutOfRange() public {
        uint256 tokenId = 101;
        nft.mint(address(1), tokenId);
    }

    function testFailMintNotOwner() public {
        address nonOwner = address(2);
        vm.prank(nonOwner);
        uint256 tokenId = 50;
        nft.mint(address(1), tokenId);
    }
}
