# Helper functions
from brownie import (
    network,
    config,
    accounts)

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local", "ganache-cli"]

DECIMALS = 8
INITIAL_VALUE = 200000000000

def get_account(index=None, id=None):
    # 1. account[0]
    # 2. account.add("env")
    # 3. accouns.load("id") # brownie accounts list

    if index:
        return accounts[index]
    
    if id:
        return accounts.load(id)

    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        print(accounts[0].balance())
        return accounts[0]
    
    return accounts.add(config["wallets"]["from_key"])