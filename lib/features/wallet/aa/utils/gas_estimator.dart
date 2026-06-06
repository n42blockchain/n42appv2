// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

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

  /// Estimate gas for a UserOperation that also deploys the account.
  ///
  /// Applies a buffer multiplier (same as [estimate]) and adds per-type
  /// deployment overhead on top of the bundler's raw estimate.
  ///
  /// The [account] parameter is used to determine account-type-specific
  /// deployment overhead:
  /// - Safe accounts require extra gas for proxy setup and threshold
  ///   configuration (~50 000 gas on top of [AAConstants.accountDeploymentGas]).
  /// - All other types use the base deployment constant.
  Future<GasEstimateResult> estimateWithDeployment(
    UserOperation userOp,
    SmartAccount account, {
    double bufferMultiplier = AAConstants.gasBufferMultiplier,
  }) async {
    final raw = await _bundlerClient.estimateUserOperationGas(userOp);

    // Per-type deployment overhead (Safe needs extra setup gas).
    final int extraDeployGas = account.type == SmartAccountType.safe
        ? 50000
        : 0;

    final withDeploy = GasEstimateResult(
      verificationGasLimit:
          raw.verificationGasLimit +
          BigInt.from(AAConstants.accountDeploymentGas + extraDeployGas),
      callGasLimit: raw.callGasLimit,
      preVerificationGas:
          raw.preVerificationGas +
          BigInt.from(10000), // Extra for init code processing
      paymasterVerificationGasLimit: raw.paymasterVerificationGasLimit,
      paymasterPostOpGasLimit: raw.paymasterPostOpGasLimit,
    );

    // Apply the same buffer multiplier as estimate().
    return withDeploy.withBuffer(bufferMultiplier);
  }

  /// Calculate pre-verification gas based on UserOp calldata size.
  ///
  /// Implements EIP-2028 byte-cost differentiation:
  /// - Zero bytes  cost 4 gas each
  /// - Non-zero bytes cost 16 gas each
  ///
  /// This is significantly more accurate than a flat 16 gas/byte charge,
  /// especially for calldata with many zero-padded ABI parameters.
  static BigInt calculatePreVerificationGas(UserOperation userOp) {
    var gas = BigInt.from(21000); // Base transaction cost

    gas += _calldataCost(userOp.callData);

    // Add costs for optional data fields when present.
    for (final data in [userOp.initCode, userOp.paymasterAndData]) {
      if (data != null && data.isNotEmpty) gas += _calldataCost(data);
    }

    // Enforce minimum pre-verification gas.
    final minGas = BigInt.from(AAConstants.minPreVerificationGas);
    return gas < minGas ? minGas : gas;
  }

  /// EIP-2028 byte cost: 4 gas for zero bytes, 16 gas for non-zero bytes.
  static BigInt _calldataCost(Uint8List data) {
    return BigInt.from(data.fold<int>(0, (sum, b) => sum + (b == 0 ? 4 : 16)));
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
    var gas = BigInt.from(AAConstants.defaultCallGasLimit);
    gas += BigInt.from(numberOfCalls * 25000);
    return gas;
  }

  /// Check if gas estimates are within reasonable bounds.
  ///
  /// Returns false for obviously wrong values (too low to execute, or so high
  /// they indicate a mis-configuration or simulation error).
  static bool validateGasEstimates(GasEstimateResult estimate) {
    bool inRange(BigInt value, int min, int max) =>
        value >= BigInt.from(min) && value <= BigInt.from(max);

    return inRange(estimate.verificationGasLimit, 50000, 10000000) &&
        inRange(estimate.callGasLimit, 21000, 30000000) &&
        inRange(estimate.preVerificationGas, 21000, 1000000);
  }
}

// ── Gas Deviation Detection ────────────────────────────────────────────────

/// Severity of a gas deviation warning.
enum GasDeviationSeverity {
  /// Informational — the user may want to know, but no action is required.
  info,

  /// Warning — the estimate is unusual; the user should review before signing.
  warning,

  /// Critical — the estimate is very likely wrong or the transaction is at risk
  /// of failure; the user should strongly reconsider.
  critical,
}

