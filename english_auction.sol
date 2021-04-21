// SPDX-License-Identifier: GPL-3.0
// ---------------------------------------------------------------------------
// File: english_auction.sol
// Compile: solc --bin english_auction.sol
// Author: Tim Siwula
// Date: 04/21/2021
// ---------------------------------------------------------------------------

pragma solidity ^0.8.3;

contract EnglishAuction {

    struct Bid {
        bytes32 englishBid;
        uint deposit;
    }

    // Auction House details
    address payable public auctioneer;
    address payable public beneficiary;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    modifier onlyBefore(uint _time) { require(block.timestamp < _time); _; }
    modifier onlyAfter(uint _time) { require(block.timestamp > _time); _; }

    constructor(
        uint _biddingTime,
        uint _tenMinuteExtensionTime,
        address payable _beneficiary
    ) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _tenMinuteExtensionTime;
        expirationTime = biddingEnd + _biddingTime;
    }

    // auction operations/mechanics
    string auctionID;
    address seller;
    address asset;
    uint suggestedOpeningBid;
    uint reservePrice;

    // auction start, stop, extend times
    uint auctionOpen;
    uint biddingEnd;
    uint auctionClose;
    uint expirationTime;
    uint plusTenMinutes;

    function bid(bytes32 _englishBid)
    public
    payable
    onlyBefore(expirationTime)
    {
        bids[msg.sender].push(Bid({
        englishBid: _englishBid,
        deposit: msg.value
        }));
    }

    function placeBid(address bidder, uint value) internal
    returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd()
    public
    onlyAfter(expirationTime)
    {
        require(!ended);
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }
}