# Deployment Guide

## Prerequisites

Before deploying, ensure you have the following installed:
- **Node.js** (v18+)
- **Foundry** (Forge)
- **Git**

## 1. Smart Contract Deployment (Arc Testnet)

### Setup Wallet
Create a `.env` file in `packages/contracts` with your private key (use a test wallet!):
```env
PRIVATE_KEY=0xyour_private_key_here
ARC_TESTNET_RPC=https://arc-testnet.g.alchemy.com/v2/YOUR-KEY
```

### Deploy
Navigate to the contracts directory and run the deployment script:
```bash
cd packages/contracts
source .env

forge create --rpc-url $ARC_TESTNET_RPC \
  --private-key $PRIVATE_KEY \
  src/ConfidentialTransferHelper.sol:ConfidentialTransferHelper \
  --constructor-args 0xUSDC_ADDRESS_ON_ARC
```

### Verify
Once deployed, verify the contract on ArcScan:
```bash
forge verify-contract \
  --chain-id 5042002 \
  --compiler-version v0.8.20+commit.a1b79de6 \
  <DEPLOYED_ADDRESS> \
  src/ConfidentialTransferHelper.sol:ConfidentialTransferHelper \
  <ETHERSCAN_API_KEY>
```

## 2. Frontend Deployment (Vercel)

1.  **Push to GitHub**: Ensure your code is pushed to the main branch.
2.  **Import to Vercel**:
    *   Go to [Vercel Dashboard](https://vercel.com/dashboard).
    *   Click "Add New Project" -> "Import" your repository.
3.  **Configure Root Directory**:
    *   Edit "Root Directory" to `packages/frontend`.
4.  **Environment Variables**:
    *   `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`: Your WalletConnect Cloud ID.
    *   `NEXT_PUBLIC_HELPER_CONTRACT_ADDRESS`: The address from step 1.
    *   `NEXT_PUBLIC_RPC_URL`: Your Alchemy/Infura endpoint for Arc.
5.  **Deploy**: Click "Deploy". Vercel will automatically detect Next.js settings.

## 3. Post-Deployment Checks
- [ ] Connect wallet on the deployed site.
- [ ] Switch to Arc Testnet.
- [ ] Perform a small test transfer (0.1 USDC).
- [ ] Verify transaction on ArcScan.
