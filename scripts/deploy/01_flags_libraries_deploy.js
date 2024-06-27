const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const FlagsImage = await ethers.getContractFactory("FlagsImage");
  const FlagsImage2 = await ethers.getContractFactory("FlagsImage2");

  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName]["Libraries"];

  if (networkData.FlagsImage === "") {
    console.log(`Deploying FlagsImage...`);
    const flags = await FlagsImage.deploy();
    await flags.deployed();
    console.log(`FlagsImage deployed at ${flags.address}`);

    networkData.FlagsImage = flags.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`FlagsImage already deployed at ${networkData.FlagsImage}`);
  }

  if (networkData.FlagsImage2 === "") {
    console.log(`Deploying FlagsImage2...`);
    const flags = await FlagsImage2.deploy();
    await flags.deployed();
    console.log(`FlagsImage2 deployed at ${flags.address}`);

    networkData.FlagsImage2 = flags.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`FlagsImage2 already deployed at ${networkData.FlagsImage2}`);
  }

  if (networkData.Flags === "") {
    console.log(`Deploying Flags...`);

    const Flags = await ethers.getContractFactory("Flags", {
      libraries: {
        FlagsImage: networkData.FlagsImage,
        FlagsImage2: networkData.FlagsImage2,
      },
    });

    const flags = await Flags.deploy();
    await flags.deployed();
    console.log(`Flags deployed at ${flags.address}`);

    networkData.Flags = flags.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`Flags already deployed at ${networkData.Flags}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
