// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import '../core/aa_config.dart';
import '../core/aa_constants.dart';
import '../core/aa_errors.dart';
import '../models/smart_account.dart';
import '../models/user_operation.dart';
import '../builder/calldata_builder.dart';
import '../builder/user_op_builder.dart';
import '../account/account_types/simple7702_account.dart';

/// Handles smart account deployment through UserOperations
///
/// Manages the deployment of smart accounts by constructing the
/// appropriate init code and including it in the first UserOperation.
///
/// Supports multiple account types:
/// - SimpleAccount (v0.7 and v0.8)
/// - Simple7702Account (EIP-7702, v0.8 only)
/// - Safe, Kernel, Biconomy (planned)
class AccountDeployer {
  final AAChainConfig _config;

  AccountDeployer({required AAChainConfig config}) : _config = config;

  // ─── Reusable gas constants ────────────────────────────────────────────────

  static final BigInt _eip7702VerificationGas = BigInt.from(
    Simple7702GasConstants.authorizationGas +
    Simple7702GasConstants.signatureValidation,
  );
  static final BigInt _deploymentGas =
      BigInt.from(AAConstants.accountDeploymentGas);
  static final BigInt _preVerificationGas =
      BigInt.from(AAConstants.defaultPreVerificationGas);
  static final BigInt _callGasLimit =
      BigInt.from(AAConstants.defaultCallGasLimit);

  /// Create a factory for a specific chain
  factory AccountDeployer.forChain(
    String chainSymbol, {
    EntryPointVersion? version,
  }) {
    final config = AAConfig.getChainConfig(chainSymbol, version: version);
    if (config == null) {
      throw AAUnsupportedChainError(chainSymbol);
    }
    return AccountDeployer(config: config);
  }

  /// Create a v0.8 deployer
  factory AccountDeployer.v08(String chainSymbol) {
    return AccountDeployer.forChain(chainSymbol, version: EntryPointVersion.v08);
  }

  /// Create a v0.7 deployer (legacy)
  factory AccountDeployer.v07(String chainSymbol) {
    return AccountDeployer.forChain(chainSymbol, version: EntryPointVersion.v07);
  }

  /// Get the EntryPoint version
  EntryPointVersion get version => _config.version;

  /// Check if EIP-7702 is supported
  bool get supportsEIP7702 => _config.supportsEIP7702;

  /// Build init code for a SimpleAccount
  Uint8List buildSimpleAccountInitCode({
    required String owner,
    required BigInt salt,
  }) {
    return CalldataBuilder.buildSimpleAccountInitCode(
      factoryAddress: _config.simpleAccountFactory,
      owner: owner,
      salt: salt,
    );
  }

  /// Build init code based on account type
  ///
  /// Returns null for EIP-7702 accounts which don't need deployment.
  Uint8List? buildInitCodeForAccountType({
    required SmartAccountType type,
    required String owner,
    required BigInt salt,
  }) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return buildSimpleAccountInitCode(owner: owner, salt: salt);

      case SmartAccountType.simple7702Account:
        // EIP-7702 accounts don't need init code - they use the EOA directly
        return null;

