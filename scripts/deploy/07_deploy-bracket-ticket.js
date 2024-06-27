const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  // Carregar o contrato GamesHub
  const GamesHub = await ethers.getContractFactory("GamesHub");
  const gamesHub = await GamesHub.attach(networkData.GAMES_HUB);
  console.log(`GamesHub loaded at ${gamesHub.address}`);

  // Deploy do BracketTicket8, se necessário
  if (networkData.NFT_BRACKETS8 === "") {
    const BracketTicket8 = await ethers.getContractFactory("BracketTicket8");
    const bracketTicket8 = await BracketTicket8.deploy(
      gamesHub.address,
      networkData.Executor,
      networkData.GAME_NAME
    );
    await bracketTicket8.deployed();
    console.log(`BracketTicket8 deployed at ${bracketTicket8.address}`);

    networkData.NFT_BRACKETS8 = bracketTicket8.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting BracketTicket8 address to GamesHub...`);
    await gamesHub.setGameContact(
      bracketTicket8.address,
      ethers.utils.id(networkData.NFT_NAME),
      true
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(
      `BracketTicket8 already deployed at ${networkData.NFT_BRACKETS8}`
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
