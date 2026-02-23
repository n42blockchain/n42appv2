// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// N42 Wallet Account Abstraction (ERC-4337) Module
//
// This module provides complete ERC-4337 v0.7 Account Abstraction support:
// - Smart account creation and management
// - UserOperation building and signing
// - Bundler integration (Pimlico, StackUp)
// - Paymaster support for gas sponsorship
// - Batch transactions
//
// Supported chains:
// - Ethereum (ETH)
// - Base (BASE)
// - Arbitrum (ARB)
// - Optimism (OP)
// - Polygon (MATIC)
//
// Usage:
// ```dart
// import 'package:n42_wallet/features/wallet/aa/aa.dart';
//
// // Create a smart account
// final factory = SmartAccountFactory(
//   ownerAddress: '0x...',
//   chainId: 1,
// );
// final account = factory.createAccount(type: SmartAccountType.simpleAccount);
//
// // Build a UserOperation
// final userOp = UserOpBuilder()
//   .setSenderFromAccount(account)
//   .setNonce(nonce)
//   .setEthTransfer(to, value)
//   .setGasFees(maxFeePerGas: fee, maxPriorityFeePerGas: priority)
//   .build();
//
// // Send via bundler
// final bundler = BundlerClient.forChain('ETH', apiKey: 'your-api-key');
// final hash = await bundler.sendUserOperation(userOp);
// ```

// Core configuration and errors
export 'core/aa_config.dart';
export 'core/aa_constants.dart';
export 'core/aa_errors.dart';

// Models
export 'models/user_operation.dart';
export 'models/user_operation_receipt.dart';
export 'models/smart_account.dart';
export 'models/paymaster_data.dart';

// Builders
export 'builder/user_op_builder.dart';
export 'builder/calldata_builder.dart';
export 'builder/signature_builder.dart';

// Account management
export 'account/smart_account_factory.dart';
export 'account/account_deployer.dart';
export 'account/account_types/simple_account.dart';
export 'account/account_types/simple7702_account.dart';

// Bundler
export 'bundler/bundler_client.dart';
export 'bundler/bundler_config.dart';

// Utilities
export 'utils/gas_estimator.dart';
export 'utils/user_op_hash.dart';
export 'utils/eip7702_handler.dart';

// Provider
export 'provider/aa_provider.dart';
