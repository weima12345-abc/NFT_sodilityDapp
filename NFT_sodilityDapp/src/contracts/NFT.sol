// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/* 创造NFT合约, 继承 ERC721URIStorage, 生成 ERC721 URI Storage */
contract NFT is ERC721URIStorage {
    /**
    1. Create Contract NFT, inherits ERC721URIStorage, Generate ERC721 URI Storage
    2. Construct the contract, initialize CreateAddress as marketplaceAddress
    3. calls internal increment function, generate new tokenId as indexId
    4. Mint NFT with current tokenId for contract caller, set tokenURI, and make it public */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Metaverse", "METT") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
