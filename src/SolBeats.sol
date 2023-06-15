// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

import "lib/solmate/src/tokens/ERC721.sol";
import {Ownable, Base64, LibString, CREATE3} from "lib/solady/src/Milady.sol";

interface IBEAT {
    function getBeat() external view returns (bytes memory);
}

contract SolBeats is ERC721('SolBeats', unicode'🎚️'), Ownable {

    uint256 public constant MINT_COST = 0.001 ether;

    uint256 public totalSupply = 1;

    mapping(uint256 => string) public beatStrings;
    mapping(bytes32 => bool) public beatMinted;

    constructor() public {
        _initializeOwner(msg.sender);
        _mint(msg.sender, 0);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "S";
    }

    function mint(bytes calldata bytecode, string calldata beatString) public payable {
        require(msg.value == MINT_COST, "SolBeats: Mint cost is 0.001 ether");

        bytes32 beatHash = keccak256(abi.encodePacked(bytecode));
        require(!beatHash, "SolBeats: Beat already minted");
        beatMinted[beatHash] = true;

        uint256 tokenId = totalSupply;
        totalSupply++;
        CREATE3.deploy(bytes32(tokenId), bytecode, 0);
        beatStrings[tokenId] = beatString;
        _mint(msg.sender, tokenId);
    }

}