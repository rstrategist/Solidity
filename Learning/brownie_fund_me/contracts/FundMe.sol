// SPDX-License-Identifier: MIT

// Smart contract that lets anyone deposit ETH into the contract
// Only the owner of the contract can withdraw the ETH
pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // SafeMath library checks uint256 for integer overflows
    /// not needed following v0.8.0
    using SafeMathChainlink for uint256;

    //mapping to store which address depositeded how much ETH
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    // Immediately executed when contract is deployed
    constructor(address _priceFeed) public {
        // Price Feed: https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1&search=
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // $50
        uint256 minimumUSD = 50 * 10 ** 18;
        // 1Gwei < $50
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "The minimum amount of ETH is $50 equivalent."
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    // Get ETH price from Chainlink price feeds
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // Get ETH amount in USD by conversion calc.
    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / (1 * 10 ** 18);
        return ethAmountInUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10 ** 18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10 ** 18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        // Require that only contract admin/owner can send
        require(
            msg.sender == owner,
            "Only contract owner can withdrawal funds. "
        );
        _;
    }

    // Function to withdrawl funds
    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        // Reset addressToAmountFunded mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset funders array once withdrawn
        funders = new address[](0);
    }
}
