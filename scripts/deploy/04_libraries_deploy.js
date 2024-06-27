const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName]["Libraries"];

  if (!networkData.ImageParts || networkData.ImageParts === "") {
    throw new Error(
      "ImageParts library address not found in contracts.json. Please deploy ImageParts first."
    );
  }
  if (!networkData.ImagePartsPhaseOne || networkData.ImagePartsPhaseOne === "") {
    throw new Error(
      "ImagePartsPhaseOne library address not found in contracts.json. Please deploy ImagePartsPhaseOne first."
    );
  }
  const imagePartsAddress = networkData.ImageParts;
  const imagePartsPhaseOneAddress = networkData.ImagePartsPhaseOne;

  if (networkData.BuildImage === "") {
    console.log(
      `Deploying BuildImage with ImageParts at ${imagePartsAddress}...`
    );

    const BuildImage = await ethers.getContractFactory("BuildImage", {
      libraries: {
        ImageParts: imagePartsAddress,
      },
    });

    const buildImage = await BuildImage.deploy();
    await buildImage.deployed();
    console.log(`BuildImage deployed at ${buildImage.address}`);

    networkData.BuildImage = buildImage.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(
      `BuildImage already deployed at ${networkData.BuildImage}`
    );
  }

  if (networkData.BuildImagePhaseOne === "") {
    console.log(
      `Deploying BuildImagePhaseOne with ImagePartsPhaseOne at ${imagePartsPhaseOneAddress}...`
    );

    const BuildImagePhaseOne = await ethers.getContractFactory("BuildImagePhaseOne", {
      libraries: {
        ImagePartsPhaseOne: imagePartsPhaseOneAddress,
      },
    });

    const buildImagePhaseOne = await BuildImagePhaseOne.deploy();
    await buildImagePhaseOne.deployed();
    console.log(`BuildImagePhaseOne deployed at ${buildImagePhaseOne.address}`);

    networkData.BuildImagePhaseOne = buildImagePhaseOne.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(
      `BuildImagePhaseOne already deployed at ${networkData.BuildImagePhaseOne}`
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
