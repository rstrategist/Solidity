// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0

contract SafeMathTester {
    // SafeMath library checks uint256 for integer overflows
    using SafeMath for uint256;

    uint8 public maxUint8 = 2 ** 8 - 1; // 255 is max before it wraps around to 0
    // after solidity v0.8.0, integer overflow checks are built in and SafeMath is no longer needed

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        return a.sub(b);
    }

    function mul(uint256 a, uint256 b) public pure returns (uint256) {
        return a.mul(b);
    }

    function div(uint256 a, uint256 b) public pure returns (uint256) {
        return a.div(b);
    }
}