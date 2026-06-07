// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/gas_tracker_api.dart';
import 'package:n42_wallet/features/wallet/models/non_evm_fee_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

// ─── 紧凑费用行（用于发送页面，统一非 EVM 链的手续费展示）──────────────────

/// 非 EVM 链费用紧凑行
///
/// 固定费用链（SOL/DOT/XRP 等）：只读，无 edit 图标
/// 可编辑费用链（BTC/LTC 等）：右侧显示 edit 图标，[onTap] 打开设置页
class NonEvmFeeCompact extends StatelessWidget {
  /// 格式化后的费用字符串，如 "0.000005 SOL" 或 "0.00001 BTC"
  final String feeText;

  /// 标签，默认为 g_key_t_16（"Max gas fee"）
  final String? label;

  /// 对可编辑链：当前速度标签（"Standard"）
  final String? speedLabel;

  /// 估计确认时间，如 "~30min"
  final String? estimatedTime;

  /// 可选费率说明，如 "10 sat/byte"
  final String? rateText;

  /// 费用是否超出余额（红色警告）
  final bool hasError;

  /// 点击回调（null 时不可点击，固定费用链）
  final VoidCallback? onTap;

  const NonEvmFeeCompact({
    super.key,
    required this.feeText,
    this.label,
    this.speedLabel,
    this.estimatedTime,
    this.rateText,
    this.hasError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final itemBg = AppColorTokens.of(context).bgSurface;
    final errorColor = AppColorTokens.of(context).danger;

    final feeColor = hasError ? errorColor : mainText;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        decoration: BoxDecoration(color: itemBg, borderRadius: AppRadius.brMd),
        child: Row(
          children: [
            // 图标
            Icon(
              Icons.local_gas_station,
              size: ScreenUtil().setWidth(40),
              color: blueColor,
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            // 左侧：标签 + 时间/速度
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    speedLabel ?? label ?? S.of(context).g_key_t_16,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w500,
                      color: mainText,
                    ),
                  ),
                  if (estimatedTime != null || rateText != null)
                    Text(
                      [estimatedTime, rateText].whereType<String>().join('  '),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(23),
                        color: subtitleText,
                      ),
                    ),
                ],
              ),
            ),

            // 右侧：费用 + 可选 edit 图标
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  feeText,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: feeColor,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              SizedBox(width: ScreenUtil().setWidth(8)),
              Icon(
                Icons.edit_outlined,
                size: ScreenUtil().setWidth(32),
                color: blueColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── 三档速度选择器（用于 NonEvmGasSettingsPage 内部）──────────────────────

/// 非 EVM 速度选择器 Widget（Slow / Standard / Fast）
class NonEvmFeeSelector extends StatefulWidget {
  final NonEvmFeeModel feeModel;
  final ValueChanged<NonEvmFeeSpeed> onSpeedChanged;
  final bool showDetails;

  const NonEvmFeeSelector({
    super.key,
    required this.feeModel,
    required this.onSpeedChanged,
    this.showDetails = true,
  });

  @override
  State<NonEvmFeeSelector> createState() => _NonEvmFeeSelectorState();
}

class _NonEvmFeeSelectorState extends State<NonEvmFeeSelector> {
  late NonEvmFeeSpeed _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.feeModel.selectedSpeed;
  }

  @override
  void didUpdateWidget(covariant NonEvmFeeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feeModel != widget.feeModel ||
        oldWidget.feeModel.selectedSpeed != widget.feeModel.selectedSpeed) {
      _selected = widget.feeModel.selectedSpeed;
    }
  }

  void _onTap(NonEvmFeeSpeed speed) {
    setState(() {
      _selected = speed;
      widget.feeModel.selectedSpeed = speed;
    });
    widget.onSpeedChanged(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：Gas Fee + 当前总费用
          _buildHeader(context),
          // 速度按钮
          _buildSpeedRow(context),
          if (widget.showDetails) _buildDetails(context),
          SizedBox(height: ScreenUtil().setWidth(20)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final blueColor = AppColorTokens.of(context).brand;

    final fee = widget.feeModel.currentOption.fee;
    final decimals = widget.feeModel.decimals;
    final unit = widget.feeModel.unit;
    final formatted = Decimal.parse(
      toEther(fee.toString(), decimals).toString(),
    );

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                size: ScreenUtil().setWidth(40),
                color: blueColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Flexible(
                child: Text(
                  S.of(context).g_key_t_16,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold,
                    color: mainText,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '$formatted $unit',
            style: TextStyle(fontSize: ScreenUtil().setSp(28), color: mainText),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          _buildOption(
            context,
            NonEvmFeeSpeed.slow,
            S.of(context).g_key_gas_slow,
            Icons.snooze,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildOption(
            context,
            NonEvmFeeSpeed.standard,
            S.of(context).g_key_gas_standard,
            Icons.speed,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildOption(
            context,
            NonEvmFeeSpeed.fast,
            S.of(context).g_key_gas_fast,
            Icons.flash_on,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    NonEvmFeeSpeed speed,
    String label,
    IconData icon,
  ) {
    final isSelected = _selected == speed;
    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final dividerColor = AppColorTokens.of(context).border;

    final option = _getOption(speed);
    final estimatedTime = GasTrackerApi.formatEstimatedTime(
      option.estimatedSeconds,
    );

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(speed),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20),
            horizontal: ScreenUtil().setWidth(16),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? blueColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: AppRadius.brMd,
            border: Border.all(
              color: isSelected ? blueColor : dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: ScreenUtil().setWidth(36),
                color: isSelected ? blueColor : subtitleText,
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? blueColor : mainText,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                estimatedTime,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: subtitleText,
                ),
              ),
              // 费率（BTC 专有）
              if (option.feeRate != null)
                Text(
                  '${option.feeRate} ${option.feeRateUnit ?? ''}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: subtitleText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final option = widget.feeModel.currentOption;
    final decimals = widget.feeModel.decimals;
    final unit = widget.feeModel.unit;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final mainText = AppColorTokens.of(context).textPrimary;
    final blueColor = AppColorTokens.of(context).brand;
    final bgColor = AppColorTokens.of(context).bgBase;

    final feeFormatted = Decimal.parse(
      toEther(option.fee.toString(), decimals).toString(),
    );

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.brMd),
      child: Column(
        children: [
          // 费率（仅 BTC 类）
          if (option.feeRate != null) ...[
            _detailRow(
              context,
              S.of(context).g_key_t_36, // "Gas Fee Rate"
              '${option.feeRate} ${option.feeRateUnit ?? ''}',
              mainText: mainText,
              subtitleText: subtitleText,
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
          ],
          const Divider(height: 1),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _detailRow(
            context,
            S.of(context).g_key_t_16, // "Max gas fee"
            '$feeFormatted $unit',
            isTotal: true,
            mainText: blueColor,
            subtitleText: subtitleText,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    required Color mainText,
    required Color subtitleText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: subtitleText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: mainText,
          ),
        ),
      ],
    );
  }

  NonEvmFeeOption _getOption(NonEvmFeeSpeed speed) {
    switch (speed) {
      case NonEvmFeeSpeed.slow:
        return widget.feeModel.slow;
      case NonEvmFeeSpeed.standard:
        return widget.feeModel.standard;
      case NonEvmFeeSpeed.fast:
        return widget.feeModel.fast;
    }
  }
}
