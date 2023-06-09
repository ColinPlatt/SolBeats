// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

import "lib/solmate/src/tokens/ERC721.sol";
import {Ownable, Base64, LibString} from "lib/solady/src/Milady.sol";
import {CREATE2} from "./utils/CREATE2.sol";

interface IBEAT {
    function getBeat() external view returns (bytes memory);
}

contract SolBeats is ERC721('SolBeats', unicode'🎚️'), Ownable {

    uint256 public constant MINT_COST = 0.001 ether;

    uint256 public totalSupply = 1;

    mapping(uint256 => string) public beatStrings;

    constructor() public {
        _initializeOwner(msg.sender);
        _mint(msg.sender, 0);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "S";
    }

    function mint(address to, bytes calldata bytecode, string calldata beatString) public payable {
        require(msg.value == MINT_COST, "SolBeats: Mint cost is 0.001 ether");
        uint256 tokenId = totalSupply;
        totalSupply++;
        CREATE2.deploy(tokenId, bytecode);
        beatStrings[tokenId] = beatString;
        _mint(to, tokenId);
    }

}