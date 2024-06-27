const hre = require("hardhat");

async function main() {
    const contracts = require("../../contracts.json");
    const networkName = hre.network.name;

    let address = contracts[networkName]["NFT_METADATA8"];
    if (!address) {
        console.error("NftMetadata address not found in contracts.json");
        process.exit(1);
    }

    console.log("Verifying NftMetadata at address", address);

    await hre.run("verify:verify", {
        address: address,
        constructorArguments: [contracts[networkName].GAMES_HUB],
        contract: "contracts/utils/NftMetadata.sol:NftMetadata"
    });

    address = contracts[networkName]["NFT_METADATA_OLYMPICS"];
    if (!address) {
        console.error("NftMetadataPhaseOne address not found in contracts.json");
        process.exit(1);
    }

    console.log("Verifying NftMetadataPhaseOne at address", address);

    await hre.run("verify:verify", {
        address: address,
        constructorArguments: [contracts[networkName].GAMES_HUB],
        contract: "contracts/utils/NftMetadataPhaseOne.sol:NftMetadataPhaseOne"
    });
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });