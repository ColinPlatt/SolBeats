// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/BEAT.sol";
import {SolBeats} from "src/SolBeats.sol";

import {MetadataRender, ISolBeats} from "src/MetadataRenderer.sol";

import {mintingUI} from "src/mintingUI.sol";

contract BEATTest is Test {
    BEAT public beat;
    MetadataRender public renderer;
    SolBeats public nft;
    mintingUI public ui;

    string RPC = vm.envString("RPC_URL");
    uint256 fork;

    function setUp() public {
        beat = new BEAT();
        renderer = new MetadataRender();
        nft = new SolBeats();
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

    function testUri() public {
        nft.setMetadataRenderer(address(renderer));

        vm.startPrank(address(0xBEEF));
        vm.deal(address(0xBEEF), 0.0025 ether);

        bytes memory byteCode = type(BEAT).creationCode;
        nft.mint{value: 0.0025 ether}(byteCode, 't*(2-(uint(1&-int(t))>>11))*(5+(2&t>>14))>>(3&t>>8)|t>>2) unchecked');

        string memory uri = nft.tokenURI(1);
        emit log_string(uri);

        vm.stopPrank();
    }

    function testUI() public {
        fork = vm.createSelectFork(RPC);

            ui = new mintingUI(0x4a55CBAc33cfF6149510D498E2B1D314678688e7);

            emit log_address(address(ui.FS_FRONTEND()));

            string memory oUI = ui.getUI();


            vm.writeFile("test/output/ui.txt", oUI);

    }

}
