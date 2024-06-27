const hre = require("hardhat");

async function main() {
  const contracts = require("../../contracts.json");
  const networkName = hre.network.name;

  const address = contracts[networkName]["OLYMPICS"];
  if (!address) {
    console.error("Olympics address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying Olympics at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [
      contracts[networkName].GAMES_HUB,
      contracts[networkName].Executor,
      contracts[networkName].PHASE_1_PROXY_NAME,
      contracts[networkName].PHASE_1_NFT_NAME
    ],
    contract: "contracts/games/Olympics.sol:Olympics",
  });

  const addressProxy = contracts[networkName]["OLYMPICS_PROXY"];
  if (!addressProxy) {
    console.error("OlympicsProxy address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying OlympicsProxy at address", addressProxy);
  console.log("Game Name:", contracts[networkName].PHASE_1_NAME);

  await hre.run("verify:verify", {
    address: addressProxy,
    constructorArguments: [
      contracts[networkName].GAMES_HUB,
      contracts[networkName].Executor,
      contracts[networkName].LAST_OLYMPICS,
      contracts[networkName].PHASE_1_NAME
    ],
    contract: "contracts/games/OlympicsProxy.sol:OlympicsProxy",
  });


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
