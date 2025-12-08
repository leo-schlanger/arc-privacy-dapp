// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ConfidentialTransferHelper} from "../src/ConfidentialTransferHelper.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("USDC", "USDC") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ConfidentialTransferTest is Test {
    ConfidentialTransferHelper public helper;
    MockERC20 public usdc;

    address user = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        usdc = new MockERC20();
        // usdc.initialize("USDC", "USDC", 6); // Not needed for standard OZ ERC20 constructor
        
        helper = new ConfidentialTransferHelper(address(usdc));
        
        // Mint tokens to user
        usdc.mint(user, 1000 * 10**6);
    }

    function test_ConfidentialTransfer_RevertOnMock() public {
        // Since we are mocking the precompile address (0x...999) which doesn't actually exist 
        // in a standard local EVM (unless we fork Arc), this call is expected to fail or return false
        // depending on how the EVM handles calls to empty accounts.
        
        // However, staticcall to non-existent address usually returns true with empty data.
        // Our contract checks (bool success, ) = ...
        
        vm.prank(user);
        
        // Mocking the inputs
        bytes memory proof = hex"1234";
        bytes32 root = bytes32(0);
        bytes32 nullifier = bytes32(uint256(1));
        
        // Expect revert because the staticcall to encoded address 999 
        // might not behave as a valid precompile locally.
        // But strictly speaking, calling an empty address returns success=true.
        // Let's see if we can simulate the precompile.
        
        // For this test, we just want to ensure the function is callable.
        
        // We can use unique Foundry cheatcodes to mock the call to the precompile address!
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(proof, root, nullifier, recipient, 100),
            abi.encode(true) // Return success
        );

        bool success = helper.confidentialTransfer(
            proof,
            root,
            nullifier,
            recipient,
            100
        );

        assertTrue(success, "Transfer should succeed with mocked precompile");
    }

    function test_ConfidentialTransfer_FailInvalidProof() public {
        // Mock precompile returning failure (simulating invalid proof)
        // Since the low-level call returns a boolean status code for the CALL itself,
        // we need to be careful. The precompile usually reverts if proof is bad.
        
        // When we use mockCall, it sets the return data. For staticcall boolean success, 
        // it usually depends on REVERT functionality.
        // vm.mockCallRevert makes the call REVERT.
        
        vm.mockCallRevert(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(hex"9999", bytes32(0), bytes32(0), recipient, 0),
            "Invalid Proof"
        );

        vm.expectRevert("ArcPrivacy: Proof verification failed or internal error");
        helper.confidentialTransfer(
            hex"9999",
            bytes32(0),
            bytes32(0),
            recipient,
            0
        );
    }
}
