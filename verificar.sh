#!/bin/bash

echo "Iniciando a verificação dos scripts..."

# yarn verify-brackets base-testnet
yarn verify-olympics base-testnet
# yarn verify-nft base-testnet
# yarn verify-nft-olympics base-testnet

yarn verify-nft-metadata base-testnet
# yarn verify-nft-image base-testnet

# yarn verify-library-1 base-testnet
# yarn verify-library-2 base-testnet
# yarn verify-library-3 base-testnet
# yarn verify-library-flags base-testnet

echo "Verificação concluída."
