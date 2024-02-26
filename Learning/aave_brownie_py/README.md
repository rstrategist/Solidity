1. Swap our ETH to WETH.
2. Deposit some ETH (WETH) into Aave.
3. Borrow some asset with the collateral.
   1. Sell that borrowed asset. (Short selling).
4. Repay everything back.

Testing:

Integration test: Sepolia
Unit tests: Mainnet-fork

Default Testing Network:

- Development with Mocking
- No oracles => mainnet-fork
