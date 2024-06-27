const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  // Ensure the BuildImage library is deployed
  if (!networkData["Libraries"].BuildImage || networkData["Libraries"].BuildImage === "") {
    throw new Error(
      "BuildImage library address not found. Please deploy BuildImage first."
    );
  }

  if (!networkData["Libraries"].BuildImagePhaseOne || networkData["Libraries"].BuildImagePhaseOne === "") {
    throw new Error(
      "BuildImagePhaseOne library address not found. Please deploy BuildImagePhaseOne first."
    );
  }

  const gamesHubAddress = networkData.GAMES_HUB;
  console.log(`GamesHub loaded at ${gamesHubAddress}`);
  const GamesHub = await ethers.getContractAt("GamesHub", gamesHubAddress);

  if (networkData.NFT_IMAGE8 === "") {
    console.log("Deploying NftImage...");
    // Linking BuildImage library
    const NftImage = await ethers.getContractFactory("NftImage", {
      libraries: {
        BuildImage: networkData["Libraries"].BuildImage,
      },
    });
    const nftImage = await NftImage.deploy(gamesHubAddress);
    await nftImage.deployed();
    console.log(`NftImage deployed at ${nftImage.address}`);

    networkData.NFT_IMAGE8 = nftImage.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    console.log("Setting NftImage address to GamesHub...");
    await GamesHub.setGameContact(
      nftImage.address,
      ethers.utils.id(networkData.NFT_IMAGE_NAME),
      true
    );
  } else {
    console.log(`NftImage already deployed at ${networkData.NFT_IMAGE8}`);
  }

  if (networkData.NFT_IMAGE_OLYMPICS === "") {
    console.log("Deploying NftImagePhaseOne...");
    // Linking BuildImagePhaseOne library
    const NftImagePhaseOne = await ethers.getContractFactory("NftImagePhaseOne", {
      libraries: {
        BuildImagePhaseOne: networkData["Libraries"].BuildImagePhaseOne,
      },
    });
    const nftImagePhaseOne = await NftImagePhaseOne.deploy(gamesHubAddress);
    await nftImagePhaseOne.deployed();
    console.log(`NftImagePhaseOne deployed at ${nftImagePhaseOne.address}`);

    networkData.NFT_IMAGE_OLYMPICS = nftImagePhaseOne.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    console.log("Setting NftImagePhaseOne address to GamesHub...");
    await GamesHub.setGameContact(
      nftImagePhaseOne.address,
      ethers.utils.id(networkData.PHASE_1_NFT_IMAGE_NAME),
      true
    );
  } else {
    console.log(`NftImagePhaseOne already deployed at ${networkData.NFT_IMAGE_OLYMPICS}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