      case SmartAccountType.safe:
      case SmartAccountType.kernel:
      case SmartAccountType.biconomy:
      case SmartAccountType.custom:
        // These account types require specific factory implementations.
        // See: https://docs.safe.global/advanced/erc-4337/4337-safe
        // See: https://docs.zerodev.app/sdk/core-api/create-account
        throw UnimplementedError(
          'Init code for ${type.name} is not yet implemented. '
          'Currently only SimpleAccount and Simple7702Account are supported.',
        );
    }
  }

  /// Check if a UserOperation needs init code (first transaction)
  bool needsInitCode(SmartAccount account) {
    // EIP-7702 accounts never need init code
    return account.type != SmartAccountType.simple7702Account &&
        account.state == SmartAccountState.notDeployed;
  }

  /// Check if account type requires deployment
  bool requiresDeployment(SmartAccountType type) {
    return type != SmartAccountType.simple7702Account;
  }

  /// Add init code to a UserOpBuilder if needed
  UserOpBuilder addInitCodeIfNeeded(
    UserOpBuilder builder,
    SmartAccount account,
  ) {
    if (!needsInitCode(account)) {
      return builder;
    }

    final initCode = buildInitCodeForAccountType(
      type: account.type,
      owner: account.ownerAddress,
      salt: account.salt,
    );

    if (initCode == null) {
      return builder;
    }

    return builder
      ..setInitCode(initCode)
      ..setGasLimits(
        // Increase verification gas for deployment
        verificationGasLimit: _deploymentGas,
      );
  }

  /// Add EIP-7702 authorization to a UserOpBuilder
  ///
  /// Only applicable for Simple7702Account types on v0.8 EntryPoint.
  UserOpBuilder addEIP7702AuthIfNeeded(
    UserOpBuilder builder,
    SmartAccount account,
    EIP7702Authorization? authorization,
  ) {
    if (account.type != SmartAccountType.simple7702Account) {
      return builder;
    }

    if (!supportsEIP7702) {
      throw AAConfigurationError(
        'EIP-7702 is not supported on this chain configuration',
      );
    }

    if (authorization != null) {
      builder.setEIP7702Auth(authorization.encode());
    }

    return builder;
  }

  /// Create a deployment UserOperation
  ///
  /// This creates a UserOperation that will deploy the smart account
  /// and optionally execute an action in the same transaction.
  ///
  /// For EIP-7702 accounts, this creates a UserOp with authorization
  /// instead of init code.
  UserOperation createDeploymentUserOp({
    required SmartAccount account,
    required BigInt nonce,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    Uint8List? callData,
    EIP7702Authorization? eip7702Authorization,
  }) {
    // If no call data provided, use a minimal execute call
    final execData = callData ??
        CalldataBuilder.buildExecute(
          target: account.address,
          value: BigInt.zero,
          data: Uint8List(0),
        );

    final builder = UserOpBuilder()
        .setSenderFromAccount(account)
        .setNonce(nonce)
        .setCallData(execData)
        .setPreVerificationGas(_preVerificationGas)
        .setGasFees(
          maxFeePerGas: maxFeePerGas,
          maxPriorityFeePerGas: maxPriorityFeePerGas,
        );

    // Handle different account types
    final BigInt verificationGas;
    if (account.type == SmartAccountType.simple7702Account) {
      // EIP-7702: Add authorization instead of init code
      if (eip7702Authorization != null) {
        builder.setEIP7702Auth(eip7702Authorization.encode());
      }
      verificationGas = _eip7702VerificationGas;
    } else {
      // Traditional smart account: Add init code
      final initCode = buildInitCodeForAccountType(
        type: account.type,
        owner: account.ownerAddress,
        salt: account.salt,
      );
      if (initCode != null) {
        builder.setInitCode(initCode);
      }
      verificationGas = _deploymentGas;
    }

    builder.setGasLimits(
      verificationGasLimit: verificationGas,
      callGasLimit: _callGasLimit,
    );

    return builder.build();
  }

  /// Create a UserOperation for EIP-7702 account
  ///
  /// EIP-7702 accounts don't need deployment, but they do need
  /// authorization for each transaction.
  UserOperation createEIP7702UserOp({
    required String eoaAddress,
    required BigInt nonce,
    required Uint8List callData,
    required BigInt maxFeePerGas,
    required BigInt maxPriorityFeePerGas,
    required EIP7702Authorization authorization,
    Uint8List? paymasterAndData,
  }) {
    if (!supportsEIP7702) {
      throw AAConfigurationError(
        'EIP-7702 is not supported on this chain configuration',
      );
    }

    return UserOpBuilder()
        .setSender(eoaAddress)
        .setNonce(nonce)
        .setCallData(callData)
        .setGasLimits(
          verificationGasLimit: _eip7702VerificationGas,
          callGasLimit: _callGasLimit,
        )
        .setPreVerificationGas(_preVerificationGas)
        .setGasFees(
          maxFeePerGas: maxFeePerGas,
          maxPriorityFeePerGas: maxPriorityFeePerGas,
        )
        .setPaymasterAndData(paymasterAndData)
        .setEIP7702Auth(authorization.encode())
        .build();
  }

  /// Estimate deployment cost
  ///
  /// For EIP-7702, this returns the authorization cost (much lower).
  DeploymentCostEstimate estimateDeploymentCost({
    required BigInt maxFeePerGas,
    SmartAccountType accountType = SmartAccountType.simpleAccount,
  }) {
    // EIP-7702 doesn't require deployment, only authorization
    final baseGas = accountType == SmartAccountType.simple7702Account
        ? BigInt.from(Simple7702GasConstants.authorizationGas)
        : _deploymentGas;
    final gasUnits = baseGas + _preVerificationGas;

    return DeploymentCostEstimate(
      gasUnits: gasUnits,
      maxFeePerGas: maxFeePerGas,
      totalCost: gasUnits * maxFeePerGas,
      accountType: accountType,
    );
  }

  /// Compare deployment costs between account types
  DeploymentCostComparison compareDeploymentCosts({
    required BigInt maxFeePerGas,
  }) {
    final simpleAccountCost = estimateDeploymentCost(
      maxFeePerGas: maxFeePerGas,
      accountType: SmartAccountType.simpleAccount,
    );

    final eip7702Cost = supportsEIP7702
        ? estimateDeploymentCost(
            maxFeePerGas: maxFeePerGas,
            accountType: SmartAccountType.simple7702Account,
          )
        : null;

    return DeploymentCostComparison(
      simpleAccountCost: simpleAccountCost,
      eip7702Cost: eip7702Cost,
    );
  }

  /// Get factory address
  String get factoryAddress => _config.simpleAccountFactory;

  /// Get EIP-7702 implementation address
  String? get eip7702ImplementationAddress => _config.simple7702AccountFactory;

  /// Get entry point address
  String get entryPoint => _config.entryPoint;
}

