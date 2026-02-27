// Copyright 2021-2026 N42 Inc. All rights reserved.

/// Transaction risk analysis result.
class TxRiskAnalysis {
  /// Overall risk level (highest severity among all flags).
  final TxRiskLevel level;

  /// Human-readable function name (e.g. "ERC-20 Approve", "Token Swap").
  final String functionName;

  /// Decoded field labels and values (e.g. Spender → 0x1234…5678).
  final List<TxRiskField> fields;

  /// Warning messages explaining each risk (may be empty for safe txs).
  final List<String> warnings;

  const TxRiskAnalysis({
    required this.level,
    required this.functionName,
    this.fields = const [],
    this.warnings = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
}

/// A single decoded parameter to display.
class TxRiskField {
  final String label;
  final String value;
  final bool isHighlighted; // e.g. red for unlimited amount

  const TxRiskField(this.label, this.value, {this.isHighlighted = false});
}

/// Risk severity levels.
enum TxRiskLevel {
  /// Normal operation, no elevated risk detected.
  safe,

  /// Potentially risky — user should review carefully.
  caution,

  /// High-risk action: unlimited approval, ownership change, etc.
  danger,
}
