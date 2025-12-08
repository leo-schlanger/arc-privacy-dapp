import { http, createConfig } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'
import { defineChain } from 'viem'

export const arcNetwork = defineChain({
    id: 999999999, // Placeholder ID for Arc
    name: 'Arc Network',
    nativeCurrency: { name: 'USDC', symbol: 'USDC', decimals: 6 },
    rpcUrls: {
        default: { http: ['https://rpc.arc-network.io'] }, // Placeholder RPC
    },
    blockExplorers: {
        default: { name: 'ArcScan', url: 'https://scan.arc-network.io' },
    },
})

export const config = createConfig({
    chains: [mainnet, sepolia, arcNetwork],
    transports: {
        [mainnet.id]: http(),
        [sepolia.id]: http(),
        [arcNetwork.id]: http(),
    },
    ssr: true,
})
