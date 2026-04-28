#!/bin/bash

# Sourcify contract verification script
# Usage: ./verify-sourcify.sh [contract_address] [network_name]
# Example: ./verify-sourcify.sh 0x123...abc monad_testnet

set -e

CONTRACT_ADDRESS=$1
NETWORK=${2:-monad_testnet}

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "❌ Contract address is required"
    echo "Usage: ./verify-sourcify.sh [contract_address] [network_name]"
    echo "Example: ./verify-sourcify.sh 0x123...abc monad_testnet"
    exit 1
fi

echo "🔍 Verifying Counter contract at $CONTRACT_ADDRESS on $NETWORK using Sourcify..."

# Get chain ID based on network
case $NETWORK in
    monad_testnet)
        CHAIN_ID=10143
        ;;
    *)
        echo "❌ Unknown network: $NETWORK"
        echo "Supported networks: monad_testnet, sepolia, polygon_mumbai, arbitrum_sepolia"
        exit 1
        ;;
esac

echo "📋 Network: $NETWORK (Chain ID: $CHAIN_ID)"
echo "📝 Contract Address: $CONTRACT_ADDRESS"

# Try Foundry's built-in Sourcify verification first
echo "🚀 Attempting verification with Foundry + Sourcify..."
forge verify-contract \
    --chain-id $CHAIN_ID \
    --verifier-url https://sourcify-api-monad.blockvision.org \
    $CONTRACT_ADDRESS \
    src/Counter.sol:Counter

if [ $? -eq 0 ]; then
    echo "✅ Contract successfully verified with Sourcify!"
    echo "🌐 View on Sourcify: https://sourcify-api-monad.blockvision.org/contracts/full_match/$CHAIN_ID/$CONTRACT_ADDRESS/"
else
    echo "⚠️  Foundry verification failed. Trying manual preparation..."
    
    # Create verification package
    TEMP_DIR=$(mktemp -d)
    echo "📦 Preparing verification files in $TEMP_DIR..."
    
    # Copy source files
    cp -r src/ $TEMP_DIR/
    cp -r out/ $TEMP_DIR/
    
    # Create metadata file if it exists
    if [ -f "out/Counter.sol/Counter.json" ]; then
        echo "📄 Found contract metadata"
        cp out/Counter.sol/Counter.json $TEMP_DIR/Counter.json
    fi
    
    echo "📁 Verification files prepared in: $TEMP_DIR"
    echo ""
    echo "🌐 Manual verification steps:"
    echo "1. Visit: https://sourcify-api-monad.blockvision.org"
    echo "2. Select network: $NETWORK (Chain ID: $CHAIN_ID)"
    echo "3. Enter contract address: $CONTRACT_ADDRESS"
    echo "4. Upload files from: $TEMP_DIR"
    echo "   - Upload src/Counter.sol"
    echo "   - Upload Counter.json (metadata) if available"
    echo "5. Click 'Verify' button"
    echo ""
    echo "💡 Alternative: Use curl to verify via API"
    echo "curl -X POST https://sourcify-api-monad.blockvision.org/server/verify \\"
    echo "  -F 'address=$CONTRACT_ADDRESS' \\"
    echo "  -F 'chain=$CHAIN_ID' \\"
    echo "  -F 'files=@$TEMP_DIR/src/Counter.sol' \\"
    echo "  -F 'files=@$TEMP_DIR/Counter.json'"
fi
