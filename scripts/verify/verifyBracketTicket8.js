const hre = require("hardhat");

async function main() {
    const contracts = require("../../contracts.json");
    const networkName = hre.network.name;

    const address = contracts[networkName]["NFT_BRACKETS8"];
    if (!address) {
        console.error("BracketTicket8 address not found in contracts.json");
        process.exit(1);
    }

    console.log("Verifying BracketTicket8 at address", address);

    await hre.run("verify:verify", {
        address: address,
        constructorArguments: [
            contracts[networkName].GAMES_HUB,
            contracts[networkName].Executor,
            contracts[networkName].GAME_NAME
        ],
        contract: "contracts/utils/BracketTicket8.sol:BracketTicket8"
    });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });