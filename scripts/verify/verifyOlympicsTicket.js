const hre = require("hardhat");

async function main() {
    const contracts = require("../../contracts.json");
    const networkName = hre.network.name;

    let tokenAddress;
    if (networkName.includes("-testnet")) {
      tokenAddress = contracts[networkName].TOKEN_ADDRESS;
    } else {
      tokenAddress = contracts[networkName].USDC;
    }

    const address = contracts[networkName]["NFT_OLYMPICS"];
    if (!address) {
        console.error("OlympicsTicket address not found in contracts.json");
        process.exit(1);
    }

    console.log("Verifying OlympicsTicket at address", address);

    await hre.run("verify:verify", {
        address: address,
        constructorArguments: [
            contracts[networkName].GAMES_HUB,
            contracts[networkName].Executor,
            tokenAddress,
            contracts[networkName].PHASE_1_NAME
        ],
        contract: "contracts/utils/OlympicsTicket.sol:OlympicsTicket"
    });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });