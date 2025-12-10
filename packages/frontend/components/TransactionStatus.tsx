import React from 'react';

interface TransactionStatusProps {
    hash?: string;
    isPending: boolean;
    isConfirming: boolean;
    isConfirmed: boolean;
    error?: Error | null;
}

export const TransactionStatus: React.FC<TransactionStatusProps> = ({
    hash,
    isPending,
    isConfirming,
    isConfirmed,
    error
}) => {
    if (!hash && !error && !isPending && !isConfirming) return null;

    return (
        <div className="mt-4 p-4 rounded-lg bg-gray-900/50 border border-gray-800">
            {error && (
                <div className="text-red-400 text-sm">
                    <span className="font-bold">Error:</span> {error.message}
                </div>
            )}

            {hash && (
                <div className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-400">Status:</span>
                        <span className={`font-bold ${isConfirmed ? 'text-green-400' : 'text-yellow-400'}`}>
                            {isConfirmed ? 'Confirmed' : isConfirming ? 'Processing...' : 'Pending'}
                        </span>
                    </div>

                    <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-400">Transaction Hash:</span>
                        <a
                            href={`https://testnet.arcscan.app/tx/${hash}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-blue-400 hover:text-blue-300 underline truncate max-w-[200px]"
                        >
                            {hash}
                        </a>
                    </div>

                    {isConfirmed && (
                        <div className="flex items-center justify-between text-sm">
                            <span className="text-gray-400">Gas Cost:</span>
                            <span className="text-gray-200">~0.01 USDC (Mock)</span>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
};
