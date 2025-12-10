// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ConfidentialTransferHelper} from "../src/ConfidentialTransferHelper.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

// Mock USDC for testing
contract MockERC20 is ERC20 {
    constructor() ERC20("USDC", "USDC") {}
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ConfidentialTransferHelperTest is Test {
    ConfidentialTransferHelper public helper;
    MockERC20 public usdc;

    address user = address(0x1);
    address recipient = address(0x2);
    address otherUser = address(0x3);

    // Events from Contract
    event ConfidentialTransferExecuted(bytes32 indexed nullifierHash, bytes32 indexed root);

    function setUp() public {
        // Deploy Mock Token
        usdc = new MockERC20();
        // Deploy Helper
        helper = new ConfidentialTransferHelper(address(usdc));
        
        // Mint tokens
        usdc.mint(user, 1000 * 10**6);
        usdc.mint(otherUser, 500 * 10**6);
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    function test_Constructor_SetsUSDCAddress() public {
        assertEq(address(helper.usdcToken()), address(usdc));
    }

    function test_Constructor_ZeroTokenAddress_Reverts() public {
        vm.expectRevert(ConfidentialTransferHelper.InvalidRecipient.selector);
        new ConfidentialTransferHelper(address(0));
    }

    /*//////////////////////////////////////////////////////////////
                               HAPPY PATH
    //////////////////////////////////////////////////////////////*/

    function test_SendConfidential_WithValidData_Succeeds() public {
        vm.prank(user);
        
        bytes memory proof = hex"1234";
        bytes32 root = bytes32(uint256(123));
        bytes32 nullifier = bytes32(uint256(456));
        uint256 amount = 100 * 10**6;

        // Mock the precompile call to return true
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(proof, root, nullifier, recipient, amount),
            abi.encode(true)
        );

        // Expect event
        vm.expectEmit(true, true, false, false);
        emit ConfidentialTransferExecuted(nullifier, root);

        bool success = helper.confidentialTransfer(proof, root, nullifier, recipient, amount);
        assertTrue(success, "Transfer should succeed");
    }

    function test_SendConfidential_MaxAmount_Succeeds() public {
        uint256 maxAmount = 1000 * 10**6; // user balance
        vm.prank(user);

        bytes memory proof = hex"1234";
        bytes32 root = bytes32(uint256(999));
        bytes32 nullifier = bytes32(uint256(888));

        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(proof, root, nullifier, recipient, maxAmount),
            abi.encode(true)
        );

        bool success = helper.confidentialTransfer(proof, root, nullifier, recipient, maxAmount);
        assertTrue(success);
    }

    /*//////////////////////////////////////////////////////////////
                               EDGE CASES
    //////////////////////////////////////////////////////////////*/

    function test_SendConfidential_ZeroAmount_Reverts() public {
        vm.prank(user);
        
        vm.expectRevert(ConfidentialTransferHelper.InvalidAmount.selector);
        helper.confidentialTransfer(hex"", bytes32(0), bytes32(0), recipient, 0);
    }

    function test_SendConfidential_ZeroRecipient_Reverts() public {
        vm.prank(user);
        
        vm.expectRevert(ConfidentialTransferHelper.InvalidRecipient.selector);
        helper.confidentialTransfer(hex"", bytes32(0), bytes32(0), address(0), 100);
    }

    /*//////////////////////////////////////////////////////////////
                               ERROR CASES
    //////////////////////////////////////////////////////////////*/

    function test_SendConfidential_PrecompileFails_Reverts() public {
        vm.prank(user);
        bytes memory proof = hex"9999";
        
        // Use etch to deploy a contract that always reverts at the precompile address
        // This is robust against Vm interface variations
        vm.etch(helper.ARC_PRECOMPILE_ADDRESS(), address(new AlwaysRevert()).code);

        // Expect the revert string from AlwaysRevert
        vm.expectRevert("Internal Precompile Error");
        helper.confidentialTransfer(proof, bytes32(0), bytes32(0), recipient, 50);
    }

    function test_SendConfidential_InvalidProofResult_Reverts() public {
        vm.prank(user);
        
        // Construct the exact calldata we expect the contract to send
        bytes memory expectedCallData = abi.encode(
            hex"deadbeef", 
            bytes32(0), 
            bytes32(0), 
            recipient, 
            uint256(50)
        );

        // Mock exact call to return false (validation failure)
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            expectedCallData,
            abi.encode(false)
        );

        vm.expectRevert(ConfidentialTransferHelper.InvalidProof.selector);
        helper.confidentialTransfer(hex"deadbeef", bytes32(0), bytes32(0), recipient, 50);
    }

    function test_SendConfidential_EmptyProof_Handled() public {
        vm.prank(user);
        
        // Construct expected calldata for empty proof
        bytes memory expectedCallData = abi.encode(
            bytes(""), 
            bytes32(0), 
            bytes32(0), 
            recipient, 
            uint256(100)
        );

        // If precompile returns false (invalid), it should revert
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            expectedCallData,
            abi.encode(false) 
        );

        vm.expectRevert(ConfidentialTransferHelper.InvalidProof.selector);
        helper.confidentialTransfer(hex"", bytes32(0), bytes32(0), recipient, 100);
    }

    function test_SendConfidential_PrecompileReturnsGarbage_Reverts() public {
        vm.prank(user);
        
        bytes memory expectedCallData = abi.encode(
            hex"12", 
            bytes32(0), 
            bytes32(0), 
            recipient, 
            uint256(100)
        );

        // Mock precompile returning empty data (invalid bool encoding)
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            expectedCallData,
            hex"" 
        );

        // Should revert due to decoding error - catch any revert
        vm.expectRevert(); 
        helper.confidentialTransfer(hex"12", bytes32(0), bytes32(0), recipient, 100);
    }

    /*//////////////////////////////////////////////////////////////
                                FUZZING
    //////////////////////////////////////////////////////////////*/

    function testFuzz_SendConfidential_Amount(uint256 amount) public {
        // Bound amount to be non-zero and reasonable
        amount = bound(amount, 1, type(uint128).max);
        
        vm.prank(user);

        // Mock SUCCESS for any valid amount
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(true), // We match loosely here or need to encode exact calldata
            abi.encode(true)
        );
        // Note: mockCall without calldata matches all calls to that address if we are lazy,
        // but here we should be specific if possible. For fuzzing, it's hard to predict exact calldata 
        // unless we encode it here.
        
        // Let's use the explicit calldata for the mock to be strict
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(hex"11", bytes32(0), bytes32(0), recipient, amount),
            abi.encode(true)
        );

        bool success = helper.confidentialTransfer(hex"11", bytes32(0), bytes32(0), recipient, amount);
        assertTrue(success);
    }

    function testFuzz_SendConfidential_RandomRecipient(address randomRecipient) public {
        vm.assume(randomRecipient != address(0));
        
        vm.prank(user);
        
        vm.mockCall(
            helper.ARC_PRECOMPILE_ADDRESS(),
            abi.encode(hex"11", bytes32(0), bytes32(0), randomRecipient, 100),
            abi.encode(true)
        );

        bool success = helper.confidentialTransfer(hex"11", bytes32(0), bytes32(0), randomRecipient, 100);
        assertTrue(success);
    }
}

// Helper contract for testing reverts
contract AlwaysRevert {
    fallback() external {
        revert("Internal Precompile Error");
    }
}
