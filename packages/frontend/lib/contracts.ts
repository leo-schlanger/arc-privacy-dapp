export const CONFIDENTIAL_TRANSFER_ABI = [
    {
        "type": "error",
        "name": "InvalidAmount",
        "inputs": []
    },
    {
        "type": "error",
        "name": "InvalidProof",
        "inputs": []
    },
    {
        "type": "error",
        "name": "InvalidRecipient",
        "inputs": []
    },
    {
        "type": "function",
        "name": "confidentialTransfer",
        "inputs": [
            { "name": "proof", "type": "bytes", "internalType": "bytes" },
            { "name": "root", "type": "bytes32", "internalType": "bytes32" },
            { "name": "nullifierHash", "type": "bytes32", "internalType": "bytes32" },
            { "name": "recipient", "type": "address", "internalType": "address" },
            { "name": "amount", "type": "uint256", "internalType": "uint256" }
        ],
        "outputs": [{ "name": "success", "type": "bool", "internalType": "bool" }],
        "stateMutability": "nonpayable"
    },
    {
        "type": "event",
        "name": "ConfidentialTransferExecuted",
        "inputs": [
            { "name": "nullifierHash", "type": "bytes32", "indexed": true, "internalType": "bytes32" },
            { "name": "root", "type": "bytes32", "indexed": true, "internalType": "bytes32" }
        ],
        "anonymous": false
    }
] as const;
