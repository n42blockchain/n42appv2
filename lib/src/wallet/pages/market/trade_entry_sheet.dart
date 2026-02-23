// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/models/portfolio_trade.dart';
import 'package:n42_wallet/src/wallet/services/portfolio_trade_service.dart';

/// Bottom sheet for recording a buy trade.
///
/// Returns `true` when the trade list changed (add or delete), `false`/null otherwise.
Future<bool?> showTradeEntrySheet({
  required BuildContext context,
  required String coinId,
  required String symbol,
  required String name,
  required double currentPrice,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TradeEntrySheet(
      coinId: coinId,
      symbol: symbol,
      name: name,
      currentPrice: currentPrice,
    ),
  );
}

// ─── Sheet widget ──────────────────────────────────────────────────────────

class _TradeEntrySheet extends StatefulWidget {
  final String coinId;
  final String symbol;
  final String name;
  final double currentPrice;

  const _TradeEntrySheet({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.currentPrice,
  });

  @override
  State<_TradeEntrySheet> createState() => _TradeEntrySheetState();
}

class _TradeEntrySheetState extends State<_TradeEntrySheet> {
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<PortfolioTrade> _trades = [];
  bool _loading = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentPrice > 0) {
      _priceCtrl.text = widget.currentPrice.toStringAsFixed(
        widget.currentPrice >= 1 ? 2 : 6,
      );
    }
    _loadTrades();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrades() async {
    final list =
        await PortfolioTradeService.getTradesForCoin(widget.coinId);
    if (mounted) setState(() => _trades = list);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (qty <= 0 || price <= 0) return;

    setState(() => _loading = true);
    await PortfolioTradeService.insertTrade(PortfolioTrade(
      coinId: widget.coinId,
      symbol: widget.symbol.toLowerCase(),
      name: widget.name,
      quantity: qty,
      buyPriceUsd: price,
      buyTimeMs: DateTime.now().millisecondsSinceEpoch,
    ));
    _qtyCtrl.clear();
    _changed = true;
    await _loadTrades();
    setState(() => _loading = false);
  }

  Future<void> _deleteTrade(PortfolioTrade trade) async {
    if (trade.id == null) return;
    await PortfolioTradeService.deleteTrade(trade.id!);
    _changed = true;
    await _loadTrades();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final subColor = textColor.withAlpha(153);
    final accentColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final s = S.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // result already set via Navigator.pop below; nothing extra needed.
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: subColor.withAlpha(80),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${s.g_pnl_add_trade} · ${widget.symbol.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context, _changed),
                      icon:
                          Icon(Icons.close, color: subColor, size: 28.sp),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: _NumField(
                          controller: _qtyCtrl,
                          label: s.g_pnl_quantity,
                          hint: '0.00',
                          textColor: textColor,
                          subColor: subColor,
                          bgColor: bgColor,
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return '> 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Buy price
                      Expanded(
                        child: _NumField(
                          controller: _priceCtrl,
                          label: s.g_pnl_buy_price_usd,
                          hint: '0.00',
                          textColor: textColor,
                          subColor: subColor,
                          bgColor: bgColor,
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return '> 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Save button
                      ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(68.w, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(s.g_pnl_save,
                                style: TextStyle(fontSize: 24.sp)),
                      ),
                    ],
                  ),
                ),
              ),

              // Existing trades list
              if (_trades.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Divider(
                    height: 1,
                    thickness: 0.5,
                    color: subColor.withAlpha(40)),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 220.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _trades.length,
                    itemBuilder: (_, i) {
                      final t = _trades[i];
                      final dateStr = DateFormat('yyyy-MM-dd').format(t.buyTime);
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 0),
                        title: Text(
                          '${t.quantity} × \$${_fmt(t.buyPriceUsd)}',
                          style: TextStyle(
                              fontSize: 26.sp, color: textColor),
                        ),
                        subtitle: Text(
                          dateStr,
                          style: TextStyle(
                              fontSize: 20.sp, color: subColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: const Color(0xFFEF4444),
                              size: 24.sp),
                          onPressed: () => _deleteTrade(t),
                        ),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}

// ─── Reusable numeric text field ─────────────────────────────────────────

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color textColor;
  final Color subColor;
  final Color bgColor;
  final String? Function(String?)? validator;

  const _NumField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.textColor,
    required this.subColor,
    required this.bgColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
      ],
      style: TextStyle(color: textColor, fontSize: 26.sp),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subColor, fontSize: 22.sp),
        hintText: hint,
        hintStyle: TextStyle(color: subColor.withAlpha(100), fontSize: 24.sp),
        filled: true,
        fillColor: subColor.withAlpha(20),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        errorStyle: TextStyle(fontSize: 18.sp),
      ),
    );
  }
}
