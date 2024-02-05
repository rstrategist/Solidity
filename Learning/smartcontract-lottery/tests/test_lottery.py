from brownie import Lottery, accounts, config, network
from web3 import Web3

# $50 is approx= $50 / $2,000 = 0.02 ETH
# 2 * 10**16 Wei


def test_get_entrance_fee():
    account = accounts[0]
    lottery = Lottery.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        {"from": account},
    )

    #assert lottery.getEntranceFee() > Web3.toWei(0.018, "ether")
    #assert lottery.getEntranceFee() < Web3.toWei(0.022, "ether")

