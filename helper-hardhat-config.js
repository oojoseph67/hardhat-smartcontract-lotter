const { ethers } = require("hardhat");

const networkConfig = {
  4: {
    name: "rinkeby",
    vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
    entranceFee: ethers.utils.parseEther("0.1"),
    keyHash:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    subId: "9112",
    callbackGasLimit: "500000",
    interval: "30",
  },
  31337: {
    name: "hardhat",
    entranceFee: ethers.utils.parseEther("0.1"),
    keyHash:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    callbackGasLimit: "1000000",
    interval: "30",
  },
  //   137: {
  //     name: "polygon",
  //     ethUsdPriceFeed: "0xF9680D996C9589e2a93a78A04A279e509205945",
  //   },
};

const VERIFICATION_BLOCK_CONFIRMATIONS = 6;
const frontEndContractsFile =
  "../nextjs-smartcontract-lottery/constants/contractAddresses.json";
const frontEndAbiFile = "../nextjs-smartcontract-lottery/constants/abi.json";

module.exports = {
  networkConfig,
  developmentChains,
  VERIFICATION_BLOCK_CONFIRMATIONS,
  frontEndContractsFile,
  frontEndAbiFile,
};