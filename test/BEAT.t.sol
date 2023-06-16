// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/BEAT.sol";

import {MetadataRender, ISolBeats} from "src/MetadataRenderer.sol";

contract BEATTest is Test {
    BEAT public beat;
    MetadataRender public renderer;

    function setUp() public {
        beat = new BEAT();
        renderer = new MetadataRender();
    }

    function testOutput() public {
        (bytes memory buff, uint32 speed) = beat.getBeat();

        string memory oJson = vm.serializeBytes("test", "data", buff);
        vm.writeJson(oJson, "test/output/example.json");

        string memory file;
    }

    function testRender() public {

        ISolBeats.beatInfo memory info = ISolBeats.beatInfo(
            address(this),
            address(beat),
            't>>(t%16==0?4:6)|t>>(t%128==0?10:4)'
        );

        string memory uri = renderer.renderURI(1, info);

        emit log_string(uri);

        vm.writeFile("test/output/render.txt", uri);

    }

}
