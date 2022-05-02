pragma solidity ^0.5.0;


contract DutchAuction {

    //TODO: place your code here
	uint256 private _initialPrice;
	uint256 private _biddingPeriod;
	uint256 private _offerPriceDecrement;
	uint256 _startBlock;
	bool private _openBidding;
	uint256 private _currPrice;
	address _winner;
	
    // Useful modifiers
    modifier biddingOpenOnly {
        require (biddingOpen());
        _;
    }

    modifier biddingClosedOnly {
        require (!biddingOpen());
        _;
    }

    // constructor
    constructor(uint256 initialPrice,
    uint256 biddingPeriod,
    uint256 offerPriceDecrement,
    bool testMode) public {

        _testMode = testMode;
        _creator = msg.sender;

        //TODO: place your code here
		_initialPrice = initialPrice;
		_biddingPeriod = biddingPeriod;
		_offerPriceDecrement = offerPriceDecrement;
		_startBlock = getBlockNumber();
		_openBidding = true;
		_currPrice = initialPrice;
		_winner = address(0);
    }

    // Return the current price of the listing.
    // This should return 0 if bidding is not open or the auction has been won.
    function currentPrice() public returns(uint) {
        //TODO: place your code here
		biddingOpen();
        return _currPrice;
    }

    // Return true if bidding is open.
    // If the auction has been won, should return false.
    function biddingOpen() public returns(bool isOpen) {
        //TODO: place your code here
		uint256 priceDecrement = (getBlockNumber() - _startBlock) * _offerPriceDecrement;
        if (getBlockNumber() > _startBlock + _biddingPeriod - 1 || priceDecrement >= _initialPrice) {
            _openBidding = false;
            _currPrice = 0;
        }
        else {
             _currPrice = _initialPrice - priceDecrement;
        }
        return _openBidding;
    }

    // Return the winning bidder, if the auction has been won.
    // Otherwise should return 0.
    function getWinningBidder() public view returns(address winningBidder) {
        //TODO: place your code here
		return _winner;
    }


    function bid() public payable biddingOpenOnly {
        //TODO: place your code here
		require (msg.value >= currentPrice());
		msg.sender.transfer(msg.value - _currPrice);
        _winner = msg.sender;
        _openBidding = false;
        _currPrice = 0;
    }


    function finalize() public creatorOnly biddingClosedOnly {
        //TODO: place your code here
		_creator.transfer(address(this).balance);
        selfdestruct(_creator);
    }

    // No need to change any code below here

    uint256 _testTime;
    bool _testMode = false;
    address payable _creator;

    modifier creatorOnly {
        require(msg.sender == _creator);
        _;
    }

    modifier testOnly {
        require(_testMode);
        _;
    }

    function overrideTime(uint time) public creatorOnly testOnly {
        _testTime = time;
    }

    function clearTime() public creatorOnly testOnly{
        _testTime = 0;
    }

    function getBlockNumber() internal view returns (uint) {
        if (_testTime != 0){
            return _testTime;
        }
        return block.number;
    }
}
