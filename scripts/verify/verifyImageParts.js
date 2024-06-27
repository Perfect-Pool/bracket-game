const hre = require("hardhat");

async function main() {
  const contracts = require("../../contracts.json");
  const networkName = hre.network.name;

  let address = contracts[networkName]["Libraries"]["ImageParts"];
  if (!address) {
    console.error("ImageParts address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying ImageParts at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [], // Adicionar os argumentos do construtor se necessário
    contract: "contracts/libraries/ImageParts.sol:ImageParts",
  });

  address = contracts[networkName]["Libraries"]["ImagePartsPhaseOne"];
  if (!address) {
    console.error("ImagePartsPhaseOne address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying ImagePartsPhaseOne at address", address);

  let libraryAddress = contracts[networkName]["Libraries"]["ImageBetTexts"];
  if (!libraryAddress) {
    console.error("ImageBetTexts address not found in contracts.json");
    process.exit(1);
  }

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [], // Add constructor arguments if necessary
    contract: "contracts/libraries/ImagePartsPhaseOne.sol:ImagePartsPhaseOne",
    // libraries: {
    //   ImageBetTexts: libraryAddress,
    // },
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
