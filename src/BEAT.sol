// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

contract BEAT {

    uint32 public constant OFFSET = 0;
    uint32 public constant SAMPLE_RATE = 8000;
    uint32 public constant LENGTH = SAMPLE_RATE * 30;

    function getBeat() external pure returns (bytes memory, uint32) {
    
        bytes memory buffer = new bytes(LENGTH);

        for(uint256 t = OFFSET; t<LENGTH+OFFSET; ++t) {
            buffer[t-OFFSET] = bytes1(uint8(t*(2-(uint(1&-int(t))>>11))*(5+(2&t>>14))>>(3&t>>8)|t>>2));
        }

        return (buffer, SAMPLE_RATE);
    }

}