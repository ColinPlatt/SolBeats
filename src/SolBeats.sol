// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

import "lib/solmate/src/tokens/ERC721.sol";
import {Ownable, Base64, LibString, CREATE3} from "lib/solady/src/Milady.sol";

interface IBEAT {
    function getBeat() external view returns (bytes memory);
}

interface UI {
    function getUI() external view returns (string memory);
}

contract SolBeats is ERC721('SolBeats', unicode'🎚️'), Ownable {

    uint256 public constant MINT_COST = 0.001 ether;

    uint256 public totalSupply = 1;
    UI public ui;

    mapping(uint256 => string) public beatStrings;
    mapping(bytes32 => bool) public beatMinted;

    error UI_NOT_SET(); 
    error ERC721_METADATA_URI_QUERY_FOR_NONEXISTENT_TOKEN(uint256 id);

    constructor() public {
        _initializeOwner(msg.sender);
        _mint(msg.sender, 0);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if(id == 0) {
            if(address(ui) != address(0)) {
                return ui.getUI();
            } else {
                revert UI_NOT_SET();
            }
        } else {
            if(ownerOf(id) == address(0)) {
                revert ERC721_METADATA_URI_QUERY_FOR_NONEXISTENT_TOKEN(id);
            } else  {
                (bytes memory buffer, uint32 sampleRate) = IBEAT(CREATE3.getDeployed(bytes32(id))).getBeat();
                return WAV_8BIT.encodeWAV(buffer, sampleRate);
            }
        }
    }

    function mint(bytes calldata bytecode, string calldata beatString) public payable {
        require(msg.value == MINT_COST, "SolBeats: Mint cost is 0.001 ether");

        bytes32 beatHash = keccak256(abi.encodePacked(beatString));
        require(!beatHash, "SolBeats: Beat already minted");
        beatMinted[beatHash] = true;

        uint256 tokenId = totalSupply;
        totalSupply++;
        CREATE3.deploy(bytes32(tokenId), bytecode, 0);
        beatStrings[tokenId] = beatString;
        _mint(msg.sender, tokenId);
    }

    // if a user wants to change the offset or length on the same beat, they need to burn their existing token and mint a new one
    function burn(uint256 id) public {
        require(ownerOf(tokenId) == msg.sender, "SolBeats: Only owner can burn");
        _burn(tokenId);

        beatMinted[keccak256(abi.encodePacked(beatStrings[tokenId]))] = false;
        beatStrings[tokenId] = "";
    }

    function setUI(address _newUI) public onlyOwner {
        ui = UI(_newUI);
    }

}