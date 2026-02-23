import 'dart:math';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:n42_wallet/src/wallet/models/ohlc_point.dart';

// Re-export so callers only need to import this file.
export 'package:n42_wallet/src/wallet/models/ohlc_point.dart';

/// Candlestick (K-line) chart widget with optional volume bars below.
///
/// Accepts OHLC price data and an optional list of volume values.
/// Volume bars occupy [volumeHeightRatio] fraction of the total height.
/// When [volumeData] is empty the volume section is hidden automatically.
class CandlestickChart extends StatelessWidget {
  final List<OhlcPoint> ohlcData;
  final List<double> volumeData;

  /// Total widget height in logical pixels.
  final double height;

  /// Fraction of height devoted to volume bars (0 = no volume section).
  final double volumeHeightRatio;

  const CandlestickChart({
    super.key,
    required this.ohlcData,
    this.volumeData = const [],
    this.height = 260,
    this.volumeHeightRatio = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    if (ohlcData.isEmpty) {
      return SizedBox(height: height);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CandlestickPainter(
          // [FIX M3] Filter out invalid candles before they reach the painter.
          ohlcData: ohlcData.where((p) => p.isValid).toList(),
          volumeData: volumeData,
          isDark: isDark,
          // [FIX] Honour caller's ratio only when volume data is present.
          volumeHeightRatio: volumeData.isEmpty ? 0.0 : volumeHeightRatio,
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<OhlcPoint> ohlcData;
  final List<double> volumeData;
  final bool isDark;
  final double volumeHeightRatio;

  static const Color _upColor = Color(0xff44A677);
  static const Color _downColor = Color(0xffd9445a);
  static const Color _gridColor = Color(0x1A888888);
  static const Color _labelColor = Color(0x66888888);

  _CandlestickPainter({
    required this.ohlcData,
    required this.volumeData,
    required this.isDark,
    required this.volumeHeightRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xff1A1A1A) : Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final n = ohlcData.length;
    if (n == 0) return;

    final chartH = size.height * (1 - volumeHeightRatio);
    final volH = size.height * volumeHeightRatio;

    // [FIX P3] Compute price range in a single pass.
    double maxPrice = ohlcData[0].high;
    double minPrice = ohlcData[0].low;
    for (final d in ohlcData) {
      if (d.high > maxPrice) maxPrice = d.high;
      if (d.low < minPrice) minPrice = d.low;
    }

    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return; // Flat chart – avoid division by zero.

    // 5% visual padding top and bottom so candles don't touch the edges.
    final pad = priceRange * 0.05;
    final priceCeil = maxPrice + pad;
    final priceFloor = minPrice - pad;
    final priceSpan = priceCeil - priceFloor;

    double toY(double price) =>
        chartH - ((price - priceFloor) / priceSpan) * chartH;

    _drawGrid(canvas, size, chartH);

    // --- Volume ---
    double maxVol = 1.0;
    if (volumeData.isNotEmpty) {
      maxVol = volumeData.reduce(max);
      if (maxVol == 0) maxVol = 1;
    }

    // Align volume data length to candle count via proportional index mapping.
    List<double> alignedVolumes = const [];
    if (volumeData.isNotEmpty && volH > 0) {
      if (volumeData.length == n) {
        alignedVolumes = volumeData;
      } else {
        final srcLen = volumeData.length;
        final denominator = n > 1 ? n - 1 : 1;
        alignedVolumes = List.generate(n, (i) {
          final srcIdx =
              ((i / denominator) * (srcLen - 1)).round().clamp(0, srcLen - 1);
          return volumeData[srcIdx];
        });
      }
    }

    // --- Candle geometry ---
    final candleSlotW = size.width / n;
    final bodyW = (candleSlotW * 0.55).clamp(1.5, 12.0);
    final halfBody = bodyW / 2;

    // [FIX P1] Allocate Paint objects once outside the drawing loop.
    final wickPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final bodyPaint = Paint()..style = PaintingStyle.fill;
    final dojiPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final volPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final d = ohlcData[i];
      final cx = candleSlotW * i + candleSlotW / 2;

      final color = d.isBullish ? _upColor : _downColor;
      wickPaint.color = color;
      bodyPaint.color = color;
      dojiPaint.color = color;

      final highY = toY(d.high);
      final lowY = toY(d.low);
      final openY = toY(d.open);
      final closeY = toY(d.close);

      // Wick
      canvas.drawLine(Offset(cx, highY), Offset(cx, lowY), wickPaint);

      // Body
      final bodyTop = min(openY, closeY);
      final bodyBottom = max(openY, closeY);
      if ((bodyBottom - bodyTop) < 1.0) {
        // Doji – draw a horizontal line instead of a zero-height rect.
        canvas.drawLine(
          Offset(cx - halfBody, bodyTop),
          Offset(cx + halfBody, bodyTop),
          dojiPaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTRB(cx - halfBody, bodyTop, cx + halfBody, bodyBottom),
          bodyPaint,
        );
      }

      // Volume bar
      if (alignedVolumes.isNotEmpty && volH > 0) {
        final vol = alignedVolumes[i];
        final barH = (vol / maxVol) * volH * 0.88;
        volPaint.color = color.withValues(alpha: 0.45);
        canvas.drawRect(
          Rect.fromLTRB(
              cx - halfBody, size.height - barH, cx + halfBody, size.height),
          volPaint,
        );
      }
    }

    _drawPriceLabels(canvas, size, chartH, priceFloor, priceCeil);

    // Separator between price chart and volume area.
    if (volH > 0) {
      canvas.drawLine(
        Offset(0, chartH),
        Offset(size.width, chartH),
        Paint()
          ..color = _gridColor
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size, double chartH) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = _gridColor;
    const steps = 4;
    for (int i = 1; i < steps; i++) {
      final y = chartH * i / steps;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawPriceLabels(
      Canvas canvas, Size size, double chartH, double minP, double maxP) {
    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      final ratio = i / steps;
      final price = minP + (maxP - minP) * ratio;
      final y = chartH - ratio * chartH;
      final label = _formatPrice(price);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: _labelColor,
            fontSize: 9,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Only draw if the label fits within the chart area.
      if (y - tp.height / 2 >= 0 && y + tp.height / 2 <= chartH) {
        tp.paint(canvas, Offset(size.width - tp.width - 2, y - tp.height / 2));
      }
    }
  }

  String _formatPrice(double price) {
    if (price >= 100000) return '\$${(price / 1000).toStringAsFixed(0)}K';
    if (price >= 1000) return '\$${(price / 1000).toStringAsFixed(1)}K';
    if (price >= 1) return '\$${price.toStringAsFixed(2)}';
    if (price >= 0.01) return '\$${price.toStringAsFixed(4)}';
    return '\$${price.toStringAsFixed(6)}';
  }

  // [FIX M1] Use value equality (OhlcPoint.== + listEquals) so repaint is
  // triggered correctly even when the list *object* reference is unchanged but
  // content differs (defensive), and skipped when reference changes but
  // content is identical.
  @override
  bool shouldRepaint(covariant _CandlestickPainter old) {
    return old.isDark != isDark ||
        !listEquals(old.ohlcData, ohlcData) ||
        !listEquals(old.volumeData, volumeData);
  }
}
