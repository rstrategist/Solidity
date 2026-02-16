// SPDX-License-Identifier: MIT

/**
 * @title FundMe Contract
 * @author Based on Patrick Collins' tutorial
 * @notice This contract allows anyone to deposit ETH and only the owner to withdraw
 * @dev Implements a crowdfunding pattern with minimum USD deposit requirement
 */
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/**
 * @title FundMe
 * @notice A crowdfunding contract with minimum USD deposit requirement
 */
contract FundMe {
    using PriceConverter for uint256;

    /////////////////
    // Errors      //
    /////////////////
    error NotOwner();
    error InsufficientFunding();

    /////////////////
    // State Variables //
    /////////////////

    /** @notice Minimum funding amount in USD (18 decimals) */
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    /** @notice Mapping of funders to their funded amounts */
    mapping(address => uint256) public addressToAmountFunded;

    /** @notice Array of all funder addresses */
    address[] public funders;

    /** @notice The contract owner who can withdraw funds */
    address public immutable i_owner;

    /** @notice Chainlink price feed for ETH/USD conversion */
    AggregatorV3Interface public immutable i_priceFeed;

    /////////////////
    // Events      //
    /////////////////

    /** @notice Emitted when a funder deposits ETH */
    event Funded(address indexed funder, uint256 amount);

    /** @notice Emitted when owner withdraws funds */
    event Withdrawn(address indexed owner, uint256 amount);

    /////////////////
    // Modifiers   //
    /////////////////

    /**
     * @notice Restricts function access to contract owner only
     * @dev Uses custom error for gas efficiency
     */
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    /////////////////
    // Functions   //
    /////////////////

    /**
     * @notice Initializes the contract with price feed and sets owner
     * @param _priceFeed Address of the Chainlink ETH/USD price feed
     * @dev Price feed addresses: https://docs.chain.link/data-feeds/price-feeds/addresses
     */
    constructor(address _priceFeed) {
        i_priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    /**
     * @notice Allows users to fund the contract with ETH
     * @dev Requires minimum USD equivalent of MINIMUM_USD
     */
    function fund() public payable {
        // Require minimum $50 equivalent in ETH
        if (msg.value.getConversionRate(i_priceFeed) < MINIMUM_USD) {
            revert InsufficientFunding();
        }

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

        emit Funded(msg.sender, msg.value);
    }

    /**
     * @notice Calculates the minimum ETH required to meet USD threshold
     * @return The minimum ETH amount in wei
     */
    function getEntranceFee() public view returns (uint256) {
        uint256 price = PriceConverter.getPrice(i_priceFeed);
        uint256 precision = 1 * 10 ** 18;
        return (MINIMUM_USD * precision) / price;
    }

    /**
     * @notice Withdraws all funds to the contract owner
     * @dev Resets all funder balances and clears funders array
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        // Reset all funder balances
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset funders array
        funders = new address[](0);

        // Transfer funds using call (recommended method post-Istanbul hard fork)
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, balance);
    }

    /**
     * @notice Alternative withdraw using cheaper storage operations
     * @dev More gas efficient for large funders arrays
     */
    function cheaperWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        // Store funders in memory for cheaper iteration
        address[] memory fundersMemory = funders;

        // Reset all funder balances
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersMemory.length;
            funderIndex++
        ) {
            address funder = fundersMemory[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset funders array
        funders = new address[](0);

        // Transfer funds
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, balance);
    }

    /**
     * @notice Gets the version of the Chainlink price feed
     * @return The version number
     */
    function getVersion() public view returns (uint256) {
        return PriceConverter.getVersion(i_priceFeed);
    }

    /**
     * @notice Gets the current ETH price from Chainlink
     * @return The current ETH price in USD (18 decimals)
     */
    function getPrice() public view returns (uint256) {
        return PriceConverter.getPrice(i_priceFeed);
    }

    /////////////////
    // Receive/Fallback //
    /////////////////

    /**
     * @notice Handles direct ETH transfers without calldata
     * @dev Forwards to fund() function
     */
    receive() external payable {
        fund();
    }

    /**
     * @notice Handles direct ETH transfers with calldata
     * @dev Forwards to fund() function
     */
    fallback() external payable {
        fund();
    }
}
