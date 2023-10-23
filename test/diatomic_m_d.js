const DiatomicMD = artifacts.require("DiatomicMD");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("DiatomicMD", function ( accounts ) {
  let simulationInstance;
  let alice;
  beforeEach(async () => {
    simulationInstance = await DiatomicMD.new();
    alice = accounts[0]
  });
  async function shouldThrow(promise) {
    try {
        await promise;
       assert(true);
    }
    catch (err) {
        return;
    }
  assert(false, "The contract did not throw.");
  
  }
  it("should assert true", async function () {
    await DiatomicMD.deployed();
    return assert.isTrue(true);
  });
  it("checks there is no 0th run", async function () {
    shouldThrow(simulationInstance.getSimOutput(0))
    assert.isTrue(true)
  });
  it("checks simulation stores results for each run at correct indeces", async function () {
    // shouldThrow(simulationInstance.getSimOutput(1)) // no runs, so should not have output
    await simulationInstance.runMd(1,0);
    await simulationInstance.getSimOutput(1)
    await simulationInstance.runMd(1,0, {from: alice})
    await simulationInstance.getSimOutput(2)
    shouldThrow(simulationInstance.getSimOutput(3)) // there was no third run, so should throw
    assert.isTrue(true)
  });
  xit("checks same simulation yields same result", async function () {
    await simulationInstance.runMd(1,0)
    let out1 = await simulationInstance.getSimOutput(1,0)
    await simulationInstance.runMd(1,0)
    let out2 = await simulationInstance.getSimOutput(2,0)
    assert.equal(out1, out2)
  });
  xit("checks size of output corresponds to timesteps", async function () {
    const timesteps = 3
    await simulationInstance.runMd(timesteps,0)
    let out = await simulationInstance.getSimOutput(1)
    assert.equal(out.outputData.length, timesteps)
  });
});
