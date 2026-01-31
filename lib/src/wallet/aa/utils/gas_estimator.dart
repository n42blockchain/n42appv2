// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import '../core/aa_constants.dart';
import '../models/user_operation.dart';
import '../models/smart_account.dart';
import '../bundler/bundler_client.dart';

/// Utility class for AA-specific gas estimation
///
/// Handles the complexity of estimating gas for UserOperations,
/// including account deployment, paymaster usage, and batched transactions.
class AAGasEstimator {
  final BundlerClient _bundlerClient;

  AAGasEstimator(this._bundlerClient);

  /// Estimate gas for a UserOperation
  ///
  /// Calls the bundler's eth_estimateUserOperationGas and applies
  /// appropriate buffers.
  Future<GasEstimateResult> estimate(
    UserOperation userOp, {
    double bufferMultiplier = AAConstants.gasBufferMultiplier,
  }) async {
    final result = await _bundlerClient.estimateUserOperationGas(userOp);
    return result.withBuffer(bufferMultiplier);
  }

  /// Estimate gas for a UserOperation with deployment
  Future<GasEstimateResult> estimateWithDeployment(
    UserOperation userOp,
    SmartAccount account,
  ) async {
    // Add extra buffer for deployment
    final result = await _bundlerClient.estimateUserOperationGas(userOp);

    // Increase verification gas for deployment
    return GasEstimateResult(
      verificationGasLimit: result.verificationGasLimit +
          BigInt.from(AAConstants.accountDeploymentGas),
      callGasLimit: result.callGasLimit,
      preVerificationGas: result.preVerificationGas +
          BigInt.from(10000), // Extra for init code
      paymasterVerificationGasLimit: result.paymasterVerificationGasLimit,
      paymasterPostOpGasLimit: result.paymasterPostOpGasLimit,
    );
  }

  /// Calculate pre-verification gas based on UserOp size
  static BigInt calculatePreVerificationGas(UserOperation userOp) {
    // Base cost
    var gas = BigInt.from(21000);

    // Add cost for calldata
    final callDataLength = userOp.callData.length;
    gas += BigInt.from(callDataLength * 16); // ~16 gas per calldata byte

    // Add cost for init code if present
    if (userOp.initCode != null && userOp.initCode!.isNotEmpty) {
      gas += BigInt.from(userOp.initCode!.length * 16);
    }

    // Add cost for paymaster data if present
    if (userOp.paymasterAndData != null && userOp.paymasterAndData!.isNotEmpty) {
      gas += BigInt.from(userOp.paymasterAndData!.length * 16);
    }

    // Minimum pre-verification gas
    if (gas < BigInt.from(AAConstants.minPreVerificationGas)) {
      gas = BigInt.from(AAConstants.minPreVerificationGas);
    }

    return gas;
  }

  /// Estimate total gas cost in wei
  static BigInt estimateTotalCost({
    required GasEstimateResult gasEstimate,
    required BigInt maxFeePerGas,
  }) {
    return gasEstimate.totalGas * maxFeePerGas;
  }

  /// Estimate gas for batch operations
  static BigInt estimateBatchGas(int numberOfCalls) {
    // Base gas for executeBatch
    var gas = BigInt.from(AAConstants.defaultCallGasLimit);

    // Additional gas per call in the batch
    gas += BigInt.from(numberOfCalls * 25000);

    return gas;
  }

  /// Check if gas estimates are reasonable
  static bool validateGasEstimates(GasEstimateResult estimate) {
    // Verification gas should be reasonable
    if (estimate.verificationGasLimit < BigInt.from(50000)) return false;
    if (estimate.verificationGasLimit > BigInt.from(10000000)) return false;

    // Call gas should be reasonable
    if (estimate.callGasLimit < BigInt.from(21000)) return false;
    if (estimate.callGasLimit > BigInt.from(30000000)) return false;

    // Pre-verification gas should be reasonable
    if (estimate.preVerificationGas < BigInt.from(21000)) return false;
    if (estimate.preVerificationGas > BigInt.from(1000000)) return false;

    return true;
  }
}

