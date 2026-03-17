import 'dart:math' as math;

import 'package:intl/intl.dart';

String formatMarketPriceDisplay(double price) {
  return _formatMarketPrice(price, useGrouping: true, maxSmallDecimals: 12);
}

String formatMarketPriceInput(double price) {
  return _formatMarketPrice(price, useGrouping: false, maxSmallDecimals: 8);
}

String _formatMarketPrice(
  double price, {
  required bool useGrouping,
  required int maxSmallDecimals,
}) {
  if (price <= 0) return '0.00';
  if (price >= 1000) {
    return useGrouping
        ? NumberFormat('#,##0.00', 'en_US').format(price)
        : price.toStringAsFixed(2);
  }
  if (price >= 1) {
    return useGrouping
        ? NumberFormat('#,##0.0000', 'en_US').format(price)
        : price.toStringAsFixed(4);
  }

  final decimals = _resolveSmallPriceDecimals(
    price,
    maxDecimals: maxSmallDecimals,
  );
  return _trimTrailingZeros(price.toStringAsFixed(decimals));
}

int _resolveSmallPriceDecimals(double price, {required int maxDecimals}) {
  var scaled = price.abs();
  var leadingZeros = 0;
  while (scaled > 0 && scaled < 1 && leadingZeros < maxDecimals) {
    scaled *= 10;
    leadingZeros++;
  }
  return math.min(maxDecimals, math.max(4, leadingZeros + 3));
}

String _trimTrailingZeros(String value) {
  return value.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}