/// Classification of the root cause for a gas deviation warning.
enum GasDeviationWarningType {
  /// Total gas (all limits combined) is above the warning threshold.
  totalGasVeryHigh,

  /// verificationGasLimit alone is above its warning threshold.
  verificationGasHigh,

  /// callGasLimit alone is above its warning threshold.
  callGasHigh,

  /// Paymaster gas overhead (verificationGasLimit + postOpGasLimit) is high.
  paymasterOverhead,

  /// The estimate includes first-time account deployment overhead.
  deploymentOverhead,

  /// The bundler's estimate deviates significantly from the client's estimate,
  /// suggesting the transaction may fail due to under-estimation.
  possibleUnderEstimate,
}

/// A single user-facing gas deviation warning.
class GasDeviationWarning {
  /// Root cause classification.
  final GasDeviationWarningType type;

  /// Severity level.
  final GasDeviationSeverity severity;

  /// i18n key for the short title (e.g. "g_key_aa_gas_warn_total_high").
  final String titleKey;

  /// i18n key for the description.
  ///
  /// Description keys that accept a `{gas}` placeholder are indicated by
  /// [hasGasPlaceholder] being true; the [gasValue] field then holds the
  /// formatted gas string to inject.
  final String descKey;

  /// Whether [descKey] requires a `{gas}` placeholder substitution.
  final bool hasGasPlaceholder;

  /// Human-readable gas value to substitute into the description (e.g. "2,500,000").
  ///
  /// Null when [hasGasPlaceholder] is false.
  final String? gasValue;

  const GasDeviationWarning({
    required this.type,
    required this.severity,
    required this.titleKey,
    required this.descKey,
    this.hasGasPlaceholder = false,
    this.gasValue,
  });

  @override
  String toString() =>
      'GasDeviationWarning(type=$type, severity=$severity, gas=$gasValue)';
}

/// Analyses a [GasEstimateResult] and returns a list of user-facing warnings.
///
/// All checks are pure computations — no network calls, no side-effects.
/// The caller is responsible for displaying the warnings in the UI.
///
/// Usage:
/// ```dart
/// final warnings = GasDeviationDetector.analyze(
///   estimate,
///   clientEstimate: myLocalEstimate, // optional, enables deviation check
/// );
/// for (final w in warnings) {
///   // use w.titleKey and w.descKey to look up translated strings
/// }
/// ```
class GasDeviationDetector {
  GasDeviationDetector._();

  // ── Cached BigInt constants ──────────────────────────────────────────────
  // These are computed once per isolate lifetime; BigInt.from() is not free.
  static final BigInt _b100 = BigInt.from(100);
  static final BigInt _bTotal = BigInt.from(
    AAConstants.gasTotalWarningThreshold,
  );
  static final BigInt _bTotalCrit = BigInt.from(
    AAConstants.gasTotalCriticalThreshold,
  );
  static final BigInt _bVerify = BigInt.from(
    AAConstants.gasVerificationWarningThreshold,
  );
  static final BigInt _bCall = BigInt.from(AAConstants.gasCallWarningThreshold);
  static final BigInt _bPmWarnPct = BigInt.from(20); // 20 % → paymaster warning
  static final BigInt _bPmCritPct = BigInt.from(
    75,
  ); // 75 % → paymaster critical
  static final BigInt _bDevWarnPct = BigInt.from(
    AAConstants.gasDeviationWarningPct.toInt(),
  );
  static final BigInt _bDevCritPct = BigInt.from(
    AAConstants.gasDeviationCriticalPct.toInt(),
  );

