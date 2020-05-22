const CoinFlip = artifacts.require("CoinFlip");

module.exports = function(deployer, network, accounts) {
 deployer.deploy(CoinFlip,{value: web3.utils.toWei("1", "ether"), from: accounts[0]}).then(function(instance){

        console.log("Wer gewinnt: " + instance.result);

  });
};
