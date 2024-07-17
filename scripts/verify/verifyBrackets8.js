const hre = require("hardhat");

async function main() {
  const contracts = require("../../contracts.json");
  const networkName = hre.network.name;

  const address = contracts[networkName]["BRACKETS8"];
  if (!address) {
    console.error("OlympicsBrackets address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying OlympicsBrackets at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [
      contracts[networkName].GAMES_HUB,
      contracts[networkName].Executor,
      contracts[networkName].PROXY_NAME,
      contracts[networkName].NFT_NAME
    ],
    contract: "contracts/games/OlympicsBrackets.sol:OlympicsBrackets",
  });

  const addressProxy = contracts[networkName]["BRACKETS8_PROXY"];
  if (!addressProxy) {
    console.error("OlympicsBracketsProxy address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying OlympicsBracketsProxy at address", addressProxy);
  console.log("Game Name:", contracts[networkName].GAME_NAME);

  await hre.run("verify:verify", {
    address: addressProxy,
    constructorArguments: [
      contracts[networkName].GAMES_HUB,
      contracts[networkName].Executor,
      contracts[networkName].LAST_GAME,
      contracts[networkName].GAME_NAME
    ],
    contract: "contracts/games/OlympicsBracketsProxy.sol:OlympicsBracketsProxy",
  });


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