/// Gas price fetcher for AA operations
class AAGasPriceProvider {
  /// Get recommended gas prices for UserOperations
  ///
  /// Returns EIP-1559 gas prices (maxFeePerGas and maxPriorityFeePerGas).
  static Future<GasPriceRecommendation> getRecommendedPrices({
    required BigInt baseFee,
    required BigInt priorityFee,
    GasSpeed speed = GasSpeed.standard,
  }) async {
    // Apply multiplier based on speed
    final multiplier = speed.multiplier;

    final adjustedPriorityFee = priorityFee * BigInt.from((multiplier * 100).round()) ~/ BigInt.from(100);

    // maxFeePerGas = 2 * baseFee + priorityFee (for EIP-1559)
    final maxFeePerGas = baseFee * BigInt.two + adjustedPriorityFee;

    return GasPriceRecommendation(
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: adjustedPriorityFee,
      baseFee: baseFee,
      speed: speed,
    );
  }

  /// Get gas prices for all speed tiers
  static List<GasPriceRecommendation> getAllPriceRecommendations({
    required BigInt baseFee,
    required BigInt priorityFee,
  }) {
    return GasSpeed.values.map((speed) {
      final multiplier = speed.multiplier;
      final adjustedPriorityFee = priorityFee * BigInt.from((multiplier * 100).round()) ~/ BigInt.from(100);
      final maxFeePerGas = baseFee * BigInt.two + adjustedPriorityFee;

      return GasPriceRecommendation(
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: adjustedPriorityFee,
        baseFee: baseFee,
        speed: speed,
      );
    }).toList();
  }
}

/// Gas speed options
enum GasSpeed {
  slow,
  standard,
  fast,
  instant;

  double get multiplier {
    switch (this) {
      case GasSpeed.slow:
        return 0.8;
      case GasSpeed.standard:
        return 1.0;
      case GasSpeed.fast:
        return 1.3;
      case GasSpeed.instant:
        return 1.6;
    }
  }

  String get displayName {
    switch (this) {
      case GasSpeed.slow:
        return 'Slow';
      case GasSpeed.standard:
        return 'Standard';
      case GasSpeed.fast:
        return 'Fast';
      case GasSpeed.instant:
        return 'Instant';
    }
  }

  Duration get estimatedTime {
    switch (this) {
      case GasSpeed.slow:
        return const Duration(minutes: 10);
      case GasSpeed.standard:
        return const Duration(minutes: 3);
      case GasSpeed.fast:
        return const Duration(seconds: 30);
      case GasSpeed.instant:
        return const Duration(seconds: 15);
    }
  }
}

/// Gas price recommendation
class GasPriceRecommendation {
  final BigInt maxFeePerGas;
  final BigInt maxPriorityFeePerGas;
  final BigInt baseFee;
  final GasSpeed speed;

  const GasPriceRecommendation({
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.baseFee,
    required this.speed,
  });

  /// Calculate total cost for given gas units
  BigInt calculateCost(BigInt gasUnits) {
    return gasUnits * maxFeePerGas;
  }

  /// Format cost as ETH string
  String formatCost(BigInt gasUnits, {int decimals = 6}) {
    final cost = calculateCost(gasUnits);
    final ethValue = cost.toDouble() / 1e18;
    return ethValue.toStringAsFixed(decimals);
  }

  /// Format maxFeePerGas as Gwei
  String get maxFeeGwei {
    final gwei = maxFeePerGas.toDouble() / 1e9;
    return gwei.toStringAsFixed(2);
  }

  /// Format maxPriorityFeePerGas as Gwei
  String get priorityFeeGwei {
    final gwei = maxPriorityFeePerGas.toDouble() / 1e9;
    return gwei.toStringAsFixed(2);
  }

  @override
  String toString() {
    return 'GasPriceRecommendation(${speed.displayName}: maxFee=$maxFeeGwei Gwei, priority=$priorityFeeGwei Gwei)';
  }
}
