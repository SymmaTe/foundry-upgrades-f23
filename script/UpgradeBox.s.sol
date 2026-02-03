// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeBox is Script {
    function run() external {
        address proxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        vm.startBroadcast();

        // 1. 部署新的实现合约
        BoxV2 boxV2 = new BoxV2();

        // 2. 通过代理调用 upgradeToAndCall 升级到新实现
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");

        vm.stopBroadcast();
    }
}
