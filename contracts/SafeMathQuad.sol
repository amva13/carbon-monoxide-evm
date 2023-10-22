// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

import "./ABDKMathQuad.sol";

library SafeMathQuad {

  using ABDKMathQuad for bytes16;

  uint constant public _DEFAULT_PRECISION = 0;
  uint constant public _PRECISION = _DEFAULT_PRECISION;

  function getValueBytes(uint256 val, uint precision) public pure returns (bytes16 valBytes) {

      bytes16 byteVal = ABDKMathQuad.fromUInt(val);
      if (precision > 0) {
          bytes16 bytePrec = ABDKMathQuad.fromUInt(10**precision);
          byteVal = byteVal.div(bytePrec);
      }
      return byteVal;
  }

  function convertValuesToBytes(uint256[] memory vals, uint precision) public pure returns (bytes16[] memory res) {
    require(vals.length > 0, 'SafeMathQuad: convertValuesToBytes - array length must be greater than 0');
    bytes16[] memory out = new bytes16[](vals.length);
    for (uint i=0; i<vals.length; i++) {
      out[i] = getValueBytes(vals[i], precision);
    }
    return out;
  }

  function getPrecision() public view returns(uint precision) {
    return _PRECISION;
  }

  function div(uint256 numerator, uint256 denominator) public view returns (bytes16 result) {
    require(denominator != 0, 'SafeMathQuad: DIVISION BY ZERO');
    uint precision = getPrecision();
    bytes16 num = getValueBytes(numerator, precision);
    bytes16 denom = getValueBytes(denominator,precision);
    return num.div(denom);
  }

  function mul(uint256 arg1, uint256 arg2) public view returns (bytes16 result) {
    uint precision = getPrecision();
    bytes16 a = getValueBytes(arg1, precision);
    bytes16 b = getValueBytes(arg2, precision);
    return a.mul(b);
  }

  function add(uint256 arg1, uint256 arg2) public view returns (bytes16 result) {
    uint precision = getPrecision();
    bytes16 a = getValueBytes(arg1, precision);
    bytes16 b = getValueBytes(arg2, precision);
    return a.add(b);
  }

  function sub(uint256 arg1, uint256 arg2) public view returns (bytes16 result) {
    uint precision = getPrecision();
    bytes16 a = getValueBytes(arg1, precision);
    bytes16 b = getValueBytes(arg2, precision);
    return a.sub(b);
  }

}
