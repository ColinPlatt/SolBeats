// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Base64, LibString} from "lib/solady/src/Milady.sol";
import {WAV_8BIT} from "lib/libAudio/src/libWAV.sol";
import {json} from "./utils/JSON.sol";


interface IBEAT {
    function getBeat() external view returns (bytes memory buffer, uint32 sampleRate);
}

interface ISolBeats {
    struct beatInfo {
        address minter;
        address beatPointer;
        string beatString;
    }

    function metadataRenderer(uint256 id) external view returns (ISolBeats.beatInfo memory);
}

interface IMetadataRender {
    function renderURI(uint256 id, ISolBeats.beatInfo memory info) external view returns (string memory);
}

string constant HEADER = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="310" height="500" viewBox="0 0 310 500"><defs><clipPath id="clipBox"><rect x="15" y="200" width="280" rx="25" ry="25" height="285"/></clipPath><style>.base{fill:#0f0;font-family:Monospace}.title{font-size:20px}.subtitle{font-size:14px}.text{font-size:12px}</style></defs>';

contract MetadataRender is IMetadataRender { 

    constructor() {}

    function getText(address _minter, string memory _beatString) internal pure returns (string memory) {
        return string.concat(
            '<rect x="0" y="0" rx="25" ry="25" width="100%" height="100%" fill="black"/><text x="10" y="40" fill="#00ff00" class="base title">{solBeat();}</text><text x="10" y="80" fill="#00ff00" class="base subtitle">Mixed by:</text><text x="10" y="100" fill="#00ff00" class="base text">',
            LibString.toHexStringChecksummed(_minter),
            '</text><text x="10" y="130" fill="#00ff00" class="base subtitle">Beat:</text><text x="10" y="150" fill="#00ff00" class="base text">',
            _beatString,
            '</text>'
        );
    }

    function getGraph(address _pointer) internal view returns (string memory) {

        (bytes memory buffer, ) = IBEAT(_pointer).getBeat();

        uint len = buffer.length < 800 ? buffer.length : 800;

        uint multiplier = buffer.length / len;

        string memory points;

        unchecked {
            for(uint i = 0; i<len; ++i) {
                points = string.concat(points, LibString.toString(15+i), ',', LibString.toString(220+uint256(uint8(buffer[i*multiplier]))), ' ');
            }
        } 

        return string.concat(
            '<rect x="15" y="200" width="280" rx="25" ry="25"  height="285" fill="gray"/><g clip-path="url(#clipBox)"><polyline points="',
            points,
            '" stroke="#00ff00" stroke-width="1" fill="none"><animateTransform attributeName="transform" attributeType="XML" type="translate" from="0" to="-',
            LibString.toString(len),
            '" dur="3s" fill="remove" repeatCount="indefinite"/></polyline></g>'
        );
    }

    function renderSVG(ISolBeats.beatInfo memory info) public view returns (string memory) {

        return string.concat(
            HEADER, 
            getText(info.minter, info.beatString),
            //getGraph(info.beatPointer),
            '</svg>'
        );
    }

    function generateWAV(address pointer) public view returns (string memory) {

        (bytes memory buffer, uint32 sampleRate) = IBEAT(pointer).getBeat();

        return WAV_8BIT.encodeWAV(buffer, sampleRate);
    }

    function renderURI(uint256 id, ISolBeats.beatInfo memory info) external view returns (string memory) {

        return json.formattedMetadata(string.concat('solBeat #', LibString.toString(id)), "solBeats are an experiment in making fully onchain music.", generateWAV(info.beatPointer), renderSVG(info));

    }

}