  /// Analyse [estimate] and return all applicable warnings, ordered by
  /// severity (critical first, then warning, then info).
  ///
  /// [clientEstimate] is optional. When provided, it is compared against the
  /// bundler's estimate to detect significant under-estimates.
  ///
  /// [isFirstTransaction] controls whether the deployment-overhead info
  /// warning is included.
  ///
  /// Warnings are **inserted in severity order** (critical → warning → info)
  /// so no post-processing sort is required.
  static List<GasDeviationWarning> analyze(
    GasEstimateResult estimate, {
    BigInt? clientEstimate,
    bool isFirstTransaction = false,
  }) {
    // Use three buckets to maintain severity order without a sort pass.
    final critical = <GasDeviationWarning>[];
    final warning = <GasDeviationWarning>[];
    final info = <GasDeviationWarning>[];

    void add(GasDeviationSeverity s, GasDeviationWarning w) {
      switch (s) {
        case GasDeviationSeverity.critical:
          critical.add(w);
        case GasDeviationSeverity.warning:
          warning.add(w);
        case GasDeviationSeverity.info:
          info.add(w);
      }
    }

    /// Create and bucket a gas warning with a formatted gas placeholder.
    void addGasWarn(
      GasDeviationWarningType type,
      GasDeviationSeverity severity,
      String titleKey,
      String descKey,
      BigInt gas,
    ) {
      add(
        severity,
        GasDeviationWarning(
          type: type,
          severity: severity,
          titleKey: titleKey,
          descKey: descKey,
          hasGasPlaceholder: true,
          gasValue: _formatGas(gas),
        ),
      );
    }

    final total = estimate.totalGas;
    final verify = estimate.verificationGasLimit;
    final call = estimate.callGasLimit;

    // ── 1. Total gas checks ──────────────────────────────────────────────
    if (total >= _bTotalCrit) {
      addGasWarn(
        GasDeviationWarningType.totalGasVeryHigh,
        GasDeviationSeverity.critical,
        'g_key_aa_gas_warn_total_high',
        'g_key_aa_gas_warn_total_high_desc',
        total,
      );
    } else if (total >= _bTotal) {
      addGasWarn(
        GasDeviationWarningType.totalGasVeryHigh,
        GasDeviationSeverity.warning,
        'g_key_aa_gas_warn_total_high',
        'g_key_aa_gas_warn_total_high_desc',
        total,
      );
    }

    // ── 2. Verification gas check ────────────────────────────────────────
    if (verify >= _bVerify) {
      addGasWarn(
        GasDeviationWarningType.verificationGasHigh,
        GasDeviationSeverity.warning,
        'g_key_aa_gas_warn_verify_high',
        'g_key_aa_gas_warn_verify_high_desc',
        verify,
      );
    }

    // ── 3. Call gas check ────────────────────────────────────────────────
    if (call >= _bCall) {
      addGasWarn(
        GasDeviationWarningType.callGasHigh,
        GasDeviationSeverity.warning,
        'g_key_aa_gas_warn_call_high',
        'g_key_aa_gas_warn_call_high_desc',
        call,
      );
    }

    // ── 4. Paymaster overhead check ──────────────────────────────────────
    // Check both warning (>20 %) and critical (>75 %) levels.
    // A paymaster consuming >75 % of total gas is almost certainly misconfigured.
    final pmTotal =
        (estimate.paymasterVerificationGasLimit ?? BigInt.zero) +
        (estimate.paymasterPostOpGasLimit ?? BigInt.zero);
    if (pmTotal > BigInt.zero && total > BigInt.zero) {
      final pct = (pmTotal * _b100) ~/ total;
      if (pct >= _bPmCritPct) {
        addGasWarn(
          GasDeviationWarningType.paymasterOverhead,
          GasDeviationSeverity.critical,
          'g_key_aa_gas_warn_paymaster',
          'g_key_aa_gas_warn_paymaster_desc',
          pmTotal,
        );
      } else if (pct >= _bPmWarnPct) {
        addGasWarn(
          GasDeviationWarningType.paymasterOverhead,
          GasDeviationSeverity.info,
          'g_key_aa_gas_warn_paymaster',
          'g_key_aa_gas_warn_paymaster_desc',
          pmTotal,
        );
      }
    }

    // ── 5. Deployment overhead info ──────────────────────────────────────
    if (isFirstTransaction) {
      addGasWarn(
        GasDeviationWarningType.deploymentOverhead,
        GasDeviationSeverity.info,
        'g_key_aa_gas_warn_deploy',
        'g_key_aa_gas_warn_deploy_desc',
        BigInt.from(AAConstants.accountDeploymentGas),
      );
    }

    // ── 6. Client vs bundler deviation check ─────────────────────────────
    // Deviation = (clientEstimate − bundlerTotal) / bundlerTotal × 100
    //
    // Positive value: client expects MORE gas than bundler → under-estimate risk.
    if (clientEstimate != null &&
        clientEstimate > BigInt.zero &&
        total > BigInt.zero) {
      final diff = clientEstimate - total;
      if (diff > BigInt.zero) {
        final pct = (diff * _b100) ~/ total;
        final GasDeviationSeverity? severity = pct >= _bDevCritPct
            ? GasDeviationSeverity.critical
            : pct >= _bDevWarnPct
            ? GasDeviationSeverity.warning
            : null;
        if (severity != null) {
          add(
            severity,
            GasDeviationWarning(
              type: GasDeviationWarningType.possibleUnderEstimate,
              severity: severity,
              titleKey: 'g_key_aa_gas_warn_under_est',
              descKey: 'g_key_aa_gas_warn_under_est_desc',
            ),
          );
        }
      }
    }

    // Merge buckets in severity order — no sort needed.
    return [...critical, ...warning, ...info];
  }

