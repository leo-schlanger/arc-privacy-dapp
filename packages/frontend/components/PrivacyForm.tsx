import React, { useState } from 'react';
import { useArcPrivacy } from '../hooks/useArcPrivacy';
import { useAccount } from 'wagmi';
import { TransactionStatus } from './TransactionStatus';

export const PrivacyForm = () => {
    const { isConnected } = useAccount();
    const [amount, setAmount] = useState('');
    const [recipient, setRecipient] = useState('');

    const {
        generateProof,
        sendConfidentialTransaction,
        isGenerating,
        isPending,
        isConfirming,
        isConfirmed,
        hash,
        error
    } = useArcPrivacy();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!amount || !recipient) return;

        try {
            const proofData = await generateProof(amount, recipient);
            sendConfidentialTransaction(proofData);
        } catch (err) {
            console.error(err);
        }
    };

    const isLoading = isGenerating || isPending || isConfirming;

    return (
        <div className="w-full max-w-md p-6 bg-gray-900/50 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-800">
            <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-bold text-white">Private Transfer</h2>
            </div>

            {!isConnected ? (
                <div className="text-center py-10 text-gray-400">
                    Please connect your wallet to start.
                </div>
            ) : (
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-xs uppercase text-gray-500 font-semibold mb-1">To</label>
                        <input
                            type="text"
                            value={recipient}
                            onChange={(e) => setRecipient(e.target.value)}
                            className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-3 text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            placeholder="0x..."
                        />
                    </div>

                    <div>
                        <label className="block text-xs uppercase text-gray-500 font-semibold mb-1">Amount (USDC)</label>
                        <input
                            type="number"
                            value={amount}
                            onChange={(e) => setAmount(e.target.value)}
                            className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-3 text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            placeholder="100.00"
                        />
                    </div>

                    <TransactionStatus
                        hash={hash}
                        isPending={isPending}
                        isConfirming={isConfirming}
                        isConfirmed={isConfirmed}
                        error={error}
                    />

                    <button
                        type="submit"
                        disabled={isLoading || isConfirmed}
                        className={`w-full py-4 rounded-xl font-bold shadow-lg transition-all transform hover:scale-[1.02] active:scale-[0.98] ${isLoading
                            ? 'bg-gray-700 cursor-not-allowed text-gray-400'
                            : isConfirmed
                                ? 'bg-green-600 hover:bg-green-500 text-white'
                                : 'bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white'
                            }`}
                    >
                        {isGenerating ? 'Generating ZK Proof...' :
                            isPending ? 'Confirm in Wallet...' :
                                isConfirming ? 'Verifying on Arc...' :
                                    isConfirmed ? 'Transfer Complete!' :
                                        'Send Privately'}
                    </button>
                </form>
            )}
        </div>
    );
};
