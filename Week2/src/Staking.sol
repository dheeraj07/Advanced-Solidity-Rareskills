pragma solidity ^0.8.0;

import "./RewardToken.sol";
import "./StakeNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Staking is IERC721Receiver, Ownable {
    RewardToken reward;
    StakeNFT sNFT;
    mapping(address => bool) stakeTracker;
    mapping(address => uint256) tokenIdsStaked;
    mapping(address => uint256) lastClaimTimestamp;

    constructor(bytes32 _merkleroot) Ownable(msg.sender) {
        reward = new RewardToken();
        sNFT = new StakeNFT(_merkleroot, address(this));
    }

    function stakeNFT(uint256 _tokenId) external {
        require(_tokenId != 0);
        require(sNFT.ownerOf(_tokenId) == msg.sender, "unauthorized");

        tokenIdsStaked[msg.sender] = _tokenId;
        sNFT.safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    function unStakeNFT(uint256 _tokenId) external {
        require(_tokenId != 0);
        require(_tokenId == tokenIdsStaked[msg.sender]);
        tokenIdsStaked[msg.sender] = 0;

        sNFT.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function collectStakingRewards() external {
        require(tokenIdsStaked[msg.sender] != 0);
        require(block.timestamp - lastClaimTimestamp[msg.sender] >= 24 hours);

        lastClaimTimestamp[msg.sender] = block.timestamp;
        reward.mintRewardTokens(msg.sender);
    }

    function onERC721Received(address, address from, uint256, bytes calldata) external override returns (bytes4) {
        stakeTracker[from] = true;
        return IERC721Receiver.onERC721Received.selector;
    }
}
