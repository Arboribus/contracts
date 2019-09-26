const Arbol = artifacts.require("./Arbol.sol");
const ArbolFactory = artifacts.require("./ArbolFactory.sol")
const Bosque = artifacts.require("./Bosque.sol");

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = ""
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  //deployer.deploy(Arbol, proxyRegistryAddress, {gas: 5000000});
  
  // Uncomment this if you want initial item sale support.
  deployer.deploy(Arbol, proxyRegistryAddress, {gas: 5000000}).then(() => {
     return deployer.deploy(ArbolFactory, proxyRegistryAddress, Arbol.address, {gas: 7000000});
  }).then(async() => {
     var arbol = await Arbol.deployed();
     return arbol.transferOwnership(ArbolFactory.address);
  })
};