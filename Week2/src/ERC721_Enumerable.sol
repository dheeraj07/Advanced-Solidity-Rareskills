// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomNFTCollection is ERC721Enumerable, Ownable {
    constructor() ERC721("MyNFTCollection", "MNFT") Ownable(msg.sender) {}

    function mint(address to, uint256 tokenId) public onlyOwner {
        require(tokenId >= 1 && tokenId <= 100, "Token ID out of range");
        _mint(to, tokenId);
    }
}
