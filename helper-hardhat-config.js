const networkConfig = {
  5: {
    name: "goerli",
    ethUsdPriceFeedAddress: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
  },
  137: {
    name: "polygon",
    ethUsdPriceFeedAddress: "0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676",
  },
};

const developmentChains = ["hardhat", "localhost"];
const DECIMALS = 8;
const INITIAL_ANSWER = 200000000000;

module.exports = { networkConfig, DECIMALS, INITIAL_ANSWER, developmentChains };
