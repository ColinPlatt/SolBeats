// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/SolBeats.sol";
import {MetadataRender} from "src/MetadataRenderer.sol";
import {BEAT} from "src/BEAT.sol";

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
//forge verify-contract 0xc4e5236b0476c9086f0bfe297ea58863c6fb1525 src/MetadataRenderer.sol:MetadataRender --chain-id 421613 --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --watch



contract mintFirst_Script is Script {

    SolBeats public nft = SolBeats(0x4a55CBAc33cfF6149510D498E2B1D314678688e7);


    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PK");
        vm.startBroadcast(deployerPrivateKey);
            bytes memory byteCode = type(BEAT).creationCode;
            nft.mint{value: 0.0025 ether}(byteCode, 't*(2-(uint(1&-int(t))>>11))*(5+(2&t>>14))>>(3&t>>8)|t>>2) 30s');
        vm.stopBroadcast();
    }

}

//forge script script/solBeats.s.sol:mintFirst_Script --rpc-url $RPC_URL --broadcast --slow -vvvv
//