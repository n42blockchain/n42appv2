// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

/// Constants for ERC-4337 Account Abstraction
class AAConstants {
  AAConstants._();

  // ==================== Gas Constants ====================

  /// Default verification gas limit
  static const int defaultVerificationGasLimit = 100000;

  /// Default call gas limit
  static const int defaultCallGasLimit = 100000;

  /// Default pre-verification gas
  static const int defaultPreVerificationGas = 50000;

  /// Gas buffer multiplier (1.2x = 20% buffer)
  static const double gasBufferMultiplier = 1.2;

  /// Minimum gas for account deployment
  static const int accountDeploymentGas = 300000;

  // ==================== UserOperation Constants ====================

  /// Empty bytes for optional fields
  static final Uint8List emptyBytes = Uint8List(0);

  /// Default signature placeholder for gas estimation
  static final Uint8List dummySignature = Uint8List.fromList(
    List.filled(65, 0xFF),
  );

  /// Signature length for ECDSA (r + s + v)
  static const int signatureLength = 65;

  // ==================== Account Types ====================

  /// SimpleAccount type identifier
  static const String simpleAccountType = 'SimpleAccount';

  /// Safe account type identifier
  static const String safeAccountType = 'Safe';

  /// Kernel account type identifier
  static const String kernelAccountType = 'Kernel';

  // ==================== Function Selectors ====================

  /// ERC20 transfer function selector: transfer(address,uint256)
  static const String erc20TransferSelector = '0xa9059cbb';

  /// ERC20 approve function selector: approve(address,uint256)
  static const String erc20ApproveSelector = '0x095ea7b3';

  /// Execute function selector: execute(address,uint256,bytes)
  static const String executeSelector = '0xb61d27f6';

  /// ExecuteBatch function selector: executeBatch(address[],uint256[],bytes[])
  static const String executeBatchSelector = '0x47e1da2a';

  /// Create account function selector: createAccount(address,uint256)
  static const String createAccountSelector = '0x5fbfb9cf';

  /// Get address function selector: getAddress(address,uint256)
  static const String getAddressSelector = '0x8cb84e18';

  // ==================== EntryPoint Function Selectors ====================

  /// handleOps function selector
  static const String handleOpsSelector = '0x765e827f';

  /// getNonce function selector
  static const String getNonceSelector = '0x35567e1a';

  // ==================== Storage Keys ====================

  /// Key for storing smart accounts in WalletInfo
  static const String smartAccountsStorageKey = 'smartAccounts';

  /// Key for storing preferred AA setting
  static const String preferAAStorageKey = 'preferAA';

  /// Key for storing default paymaster
  static const String defaultPaymasterStorageKey = 'defaultPaymaster';

  // ==================== Gas Deviation Thresholds ====================

  /// Total gas (verificationGasLimit + callGasLimit + preVerificationGas) above
  /// which a "gas very high" warning is surfaced to the user.
  static const int gasTotalWarningThreshold = 2000000;

  /// Total gas above which a "gas critically high" warning is surfaced.
  /// Operations approaching this limit are often mis-configured or re-entrancy
  /// attacks; the user should be strongly cautioned.
  static const int gasTotalCriticalThreshold = 5000000;

  /// verificationGasLimit above which an individual verification warning fires.
  static const int gasVerificationWarningThreshold = 500000;

  /// callGasLimit above which an individual call gas warning fires.
  static const int gasCallWarningThreshold = 500000;

  /// Percentage deviation (bundler estimate vs client estimate) above which a
  /// "warning" severity deviation alert is raised.
  static const double gasDeviationWarningPct = 50.0;

  /// Percentage deviation above which a "critical" severity deviation alert is
  /// raised (possible under-estimation — transaction likely to fail).
  static const double gasDeviationCriticalPct = 100.0;

  // ==================== Validation ====================

  /// Maximum UserOperation calldata size (128KB)
  static const int maxCalldataSize = 128 * 1024;

  /// Maximum nonce value
  static final BigInt maxNonce = BigInt.two.pow(192) - BigInt.one;

  /// Minimum pre-verification gas
  static const int minPreVerificationGas = 21000;

  // ==================== Timeouts ====================

  /// Bundler RPC timeout in milliseconds
  static const int bundlerRpcTimeout = 30000;

  /// Transaction confirmation timeout in milliseconds
  static const int confirmationTimeout = 120000;

  /// Polling interval for receipt in milliseconds
  static const int receiptPollingInterval = 2000;

  // ==================== Error Codes ====================

  /// Bundler error code: invalid UserOperation
  static const int errorInvalidUserOp = -32500;

  /// Bundler error code: execution reverted
  static const int errorExecutionReverted = -32521;

  /// Bundler error code: paymaster validation failed
  static const int errorPaymasterValidation = -32502;

  /// Bundler error code: insufficient funds
  static const int errorInsufficientFunds = -32503;
}

/// Nonce key constants for different use cases
class NonceKeys {
  NonceKeys._();

  /// Default nonce key (sequential transactions)
  static final BigInt defaultKey = BigInt.zero;

  /// Session key nonce key space
  static final BigInt sessionKeySpace = BigInt.from(1);

  /// Batch transaction nonce key space
  static final BigInt batchSpace = BigInt.from(2);
}
