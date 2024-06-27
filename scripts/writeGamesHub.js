const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  const GamesHub = await ethers.getContractAt(
    "GamesHub",
    networkData.GAMES_HUB
  );
  console.log(`GamesHub loaded at ${GamesHub.address}`);
  console.log(`Executor Address: ${networkData.Executor}`);

  if (networkData.BRACKETS8 !== "") {
    console.log(`Setting BracketGame8 address to GamesHub...`);
    await GamesHub.setGameContact(
      networkData.BRACKETS8,
      ethers.utils.id("BRACKETS8"),
      false
    );
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  if (networkData.NFT_BRACKETS8 !== "") {
    console.log(`Setting BracketTicket8 address to GamesHub...`);
    await GamesHub.setGameContact(
      networkData.NFT_BRACKETS8,
      ethers.utils.id("BRACKET8_TICKET"),
      true
    );
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  if (networkData.NFT_IMAGE !== "") {
    console.log("Setting NftImage address to GamesHub...");
    await GamesHub.setGameContact(
      networkData.NFT_IMAGE,
      ethers.utils.id("NFT_IMAGE8"),
      true
    );
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }

  if (networkData.NFT_METADATA !== "") {
    console.log(`Setting NftMetadata address to GamesHub...`);
    await GamesHub.setGameContact(
      networkData.NFT_METADATA,
      ethers.utils.id("METADATA8"),
      true
    );
    await new Promise((resolve) => setTimeout(resolve, 5000));
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
