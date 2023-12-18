# `How does ERC721A save gas?`
## Batch Minting:
- ERC721A enables the minting of multiple tokens in a single transaction by updating the owner's balance just once for the entire batch transaction, as opposed to making multiple updates for each token within the batch. Additionally, it optimizes the process by updating ownership data once per batch mint request, rather than for each individually minted NFT

## Cumulative Balance Tracking:
-  Instead of updating the balance for each token minted, it uses a cumulative sum approach to track the number of tokens owned.


# `Where does it add cost?`

- `transferFrom` and `safeTransferFrom` transactions cost more gas in ERC721A due to the reason of cummulative balance tracking.

Reference: https://www.alchemy.com/blog/erc721-vs-erc721a-batch-minting-nfts