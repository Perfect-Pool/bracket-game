const hre = require("hardhat");

async function main() {
  const contracts = require("../../contracts.json");
  const networkName = hre.network.name;

  // Carregando o endereço do contrato de contracts.json
  let address = contracts[networkName]["Libraries"]["BuildImage"];
  if (!address) {
    console.error("BuildImage address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying BuildImage at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [],
    contract: "contracts/libraries/BuildImage.sol:BuildImage",
  });

  address = contracts[networkName]["Libraries"]["BuildImagePhaseOne"];
  if (!address) {
    console.error("BuildImagePhaseOne address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying BuildImagePhaseOne at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [],
    contract: "contracts/libraries/BuildImagePhaseOne.sol:BuildImagePhaseOne",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
