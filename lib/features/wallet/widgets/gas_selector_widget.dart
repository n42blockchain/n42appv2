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
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// Gas 选择器组件
///
/// 提供慢/标准/快三档 Gas 选择，支持 EIP-1559 和 Legacy 模式
class GasSelectorWidget extends StatefulWidget {
  /// Gas 估算数据
  final GasEstimateModel gasEstimate;

  /// 选择改变回调
  final ValueChanged<GasSpeed>? onSpeedChanged;

  /// 是否显示详细信息
  final bool showDetails;

  /// 是否可展开
  final bool expandable;

  /// 初始是否展开
  final bool initialExpanded;

  const GasSelectorWidget({
    super.key,
    required this.gasEstimate,
    this.onSpeedChanged,
    this.showDetails = true,
    this.expandable = true,
    this.initialExpanded = false,
  });

  @override
  State<GasSelectorWidget> createState() => _GasSelectorWidgetState();
}

class _GasSelectorWidgetState extends State<GasSelectorWidget> {
  late GasSpeed _selectedSpeed;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.gasEstimate.selectedSpeed;
    _isExpanded = widget.initialExpanded;
  }

  @override
  void didUpdateWidget(GasSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gasEstimate != oldWidget.gasEstimate) {
      _selectedSpeed = widget.gasEstimate.selectedSpeed;
    }
  }

  void _onSpeedSelected(GasSpeed speed) {
    setState(() {
      _selectedSpeed = speed;
      widget.gasEstimate.selectedSpeed = speed;
    });
    widget.onSpeedChanged?.call(speed);
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
          _buildHeader(context),
          _buildSpeedSelector(context),
          if (widget.showDetails && _isExpanded) _buildDetails(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;

    return InkWell(
      onTap: widget.expandable
          ? () => setState(() => _isExpanded = !_isExpanded)
          : null,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(
                    Icons.local_gas_station,
                    size: ScreenUtil().setWidth(40),
                    color: blueColor,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(16)),
                  Flexible(
                    child: Text(
                      S.of(context).g_key_t_16, // Gas Fee
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: mainText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _formatTotalFee(),
                  style: AppTypography.body.copyWith(color: mainText),
                ),
                if (widget.expandable) ...[
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: ScreenUtil().setWidth(40),
                    color: subtitleText,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedSelector(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          _buildSpeedOption(
            context,
            GasSpeed.slow,
            S.of(context).g_key_gas_slow,
            Icons.snooze,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildSpeedOption(
            context,
            GasSpeed.standard,
            S.of(context).g_key_gas_standard,
            Icons.speed,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildSpeedOption(
            context,
            GasSpeed.fast,
            S.of(context).g_key_gas_fast,
            Icons.flash_on,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedOption(
    BuildContext context,
    GasSpeed speed,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedSpeed == speed;
    final option = _getOption(speed);
    final estimatedTime = GasTrackerApi.formatEstimatedTime(
      option.estimatedSeconds,
    );

    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final dividerColor = AppColorTokens.of(context).border;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onSpeedSelected(speed),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20),
            horizontal: ScreenUtil().setWidth(16),
          ),
          decoration: BoxDecoration(
            color: isSelected ? blueColor.withAlpha(25) : Colors.transparent,
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
                style: AppTypography.caption.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? blueColor : mainText,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                estimatedTime,
                style: AppTypography.caption.copyWith(color: subtitleText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final currentOption = widget.gasEstimate.currentOption;
    final gasLimit = widget.gasEstimate.gasLimit;
    final s = S.of(context);
    final spacing = SizedBox(height: ScreenUtil().setWidth(16));

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgBase,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          _buildDetailRow(context, s.g_key_101, gasLimit.toString()),
          spacing,
          if (widget.gasEstimate.supportsEIP1559 &&
              currentOption.eip1559 != null) ...[
            _buildDetailRow(
              context,
              s.g_key_gas_base_fee,
              '${_formatGwei(widget.gasEstimate.baseFee ?? BigInt.zero)} Gwei',
            ),
            spacing,
            _buildDetailRow(
              context,
              s.g_key_gas_priority_fee,
              '${_formatGwei(currentOption.maxPriorityFeePerGas)} Gwei',
            ),
            spacing,
            _buildDetailRow(
              context,
              s.g_key_gas_max_fee,
              '${_formatGwei(currentOption.effectiveGasPrice)} Gwei',
            ),
          ] else ...[
            _buildDetailRow(
              context,
              s.g_key_t_17,
              '${_formatGwei(currentOption.effectiveGasPrice)} Gwei',
            ),
          ],
          spacing,
          const Divider(height: 1),
          spacing,
          _buildDetailRow(
            context,
            s.g_key_t_16,
            _formatTotalFee(),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final valueColor = isTotal
        ? AppColorTokens.of(context).brand
        : AppColorTokens.of(context).textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(color: subtitleText),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  GasOption _getOption(GasSpeed speed) {
    switch (speed) {
      case GasSpeed.slow:
        return widget.gasEstimate.slow;
      case GasSpeed.standard:
        return widget.gasEstimate.standard;
      case GasSpeed.fast:
        return widget.gasEstimate.fast;
    }
  }

  String _formatTotalFee() {
    final totalFee = widget.gasEstimate.currentTotalFee;
    final decimals = widget.gasEstimate.decimals;
    final unit = widget.gasEstimate.unit;
    final formatted = toEther(totalFee.toString(), decimals);
    return '${Decimal.parse(formatted.toString())} $unit';
  }

  String _formatGwei(BigInt wei) {
    return Decimal.parse(toGWei(wei.toString()).toString()).toString();
  }
}

/// 紧凑版 Gas 选择器（用于转账确认页面）
class GasSelectorCompact extends StatelessWidget {
  final GasEstimateModel gasEstimate;
  final VoidCallback? onTap;

  const GasSelectorCompact({super.key, required this.gasEstimate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currentOption = gasEstimate.currentOption;
    final totalFee = gasEstimate.currentTotalFee;
    final decimals = gasEstimate.decimals;
    final unit = gasEstimate.unit;
    final formatted = Decimal.parse(
      toEther(totalFee.toString(), decimals).toString(),
    );
    final estimatedTime = GasTrackerApi.formatEstimatedTime(
      currentOption.estimatedSeconds,
    );

    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: ScreenUtil().setWidth(36),
                  color: blueColor,
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSpeedLabel(context, gasEstimate.selectedSpeed),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: mainText,
                      ),
                    ),
                    Text(
                      estimatedTime,
                      style: AppTypography.caption.copyWith(
                        color: subtitleText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '$formatted $unit',
                  style: AppTypography.body.copyWith(color: mainText),
                ),
                if (onTap != null) ...[
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Icon(
                    Icons.edit,
                    size: ScreenUtil().setWidth(32),
                    color: blueColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSpeedLabel(BuildContext context, GasSpeed speed) {
    switch (speed) {
      case GasSpeed.slow:
        return S.of(context).g_key_gas_slow;
      case GasSpeed.standard:
        return S.of(context).g_key_gas_standard;
      case GasSpeed.fast:
        return S.of(context).g_key_gas_fast;
    }
  }
}
