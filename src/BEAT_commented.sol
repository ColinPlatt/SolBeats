// SPDX-License-Identifier: The Unlicense
pragma solidity ^0.8.19;

contract BEAT {

    uint32 public constant OFFSET = 0;
    uint32 public constant SAMPLE_RATE = 8000;
    uint32 public constant LENGTH = SAMPLE_RATE * 1;

    function getBeat() external pure returns (bytes memory, uint32) {
    
        bytes memory buffer = new bytes(LENGTH);

        //[vars_init]

        for(uint256 t = OFFSET; t<LENGTH+OFFSET; ++t) {
            //[vars_pre]
            //[code_pre]
            buffer[t-OFFSET] = bytes1(uint8(t>>(t%16==0?4:6)|t>>(t%128==0?10:4)));
            //[vars_post]
            //[code_post]
        }

        return (buffer, SAMPLE_RATE);
    }

}