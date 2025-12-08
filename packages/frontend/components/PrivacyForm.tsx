import React, { useState } from 'react';
import { useArcPrivacy } from '../hooks/useArcPrivacy';

export const PrivacyForm = () => {
    const [amount, setAmount] = useState('');
    const [recipient, setRecipient] = useState('');
    const { generateProof, sendConfidentialTransaction, isLoading, error } = useArcPrivacy();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!amount || !recipient) return;

        try {
            console.log("Starting confidential transaction flow...");

            // 1. Generate ZK Proof
            const proofData = await generateProof(amount, recipient);

            // 2. Send Transaction
            await sendConfidentialTransaction(proofData);

            alert('Transaction submitted confidentially!');
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div className="w-full max-w-md p-6 bg-gray-800 rounded-xl shadow-2xl border border-gray-700">
            <h2 className="text-2xl font-bold text-white mb-6">Confidential Transfer</h2>

            <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                    <label htmlFor="recipient" className="block text-sm font-medium text-gray-300">
                        Recipient Address (0x...)
                    </label>
                    <input
                        id="recipient"
                        type="text"
                        value={recipient}
                        onChange={(e) => setRecipient(e.target.value)}
                        className="mt-1 block w-full px-3 py-2 bg-gray-900 border border-gray-600 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="0x123..."
                    />
                </div>

                <div>
                    <label htmlFor="amount" className="block text-sm font-medium text-gray-300">
                        Amount (USDC)
                    </label>
                    <input
                        id="amount"
                        type="number"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        className="mt-1 block w-full px-3 py-2 bg-gray-900 border border-gray-600 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="100.00"
                    />
                </div>

                {error && (
                    <div className="text-red-400 text-sm bg-red-900/20 p-2 rounded">
                        Error: {error}
                    </div>
                )}

                <button
                    type="submit"
                    disabled={isLoading}
                    className={`w-full py-3 px-4 rounded-md font-semibold text-white transition-colors ${isLoading
                            ? 'bg-blue-800 cursor-not-allowed'
                            : 'bg-blue-600 hover:bg-blue-700'
                        }`}
                >
                    {isLoading ? 'Generating Proof...' : 'Send Privately'}
                </button>
            </form>

            <div className="mt-4 text-xs text-gray-500 text-center">
                Powered by Arc Network Privacy Precompile
            </div>
        </div>
    );
};
