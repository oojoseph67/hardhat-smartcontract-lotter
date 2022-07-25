const { getNamedAccounts, deployments, network, ethers } = require("hardhat");
const { developmentChains } = require('../helper-hardhat-config')

const BASE_FEE = "250000000000000000"
const GAS_PRICE_LINK = 1e9

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments 
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    // const args = [BASE_FEE, GAS_PRICE_LINK]

    if (developmentChains.includes(network.name)) {
        log("Local network detected! Deploying mocks...")
        let args = [BASE_FEE, GAS_PRICE_LINK];
        await deploy("VRFCoordinatorV2Mock", {
          from: deployer,
          args: args,
          log: true,
          waitConfirmations: network.config.blockConfirmations || 1,
        });
        log("Mocks Deployed!")
        log("----------------------------------------------------")
    }
};


module.exports.tags = ['all', 'mocks']