  /// Format a gas value with thousands-separators for display.
  static String _formatGas(BigInt gas) {
    final str = gas.toString();
    final buffer = StringBuffer();
    final offset = str.length % 3;
    for (var i = 0; i < str.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── Gas Price Provider (unchanged) ────────────────────────────────────────

/// Gas price fetcher for AA operations
class AAGasPriceProvider {
  /// Build a [GasPriceRecommendation] for [speed] given current fee parameters.
  static GasPriceRecommendation _buildRecommendation({
    required BigInt baseFee,
    required BigInt priorityFee,
    required GasSpeed speed,
  }) {
    final adjustedPriorityFee =
        priorityFee *
        BigInt.from((speed.multiplier * 100).round()) ~/
        BigInt.from(100);
    return GasPriceRecommendation(
      maxFeePerGas: baseFee * BigInt.two + adjustedPriorityFee,
      maxPriorityFeePerGas: adjustedPriorityFee,
      baseFee: baseFee,
      speed: speed,
    );
  }

  /// Get recommended gas prices for UserOperations
  ///
  /// Returns EIP-1559 gas prices (maxFeePerGas and maxPriorityFeePerGas).
  static Future<GasPriceRecommendation> getRecommendedPrices({
    required BigInt baseFee,
    required BigInt priorityFee,
    GasSpeed speed = GasSpeed.standard,
  }) async {
    return _buildRecommendation(
      baseFee: baseFee,
      priorityFee: priorityFee,
      speed: speed,
    );
  }

  /// Get gas prices for all speed tiers
  static List<GasPriceRecommendation> getAllPriceRecommendations({
    required BigInt baseFee,
    required BigInt priorityFee,
  }) {
    return GasSpeed.values
        .map(
          (speed) => _buildRecommendation(
            baseFee: baseFee,
            priorityFee: priorityFee,
            speed: speed,
          ),
        )
        .toList();
  }
}

/// Gas speed options
enum GasSpeed {
  slow(0.8, 'Slow', Duration(minutes: 10)),
  standard(1.0, 'Standard', Duration(minutes: 3)),
  fast(1.3, 'Fast', Duration(seconds: 30)),
  instant(1.6, 'Instant', Duration(seconds: 15));

  const GasSpeed(this.multiplier, this.displayName, this.estimatedTime);

  final double multiplier;
  final String displayName;
  final Duration estimatedTime;
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
  BigInt calculateCost(BigInt gasUnits) => gasUnits * maxFeePerGas;

  /// Format cost as ETH string
  String formatCost(BigInt gasUnits, {int decimals = 6}) {
    final cost = calculateCost(gasUnits);
    final ethValue = cost.toDouble() / 1e18;
    return ethValue.toStringAsFixed(decimals);
  }

  /// Format maxFeePerGas as Gwei
  String get maxFeeGwei => (maxFeePerGas.toDouble() / 1e9).toStringAsFixed(2);

  /// Format maxPriorityFeePerGas as Gwei
  String get priorityFeeGwei =>
      (maxPriorityFeePerGas.toDouble() / 1e9).toStringAsFixed(2);

  @override
  String toString() =>
      'GasPriceRecommendation(${speed.displayName}: maxFee=$maxFeeGwei Gwei, priority=$priorityFeeGwei Gwei)';
}
