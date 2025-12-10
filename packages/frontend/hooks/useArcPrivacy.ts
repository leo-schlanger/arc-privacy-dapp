import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseUnits } from 'viem';
import { CONFIDENTIAL_TRANSFER_ABI } from '../lib/contracts';
import { CONFIDENTIAL_HELPER_ADDRESS } from '../lib/constants';

interface ProofData {
    proof: `0x${string}`;
    root: `0x${string}`;
    nullifierHash: `0x${string}`;
    recipient: `0x${string}`;
    amount: bigint;
}

export const useArcPrivacy = () => {
    const [isGenerating, setIsGenerating] = useState(false);
    const { writeContract, data: hash, error: writeError, isPending } = useWriteContract();

    const { isLoading: isConfirming, isSuccess: isConfirmed } =
        useWaitForTransactionReceipt({ hash });

    const generateProof = async (amountStr: string, recipient: string): Promise<ProofData> => {
        setIsGenerating(true);
        // Mock proof generation
        return new Promise((resolve) => {
            setTimeout(() => {
                setIsGenerating(false);
                resolve({
                    proof: "0x12345678" as `0x${string}`,
                    root: "0x0000000000000000000000000000000000000000000000000000000000000000" as `0x${string}`,
                    nullifierHash: "0x0000000000000000000000000000000000000000000000000000000000001111" as `0x${string}`,
                    recipient: recipient as `0x${string}`,
                    amount: parseUnits(amountStr, 6) // USDC 6 decimals
                });
            }, 1500);
        });
    };

    const sendConfidentialTransaction = (proofData: ProofData) => {
        writeContract({
            address: CONFIDENTIAL_HELPER_ADDRESS,
            abi: CONFIDENTIAL_TRANSFER_ABI,
            functionName: 'confidentialTransfer',
            args: [
                proofData.proof,
                proofData.root,
                proofData.nullifierHash,
                proofData.recipient,
                proofData.amount
            ],
        });
    };

    return {
        generateProof,
        sendConfidentialTransaction,
        isGenerating,
        isPending,
        isConfirming,
        isConfirmed,
        hash,
        error: writeError
    };
};
