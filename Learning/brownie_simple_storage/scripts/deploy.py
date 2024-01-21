from brownie import (
    accounts,
    config,
    SimpleStorage,
    network,
)  # Can add accounts in 3 ways
import os


def deploy_simple_storage():
    account = get_account()
    # account = accounts.load("demo-account")
    print(account)

    simple_storage = SimpleStorage.deploy({"from": account})
    print(simple_storage)
    stored_value = simple_storage.retrieve()
    print(stored_value)
    transaction = simple_storage.store(15, {"from": account})
    transaction.wait(1)
    stored_value = simple_storage.retrieve()
    print(stored_value)


def get_account():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def main():
    deploy_simple_storage()
    print("Hello!")
