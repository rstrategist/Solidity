// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    address payable[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUSDPriceFeed;

    enum LOTTERY_STATE {
        OPEN, //0
        CLOSED, //1
        CALCULATING_WINNER //2
    }
    LOTTERY_STATE public lotteryState;

    constructor(address _priceFeedAddress) public {
        usdEntryFee = 50 * (10 ** 18);
        ethUSDPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // Enter the lottery
    function enter() public payable {
        // Check if lottery is open
        require(lotteryState == LOTTERY_STATE.OPEN);
        // $50 minimum
        require(
            msg.value >= getEntranceFee(),
            "Not enough ETH for entrance fee!"
        );
        players.push(msg.sender);
    }

    // Get entrance fee: $50 in Wei
    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUSDPriceFeed.latestRoundData();
        uint256 adustedPrice = uint256(price) * 10 ** 10; // 18 decimals
        uint256 costToEnter = (usdEntryFee * 10 ** 18) / adustedPrice;
        return costToEnter;
    }

    // Start the lottery
    function startLottery() public {
        require(
            lotteryState == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet"
        );
        lotteryState = LOTTERY_STATE.OPEN;
    }

    // End the lottery
    function endLottery() public onlyOwner {
        uint(
            keccak256(
                abi.encode(nonce, msg.sender, block.difficulty, block.timestamp)
            )
        ) % players.length;
    }
}
