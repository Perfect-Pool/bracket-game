#!/bin/bash

echo "Iniciando a verificação dos scripts..."

yarn verify-brackets base-testnet
# yarn verify-olympics base-testnet
yarn verify-nft base-testnet
# yarn verify-nft-olympics base-testnet

# yarn verify-nft-metadata base-testnet
# yarn verify-nft-image base-testnet

# yarn verify-library-1 base-testnet
# yarn verify-library-2 base-testnet
# yarn verify-library-3 base-testnet
# yarn verify-library-flags base-testnet


# yarn verify-brackets base
# yarn verify-olympics base
# yarn verify-nft base
# yarn verify-nft-olympics base

# yarn verify-nft-metadata base
# yarn verify-nft-image base

# yarn verify-library-1 base
# yarn verify-library-2 base
# yarn verify-library-3 base
# yarn verify-library-flags base

echo "Verificação concluída."
