// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Color palette for pie slices ────────────────────────────────────────────

const portfolioSliceColors = [
  Color(0xFF1976F9), // blue
  Color(0xFF22C55E), // green
  Color(0xFFFF9800), // orange
  Color(0xFF9333EA), // purple
  Color(0xFFEF4444), // red
  Color(0xFF00BCD4), // cyan
  Color(0xFFFF9800), // amber
  Color(0xFFEC4899), // pink
  Color(0xFF10B981), // emerald
  Color(0xFF6366F1), // indigo
  Color(0xFF8A9AAC), // slate (Others)
];

// ─── Data model ──────────────────────────────────────────────────────────────

class CoinRecord {
  final String symbol;
  final String name;
  final String icon;
  final double value;
  final double percentage;

  const CoinRecord({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.value,
    required this.percentage,
  });
}

// ─── Formatting utilities ─────────────────────────────────────────────────────

final _oCcy = NumberFormat('#,##0.00', 'en_US');
final _oCcyBig = NumberFormat('#,##0.0#', 'en_US');

String fmtUsd(double v) {
  if (v.abs() >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v.abs() >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
  if (v.abs() >= 1000) return '\$${_oCcyBig.format(v)}';
  return '\$${_oCcy.format(v)}';
}

String fmtPnl(double v) {
  final sign = v >= 0 ? '+' : '';
  if (v.abs() >= 1e6) return '$sign\$${(v / 1e6).toStringAsFixed(2)}M';
  if (v.abs() >= 1000) return '$sign\$${_oCcyBig.format(v)}';
  return '$sign\$${_oCcy.format(v)}';
}

/// pnl24h ≈ value × pct / 100 (approximation; exact for small pct)
double calcPnl(double value, double pct) => value * pct / 100.0;
