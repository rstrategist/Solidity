// SPDX-License-Identifier: MIT

/**
 * @title PriceConverter Library
 * @author Based on Chainlink patterns
 * @notice This library provides functions to convert ETH amounts to USD
 *         using Chainlink price feeds
 * @dev Uses AggregatorV3Interface from Chainlink for price data
 */
pragma solidity ^0.8.19;

import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Chainlink price feeds have 8 decimals for ETH/USD
    uint256 internal constant PRICE_FEED_DECIMALS = 8;
    uint256 internal constant ETH_DECIMALS = 18;

    /**
     * @notice Gets the version of the Chainlink price feed aggregator
     * @param _priceFeed The address of the price feed contract
     * @return The version number of the price feed
     */
    function getVersion(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint256) {
        return _priceFeed.version();
    }

    /**
     * @notice Gets the current ETH price in USD from Chainlink
     * @dev Uses latestRoundData from Chainlink aggregator
     * @param _priceFeed The address of the price feed contract
     * @return The current ETH price in USD with 18 decimals
     */
    function getPrice(
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint256) {
        // Chainlink returns price with 8 decimals for ETH/USD
        // We need to convert to 18 decimals for consistency with ETH amounts
        (, int256 price, , , ) = _priceFeed.latestRoundData();

        // Validate that price is positive
        require(price > 0, "PriceConverter: Invalid price from feed");

        // Convert from 8 decimals to 18 decimals
        // price * 10^10 = price with 18 decimals
        return uint256(price) * (10 ** (ETH_DECIMALS - PRICE_FEED_DECIMALS));
    }

    /**
     * @notice Converts an ETH amount to its USD equivalent
     * @dev Both the ETH amount and returned USD value have 18 decimals
     * @param _ethAmount The amount of ETH to convert (in wei, 18 decimals)
     * @param _priceFeed The address of the price feed contract
     * @return The USD equivalent of the ETH amount (18 decimals)
     */
    function getConversionRate(
        uint256 _ethAmount,
        AggregatorV3Interface _priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(_priceFeed);
        // ethPrice has 18 decimals, ethAmount has 18 decimals
        // Division by 10^18 normalizes the result to 18 decimals
        uint256 ethAmountInUSD = (ethPrice * _ethAmount) / (10 ** ETH_DECIMALS);
        return ethAmountInUSD;
    }
}
