import { ConnectButton } from '@rainbow-me/rainbowkit';

export const WalletConnect = () => {
    return (
        <div className="flex items-center gap-4">
            <ConnectButton
                accountStatus={{
                    smallScreen: 'avatar',
                    largeScreen: 'full',
                }}
                chainStatus="icon"
                showBalance={true}
            />
        </div>
    );
};
