const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  
  let tokenAddress;
  if (networkName.includes("-testnet")) {
    tokenAddress = networkData.TOKEN_ADDRESS;
  }else{
    tokenAddress = networkData.USDC;
  }

  // Carregar o contrato GamesHub
  const GamesHub = await ethers.getContractFactory("GamesHub");
  const gamesHub = await GamesHub.attach(networkData.GAMES_HUB);
  console.log(`GamesHub loaded at ${gamesHub.address}`);

  // Deploy do OlympicsTicket, se necessário
  if (networkData.NFT_OLYMPICS === "") {
    const OlympicsTicket = await ethers.getContractFactory("OlympicsTicket");
    const olympicsTicket = await OlympicsTicket.deploy(
      gamesHub.address,
      networkData.Executor,
      tokenAddress,
      networkData.PHASE_1_NAME
    );
    await olympicsTicket.deployed();
    console.log(`OlympicsTicket deployed at ${olympicsTicket.address}`);

    networkData.NFT_OLYMPICS = olympicsTicket.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting OlympicsTicket address to GamesHub...`);
    await gamesHub.setGameContact(
      olympicsTicket.address,
      ethers.utils.id(networkData.PHASE_1_NFT_NAME),
      true
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(
      `OlympicsTicket already deployed at ${networkData.NFT_OLYMPICS}`
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
