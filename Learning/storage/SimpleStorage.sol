// SPDX-License-Identifier: MIT

//pragma solidity >=0.6.0 <0.9.0;
pragma solidity ^0.8.24; // For zksync

contract SimpleStorage {
    /* This will get initialised to 0!
    public variables are also view functions
    without defining as public, it is initialised
    to internal and cannot be viewed externally.
    */
    uint256 favNum;
    /*
    bool favoriteBool = true;
    string favoriteString = "Hala habibi";
    int256 favoriteInt = -5;
    address favoriteAddress = 0x5B38Da6a701c535875dCfcB03FcB875f56beddC;
    bytes32 favoriteBytes = "lion";
    uint256[3] ListofNumbers = [1, 2, 3]; Static array with max 3 entries, indexed from 0 to 2
    unit256[] dynamicListofNumbers; Dynamic array with no max entries, indexed from 0 to n
    */

    // Create a structure to add a number and a name
    struct People {
        uint256 favNum;
        string name;
    }

    // Dynamic array to store People structs
    People[] public people;

    // mapping, a dictionary like structure with key-value pairs
    mapping(string => uint256) public nameToFavNum;

    // store a number
    function store(uint256 _favNum) public returns (uint256) {
        favNum = _favNum;
        return favNum;
    }

    // view and pure functions do not cost gas when called externally (without a transaction)
    // view functions can read state on the blockchain but cannot modify it
    // pure functions cannot read or modify state on the blockchain but perform
    // computations and return values based on the input parameters
    function retrieve() public view returns (uint256) {
        //return people[0].favNum;
        return favNum;
    }

    /* People public person = People({favoriteNumber: 3, name: "Muhammad Ali"});
    Storing in memory means it will only be stored during contract execution.
    Alternative option is to use "storage" so the data persists.*/
    function addPerson(string memory _name, uint256 _favNum) public {
        people.push(People(_favNum, _name));
        nameToFavNum[_name] = _favNum;
    }
}
