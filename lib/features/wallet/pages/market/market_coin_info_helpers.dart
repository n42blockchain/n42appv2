import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_price_format_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

// ─── period selector constants ─────────────────────────────────────────────
// Both arrays must stay in sync (enforced by assert in initState).
const periodLabels = ['1D', '7D', '1M', '3M', '1Y'];
const periodDays = [1, 7, 30, 90, 365];

// Record type for social link list items.
typedef LinkItem = ({String icon, String label, String url});

// ─── number formatters ─────────────────────────────────────────────────────

/// Converts an API value (num | String | null) to double without throwing.
double toDouble(dynamic v, [double fallback = 0.0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

/// Formats a price with automatic decimal precision:
/// ≥$1000 → 2dp, ≥$1 → 4dp, <$1 → 4 significant figures, trailing zeros removed.
String fmtPrice(double price) {
  return formatMarketPriceDisplay(price);
}

/// Formats a percentage with a leading sign.
String fmtPct(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

/// Formats a quantity, stripping trailing zeros and unnecessary decimal point.
String fmtQty(double v) {
  if (v == v.truncateToDouble()) return v.truncate().toString();
  return v
      .toStringAsFixed(v < 1 ? 6 : 4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

/// Returns the theme color for a positive/negative percentage value.
Color pctColor(double v, BuildContext ctx) => AppThemeUtils.getColorByKey(
  ctx,
  v >= 0 ? AppThemeKeys.rightTextColor.name : AppThemeKeys.errorTextColor.name,
);

bool marketCoinMatchesSymbol(Map<String, dynamic> coin, String expectedSymbol) {
  return (coin['coin']?.toString().trim().toLowerCase() ?? '') ==
      expectedSymbol.trim().toLowerCase();
}

Map<String, dynamic> mergeMarketCoinSnapshot(
  Map<String, dynamic> existing,
  Map<String, dynamic> incoming,
) {
  return {
    ...existing,
    ...incoming,
    if (!incoming.containsKey('coin_gecko_id') &&
        existing['coin_gecko_id'] != null)
      'coin_gecko_id': existing['coin_gecko_id'],
    if (!incoming.containsKey('image') && existing['image'] != null)
      'image': existing['image'],
    if (!incoming.containsKey('name') && existing['name'] != null)
      'name': existing['name'],
  };
}

// ─── URL / username validation ─────────────────────────────────────────────

/// Returns [raw] only when it has an http/https scheme and a non-empty host.
String? validateHttpUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.host.isEmpty) return null;
  if (!uri.isScheme('https') && !uri.isScheme('http')) return null;
  return raw;
}

/// Allows only characters valid in social-media usernames
/// (alphanumeric, underscore, hyphen, dot) — prevents path traversal.
bool isSafeUsername(String? u) =>
    u != null && u.isNotEmpty && RegExp(r'^[\w\-\.]+$').hasMatch(u);

// ─── layout helpers ────────────────────────────────────────────────────────

/// Inserts a themed divider between every adjacent pair of items.
List<Widget> withDividers(BuildContext context, List<Widget> items) {
  final result = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    if (i > 0) result.add(coinInfoDivider(context));
    result.add(items[i]);
  }
  return result;
}

Widget coinInfoDivider(BuildContext context) => Divider(
  height: ScreenUtil().setWidth(1),
  thickness: 0.5,
  color: AppThemeUtils.getColorByKey(
    context,
    AppThemeKeys.itemSubtitleTextColor.name,
  ).withValues(alpha: 0.15),
);
