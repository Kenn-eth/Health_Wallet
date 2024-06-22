// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/health_wallet.sol";

contract walletTest is Test {
    HealthDataWallet private health_wallet;

    function setUp() public {
        health_wallet = new wallet();
    }
}
