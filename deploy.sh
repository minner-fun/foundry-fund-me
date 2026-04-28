#!/bin/bash

# Counter contract deployment script
# Usage: ./deploy.sh [network_name]
# Example: ./deploy.sh monad_testnet

set -e

NETWORK=${1:-monad_testnet}

echo "🚀 Deploying Counter contract to $NETWORK network..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found, please create it and set PRIVATE_KEY"
    echo "💡 You can copy .env.example to .env and fill in your private key"
    exit 1
fi

# Load environment variables
source .env

# Check if private key is set
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY not set in .env file"
    exit 1
fi

# Execute deployment
echo "📝 Starting deployment..."

if [ "$NETWORK" = "monad_testnet" ]; then
    # Deploy to Monad Testnet without auto-verification
    forge script script/DeployFundMe.s.sol \
        --rpc-url $NETWORK \
        --private-key $PRIVATE_KEY \
        --broadcast \
        -vvvv
    
    echo "✅ Deployment completed!"
    echo "📋 Deployment details saved in broadcast/ directory"
    echo "🔍 Use Sourcify for contract verification: https://sourcify-api-monad.blockvision.org"
    echo "💡 Run './verify-sourcify.sh [contract_address]' for Sourcify verification"
else
    # Deploy with auto-verification for other networks
    forge script script/Counter.s.sol \
        --rpc-url $NETWORK \
        --private-key $PRIVATE_KEY \
        --broadcast \
        --verify \
        -vvvv
    
    echo "✅ Deployment completed!"
    echo "📋 Deployment details saved in broadcast/ directory"
    echo "🔍 Contract will be automatically verified on block explorer"
fi
