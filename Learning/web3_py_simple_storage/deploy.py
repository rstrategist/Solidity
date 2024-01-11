from solcx import compile_standard

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    print(simple_storage_file)

# Compile our Solidity code

compiled_sol = sompile_standard{
    {"language": "Solidity",
     "sources": {"simple_storage.sol": {"content": simple_storage_file}},
     "settings": {
         "outputSelection": {
             "*" : {"*": ["abi", "metadata", "evm.btecode", "evm.sourceMap"]}
         }
     }
                 
    }
    solc_version="0.6.0",
}
print(compiled_sol)