from brownie import network, config, interface
from scripts.helpful_scripts import get_account
from scripts.get_weth import get_weth
from web3 import Web3

amountEth = 0.1
amount = Web3.toWei(amountEth, "ether")

def main():
    # Get account, WETH and lending pool
    account = get_account()
    erc20_address = config["networks"][network.show_active()]["weth_token"]
    if network.show_active() in ["mainnet-fork"]:
        get_weth()
    lending_pool = get_lending_pool()
    
    # Approve sending out ERC20 tokens
    approve_erc20(amount, lending_pool.address, erc20_address, account)
    
    # Deposit WETH
    print("Depositing...")
    print(erc20_address)
    print(amount)
    print(account.address)
    tx = lending_pool.deposit(erc20_address, amount, account.address, 0, {"from": account})
    tx.wait(1)
    print(f"Deposited {amountEth} of ETH (WETH)!")
    
    # Borrow DAI
    borrowable_eth, total_debt_eth = get_borrowable_data(lending_pool, account)
    print("Let's borrow")
    # DAI in terms of ETH
    price_feed_address = config["networks"][network.show_active()]["dai_eth_price_feed"]
    erc20_eth_price = get_asset_price(price_feed_address)
    amount_erc20_to_borrow = (1 / erc20_eth_price) * (borrowable_eth * 0.0000000000095)
    # borrowable_eth -> borrowable_dai * 95%
    print(f"We are going to borrow {amount_erc20_to_borrow} DAI.")
    erc20_address = config["networks"][network.show_active()]["aave_dai_token"]
    
    borrow_erc20(lending_pool, amount_erc20_to_borrow, account)
    # Print User Account Data
    get_borrowable_data(lending_pool, account)

    repay_all(amount, lending_pool, account)

def get_asset_price(price_feed_address):
    # For mainnet we can just do:
    # return Contract(f"{pair}.data.eth").latestAnswer() / 1e8
    dai_eth_price_feed = interface.AggregatorV3Interface(price_feed_address)
    #latest_price = dai_eth_price_feed.latestRoundData()[1] / 1e8
    latest_price = Web3.fromWei(dai_eth_price_feed.latestRoundData()[1], "ether")
    print(f"The DAI/ETH price is {latest_price}")
    return float(latest_price)
    
    dai_eth_price_feed = interface.AggregatorV3Interface(price_feed_address)
    latest_price = dai_eth_price_feed.latestRoundData()[1]
    converted_latest_price = Web3.fromWei(latest_price, "ether")
    print(f"The DAI/ETH price feed is: {converted_latest_price}")
    return float(converted_latest_price)

def repay_all(amount, lending_pool, account):
    erc20_address = config["networks"][network.showactive()]["aave_dai_token"]
    approve_erc20(
        Web3.toWei(amount, "ether"),
        lending_pool,
        erc20_address,
        account)
    repay_tx = lending_pool.repay(
        erc20_address,
        amount,
        1,
        account.address,
        {"from": account}
    )
    repay_tx.wait(1)
    print("You repaid  all debts!")
    get_asset_price(lending_pool, account)
    print("You just deposited, borrowed, and repayed with Aave, Brownie and Chainlink!!!")

# getUserAccountData
def get_borrowable_data(lending_pool, account):
    (
        totalCollateralBase,
        totalDebtBase,
        availableBorrowsBase,
        currentLiquidationThreshold,
        ltv,
        healthFactor
    ) = lending_pool.getUserAccountData(account.address)
    totalCollateralBaseETH = Web3.fromWei(totalCollateralBase, "ether")
    totalDebtBaseETH = Web3.fromWei(totalDebtBase, "ether")
    availableBorrowsBaseETH = Web3.fromWei(availableBorrowsBase, "ether")
    print(f"You have {totalCollateralBaseETH} worth of ETH deposited.")
    print(totalCollateralBase)
    print(f"You have {totalDebtBaseETH} worth of ETH borrowed.")
    print(totalDebtBase)
    print(f"You can borrow {availableBorrowsBaseETH} worth of ETH.")
    print(availableBorrowsBase)
    print(f"Your current health factor is {healthFactor}.")
    return (float(availableBorrowsBase), float(totalDebtBase))

def approve_erc20(amount, spender, erc20_address, account):
    print("Approving ERC20 token...")
    erc20 = interface.IERC20(erc20_address)
    tx = erc20.approve(spender, amount, {"from": account})
    tx.wait(1)
    print("Approved!")
    return tx

def borrow_erc20(lending_pool, amount_erc20, account):
    print("Approving ERC20 token...")
    erc20 = interface.IERC20(erc20_address)
    tx = erc20.approve(spender, amount, {"from": account})
    tx.wait(1)
    print("Approved!")
    return tx

def borrow_erc20(lending_pool, amount, account, erc20_address=None):
    erc20_address = (
        erc20_address
        if erc20_address
        else config["networks"][network.show_active()]["aave_dai_token"]
    )
    # 1 is stable interest rate
    # 0 is the referral code
    tx = lending_pool.borrow(
        erc20_address,
        Web3.toWei(amount, "ether"),
        1,
        0,
        account.address,
        {"from": account},
    )
    tx.wait(1)
    print(f"Congratulations! You have just borrowed {amount}.")

def get_lending_pool():
    try:
        # Get the address provider
        address_provider_address = config["networks"][network.show_active()]["pool_address_provider"]
        address_provider = interface.IPoolAddressesProvider(address_provider_address)
        lending_pool_address = address_provider.getPool()
        lending_pool = interface.IPool(lending_pool_address)
        return lending_pool
    except Exception as e:
        print("Error while getting lending pool:", e)
        raise e