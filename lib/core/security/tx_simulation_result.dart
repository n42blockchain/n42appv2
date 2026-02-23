// Copyright 2021-2026 N42 Inc. All rights reserved.

/// Status of an on-chain transaction simulation.
enum TxSimStatus { simulating, success, reverted, unavailable }

/// Immutable result of a transaction simulation via [TxSimulationService].
class TxSimulationResult {
  final TxSimStatus status;

  /// Human-readable revert reason. Non-null only when [status] is [TxSimStatus.reverted].
  final String? revertReason;

  /// Estimated gas units consumed by the transaction.
  /// Non-null only when [status] is [TxSimStatus.success] and the RPC
  /// successfully returned an `eth_estimateGas` result.
  final BigInt? gasEstimate;

  const TxSimulationResult._({
    required this.status,
    this.revertReason,
    this.gasEstimate,
  });

  factory TxSimulationResult.simulating() =>
      const TxSimulationResult._(status: TxSimStatus.simulating);

  factory TxSimulationResult.success({BigInt? gasEstimate}) =>
      TxSimulationResult._(status: TxSimStatus.success, gasEstimate: gasEstimate);

  factory TxSimulationResult.reverted(String? reason) =>
      TxSimulationResult._(status: TxSimStatus.reverted, revertReason: reason);

  factory TxSimulationResult.unavailable() =>
      const TxSimulationResult._(status: TxSimStatus.unavailable);
}
