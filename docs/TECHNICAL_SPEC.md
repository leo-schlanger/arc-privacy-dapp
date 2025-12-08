# Technical Specification

## Overview
ArcShield enables confidential transfers of USDC on the Arc Network. It abstracts the complexity of Zero-Knowledge Proof (ZKP) generation and interaction with the Arc Privacy Precompile.

## Transaction Flow

1.  **User Input**: The user selects a recipient address and an amount of USDC to send on the frontend interface.
2.  **Proof Generation (Client-Side)**:
    *   The frontend uses a WASM-based circuit prover to generate a ZK-proof.
    *   **Note**: For this version, the proof generation is mocked/simplified but follows the standard Groth16 interface expected by the precompile.
    *   *Input*: `(sender_private_key, recipient_public_key, amount, merkle_path)`
    *   *Output*: `(proof_bytes, public_inputs)`
3.  **Contract Interaction**:
    *   The client calls the `confidentialTransfer` function on the `ConfidentialTransferHelper` contract.
    *   The payload includes the generated proof and the encrypted transaction data.
4.  **Precompile Verification**:
    *   The `ConfidentialTransferHelper` contract performs a `staticcall` to the Arc Privacy Precompile (`0xARC_PRIVACY_PRECOMPILE`).
    *   If the proof is valid, the precompile updates the private state tree.
    *   If invalid, the transaction reverts.

## Smart Contract Interface

### `ConfidentialTransferHelper.sol`

This stateless contract acts as a facade/proxy for the system.

**Address**: `TODO: Deploy Address`

#### `confidentialTransfer`
Executes a private transaction by collecting the user's proof and forwarding it to the native precompile.

```solidity
function confidentialTransfer(
    bytes calldata proof, 
    bytes32 root, 
    bytes32 nullifierHash, 
    address recipient, 
    uint256 amount
) external returns (bool success);
```

**Parameters:**
*   `proof`: The ZK-SNARK proof bytes.
*   `root`: The Merkle root of the state tree against which the proof was generated.
*   `nullifierHash`: Unique hash to prevent double-spending of the input note.
*   `recipient`: The destination address (if semi-private) or encrypted output note.
*   `amount`: The amount of USDC being transferred.

---

## Data Structures

### ZK Proof (Mock/Standard)
We utilize a standard format compatible with the Arc Precompile constraints.
- Curve: BN254
- Proof Size: ~256 bytes

## Security Considerations
- **Front-running**: Since the nullifier is public in the mempool, we must ensure the precompile handles replay protection atomically.
- **Trusted Setup**: Relies on Arc Network's initial trusted setup for the privacy circuits.
