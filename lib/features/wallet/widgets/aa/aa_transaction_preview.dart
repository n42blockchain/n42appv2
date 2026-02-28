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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_202,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              if (data.isGasSponsored)
                const GasSponsoredIcon(isSponsored: true),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 转账金额
          _buildAmountSection(context),
          SizedBox(height: ScreenUtil().setWidth(20)),

          // 地址信息
          _buildAddressSection(context),
          SizedBox(height: ScreenUtil().setWidth(20)),

          // Gas 信息
          _buildGasSection(context),

          // 批量操作列表
          if (data.batchOperations != null && data.batchOperations!.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(20)),
            _buildBatchOperationsSection(context),
          ],
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.mainBlueColor.name,
    );
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(20), blueColor.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).g_key_44,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(48),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
                child: Text(
                  data.tokenSymbol,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
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
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.backGroundColor.name,
        ).withAlpha(100),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
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
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
            child: Icon(
              Icons.arrow_downward,
              size: ScreenUtil().setWidth(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
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
    return Row(
      children: [
        Icon(
          icon,
          size: ScreenUtil().setWidth(22),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            Text(
              _shortenAddress(address),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontFamily: 'monospace',
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGasSection(BuildContext context) {
    final sponsored = data.isGasSponsored;
    final subtitleColor = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.itemSubtitleTextColor.name,
    );
    final bgFallback = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.backGroundColor.name,
    ).withAlpha(100);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: sponsored ? Colors.green.withAlpha(20) : bgFallback,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: sponsored ? Border.all(color: Colors.green.withAlpha(40)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                size: ScreenUtil().setWidth(22),
                color: sponsored ? Colors.green : subtitleColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                S.of(context).g_key_t_17,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          if (sponsored)
            Row(
              children: [
                Text(
                  data.formattedGasCost,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    decoration: TextDecoration.lineThrough,
                    color: subtitleColor,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Text(
                  S.of(context).g_key_aa_free,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            )
          else
            Text(
              data.formattedGasCost,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatchOperationsSection(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.mainBlueColor.name,
    );
    final ops = data.batchOperations!;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.backGroundColor.name,
        ).withAlpha(100),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).g_key_aa_batch_operations} (${ops.length})',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          for (final (i, op) in ops.indexed)
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
              child: Row(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(24),
                    height: ScreenUtil().setWidth(24),
                    decoration: BoxDecoration(
                      color: blueColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(18),
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: Text(
                      op,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name,
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
            ),
            child: Text(
              S.of(context).g_key_79,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: ScreenUtil().setWidth(24),
                    height: ScreenUtil().setWidth(24),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    S.of(context).g_key_78,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
