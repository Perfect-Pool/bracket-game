const hre = require("hardhat");

async function main() {
  const contracts = require("../../contracts.json");
  const networkName = hre.network.name;

  let address = contracts[networkName]["Libraries"]["FlagsImage"];
  if (!address) {
    console.error("FlagsImage address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying FlagsImage at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [],
    contract: "contracts/libraries/FlagsImage.sol:FlagsImage",
  });

  address = contracts[networkName]["Libraries"]["FlagsImage2"];
  if (!address) {
    console.error("FlagsImage2 address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying FlagsImage2 at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [],
    contract: "contracts/libraries/FlagsImage2.sol:FlagsImage2",
  });

  address = contracts[networkName]["Libraries"]["Flags"];
  if (!address) {
    console.error("Flags address not found in contracts.json");
    process.exit(1);
  }

  console.log("Verifying Flags at address", address);

  await hre.run("verify:verify", {
    address: address,
    constructorArguments: [],
    contract: "contracts/libraries/Flags.sol:Flags",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
