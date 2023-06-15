pragma solidity ^0.8.19;
contract BEAT_TEST {
    uint32 public constant OFFSET = 0;
    uint32 public constant SAMPLE_RATE = 8000;
    uint32 public constant LENGTH = SAMPLE_RATE;
    function getBeat() external pure returns (string memory) {
        bytes memory buffer = new bytes(LENGTH);
        for(uint256 t = OFFSET; t<LENGTH+OFFSET; ++t) {
            buffer[t-OFFSET] = bytes1(uint8(t>>(t%16==0?4:6)|t>>(t%128==0?10:4)));
        }
        return WAV_8BIT.encodeWAV(buffer, SAMPLE_RATE);
    }
}
library WAV_8BIT {
    bytes4 constant RIFF_HDR = hex'52494646';
    bytes16 constant WAV_FMT_HDR = hex'57415645666d74201000000001000100';  
    function reverse(uint32 input) internal pure returns (uint32 v) {
        v = input;
        v = ((v & 0xFF00FF00) >> 8) |
            ((v & 0x00FF00FF) << 8);
        v = (v >> 16) | (v << 16);
    }
    function fmtByteRate(uint32 sampleRate) internal pure returns (bytes12) {
        bytes4 lsbSampleRate = bytes4(reverse(sampleRate));
        return bytes12(
            bytes.concat(
                lsbSampleRate,
                lsbSampleRate,
                hex'01000800'
            )
        );
    }
    function formatDataChunk(bytes memory audioData) internal pure returns (bytes memory) {
        return bytes.concat(
            bytes4('data'),
            bytes4(reverse(uint32(audioData.length))),
            audioData
        );
    }
    function encodeWAV(bytes memory _audioData, uint32 _sampleRate) internal pure returns (string memory) {
        uint32 audioSize = uint32(_audioData.length);
        return string.concat(
            'data:audio/wav;base64,',
            Base64.encode(
                bytes.concat(
                    RIFF_HDR,
                    bytes4(reverse(audioSize+12)),
                    WAV_FMT_HDR,
                    bytes12(fmtByteRate(_sampleRate)),
                    formatDataChunk(_audioData)
                )
            )
        );
    } 
}
library Base64 {
    function encode(bytes memory data)
        internal
        pure
        returns (string memory result)
    {
        bool fileSafe = false;
        bool noPadding = false; 
        assembly {
            let dataLength := mload(data)
            if dataLength {
                let encodedLength := shl(2, div(add(dataLength, 2), 3))
                result := mload(0x40)
                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                mstore(0x3f, sub("ghijklmnopqrstuvwxyz0123456789-_", mul(iszero(fileSafe), 0x0230)))
                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)
                for {} 1 {} {
                    data := add(data, 3)
                    let input := mload(data)
                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))
                    ptr := add(ptr, 4)
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20))
                let o := div(2, mod(dataLength, 3))
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                o := mul(iszero(iszero(noPadding)), o)
                mstore(sub(ptr, o), 0)
                mstore(result, sub(encodedLength, o))
            }
        }
    }
}