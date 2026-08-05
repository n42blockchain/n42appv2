import 'dart:math';

/// Immutable OHLC price data point for a single K-line candle.
///
/// Placed in the model layer so both the data (API) layer and the UI
/// (widget) layer can import it without creating an upward dependency.
///
/// All fields are final; the class is effectively immutable by design.
class OhlcPoint {
  final double open;
  final double high;
  final double low;
  final double close;

  const OhlcPoint({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  /// True when the candle closes higher than it opened (bullish).
  bool get isBullish => close >= open;

  /// True when all fields are finite and OHLC constraints hold:
  ///   high ≥ max(open, close)   and   low ≤ min(open, close)
  bool get isValid =>
      open.isFinite &&
      high.isFinite &&
      low.isFinite &&
      close.isFinite &&
      high >= low &&
      high >= max(open, close) &&
      low <= min(open, close);

  // Value equality so that listEquals() and shouldRepaint() work correctly.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OhlcPoint &&
          open == other.open &&
          high == other.high &&
          low == other.low &&
          close == other.close;

  @override
  int get hashCode => Object.hash(open, high, low, close);

  @override
  String toString() => 'OhlcPoint(O:$open H:$high L:$low C:$close)';
}
