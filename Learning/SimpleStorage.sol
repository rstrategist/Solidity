// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract SimpleStorage {
    /* This will get initialised to 0!
    public variables are also view functions
    without defining as public, it is initialised
    to internal and cannot be viewed externally.
    */
    uint256 favNum;
    //bool favoriteBool;

    // Create a structure to add a number and a name
    struct People {
        uint256 favNum;
        string name;
    }

    // Create a dynamic array of type People[]
    People[] public people;

    // Dictionary like structure with key-value pairs
    mapping(string => uint256) public nameToFavNum;

    // store a number
    function store(uint256 _favNum) public returns (uint256) {
        favNum = _favNum;
        return favNum;
    }

    // view (read state from the blockchain)
    // pure functions perform some kind of computation
    function retrieve() public view returns (uint256) {
        //return people[0].favNum;
        return favNum;
    }

    // People public person = People({favoriteNumber: 3, name: "Muhammad Ali"});
    /* Storing in memory means it will only be stored
    during contract execution. Alternative option is to use "storage" so the
    data persists.*/
    function addPerson(string memory _name, uint256 _favNum) public {
        people.push(People(_favNum, _name));
        nameToFavNum[_name] = _favNum;
    }
}
