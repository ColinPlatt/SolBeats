// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/BEAT.sol";

contract BEATTest is Test {
    BEAT public beat;

    function setUp() public {
        beat = new BEAT();

    }

    function testOutput() public {
        (bytes memory buff, uint32 speed) = beat.getBeat();

        string memory json = vm.serializeBytes("test", "data", buff);
        vm.writeJson(json, "test/output/example.json");

        string memory file;
    }

}
