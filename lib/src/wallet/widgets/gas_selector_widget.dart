// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/gas_tracker_api.dart';
import 'package:n42appv2/src/wallet/models/gas_estimate_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';

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
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
    return InkWell(
      onTap: widget.expandable ? () => setState(() => _isExpanded = !_isExpanded) : null,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: ScreenUtil().setWidth(40),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                Text(
                  S.of(context).g_key_t_16, // Gas Fee
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _formatTotalFee(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                if (widget.expandable) ...[
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: ScreenUtil().setWidth(40),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
          _buildSpeedOption(context, GasSpeed.slow, S.of(context).g_key_gas_slow, Icons.snooze),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildSpeedOption(context, GasSpeed.standard, S.of(context).g_key_gas_standard, Icons.speed),
          SizedBox(width: ScreenUtil().setWidth(16)),
          _buildSpeedOption(context, GasSpeed.fast, S.of(context).g_key_gas_fast, Icons.flash_on),
        ],
      ),
    );
  }

  Widget _buildSpeedOption(BuildContext context, GasSpeed speed, String label, IconData icon) {
    final isSelected = _selectedSpeed == speed;
    final option = _getOption(speed);
    final estimatedTime = GasTrackerApi.formatEstimatedTime(option.estimatedSeconds);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onSpeedSelected(speed),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20),
            horizontal: ScreenUtil().setWidth(16),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            border: Border.all(
              color: isSelected
                  ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                  : AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: ScreenUtil().setWidth(36),
                color: isSelected
                    ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                estimatedTime,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
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

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            S.of(context).g_key_101, // Gas Limit
            gasLimit.toString(),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          if (widget.gasEstimate.supportsEIP1559 && currentOption.eip1559 != null) ...[
            _buildDetailRow(
              context,
              'Base Fee',
              '${_formatGwei(widget.gasEstimate.baseFee ?? BigInt.zero)} Gwei',
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            _buildDetailRow(
              context,
              'Max Priority Fee',
              '${_formatGwei(currentOption.maxPriorityFeePerGas)} Gwei',
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            _buildDetailRow(
              context,
              'Max Fee',
              '${_formatGwei(currentOption.effectiveGasPrice)} Gwei',
            ),
          ] else ...[
            _buildDetailRow(
              context,
              S.of(context).g_key_t_17, // Gas Price
              '${_formatGwei(currentOption.effectiveGasPrice)} Gwei',
            ),
          ],
          SizedBox(height: ScreenUtil().setWidth(16)),
          Divider(height: 1),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildDetailRow(
            context,
            S.of(context).g_key_t_16, // Total Fee
            _formatTotalFee(),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
    final gwei = toGWei(wei.toString());
    return Decimal.parse(gwei.toString()).toString();
  }
}

/// 紧凑版 Gas 选择器（用于转账确认页面）
class GasSelectorCompact extends StatelessWidget {
  final GasEstimateModel gasEstimate;
  final VoidCallback? onTap;

  const GasSelectorCompact({
    super.key,
    required this.gasEstimate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentOption = gasEstimate.currentOption;
    final totalFee = gasEstimate.currentTotalFee;
    final decimals = gasEstimate.decimals;
    final unit = gasEstimate.unit;
    final formatted = toEther(totalFee.toString(), decimals);
    final estimatedTime = GasTrackerApi.formatEstimatedTime(currentOption.estimatedSeconds);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(20),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: ScreenUtil().setWidth(36),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSpeedLabel(context, gasEstimate.selectedSpeed),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                    Text(
                      estimatedTime,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${Decimal.parse(formatted.toString())} $unit',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Icon(
                    Icons.edit,
                    size: ScreenUtil().setWidth(32),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
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
