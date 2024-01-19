""" Compile Solidity contracts using
the JSON-input-output interface.
"""
from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv

# Import .env files
load_dotenv()

# Read Solidity source code from file
with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    # print(simple_storage_file)

# Compile Solidity code
install_solc("0.6.0")
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

# print(compiled_sol)
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# Get bytecode from the JSON
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# Get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# Connecting to Ganache
# w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
# chain_id = 1337

# Connecting to Infura Ethereum Sepolia Testnet
w3 = Web3(
    Web3.HTTPProvider("https://sepolia.infura.io/v3/d33763ff828a41bfb8e010721b644bd1")
)
chain_id = 11155111


# This is a simulated account on an EVM, sorry, no real ETH there :)
# my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
# private_key = os.getenv("PRIVATE_KEY")

# Ethereum Sepolia Testnet
my_address = "0x7c9850D69EA44C715ecf7C0806C5dceAe388AdC0"
private_key = os.getenv("PRIVATE_KEY")

# Create the contract in Python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# print(SimpleStorage)

# Get the latest transaction
nonce = w3.eth.get_transaction_count(my_address)

# 1. Build the transaction
transaction = SimpleStorage.constructor().build_transaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
    }
)

# 2. Sign the transaction
print("Deploying contract...")
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
# print(signed_txn)

# 3. Send the transaction
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("Contract deployed!")

# Working with the contract, you always need:
# (i) Contract Address
# (ii) Contract ABI
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# Call => Simulate making the call and getting a return value
# Transact => Actually make a state change (transaction) that will be executed on the blockchain
print(simple_storage.functions.retrieve().call())

# Store a value on the blockchain and retrieve it
print("Updating contract...")
# 1. Build transaction
store_transaction = simple_storage.functions.store(15).build_transaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce + 1,
    }
)
# 2. Sign the transaction
signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)
# 3. Send the transaction
send_store_tx = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(send_store_tx)
print("Contract updated!")

# Retrieve the data to check it was stored correctly
print(simple_storage.functions.retrieve().call())
