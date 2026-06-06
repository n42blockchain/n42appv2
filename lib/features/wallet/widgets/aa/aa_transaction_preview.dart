// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/gas_sponsorship_badge.dart';

/// AA 交易预览数据
class AATransactionPreviewData {
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String tokenSymbol;
  final BigInt? estimatedGas;
  final BigInt? maxFeePerGas;
  final bool isGasSponsored;
  final String? sponsorName;
  final List<String>? batchOperations;

  const AATransactionPreviewData({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.tokenSymbol,
    this.estimatedGas,
    this.maxFeePerGas,
    this.isGasSponsored = false,
    this.sponsorName,
    this.batchOperations,
  });

  static final BigInt _weiPerEth = BigInt.from(10).pow(18);

  String get formattedGasCost {
    if (estimatedGas == null || maxFeePerGas == null) return '~';
    final ethValue = (estimatedGas! * maxFeePerGas!) / _weiPerEth;
    return '${ethValue.toStringAsFixed(6)} ETH';
  }
}

/// AA 交易预览组件
class AATransactionPreview extends StatelessWidget {
  final AATransactionPreviewData data;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const AATransactionPreview({
    super.key,
    required this.data,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  // ─── Theme helpers ──────────────────────────────────────────────────────

  Color _color(BuildContext context, AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: _color(context, AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_202,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: _color(context, AppThemeKeys.mainTextColor),
                  ),
                ),
              ),
              if (data.isGasSponsored)
                const GasSponsoredIcon(isSponsored: true),
            ],
          ),
          SizedBox(height: 24.w),

          // 转账金额
          _buildAmountSection(context),
          SizedBox(height: 20.w),

          // 地址信息
          _buildAddressSection(context),
          SizedBox(height: 20.w),

          // Gas 信息
          _buildGasSection(context),

          // 批量操作列表
          if (data.batchOperations != null &&
              data.batchOperations!.isNotEmpty) ...[
            SizedBox(height: 20.w),
            _buildBatchOperationsSection(context),
          ],
          SizedBox(height: 24.w),

          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final blueColor = _color(context, AppThemeKeys.mainBlueColor);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(20), blueColor.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).g_key_44,
            style: TextStyle(
              fontSize: 24.sp,
              color: _color(context, AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
          SizedBox(height: 8.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: _color(context, AppThemeKeys.mainTextColor),
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 6.w),
                child: Text(
                  data.tokenSymbol,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _color(context, AppThemeKeys.backGroundColor).withAlpha(100),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            context,
            S.of(context).g_key_75,
            data.fromAddress,
            Icons.account_balance_wallet,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: Icon(
              Icons.arrow_downward,
              size: 24.w,
              color: _color(context, AppThemeKeys.mainBlueColor),
            ),
          ),
          _buildAddressRow(
            context,
            S.of(context).g_key_38,
            data.toAddress,
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    BuildContext context,
    String label,
    String address,
    IconData icon,
  ) {
    final subtitleColor = _color(context, AppThemeKeys.itemSubtitleTextColor);
    return Row(
      children: [
        Icon(icon, size: 22.w, color: subtitleColor),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 20.sp, color: subtitleColor),
            ),
            Text(
              _shortenAddress(address),
              style: TextStyle(
                fontSize: 24.sp,
                fontFamily: 'monospace',
                color: _color(context, AppThemeKeys.mainTextColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGasSection(BuildContext context) {
    final sponsored = data.isGasSponsored;
    final subtitleColor = _color(context, AppThemeKeys.itemSubtitleTextColor);
    final bgFallback = _color(
      context,
      AppThemeKeys.backGroundColor,
    ).withAlpha(100);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: sponsored ? Colors.green.withAlpha(20) : bgFallback,
        borderRadius: BorderRadius.circular(12.w),
        border: sponsored
            ? Border.all(color: Colors.green.withAlpha(40))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                size: 22.w,
                color: sponsored ? Colors.green : subtitleColor,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  S.of(context).g_key_t_17,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24.sp, color: subtitleColor),
                ),
              ),
            ],
          ),
          if (sponsored)
            Row(
              children: [
                Flexible(
                  child: Text(
                    data.formattedGasCost,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.sp,
                      decoration: TextDecoration.lineThrough,
                      color: subtitleColor,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    S.of(context).g_key_aa_free,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              data.formattedGasCost,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: _color(context, AppThemeKeys.mainTextColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatchOperationsSection(BuildContext context) {
    final blueColor = _color(context, AppThemeKeys.mainBlueColor);
    final ops = data.batchOperations!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _color(context, AppThemeKeys.backGroundColor).withAlpha(100),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).g_key_aa_batch_operations} (${ops.length})',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: _color(context, AppThemeKeys.mainTextColor),
            ),
          ),
          SizedBox(height: 8.w),
          for (final (i, op) in ops.indexed)
            Padding(
              padding: EdgeInsets.only(top: 6.w),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: blueColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      op,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: _color(
                          context,
                          AppThemeKeys.itemSubtitleTextColor,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttonRadius = BorderRadius.circular(14.w);
    final buttonPadding = EdgeInsets.symmetric(vertical: 16.w);
    final buttonTextStyle = TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            ),
            child: Text(S.of(context).g_key_79, style: buttonTextStyle),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _color(context, AppThemeKeys.mainBlueColor),
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(S.of(context).g_key_78, style: buttonTextStyle),
          ),
        ),
      ],
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }
}
