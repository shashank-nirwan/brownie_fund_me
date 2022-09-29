from cgi import test
from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest


def test_can_fund_and_withdraw():
    accounts = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee()
    tx = fund_me.fund({"from": accounts, "value": entrance_fee})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(accounts.address) == entrance_fee
    tx2 = fund_me.Withdraw({"from": accounts})
    tx2.wait(1)
    assert fund_me.addressToAmountFunded(accounts.address) == 0
    pass


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for loal testing")
    fund_me = deploy_fund_me()
    bad_actor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.Withdraw({"from": bad_actor})


def main():
    test_can_fund_and_withdraw()
