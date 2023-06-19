// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

contract BEAT {

    uint32 public constant OFFSET = 0;
    uint32 public constant SAMPLE_RATE = 8000;
    uint32 public constant LENGTH = SAMPLE_RATE * 30;

    function getBeat() external pure returns (bytes memory, uint32) {
    
        bytes memory buffer = new bytes(LENGTH);

        unchecked{
            for(uint256 t = OFFSET; t<LENGTH+OFFSET; ++t) {
                buffer[t-OFFSET] = bytes1(uint8(t>>(t%32==0?4:3)|(t%128==0?t>>3:t>>3|t>>9)));
            }
        }

        return (buffer, SAMPLE_RATE);
    }

}