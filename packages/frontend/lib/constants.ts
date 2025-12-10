export const ARC_CHAIN_ID = 5042002;
export const ARC_CHAIN_NAME = "Arc Testnet";
export const ARC_RPC_URL = process.env.NEXT_PUBLIC_RPC_URL || "https://arc-testnet.g.alchemy.com/v2/YOUR-KEY";
export const ARC_EXPLORER_URL = "https://testnet.arcscan.app";

// Helper Contract Address (Deployed on Arc Testnet)
export const CONFIDENTIAL_HELPER_ADDRESS = process.env.NEXT_PUBLIC_HELPER_CONTRACT_ADDRESS as `0x${string}` || "0x0000000000000000000000000000000000001234"; 
