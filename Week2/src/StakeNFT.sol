// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract StakeNFT is ERC721, ERC721Royalty, Ownable {
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap claimedUsers;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant DISCOUNT_PRICE = 0.01 ether;
    uint256 public constant REGULAR_PRICE = 0.02 ether;
    uint256 private _tokenIds;
    bytes32 public merkleRoot;

    constructor(bytes32 _merkleRoot, address _stakingContract) ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(msg.sender, 250);
    }

    function mint(address account) public payable {
        require(_tokenIds < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= REGULAR_PRICE);

        _tokenIds++;
        _mint(account, _tokenIds);
    }

    function mintWithDiscount(address _to, uint256 _accountId, bytes32[] calldata _merkleProof) public payable {
        require(_tokenIds < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= DISCOUNT_PRICE, "Ether sent is not correct");
        require(!claimedUsers.get(_accountId), "Already claimed");
        require(
            MerkleProof.verify(
                _merkleProof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(_to, _accountId))))
            ),
            "Invalid Merkle Proof"
        );

        claimedUsers.set(_accountId);
        _tokenIds++;
        _mint(_to, _tokenIds);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool sent,) = payable(owner()).call{value: balance}("");
        require(sent, "failed to send");
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Royalty) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || interfaceId == type(ERC721Royalty).interfaceId;
    }
}
