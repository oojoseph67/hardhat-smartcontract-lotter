1. yarn add --dev hardhat
2. yarn hardhat
3. select "create an empty hardhat.config.js"
4. yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-etherscan @nomiclabs/hardhat-waffle chai ethereum-waffle hardhat hardhat-contract-sizer hardhat-deploy hardhat-gas-reporter prettier prettier-plugin-solidity solhint solidity-coverage dotenv
5. copy the require file in hardhat.config.js
6. after writing the contract create a deploy folder and script
7. when creating the deploy script we need to look for constructors that have an external address to create a mock
8. 