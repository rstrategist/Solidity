# Brownie FundMe

A crowdfunding smart contract built with Brownie that allows users to deposit ETH with a minimum USD threshold, using Chainlink price feeds for ETH/USD conversion.

## Project Structure

```
brownie_fund_me/
├── .env                      # Environment variables (private key, API keys)
├── .gitattributes            # Git language attributes for Solidity/Vyper
├── .gitignore                # Git ignore patterns
├── .pytest_cache/            # Pytest cache directory
├── brownie-config.yaml       # Brownie configuration file
├── build/                    # Compiled contracts and deployments
├── contracts/                # Solidity smart contracts
│   ├── FundMe.sol           # Main crowdfunding contract
│   ├── PriceConverter.sol   # Library for ETH/USD conversion
│   └── test/
│       └── MockV3Aggregator.sol  # Mock Chainlink price feed for testing
├── interfaces/               # Contract interfaces (empty - uses Chainlink)
├── reports/                  # Brownie reports and analysis
├── scripts/                  # Python deployment and interaction scripts
│   ├── __init__.py
│   ├── deploy.py            # Contract deployment script
│   ├── fund_and_withdraw.py # Fund and withdraw interaction script
│   └── helpful_scripts.py   # Utility functions
└── tests/                    # Pytest test files
    └── test_fund_me.py      # Unit and integration tests
```

## Smart Contracts

### FundMe.sol

The main crowdfunding contract with the following features:

- **Minimum Funding**: Requires minimum $50 USD equivalent in ETH
- **Owner Withdrawal**: Only the contract owner can withdraw funds
- **Price Feed Integration**: Uses Chainlink ETH/USD price feeds
- **Gas Optimized**: Uses custom errors, immutable variables, and efficient storage patterns

**Key Functions**:
| Function | Description |
|----------|-------------|
| `fund()` | Deposit ETH (minimum $50 USD equivalent) |
| `withdraw()` | Withdraw all funds (owner only) |
| `cheaperWithdraw()` | Gas-optimised withdrawal for large funder arrays |
| `getEntranceFee()` | Get minimum ETH required to fund |
| `getVersion()` | Get Chainlink price feed version |
| `getPrice()` | Get current ETH price in USD |

### PriceConverter.sol

A library providing ETH/USD conversion utilities:

- `getPrice()`: Fetches current ETH price from Chainlink
- `getConversionRate()`: Converts ETH amount to USD equivalent
- `getVersion()`: Returns Chainlink aggregator version

### MockV3Aggregator.sol

A mock Chainlink price feed for local testing environments.

## Scripts

### deploy.py

Deploys the FundMe contract to the active network.

```bash
# Deploy to local development network
brownie run scripts/deploy.py

# Deploy to Sepolia testnet
brownie run scripts/deploy.py --network sepolia

# Deploy to mainnet fork
brownie run scripts/deploy.py --network mainnet-fork-dev
```

**Functions**:
- `deploy_fund_me()`: Main deployment function
- `main()`: Entry point for Brownie

### fund_and_withdraw.py

Interacts with a deployed FundMe contract.

```bash
# Fund and withdraw from the most recent deployment
brownie run scripts/fund_and_withdraw.py

# On a specific network
brownie run scripts/fund_and_withdraw.py --network sepolia
```

**Functions**:
- `fund()`: Funds the contract with the minimum entrance fee
- `withdraw()`: Withdraws all funds (requires owner account)

### helpful_scripts.py

Utility functions used by other scripts.

**Constants**:
- `LOCAL_BLOCKCHAIN_ENVIRONMENTS`: ["development", "ganache-local", "ganache-cli"]
- `FORKED_LOCAL_ENVIRONMENTS`: ["mainnet-fork", "mainnet-fork-dev"]
- `DECIMALS`: 8 (Chainlink price feed decimals)
- `STARTING_PRICE`: 200000000000 (Mock initial ETH price ~$2000)

**Functions**:
- `get_account()`: Returns the appropriate account based on network
- `deploy_mocks()`: Deploys mock price feed for local testing

## Testing

Run the test suite:

```bash
# Run all tests on local network
brownie test

# Run with verbose output
brownie test -v

# Run specific test
brownie test tests/test_fund_me.py::test_can_fund_and_withdraw

# Run on a forked mainnet
brownie test --network mainnet-fork-dev
```

### Test Cases

| Test | Description |
|------|-------------|
| `test_can_fund_and_withdraw()` | Tests funding and withdrawal flow |
| `test_only_owner_can_withdraw()` | Verifies only owner can withdraw |

## Network Configuration

The project supports multiple networks configured in `brownie-config.yaml`:

| Network | Price Feed | Verification |
|---------|------------|--------------|
| development | Mock | No |
| ganache-local | Mock | No |
| ganache-cli | Mock | No |
| sepolia | Chainlink | Yes |
| mainnet-fork-dev | Chainlink | No |

### Chainlink Price Feed Addresses

- **Sepolia**: `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- **Mainnet**: `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`

## Environment Setup

Create a `.env` file with the following variables:

```env
export PRIVATE_KEY=your_private_key_here
export WEB3_INFURA_PROJECT_ID=your_infura_project_id
export ETHERSCAN_TOKEN=your_etherscan_api_token
```

## Installation

1. Install Brownie:
```bash
pip install eth-brownie
```

2. Clone and navigate to the project:
```bash
cd Learning/brownie_fund_me
```

3. Install dependencies:
```bash
brownie compile
```

## Quick Start

```bash
# Compile contracts
brownie compile

# Run tests
brownie test

# Deploy locally
brownie run scripts/deploy.py

# Deploy to Sepolia (requires .env configuration)
brownie run scripts/deploy.py --network sepolia

# Fund and withdraw
brownie run scripts/fund_and_withdraw.py
```

## License

MIT License