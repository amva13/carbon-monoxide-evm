pragma solidity >=0.8.7 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DiatomicMD.sol";

contract TestDiatomicMD {
    function testSameSimulationSameResult() public {
        DiatomicMD sim = DiatomicMD(DeployedAddresses.DiatomicMD());
        sim.runMd(1,0);
        sim.runMd(1,0);
        uint256 out1 = sim.getSimOutput(1, 0);
        uint256 out2 = sim.getSimOutput(2, 0);
        Assert.equal(out1, out2, "simulations with same timesteps and precision should have same result");
    }
    function testSimulationResultsLength() public {
        uint timesteps = 3;
        DiatomicMD sim = DiatomicMD(DeployedAddresses.DiatomicMD());
        sim.runMd(timesteps,0);
        uint length = sim.getSimOutput(3).length;
        Assert.equal(timesteps, length, "length of a simulation run results should match the number of timesteps");
    }
}