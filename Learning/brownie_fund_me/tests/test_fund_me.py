from brownie import FundMe, network, accounts, exceptions
from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me
import pytest

def test_can_fund_and_withdraw():
    account = get_account()
    fund_me = deploy_fund_me()
    # Test 1 - Fund Account
    entrance_fee = fund_me.getEntranceFee() + 100
    tx = fund_me.fund({"from": account, "value": entrance_fee})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee
    # Test 2 - Withdraw from Account
    tx2 = fund_me.withdraw({"from": account})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0

    print(f"The current entry fee is {entrance_fee}.")
    print("Funding")

def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for local testing")
        fund_me = deploy_fund_me()
        bad_actor = accounts.add()
        with pytest.raises(exceptions.VirtualMachineError):
            fund_me.withdraw({"from": bad_actor})