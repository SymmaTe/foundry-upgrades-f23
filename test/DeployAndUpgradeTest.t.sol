// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox deployer;
    address proxy;

    address public OWNER = makeAddr("owner");

    function setUp() public {
        deployer = new DeployBox();
        proxy = deployer.run();
    }

    function testProxyStartsAsBoxV1() public view {
        assertEq(BoxV1(proxy).version(), 1);
    }

    function testDeploymentIsInitialized() public view {
        // owner 应该是调用 initialize 时的 msg.sender
        assertNotEq(BoxV1(proxy).owner(), address(0));
    }

    function testCannotReinitialize() public {
        vm.expectRevert();
        BoxV1(proxy).initialize();
    }

    function testBoxV1GetNumber() public view {
        assertEq(BoxV1(proxy).getNumber(), 0);
    }

    function testUpgradeToBoxV2() public {
        BoxV2 boxV2 = new BoxV2();

        vm.prank(BoxV1(proxy).owner());
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");

        assertEq(BoxV2(proxy).version(), 2);
    }

    function testUpgradedContractHasSetNumber() public {
        BoxV2 boxV2 = new BoxV2();

        vm.prank(BoxV1(proxy).owner());
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");

        BoxV2(proxy).setNumber(42);
        assertEq(BoxV2(proxy).getNumber(), 42);
    }

    function testOnlyOwnerCanUpgrade() public {
        BoxV2 boxV2 = new BoxV2();

        vm.prank(OWNER); // 非 owner 尝试升级
        vm.expectRevert();
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");
    }

    function testStateIsPreservedAfterUpgrade() public {
        // V1 没有 setNumber，所以 number 保持为 0
        assertEq(BoxV1(proxy).getNumber(), 0);

        // 升级到 V2
        BoxV2 boxV2 = new BoxV2();
        vm.prank(BoxV1(proxy).owner());
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");

        // 状态应该保留
        assertEq(BoxV2(proxy).getNumber(), 0);

        // 设置新值
        BoxV2(proxy).setNumber(100);
        assertEq(BoxV2(proxy).getNumber(), 100);
    }
}
