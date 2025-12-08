// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ConfidentialTransferHelper
 * @notice Stateless proxy contract for interacting with the Arc Privacy Precompile.
 * @dev This contract facilitates confidential USDC transfers by verifying ZK-proofs via the native precompile.
 */
contract ConfidentialTransferHelper {
    
    /// @notice The address of the Arc native privacy precompile.
    /// @dev Placeholder address used for hackathon/development purposes.
    address public constant ARC_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000999;

    /// @notice Address of the native USDC token on Arc Network.
    IERC20 public immutable usdcToken;

    event Metadata(string message);

    constructor(address _usdcToken) {
        usdcToken = IERC20(_usdcToken);
    }

    /**
     * @notice Executes a confidential transfer using a Zero-Knowledge Proof.
     * @dev This function blindly forwards the proof and public inputs to the precompile via a staticcall.
     *      It effectively "spends" a private note and creates a new one (or deposits to a public address).
     * 
     * @param proof The encoded ZK-SNARK proof verifying the user owns the funds and the transaction is valid.
     * @param root The Merkle root of the current (or recent) state tree.
     * @param nullifierHash A unique hash derived from the private note ensuring it hasn't been spent.
     * @param recipient The recipient address (can be a public address or a stealth address hash).
     * @param amount The amount of funds involved in the transfer.
     * 
     * @return success True if the precompile verified the proof and executed the state transition.
     */
    function confidentialTransfer(
        bytes calldata proof,
        bytes32 root,
        bytes32 nullifierHash,
        address recipient,
        uint256 amount
    ) external returns (bool success) {
        // 1. Prepare data for the precompile call. 
        //    The encoding must match the precompile's expected ABI.
        bytes memory input = abi.encode(proof, root, nullifierHash, recipient, amount);

        // 2. Call the precompile using staticcall (since we are verifying, though state updates might require call).
        //    Note: If the specific precompile updates state, we use 'call'. 
        //    Assuming 'call' here as privacy usually involves updating the nullifier set.
        (bool callSuccess, ) = ARC_PRECOMPILE_ADDRESS.call(input);

        require(callSuccess, "ArcPrivacy: Proof verification failed or internal error");

        // 3. Emit event for client-side indexing (privacy-preserving metadata only)
        emit Metadata("Confidential transfer executed successfully");

        return true;
    }
}
