// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

import "lib/solmate/src/tokens/ERC721.sol";
import {Ownable, Base64, LibString, CREATE3} from "lib/solady/src/Milady.sol";

interface ISolBeats {
    struct beatInfo {
        address minter;
        address beatPointer;
        string beatString;
    }
}

interface IBeat {
    function getBeat() external view returns (bytes memory buffer, uint32 sampleRate);
}

interface UI {
    function getUI() external view returns (string memory);
}

interface IMetadataRender {
    function renderURI(uint256 id, ISolBeats.beatInfo memory info) external view returns (string memory);
}

contract SolBeats is ISolBeats, ERC721('SolBeats', unicode'{🎚️();}'), Ownable {

    uint256 public constant MINT_COST = 0.0025 ether;

    uint256 public totalSupply = 1; //we have to set this to 1 because the constructor mints the UI token
    UI public ui;
    IMetadataRender public metadataRenderer;

    mapping(uint256 => beatInfo) public beats;
    mapping(bytes32 => bool) public beatMinted;

    error UI_NOT_SET(); 
    error ERC721_METADATA_URI_QUERY_FOR_NONEXISTENT_TOKEN(uint256 id);
    error BEAT_ALREADY_MINTED();
    error INCORRECT_MINT_COST();
    error NOT_OWNER();

    constructor() {
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
                return metadataRenderer.renderURI(id, beats[id]);
            }
        }
    }

    function mint(bytes calldata bytecode, string calldata beatString) public payable {
        if(msg.value != MINT_COST) revert INCORRECT_MINT_COST();

        bytes32 beatHash = keccak256(abi.encodePacked(beatString));
        if(beatMinted[beatHash]) revert BEAT_ALREADY_MINTED();
        beatMinted[beatHash] = true;

        uint256 id = totalSupply;
        totalSupply++;
        // we use the bytecode itself as the salt to prevent collisions
        address pointer = CREATE3.deploy(bytes32(keccak256(bytecode)), bytecode, 0);
        beats[id] = beatInfo(msg.sender, pointer, beatString);
        _mint(msg.sender, id);
    }

    // if a user wants to change the offset or length on the same beat, they need to burn their existing token and mint a new one
    function burn(uint256 id) public {
        if(ownerOf(id) != msg.sender) revert NOT_OWNER();
        _burn(id);

        beatMinted[keccak256(abi.encodePacked(beats[id].beatString))] = false;
        beats[id] = beatInfo(address(0), address(0), "");
    }

    function setUI(address _newUI) public onlyOwner {
        ui = UI(_newUI);
    }

    function setMetadataRenderer(address _newMetadataRenderer) public onlyOwner {
        metadataRenderer = IMetadataRender(_newMetadataRenderer);
    }

    function withdraw(uint256 amount) external onlyOwner{
        bool success;
        address to = owner();

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

}