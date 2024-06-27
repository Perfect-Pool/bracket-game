const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  const gamesHubAddress = networkData.GAMES_HUB;
  console.log(`GamesHub loaded at ${gamesHubAddress}`);
  const GamesHub = await ethers.getContractAt("GamesHub", gamesHubAddress);

  if (networkData.NFT_METADATA8 === "") {
    console.log(`Deploying NftMetadata...`);
    const NftMetadata = await ethers.getContractFactory("NftMetadata");
    const nftMetadata = await NftMetadata.deploy(gamesHubAddress);
    await nftMetadata.deployed();
    console.log(`NftMetadata deployed at ${nftMetadata.address}`);

    networkData.NFT_METADATA8 = nftMetadata.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting NftMetadata address to GamesHub...`);
    await GamesHub.setGameContact(
      nftMetadata.address,
      ethers.utils.id(networkData.NFT_METADATA_NAME),
      true
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`NftMetadata already deployed at ${networkData.NFT_METADATA8}`);
  }

  if (networkData.NFT_METADATA_OLYMPICS === "") {
    console.log(`Deploying NftMetadataPhaseOne...`);
    const NftMetadataPhaseOne = await ethers.getContractFactory("NftMetadataPhaseOne");
    const nftMetadataPhaseOne = await NftMetadataPhaseOne.deploy(gamesHubAddress);
    await nftMetadataPhaseOne.deployed();
    console.log(`NftMetadataPhaseOne deployed at ${nftMetadataPhaseOne.address}`);

    networkData.NFT_METADATA_OLYMPICS = nftMetadataPhaseOne.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting NftMetadataPhaseOne address to GamesHub...`);
    await GamesHub.setGameContact(
      nftMetadataPhaseOne.address,
      ethers.utils.id(networkData.PHASE_1_NFT_METADATA_NAME),
      true
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`NftMetadataPhaseOne already deployed at ${networkData.NFT_METADATA_OLYMPICS}`);
  }
}

main().then(() => process.exit(0)).catch((error) => {
  console.error(error);
  process.exit(1);
});
