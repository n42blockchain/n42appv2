// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/services/coin_price_alert_service.dart';

/// 价格到达提醒配置底部弹窗
///
/// 调用方式：
/// ```dart
/// final changed = await showPriceAlertSheet(
///   context: context,
///   coinId:  'bitcoin',
///   symbol:  'btc',
///   name:    'Bitcoin',
///   currentPrice: 95000.0, // optional, 0 = unknown
/// );
/// if (changed == true) { /* reload alert states */ }
/// ```
Future<bool?> showPriceAlertSheet({
  required BuildContext context,
  required String coinId,
  required String symbol,
  required String name,
  double currentPrice = 0,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PriceAlertSheet(
      coinId: coinId,
      symbol: symbol,
      name: name,
      currentPrice: currentPrice,
    ),
  );
}

// ─── Private sheet widget ─────────────────────────────────────────────────────

class _PriceAlertSheet extends StatefulWidget {
  final String coinId;
  final String symbol;
  final String name;
  final double currentPrice;

  const _PriceAlertSheet({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.currentPrice,
  });

  @override
  State<_PriceAlertSheet> createState() => _PriceAlertSheetState();
}

class _PriceAlertSheetState extends State<_PriceAlertSheet> {
  final _priceCtrl = TextEditingController();
  bool _alertAbove = true;
  bool _enabled = true;
  bool _loading = true;
  bool _saving = false;
  CoinPriceAlertConfig? _existing;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final all = await CoinPriceAlertService.loadAll();
    final config = all[widget.coinId];
    if (!mounted) return;
    setState(() {
      _existing = config;
      if (config != null) {
        _priceCtrl.text = _fmtForInput(config.targetPrice);
        _alertAbove = config.alertAbove;
        _enabled = config.enabled;
      } else {
        // Pre-fill with current price if available
        if (widget.currentPrice > 0) {
          _priceCtrl.text = _fmtForInput(widget.currentPrice);
        }
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    final text = _priceCtrl.text.trim();
    final price = double.tryParse(text);
    if (price == null || price <= 0) {
      _showError('Please enter a valid price greater than 0');
      return;
    }

    setState(() => _saving = true);
    final config = CoinPriceAlertConfig(
      coinId: widget.coinId,
      symbol: widget.symbol.toLowerCase(),
      name: widget.name,
      targetPrice: price,
      alertAbove: _alertAbove,
      enabled: _enabled,
      lastNotifiedMs: _existing?.lastNotifiedMs,
    );
    await CoinPriceAlertService.save(config);
    if (!mounted) return;
    Navigator.pop(context, true); // signal: reload needed
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    await CoinPriceAlertService.remove(widget.coinId);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final dividerColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.35),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h + bottomPad),
      child: _loading
          ? SizedBox(
              height: 160.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle bar ─────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Title ──────────────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: accentColor, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Price Alert · ${widget.symbol.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    if (_existing != null)
                      TextButton(
                        onPressed: _saving ? null : _delete,
                        child: Text(
                          'Remove',
                          style: TextStyle(
                              color: const Color(0xFFEF4444), fontSize: 13.sp),
                        ),
                      ),
                  ],
                ),

                // ── Current price hint ─────────────────────────────────────
                if (widget.currentPrice > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Current price: \$${_fmtPrice(widget.currentPrice)}',
                    style: TextStyle(fontSize: 12.sp, color: subColor),
                  ),
                ],
                SizedBox(height: 20.h),

                // ── Direction toggle ───────────────────────────────────────
                Text(
                  'Alert me when price',
                  style: TextStyle(fontSize: 13.sp, color: subColor),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _DirectionChip(
                      label: 'Goes Above ↑',
                      selected: _alertAbove,
                      onTap: () => setState(() => _alertAbove = true),
                      accentColor: accentColor,
                      textColor: textColor,
                      dividerColor: dividerColor,
                    ),
                    SizedBox(width: 10.w),
                    _DirectionChip(
                      label: 'Drops Below ↓',
                      selected: !_alertAbove,
                      onTap: () => setState(() => _alertAbove = false),
                      accentColor: accentColor,
                      textColor: textColor,
                      dividerColor: dividerColor,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Target price input ─────────────────────────────────────
                Text(
                  'Target price (USD)',
                  style: TextStyle(fontSize: 13.sp, color: subColor),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,8}')),
                  ],
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle:
                        TextStyle(fontSize: 18.sp, color: subColor),
                    hintText: '0.00',
                    hintStyle:
                        TextStyle(fontSize: 18.sp, color: subColor),
                    filled: true,
                    fillColor: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor2.name),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide:
                          BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Enable switch ──────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Enable this alert',
                      style: TextStyle(fontSize: 14.sp, color: textColor),
                    ),
                    const Spacer(),
                    Switch(
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                      activeTrackColor: accentColor,
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Save button ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _existing != null ? 'Update Alert' : 'Set Alert',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Direction chip ──────────────────────────────────────────────────────────

class _DirectionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;
  final Color textColor;
  final Color dividerColor;

  const _DirectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accentColor,
    required this.textColor,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? accentColor.withAlpha(26) : dividerColor.withAlpha(80),
          border: Border.all(
            color: selected ? accentColor : dividerColor,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? accentColor : textColor.withAlpha(153),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _fmtPrice(double price) {
  if (price >= 1000) return price.toStringAsFixed(2);
  if (price >= 1) return price.toStringAsFixed(4);
  return price.toStringAsPrecision(4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

String _fmtForInput(double price) {
  if (price >= 1000) return price.toStringAsFixed(2);
  if (price >= 1) return price.toStringAsFixed(4);
  return price.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}
