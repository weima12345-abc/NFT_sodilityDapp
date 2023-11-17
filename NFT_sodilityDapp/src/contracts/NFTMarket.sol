// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    /*  
    Definitions MarketItem
    @param: itemId 
    @param: ntfContract NFT ERC721 URI Storage deployed on ERC721URIStorage
    @param: seller  Address of Seller
    @param: owner Address of Owner
    @param: price Price of the item
    @param: sold  Sold or not, boolean
    */
    struct MarketItem {
        uint itemId;
        address contractAddress;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    /* Listing NFT to the Marketplace */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "price must be positive");
        require(msg.value == listingPrice, "need listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // emit MarketItemCreated(
        //     itemId,
        //     nftContract,
        //     tokenId,
        //     msg.sender,
        //     address(0),
        //     price,
        //     false
        // );
    }

    /* sellContract　createMarketSale */
    function createMarketSale(
        address nftContract,
        uint itemId
    ) public payable nonReentrant {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "purchase failed cuz insuffient price");

        idToMarketItem[itemId].seller.transfer(msg.value);

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();

        payable(owner).transfer(listingPrice);
    }
}
