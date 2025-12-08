'use client'

import * as React from 'react'
import {
    RainbowKitProvider,
    getDefaultWallets,
    getDefaultConfig,
} from '@rainbow-me/rainbowkit'
import {
    argentWallet,
    trustWallet,
    ledgerWallet,
} from '@rainbow-me/rainbowkit/wallets'
import {
    QueryClientProvider,
    QueryClient,
} from "@tanstack/react-query";
import { WagmiProvider } from 'wagmi'
import { config } from './config'

const queryClient = new QueryClient();

export function Providers({ children }: { children: React.ReactNode }) {
    return (
        <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
                <RainbowKitProvider>
                    {children}
                </RainbowKitProvider>
            </QueryClientProvider>
        </WagmiProvider>
    )
}
