// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

import "./ABDKMathQuad.sol";

library SafeMathQuad {

  using ABDKMathQuad for bytes16;

  uint constant public _DEFAULT_PRECISION = 0;
  uint constant public _PRECISION = _DEFAULT_PRECISION;

  function toInt(bytes16 num) public pure returns (int256 result) {
    // require(false, "called toInt");
    return ABDKMathQuad.toInt(num);
  }

  function toUint(bytes16 num) public pure returns (uint256 result) {
    return ABDKMathQuad.toUInt(num);
  }

  function getUintValueBytes(uint256 val, uint precision) public pure returns (bytes16 valBytes) {

      bytes16 byteVal = ABDKMathQuad.fromUInt(val);
      if (precision > 0) {
          bytes16 bytePrec = ABDKMathQuad.fromUInt(10**precision);
          byteVal = byteVal.div(bytePrec);
      }
      return byteVal;
  }

  function getIntValueBytes(int256 val, uint precision) public pure returns (bytes16 valBytes) {
    bytes16 byteVal = ABDKMathQuad.fromInt(val);
    if (precision > 0) {
        int p = 10;
        for(uint i=0; i < precision; i++){
          p*=10;
        }
        bytes16 bytePrec = ABDKMathQuad.fromInt(p);
        byteVal = byteVal.div(bytePrec);
    }
      return byteVal;
  }

  function convertUintValuesToBytes(uint256[] memory vals, uint precision) public pure returns (bytes16[] memory res) {
    require(vals.length > 0, 'SafeMathQuad: convertValuesToBytes - array length must be greater than 0');
    bytes16[] memory out = new bytes16[](vals.length);
    for (uint i=0; i<vals.length; i++) {
      out[i] = getUintValueBytes(vals[i], precision);
    }
    return out;
  }

  function convertIntValuesToBytes(int256[] memory vals, uint precision) public pure returns (bytes16[] memory res) {
    require(vals.length > 0, 'SafeMathQuad: convertValuesToBytes - array length must be greater than 0');
    bytes16[] memory out = new bytes16[](vals.length);
    for (uint i=0; i<vals.length; i++) {
      out[i] = getIntValueBytes(vals[i], precision);
    }
    return out;
  }

  function getPrecision() public view returns(uint precision) {
    return _PRECISION;
  }

  function div(uint256 numerator, uint256 denominator) public view returns (uint256 result) {
    require(denominator != 0, 'SafeMathQuad: DIVISION BY ZERO');
    uint precision = getPrecision();
    bytes16 num = getUintValueBytes(numerator, precision);
    bytes16 denom = getUintValueBytes(denominator,precision);
    return toUint(num.div(denom));
  }

  function div(int256 numerator, int256 denominator) public view returns (int256 result) {
    require(denominator != 0, 'SafeMathQuad: DIVISION BY ZERO');
    uint precision = getPrecision();
    bytes16 num = getIntValueBytes(numerator, precision);
    bytes16 denom = getIntValueBytes(denominator,precision);
    return toInt(num.div(denom));
  }


function div(uint256 numerator, int256 denominator) public view returns (int256 result) {
    require(denominator != 0, 'SafeMathQuad: DIVISION BY ZERO');
    uint precision = getPrecision();
    bytes16 num = getUintValueBytes(numerator, precision);
    bytes16 denom = getIntValueBytes(denominator,precision);
    return toInt(num.div(denom));
  }

  function div(int256 numerator, uint256 denominator) public view returns (int256 result) {
    require(denominator != 0, 'SafeMathQuad: DIVISION BY ZERO');
    uint precision = getPrecision();
    bytes16 num = getIntValueBytes(numerator, precision);
    bytes16 denom = getUintValueBytes(denominator,precision);
    return toInt(num.div(denom));
  }

  function mul(uint256 arg1, uint256 arg2) public view returns (uint256 result) {
    uint precision = getPrecision();
    bytes16 a = getUintValueBytes(arg1, precision);
    bytes16 b = getUintValueBytes(arg2, precision);
    return toUint(a.mul(b));
  }

  function mul(int256 arg1, int256 arg2) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 a = getIntValueBytes(arg1, precision);
    bytes16 b = getIntValueBytes(arg2, precision);
    return toInt(a.mul(b));
  }

  function mul(uint256 arg1, int256 arg2) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 a = getUintValueBytes(arg1, precision);
    bytes16 b = getIntValueBytes(arg2, precision);
    return toInt(a.mul(b));
  }

  function mul(int256 arg1, uint256 arg2) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 a = getIntValueBytes(arg1, precision);
    bytes16 b = getUintValueBytes(arg2, precision);
    return toInt(a.mul(b));
  }

  function add(uint256 arg1, uint256 arg2) public view returns (uint256 result) {
    uint precision = getPrecision();
    bytes16 a = getUintValueBytes(arg1, precision);
    bytes16 b = getUintValueBytes(arg2, precision);
    return toUint(a.add(b));
  }

  function add(int256 arg1, int256 arg2) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 a = getIntValueBytes(arg1, precision);
    bytes16 b = getIntValueBytes(arg2, precision);
    return toInt(a.add(b));
  }

  function sub(uint256 arg1, uint256 arg2) public view returns (uint256 result) {
    uint precision = getPrecision();
    bytes16 a = getUintValueBytes(arg1, precision);
    bytes16 b = getUintValueBytes(arg2, precision);
    return toUint(a.sub(b));
  }

  function sub(int256 arg1, int256 arg2) public view returns (int256 result) {
    // require(false, "called sub int");
    uint precision = getPrecision();
    // require(false,"got precision");
    bytes16 a = getIntValueBytes(arg1, precision);
    bytes16 b = getIntValueBytes(arg2, precision);
    // require(false,"converted");
    bytes16 res = a.sub(b);
    // require(false, "subtracted");
    result = toInt(res);
    // require(false, "converted to int");
  }

  function sub(uint256 arg1, int256 arg2) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 a = getUintValueBytes(arg1, precision);
    bytes16 b = getIntValueBytes(arg2, precision);
    return toInt(a.sub(b));
  }

  function abs(int256 x) public view returns (uint256 result) {
    uint precision = getPrecision();
    bytes16 val = getIntValueBytes(x, precision);
    return toUint(ABDKMathQuad.abs(val));
  }

  function neg(uint256 x) public view returns (int256 result) {
    uint precision = getPrecision();
    bytes16 val = getUintValueBytes(x, precision);
    bytes16 n1 = getIntValueBytes(-1, precision);
    bytes16 resBytes = val.mul(n1);
    return toInt(resBytes);
  }

}