/// Deployment cost estimate
class DeploymentCostEstimate {
  /// Total gas units required
  final BigInt gasUnits;

  /// Max fee per gas
  final BigInt maxFeePerGas;

  /// Total cost in wei
  final BigInt totalCost;

  /// Account type for this estimate
  final SmartAccountType accountType;

  const DeploymentCostEstimate({
    required this.gasUnits,
    required this.maxFeePerGas,
    required this.totalCost,
    this.accountType = SmartAccountType.simpleAccount,
  });

  /// Get cost in ETH (as double)
  double get costInEth {
    return totalCost.toDouble() / 1e18;
  }

  /// Format cost for display
  String formatCost({int decimals = 6}) {
    return costInEth.toStringAsFixed(decimals);
  }

  /// Check if this is an EIP-7702 estimate
  bool get isEIP7702 => accountType == SmartAccountType.simple7702Account;

  @override
  String toString() {
    return 'DeploymentCostEstimate(type: ${accountType.name}, gasUnits: $gasUnits, cost: ${formatCost()} ETH)';
  }
}

/// Comparison between different deployment options
class DeploymentCostComparison {
  /// Cost for SimpleAccount deployment
  final DeploymentCostEstimate simpleAccountCost;

  /// Cost for EIP-7702 (null if not supported)
  final DeploymentCostEstimate? eip7702Cost;

  const DeploymentCostComparison({
    required this.simpleAccountCost,
    this.eip7702Cost,
  });

  /// Check if EIP-7702 is available
  bool get eip7702Available => eip7702Cost != null;

  /// Get savings when using EIP-7702
  BigInt get eip7702Savings {
    if (eip7702Cost == null) return BigInt.zero;
    return simpleAccountCost.totalCost - eip7702Cost!.totalCost;
  }

  /// Get savings percentage
  double get savingsPercentage {
    if (eip7702Cost == null || simpleAccountCost.totalCost == BigInt.zero) {
      return 0.0;
    }
    return (eip7702Savings.toDouble() / simpleAccountCost.totalCost.toDouble()) * 100;
  }

  /// Get recommendation
  String get recommendation {
    if (!eip7702Available) {
      return 'Use SimpleAccount (EIP-7702 not available)';
    }
    if (savingsPercentage > 50) {
      return 'Strongly recommend EIP-7702 (${savingsPercentage.toStringAsFixed(1)}% savings)';
    }
    if (savingsPercentage > 20) {
      return 'Consider EIP-7702 (${savingsPercentage.toStringAsFixed(1)}% savings)';
    }
    return 'Either option is reasonable';
  }

  @override
  String toString() {
    final sb = StringBuffer('DeploymentCostComparison:\n');
    sb.writeln('  SimpleAccount: ${simpleAccountCost.formatCost()} ETH');
    if (eip7702Cost != null) {
      sb.writeln('  EIP-7702: ${eip7702Cost!.formatCost()} ETH');
      sb.writeln('  Savings: ${(eip7702Savings.toDouble() / 1e18).toStringAsFixed(6)} ETH (${savingsPercentage.toStringAsFixed(1)}%)');
    }
    sb.writeln('  Recommendation: $recommendation');
    return sb.toString();
  }
}

/// Deployment status tracking
class DeploymentStatus {
  final SmartAccountState state;
  final String? transactionHash;
  final String? userOpHash;
  final String? error;
  final DateTime timestamp;

  const DeploymentStatus({
    required this.state,
    this.transactionHash,
    this.userOpHash,
    this.error,
    required this.timestamp,
  });

  factory DeploymentStatus.pending({String? userOpHash}) {
    return DeploymentStatus(
      state: SmartAccountState.deploying,
      userOpHash: userOpHash,
      timestamp: DateTime.now(),
    );
  }

  factory DeploymentStatus.success({
    required String transactionHash,
    String? userOpHash,
  }) {
    return DeploymentStatus(
      state: SmartAccountState.deployed,
      transactionHash: transactionHash,
      userOpHash: userOpHash,
      timestamp: DateTime.now(),
    );
  }

  factory DeploymentStatus.failed(String error) {
    return DeploymentStatus(
      state: SmartAccountState.error,
      error: error,
      timestamp: DateTime.now(),
    );
  }

  bool get isPending => state == SmartAccountState.deploying;
  bool get isSuccess => state == SmartAccountState.deployed;
  bool get isFailed => state == SmartAccountState.error;

  @override
  String toString() {
    return 'DeploymentStatus(state: ${state.name}, txHash: $transactionHash)';
  }
}
