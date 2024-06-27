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


  if (networkData.OLYMPICS === "") {
    console.log(`Deploying Olympics...`);
    const Olympics = await ethers.getContractFactory("Olympics");
    const olympicsGame = await Olympics.deploy(
      networkData.GAMES_HUB,
      networkData.Executor,
      networkData.PHASE_1_PROXY_NAME,
      networkData.PHASE_1_NFT_NAME
    );
    await olympicsGame.deployed();

    console.log(`Olympics deployed at ${olympicsGame.address}`);
    networkData.OLYMPICS = olympicsGame.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting Olympics address to GamesHub...`);
    await GamesHub.setGameContact(
      olympicsGame.address,
      ethers.utils.id(networkData.PHASE_1_NAME),
      false
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`Olympics already deployed at ${networkData.OLYMPICS}`);
  }

  if (networkData.OLYMPICS_PROXY === "") {
    console.log(`Getting OlympicsProxy data...`);
    const OlympicsProxy = await ethers.getContractFactory("OlympicsProxy");
    console.log(`Deploying OlympicsProxy...`);
    const olympicsProxy = await OlympicsProxy.deploy(
      networkData.GAMES_HUB,
      networkData.Executor,
      networkData.LAST_OLYMPICS,
      networkData.PHASE_1_NAME
    );
    await olympicsProxy.deployed();

    console.log(`OlympicsProxy deployed at ${olympicsProxy.address}`);
    networkData.OLYMPICS_PROXY = olympicsProxy.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting OlympicsProxy address to GamesHub...`);
    await GamesHub.setGameContact(
      olympicsProxy.address,
      ethers.utils.id(networkData.PHASE_1_PROXY_NAME),
      false
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));

    // console.log(`Setting OlympicsProxy last game...`);
    // const olympicsProxyExec = await ethers.getContractAt(
    //   "OlympicsProxy",
    //   olympicsProxy.address
    // );
    // await olympicsProxyExec.setGameContract(
    //   networkData.LAST_OLYMPICS,
    //   networkData.PREVIOUS_OLYMPICS
    // );
  } else {
    console.log(`OlympicsProxy already deployed at ${networkData.OLYMPICS_PROXY}`);
  }

  // networkData.PREVIOUS_OLYMPICS = networkData.OLYMPICS;
  // fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
