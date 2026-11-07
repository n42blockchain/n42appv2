// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// Disposable local-chain fixture. Never deploy as a production token.
contract MpcQaToken {
    mapping(address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        balanceOf[msg.sender] = 10 ** 30;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0) && balanceOf[msg.sender] >= value, "invalid transfer");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
}
