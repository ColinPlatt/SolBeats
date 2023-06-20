// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/SolBeats.sol";
import {MetadataRender} from "src/MetadataRenderer.sol";
import {BEAT} from "src/BEAT.sol";
import {mintingUI} from "src/mintingUI.sol";

contract baseNFT_Script is Script {
    SolBeats public nft; //0x4a55cbac33cff6149510d498e2b1d314678688e7

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);
            nft = new SolBeats();
        vm.stopBroadcast();
    }
}

//forge script script/solBeats.s.sol:baseNFT_Script --rpc-url $RPC_URL --broadcast --slow --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
//forge verify-contract 0x4a55CBAc33cfF6149510D498E2B1D314678688e7 src/SolBeats.sol:SolBeats --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --watch


contract metadataRender_Script is Script {
    SolBeats public nft = SolBeats(0x4a55CBAc33cfF6149510D498E2B1D314678688e7);
    MetadataRender public renderer;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);
            renderer = new MetadataRender();
            nft.setMetadataRenderer(address(renderer));
        vm.stopBroadcast();
    }
}

//forge script script/solBeats.s.sol:metadataRender_Script --rpc-url $RPC_URL --broadcast --slow --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
//forge verify-contract 0x7aE647354320828aD4042DF44c52B3195087FF5F src/MetadataRenderer.sol:MetadataRender --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --watch



contract mintFirst_Script is Script {

    SolBeats public nft = SolBeats(0x4a55CBAc33cfF6149510D498E2B1D314678688e7);


    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);
            bytes memory byteCode = type(BEAT).creationCode;
            nft.mint{value: 0.0025 ether}(byteCode, 't*(2-(uint(1&-int(t))>>11))*(5+(2&t>>14))>>(3&t>>8)|t>>2) unchecked');
        vm.stopBroadcast();
    }

}

contract addUI_Script is Script {

    address public nft = 0x4a55CBAc33cfF6149510D498E2B1D314678688e7;


    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);
            mintingUI ui = new mintingUI(nft);
            SolBeats(nft).setUI(address(ui));
        vm.stopBroadcast();
    }

}

//forge script script/solBeats.s.sol:addUI_Script --rpc-url $RPC_URL --broadcast --slow -vvvv


//forge verify-contract 0xec2a007bc44ee155ee78658ccbdea6cc76d0370d src/mintingUI.sol:mintingUI --constructor-args $(cast abi-encode "constructor(address)" 0x4a55CBAc33cfF6149510D498E2B1D314678688e7) --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --watch