const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  const GamesHub = await ethers.getContractAt(
    "GamesHub",
    networkData.GAMES_HUB
  );
  console.log(`GamesHub loaded at ${GamesHub.address}`);
  console.log(`Executor Address: ${networkData.Executor}`);


  if (networkData.BRACKETS8 === "") {
    console.log(`Deploying OlympicsBrackets...`);
    const OlympicsBrackets = await ethers.getContractFactory("OlympicsBrackets");
    const bracketGame = await OlympicsBrackets.deploy(
      networkData.GAMES_HUB,
      networkData.Executor,
      networkData.PROXY_NAME,
      networkData.NFT_NAME
    );
    await bracketGame.deployed();

    console.log(`OlympicsBrackets deployed at ${bracketGame.address}`);
    networkData.BRACKETS8 = bracketGame.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting OlympicsBrackets address to GamesHub...`);
    await GamesHub.setGameContact(
      bracketGame.address,
      ethers.utils.id(networkData.GAME_NAME),
      false
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`OlympicsBrackets already deployed at ${networkData.BRACKETS8}`);
  }

  if (networkData.BRACKETS8_PROXY === "") {
    console.log(`Getting OlympicsBracketsProxy data...`);
    const OlympicsBracketsProxy = await ethers.getContractFactory("OlympicsBracketsProxy");
    console.log(`Deploying OlympicsBracketsProxy...`);
    const bracketProxy = await OlympicsBracketsProxy.deploy(
      networkData.GAMES_HUB,
      networkData.Executor,
      networkData.LAST_GAME,
      networkData.GAME_NAME
    );
    await bracketProxy.deployed();

    console.log(`OlympicsBracketsProxy deployed at ${bracketProxy.address}`);
    networkData.BRACKETS8_PROXY = bracketProxy.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting OlympicsBracketsProxy address to GamesHub...`);
    await GamesHub.setGameContact(
      bracketProxy.address,
      ethers.utils.id(networkData.PROXY_NAME),
      false
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));

    // console.log(`Setting OlympicsBracketsProxy last game...`);
    // const bracketProxyExec = await ethers.getContractAt(
    //   "OlympicsBracketsProxy",
    //   bracketProxy.address
    // );
    // await bracketProxyExec.setGameContract(
    //   networkData.LAST_GAME,
    //   networkData.PREVIOUS_BRACKETS8
    // );
  } else {
    console.log(`OlympicsBracketsProxy already deployed at ${networkData.BRACKETS8_PROXY}`);
  }

  // networkData.PREVIOUS_BRACKETS8 = networkData.BRACKETS8;
  // fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
