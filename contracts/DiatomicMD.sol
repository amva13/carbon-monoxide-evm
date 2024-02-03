// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

/**
@title Diatomic Molecular Dynamics
@author Alejandro Velez Arce | GH: @amva13 | <amva13@alum.mit.edu>
@notice Molecular Dynamics simulation smnart contract adapted from the paper by <a href="https://onlinelibrary.wiley.com/doi/full/10.1002/qua.27035 />
@dev features extensibility, refactoring, and security improvements for building more powerful applications
 */

import "./SafeMathQuad.sol";
import "./ABDKMathQuad.sol";

contract DiatomicMD {

  using ABDKMathQuad for bytes16;


  // for mocking only
  int256[] private mockResults;


  // Output object.
  struct DiatomicMDOutput {
      uint256 runNum;
      uint256[] outputData;
  }

  // Current run counter.
  uint256 private runCount;

  // Stored simulation output data.
  mapping (uint256 => uint256[]) private simulationOutput;

  // Input Variables
  bytes16 Re;
  bytes16 R1;
  bytes16 R2;
  bytes16 K;
  bytes16 M1;
  bytes16 M2;
  bytes16 dT;
  bytes16 v1;
  bytes16 v2;

  // Pre-Calculated Variables
  bytes16 dTdTbyM1x2;
  bytes16 dTdTbyM2x2;
  bytes16 dTbyM1x2;
  bytes16 dTbyM2x2;

  // Process Variables
  bytes16 r;
  bytes16 rMag;
  bytes16 f;
  bytes16 fNew;

  // initial vals
  bytes16 Re_0;
  bytes16 R1_0;
  bytes16 R2_0;
  bytes16 K_0;
  bytes16 M1_0;
  bytes16 M2_0;
  bytes16 dT_0;
  bytes16 v1_0;
  bytes16 v2_0;
  bytes16 dTdTbyM1x2_0;
  bytes16 dTdTbyM2x2_0;
  bytes16 dTbyM1x2_0;
  bytes16 dTbyM2x2_0;
  bytes16 r_0;
  bytes16 rMag_0;
  bytes16 f_0;
  bytes16 fNew_0;

  // constants
  bytes16 private constant two = 0x00000000000000000000000000000002;


  constructor() {
    bytes16 eqBondLen = SafeMathQuad.getUintValueBytes(21316,4);
    bytes16 initBondLen = SafeMathQuad.getUintValueBytes(226767135,8);
    bytes16 forceConst = SafeMathQuad.getUintValueBytes(11915,4);
    bytes16 atomOne = SafeMathQuad.getUintValueBytes(21875, 0);
    bytes16 atomTwo = SafeMathQuad.getUintValueBytes(291569457, 4);
    bytes16 timestep = SafeMathQuad.getUintValueBytes(413, 2);
    defaultValues(eqBondLen, initBondLen, forceConst, atomOne, atomTwo, timestep);
  }

  /// @param eqBondLen Equilibrium bond length in a_0.
  /// @param initBondLen Initial bond length in a_0.
  /// @param forceConst Force constant in Eh/a_0^2.
  /// @param atomOne Mass of atom one in m_e. 
  /// @param atomTwo Mass of atom two in m_e.
  /// @param timestep Time step in hbar/E_h.
  function defaultValues(bytes16 eqBondLen, bytes16 initBondLen, bytes16 forceConst, bytes16 atomOne, bytes16 atomTwo, bytes16 timestep) internal {
    
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

      require(ABDKMathQuad.abs(Re)!=ABDKMathQuad.abs(R1), "flawed init");


      // Pre-calculate all variables that can be.
      dTdTbyM1x2 = dT.mul(dT).div(M1.mul(two)); // ((dT*dT)/(M1*2))
      dTdTbyM1x2_0 = dTdTbyM1x2;
      dTdTbyM2x2 = dT.mul(dT).div(M2.mul(two)); // ((dT*dT)/(M2*2))
      dTdTbyM2x2_0 = dTdTbyM2x2;
      dTbyM1x2 = dT.div(M1.mul(two)); // (dT/(M1*2))
      dTbyM1x2_0 = dTbyM1x2;
      dTbyM2x2 = dT.div(M2.mul(two)); // (dT/(M2*2))
      dTbyM2x2_0 = dTbyM2x2;


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

    require(ABDKMathQuad.abs(Re)!=ABDKMathQuad.abs(R1), "flawed reset");
  }

  /// @notice Initializes a molecular dynamics trajectory
  /// @param steps Number of steps in time in units of 0.1 femtosecond.
  /// @param precision Number of decimal places to include in output.
  function runMd(uint256 steps, uint precision) public returns (DiatomicMDOutput memory) {
      reset();
      // require(false, "did reset");
      bytes16 multiplier = SafeMathQuad.getUintValueBytes(10**precision,0);
      uint256[] memory results = new uint256[](steps);
      for (uint t=0; t<steps; t++) {
        // require(false, "looped");
        require(ABDKMathQuad.abs(Re)!=ABDKMathQuad.abs(R1), "flawed loop");
        r = R1.sub(R2);
        require(r!=0, "r is zero...");
        // require(R2==0, "expected r2 be zero here...");
        rMag = ABDKMathQuad.abs(r);
        bytes16 nK = ABDKMathQuad.neg(K); 
        require(nK!=0, "-K is zero...");
        require(rMag!=Re, "rmag went to equillibrium length");
        bytes16 diff = rMag.sub(Re);
        require(diff!=0, "diff is zero");
        f = nK.mul(diff).mul(r).div(rMag);
        require(f!=0, "the force is 0...");
        // require(false, "made it past force computation");
        v1 = v1.add(dTbyM1x2.mul(fNew.add(f)));
        v2 = v2.sub(dTbyM2x2.mul(fNew.add(f)));
        R1 = R1.add(dT.mul(v1)).add(dTdTbyM1x2.mul(f));
        R2 = R2.add(dT.mul(v2)).sub(dTdTbyM2x2.mul(f));
        // require(false, "computed velocities and radii");
        r = R1.sub(R2);
        require(r!=0, "r update resulted in r==0... cannot divide by zero");
        rMag = ABDKMathQuad.abs(r);
        fNew = nK.mul(rMag.sub(Re)).mul(r).div(rMag);
        // require(false, "updated fNew successfully");
        bytes16 resPre = rMag.mul(multiplier);
        // require(false, "applied multiplier");
        uint256 resInt = SafeMathQuad.toUint(resPre);
        // require(false, "converted to int");
        results[t] = resInt;
        // require(false, "added to results");
        require(v1!=0, "velocity has remained at 0...");
        require(R1!=R1_0, "runMd did not change R1");
      }
      runCount++;
      simulationOutput[runCount] = results;
      DiatomicMDOutput memory newOutput = DiatomicMDOutput(runCount, results);
      return newOutput;
    }

    // @notice Retrieves the results of a previous run.
    /// @param runNum The number of the run to retrieve results for.
    function getSimOutput(uint256 runNum) public view returns (uint256[] memory output) {
      require(runNum > 0, "runNum must be greater than 0");
      require(runNum <= runCount, "No such run exists.");
      return simulationOutput[runNum];
    }

    function getSimOutput(uint256 runNum, uint idx) public view returns (uint256 output) {
      require(runNum > 0, "runNum must be greater than 0");
      require(runNum <= runCount, "No such run exists.");
      return simulationOutput[runNum][idx];
    }

    // @notice mocks functionality by returning a fixed array of results
    function getSimOutput() public returns (int256[] memory) {
      uint timesteps = 10;
      uint numValues = 7;
      uint arrLength = timesteps * numValues + 2;
      mockResults = new  int256[](arrLength);
      uint256 startCt = runCount+1;
      for (uint i=0; i<timesteps; i++) {
        runMd(i+1, 0);
        // require(false, "ran the simulation in mock");
        mockResults[numValues*i] = int256(getSimOutput(startCt+i, i)); // radius magnitude - equillibrium
        // require(false, "got sim output");
        mockResults[numValues*i+1] = SafeMathQuad.toInt(M2); // oxygen mass (2)
        mockResults[numValues*i+2] = SafeMathQuad.toInt(M1); // carbon mass (1)
        // require(false, "got masses");
        mockResults[numValues*i+3] = SafeMathQuad.toInt(v2); // oxygen v
        mockResults[numValues*i+4] = SafeMathQuad.toInt(v1); // carbon v
        // require(false, "got velocities");
        mockResults[numValues*i+5] = SafeMathQuad.toInt(R1); // radius carbon
        mockResults[numValues*i+6] = SafeMathQuad.toInt(R2); // radius oxygen
        // require(R1!=R2, "why radius are the same??");
        require(R1!=R1_0, "why no change in radius?");
      }
      // last 2 values are timesteps and numValues
      mockResults[arrLength-2] = int(timesteps);
      mockResults[arrLength-1] = int(numValues);
      return mockResults;
    }

}
