// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";


/**
 * @title ConfidentialTransferHelper
 * @notice Stateless helper contract for facilitating private transactions on the Arc Network.
 * @dev Acts as a proxy to verify ZK-proofs via the native Arc Privacy Precompile.
 *      This contract does not hold user funds excessively; it delegates privacy logic to the L1 precompile.
 */
contract ConfidentialTransferHelper {

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the ZK proof verification fails at the precompile level.
    error InvalidProof();

    /// @notice Thrown when the transfer amount is zero, which is not allowed.
    error InvalidAmount();

    /// @notice Thrown when the recipient address is the zero address.
    error InvalidRecipient();

    /// @notice Thrown when the interaction with the precompile fails unexpectedly.
    /// @param data The raw return data from the failed call.
    error PrecompileInteractionFailed(bytes data);

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a confidential transfer is successfully executed.
     * @dev We do NOT log the amount or recipient here to preserve privacy.
     *      Only metadata useful for client synchronization is emitted.
     * @param nullifierHash The unique hash preventing double-spending of the input note.
     * @param root The new Merkle root of the private state tree after insertion.
     */
    event ConfidentialTransferExecuted(bytes32 indexed nullifierHash, bytes32 indexed root);

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the Arc native privacy precompile.
    /// @dev This is a constant precompile address on the Arc Network.
    address public constant ARC_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000999;

    /// @notice The USDC token contract used for value transfer.
    IERC20 public immutable usdcToken;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the helper contract with the USDC token address.
     * @param _usdcToken The address of the canonical USDC token on Arc.
     */
    constructor(address _usdcToken) {
        if (_usdcToken == address(0)) revert InvalidRecipient();
        usdcToken = IERC20(_usdcToken);
    }

    /*//////////////////////////////////////////////////////////////
                             MAIN FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Executes a private transaction by submitting a ZK-proof to the Arc Precompile.
     * @dev Verifies that the sender owns the funds and nullifies the input note.
     *      Calling this function requires a generated ZK-SNARK proof.
     * 
     * @param proof The encoded ZK-SNARK proof verifying the transaction validity.
     * @param root The Merkle root of the state tree against which the proof was generated.
     * @param nullifierHash A unique hash derived from the private note ensuring it hasn't been spent.
     * @param recipient The destination address for the funds (if public output) or encrypted note.
     * @param amount The amount of USDC being transferred.
     * 
     * @return success Returns true if the proof was verified and state updated.
     */
    function confidentialTransfer(
        bytes calldata proof,
        bytes32 root,
        bytes32 nullifierHash,
        address recipient,
        uint256 amount
    ) external returns (bool success) {
        // 1. Validation
        if (amount == 0) revert InvalidAmount();
        if (recipient == address(0)) revert InvalidRecipient();

        // 2. Prepare data for the precompile call. 
        //    The encoding must match the precompile's expected ABI: (bytes, bytes32, bytes32, address, uint256)
        bytes memory inputData = abi.encode(proof, root, nullifierHash, recipient, amount);

        // 3. Call the precompile.
        //    We use a staticcall here for the PoC, but in production this might be a delegatecall 
        //    or normal call depending on if state updates happen in the precompile context.
        //    Assuming 'call' is needed to update the global nullifier set.
        (bool callSuccess, bytes memory returnData) = ARC_PRECOMPILE_ADDRESS.call(inputData);

        if (!callSuccess) {
            // Attempt to decode error or revert with generic error
            if (returnData.length > 0) {
                // Bubble up the revert reason
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert PrecompileInteractionFailed(returnData);
            }
        }

        // 4. Decode output. The precompile should return a boolean success indicator.
        bool verified = abi.decode(returnData, (bool));
        if (!verified) revert InvalidProof();

        // 5. Emit Event
        emit ConfidentialTransferExecuted(nullifierHash, root);

        return true;
    }
}
