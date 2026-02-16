// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24; // For zksync

import {SimpleStorage} from "./SimpleStorage.sol";

// Create contracts, store information on-chain and retrieve it
contract StorageFactory is SimpleStorage {
    // List of contracts
    SimpleStorage[] public simpleStorageArray;

    // Create SimpleStorage contracts
    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    // Store data
    function sfStore(
        uint256 _simpleStorageIndex,
        uint256 _simpleStorageNumber
    ) public {
        // Address
        // ABI (Application Binary Interface)
        SimpleStorage simpleStorage = SimpleStorage(
            address(simpleStorageArray[_simpleStorageIndex])
        );
        simpleStorage.store(_simpleStorageNumber);
    }

    // Retrieve data
    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        return
            SimpleStorage(address(simpleStorageArray[_simpleStorageIndex]))
                .retrieve();
    }
}
