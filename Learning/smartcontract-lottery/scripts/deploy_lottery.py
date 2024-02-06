from scripts.helpful_scripts import get_account, get_contract, fund_with_link
from brownie import Lottery, network, config
import time

def deploy_lottery():
        #account = get_account(id="demo-account")
        account = get_account()
        Lottery.deploy(
                get_contract("eth_usd_price_feed").address,
                get_contract("vrf_coordinator").address,
                get_contract("link_token").address,
                config["networks"][network.show_active()]["fee"],
                config["networks"][network.show_active()]["keyhash"],
                {"from": account},
                publish_source=config["networks"][network.show_active()].get("verify", False),
                )
        print("Lottery contract deployed!")
        #print(f"Lottery contract deployed to {lottery.address}")

def start_lottery():
        print("Starting lottery...")
        account = get_account()
        lottery = Lottery[-1]
        starting_tx = lottery.startLottery({"from": account})
        starting_tx.wait(1)
        print("Lottery started!")

def enter_lottery():
        print("Entering you into the lottery!")
        account = get_account()
        lottery = Lottery[-1]
        value = lottery.getEntranceFee() + 1*10**8
        tx = lottery.enter({"from": account, "value": value})
        tx.wait(1)
        print("You have entered the lottery!")

def end_lottery():
        print("Ending the lottery...")
        account = get_account()
        lottery = Lottery[-1]
        # Fund the contract with LINK token
        tx = fund_with_link(lottery.address)
        #tx.wait(1)
        # End lottery
        ending_tx = lottery.endLottery({"from": account})
        ending_tx.wait(1)
        time.sleep(60)
        print("Lottery ended!")
        print(f"{lottery.recentWinner()} is the new WINNER!")


def main():
        deploy_lottery()
        start_lottery()
        enter_lottery()
        end_lottery()