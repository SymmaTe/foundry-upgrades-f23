// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployBox is Script {
    function run() external returns (address) {
        vm.startBroadcast();

        // 1. 部署实现合约
        BoxV1 boxV1 = new BoxV1();

        // 2. 部署代理合约，并调用 initialize()
        ERC1967Proxy proxy = new ERC1967Proxy(address(boxV1), abi.encodeCall(BoxV1.initialize, ()));

        vm.stopBroadcast();

        // 返回代理地址（用户应该与代理交互，而不是直接与实现合约交互）
        return address(proxy);
    }
}
