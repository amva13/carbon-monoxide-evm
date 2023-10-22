// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

/**
@title Diatomic Molecular Dynamics
@author Alejandro Velez Arce | GH: @amva13 | <amva13@alum.mit.edu>
@notice Molecular Dynamics simulation smnart contract adapted from the paper by <a href="https://onlinelibrary.wiley.com/doi/full/10.1002/qua.27035 />
@dev features extensibility, refactoring, and security improvements for building more powerful applications
 */

import "./SafeMathQuad.sol";

contract DiatomicMD {

  using SafeMathQuad for uint256;


  // Output object.
  struct DiatomicMDOutput {
      uint256 runNum;
      int256[] outputData;
  }

  // Current run counter.
  uint256 public runCount;

  // Stored simulation output data.
  mapping (uint256 => int256[]) simulationOutput;

  // Input Variables
  uint256 Re;
  uint256 R1;
  uint256 R2;
  uint256 K;
  uint256 M1;
  uint256 M2;
  uint256 dT;
  uint256 v1;
  uint256 v2;

  // Pre-Calculated Variables
  uint256 dTdTbyM1x2;
  uint256 dTdTbyM2x2;
  uint256 dTbyM1x2;
  uint256 dTbyM2x2;

  // Process Variables
  uint256 r;
  uint256 rMag;
  uint256 f;
  uint256 fNew;

  constructor(uint256 eqBondLen, uint256 initBondLen, uint256 forceConst, uint256 atomOne, uint256 atomTwo, uint256 timestep) {

  }

}
