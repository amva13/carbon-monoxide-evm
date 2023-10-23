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
  using SafeMathQuad for int256;
  using SafeMathQuad for bytes16;


  // Output object.
  struct DiatomicMDOutput {
      uint256 runNum;
      uint256[] outputData;
  }

  // Current run counter.
  uint256 public runCount;

  // Stored simulation output data.
  mapping (uint256 => uint256[]) simulationOutput;

  // Input Variables
  int256 Re;
  int256 R1;
  int256 R2;
  uint256 K;
  uint256 M1;
  uint256 M2;
  uint256 dT;
  int256 v1;
  int256 v2;

  // Pre-Calculated Variables
  uint256 dTdTbyM1x2;
  uint256 dTdTbyM2x2;
  uint256 dTbyM1x2;
  uint256 dTbyM2x2;

  // Process Variables
  int256 r;
  uint256 rMag;
  int256 f;
  int256 fNew;

  // initial vals
  int256 Re_0;
  int256 R1_0;
  int256 R2_0;
  uint256 K_0;
  uint256 M1_0;
  uint256 M2_0;
  uint256 dT_0;
  int256 v1_0;
  int256 v2_0;
  uint256 dTdTbyM1x2_0;
  uint256 dTdTbyM2x2_0;
  uint256 dTbyM1x2_0;
  uint256 dTbyM2x2_0;
  int256 r_0;
  uint256 rMag_0;
  int256 f_0;
  int256 fNew_0;

  // constants
  uint256 private constant two = 2;

  constructor() {
    bytes16 eqBondLen = SafeMathQuad.getUintValueBytes(21316,4);
    bytes16 initBondLen = SafeMathQuad.getUintValueBytes(226767135,8);
    bytes16 forceConst = SafeMathQuad.getUintValueBytes(11915,4);
    bytes16 atomOne = SafeMathQuad.getUintValueBytes(21875, 0);
    bytes16 atomTwo = SafeMathQuad.getUintValueBytes(291569457, 4);
    bytes16 timestep = SafeMathQuad.getUintValueBytes(413, 2);
    defaultValues(SafeMathQuad.toInt(eqBondLen), SafeMathQuad.toInt(initBondLen), SafeMathQuad.toUint(forceConst), 
    SafeMathQuad.toUint(atomOne), SafeMathQuad.toUint(atomTwo), SafeMathQuad.toUint(timestep));
  }

  /// @param eqBondLen Equilibrium bond length in a_0.
  /// @param initBondLen Initial bond length in a_0.
  /// @param forceConst Force constant in Eh/a_0^2.
  /// @param atomOne Mass of atom one in m_e. 
  /// @param atomTwo Mass of atom two in m_e.
  /// @param timestep Time step in hbar/E_h.
  function defaultValues(int256 eqBondLen, int256 initBondLen, uint256 forceConst, uint256 atomOne, uint256 atomTwo, uint256 timestep) internal {
    
      Re = eqBondLen;
      Re_0 = Re;
      R1 = initBondLen;
      R1_0 = R1;
      K = forceConst;
      K_0 = K;
      M1 = atomOne;
      M1_0 = M1;
      M2 = atomTwo;
      M2_0 = M2;
      dT = timestep;
      dT_0 = dT;


      // Pre-calculate all variables that can be.
      dTdTbyM1x2 = dT.mul(dT).div(M1.mul(two)); // ((dT*dT)/(M1*2))
      dTdTbyM2x2 = dT.mul(dT).div(M2.mul(two)); // ((dT*dT)/(M2*2))
      dTbyM1x2 = dT.div(M1.mul(two)); // (dT/(M1*2))
      dTbyM2x2 = dT.div(M1.mul(two)); // (dT/(M2*2))


  }

  function reset() internal {
    // Reset the state of this contract to its original values, as if it was just deployed and initialized.
    Re = Re_0;
    R1 = R1_0;
    R2 = R2_0;
    K = K_0;
    M1 = M1_0;
    M2 = M2_0;
    dT = dT_0;
    v1 = v1_0;
    v2 = v2_0;
    dTdTbyM1x2 = dTdTbyM1x2_0;
    dTdTbyM2x2 = dTdTbyM2x2_0;
    dTbyM1x2 = dTbyM1x2_0;
    dTbyM2x2 = dTbyM2x2_0;
    r = r_0;
    rMag = rMag_0;
    f = f_0;
    fNew = fNew_0; 
  }

  /// @notice Initializes a molecular dynamics trajectory
  /// @param steps Number of steps in time in units of 0.1 femtosecond.
  /// @param precision Number of decimal places to include in output.
  function runMd(uint256 steps, uint precision) public returns (DiatomicMDOutput memory) {
      reset();

      uint256 multiplier = 10**precision;
      uint256[] memory results = new uint256[](steps);
      for (uint t=0; t<steps; t++) {
        r = R1.sub(R2);
        rMag = SafeMathQuad.abs(r);
        int256 nK = SafeMathQuad.neg(K);
        f = nK.mul(rMag.sub(Re)).mul(r).div(rMag);
        R1 = R1.add(dT.mul(v1)).add(dTdTbyM1x2.mul(f));
        R2 = R2.add(dT.mul(v2)).sub(dTdTbyM2x2.mul(f));
        r = R1.sub(R2);
        rMag = SafeMathQuad.abs(r);
        fNew = nK.mul(rMag.sub(Re)).mul(r).div(rMag);
        v1 = v1.add(dTbyM1x2.mul(fNew.add(f)));
        v2 = v2.sub(dTbyM2x2.mul(fNew.add(f)));
        results[t] = rMag.mul(multiplier);
      }
      runCount++;
      simulationOutput[runCount] = results;
      DiatomicMDOutput memory newOutput = DiatomicMDOutput(runCount, results);
      return newOutput;
    }

    // @notice Retrieves the results of a previous run.
    /// @param runNum The number of the run to retrieve results for.
    function getSimOutput(uint256 runNum) public view returns (DiatomicMDOutput memory output) {
      require(runNum > 0, "runNum must be greater than 0");
      require(runNum <= runCount, "No such run exists.");
      output = DiatomicMDOutput(runCount,simulationOutput[runNum]);
      return output;
    }

}
