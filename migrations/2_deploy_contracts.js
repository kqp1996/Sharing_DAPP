var Sharing = artifacts.require("./Sharing.sol");

module.exports = function(deployer) {
  deployer.deploy(Sharing,{gas:6700000});
};
