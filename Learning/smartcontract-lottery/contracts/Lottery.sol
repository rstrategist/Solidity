// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public usdEntryFee;
    uint256 public randomness;
    AggregatorV3Interface internal ethUSDPriceFeed;

    LOTTERY_STATE public lotteryState;
    enum LOTTERY_STATE {
        OPEN, //0
        CLOSED, //1
        CALCULATING_WINNER //2
    }
    uint256 public fee;
    bytes32 public keyhash;

    // Constrctor
    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        // $50 minimum entry fee
        usdEntryFee = 50 * (10 ** 18);
        ethUSDPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lotteryState = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
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
        // Chainlink VRF Provides Verifiable Randomness

        // Pseudorandom number generation
        // uint(
        //     keccak256(
        //         abi.encode(nonce, msg.sender, block.difficulty, block.timestamp)
        //     )
        // ) % players.length;

        lotteryState = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
    }

    // override fulfillRandomness function since not defined
    function fulfillRandomness(
        bytes32 _requestID,
        uint256 _randomness
    ) internal override {
        require(
            lotteryState == LOTTERY_STATE.CALCULATING_WINNER,
            "Lottery winner not yet selected!"
        );

        require(_randomness > 0, "random-not-found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        // Reset
        players = new address payable[](0);
        randomness = _randomness;
        lotteryState = LOTTERY_STATE.CLOSED;
    }
}
