const DiatomicMD = artifacts.require("DiatomicMD");
const ABDKMathQuad = artifacts.require("ABDKMathQuad");
const SafeMathQuad = artifacts.require("SafeMathQuad");

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  const deployer = _deployer;
  deployer.deploy(ABDKMathQuad);
  deployer.link(ABDKMathQuad, SafeMathQuad);
  deployer.deploy(SafeMathQuad);
  deployer.link(SafeMathQuad, DiatomicMD);
  deployer.deploy(DiatomicMD);
};
