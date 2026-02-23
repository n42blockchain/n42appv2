// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/gas_selector_widget.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';

/// Gas 设置页面
///
/// 允许用户选择 Gas 速度或自定义 Gas 参数
class GasSettingsPage extends StatefulWidget {
  /// Gas 估算数据
  final GasEstimateModel gasEstimate;

  /// 是否允许自定义
  final bool allowCustom;

  const GasSettingsPage({
    super.key,
    required this.gasEstimate,
    this.allowCustom = true,
  });

  @override
  State<GasSettingsPage> createState() => _GasSettingsPageState();
}

class _GasSettingsPageState extends State<GasSettingsPage> {
  late GasEstimateModel _gasEstimate;
  late GasSpeed _selectedSpeed;
  bool _isCustomMode = false;

  // 自定义输入控制器
  final TextEditingController _gasLimitController = TextEditingController();
  final TextEditingController _gasPriceController = TextEditingController();
  final TextEditingController _maxPriorityFeeController = TextEditingController();
  final TextEditingController _maxFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gasEstimate = widget.gasEstimate;
    _selectedSpeed = _gasEstimate.selectedSpeed;
    _initControllers();
  }

  void _initControllers() {
    _gasLimitController.text = _gasEstimate.gasLimit.toString();

    final currentOption = _gasEstimate.currentOption;
    if (_gasEstimate.supportsEIP1559 && currentOption.eip1559 != null) {
      _maxPriorityFeeController.text = _formatGwei(currentOption.maxPriorityFeePerGas);
      _maxFeeController.text = _formatGwei(currentOption.effectiveGasPrice);
    } else {
      _gasPriceController.text = _formatGwei(currentOption.effectiveGasPrice);
    }
  }

  @override
  void dispose() {
    _gasLimitController.dispose();
    _gasPriceController.dispose();
    _maxPriorityFeeController.dispose();
    _maxFeeController.dispose();
    super.dispose();
  }

  void _onSpeedChanged(GasSpeed speed) {
    setState(() {
      _selectedSpeed = speed;
      _gasEstimate.selectedSpeed = speed;
      _isCustomMode = false;
      _initControllers();
    });
  }

  void _onConfirm() {
    if (_isCustomMode) {
      // 应用自定义值
      _applyCustomValues();
    }
    Navigator.pop(context, _gasEstimate);
  }

  void _applyCustomValues() {
    final gasLimit = BigInt.tryParse(_gasLimitController.text) ?? _gasEstimate.gasLimit;

    if (_gasEstimate.supportsEIP1559) {
      final maxPriorityFee = _gweiToWei(_maxPriorityFeeController.text);
      final maxFee = _gweiToWei(_maxFeeController.text);

      // 创建自定义的 GasOption
      final customOption = GasOption.eip1559(
        maxPriorityFeePerGas: maxPriorityFee,
        maxFeePerGas: maxFee,
        baseFee: _gasEstimate.baseFee ?? BigInt.zero,
        estimatedSeconds: 30, // 自定义模式无法预测时间
      );

      // 更新到当前选择的速度档位
      _gasEstimate = GasEstimateModel(
        supportsEIP1559: true,
        slow: _selectedSpeed == GasSpeed.slow ? customOption : _gasEstimate.slow,
        standard: _selectedSpeed == GasSpeed.standard ? customOption : _gasEstimate.standard,
        fast: _selectedSpeed == GasSpeed.fast ? customOption : _gasEstimate.fast,
        baseFee: _gasEstimate.baseFee,
        gasLimit: gasLimit,
        chainSymbol: _gasEstimate.chainSymbol,
        decimals: _gasEstimate.decimals,
        unit: _gasEstimate.unit,
        selectedSpeed: _selectedSpeed,
      );
    } else {
      final gasPrice = _gweiToWei(_gasPriceController.text);

      final customOption = GasOption.legacy(
        gasPrice: gasPrice,
        estimatedSeconds: 60,
      );

      _gasEstimate = GasEstimateModel(
        supportsEIP1559: false,
        slow: _selectedSpeed == GasSpeed.slow ? customOption : _gasEstimate.slow,
        standard: _selectedSpeed == GasSpeed.standard ? customOption : _gasEstimate.standard,
        fast: _selectedSpeed == GasSpeed.fast ? customOption : _gasEstimate.fast,
        gasLimit: gasLimit,
        chainSymbol: _gasEstimate.chainSymbol,
        decimals: _gasEstimate.decimals,
        unit: _gasEstimate.unit,
        selectedSpeed: _selectedSpeed,
      );
    }
  }

  BigInt _gweiToWei(String gwei) {
    try {
      final decimal = Decimal.parse(gwei);
      final wei = decimal * Decimal.fromInt(1000000000);
      return BigInt.parse(wei.floor().toString());
    } catch (e) {
      return BigInt.zero;
    }
  }

  String _formatGwei(BigInt wei) {
    final gwei = toGWei(wei.toString());
    return Decimal.parse(gwei.toString()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_gas_settings,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 网络状态指示
                    _buildNetworkStatus(context),
                    SizedBox(height: ScreenUtil().setWidth(30)),

                    // Gas 速度选择器
                    GasSelectorWidget(
                      gasEstimate: _gasEstimate,
                      onSpeedChanged: _onSpeedChanged,
                      showDetails: true,
                      expandable: true,
                      initialExpanded: true,
                    ),

                    SizedBox(height: ScreenUtil().setWidth(30)),

                    // 自定义模式开关
                    if (widget.allowCustom) ...[
                      _buildCustomToggle(context),
                      if (_isCustomMode) ...[
                        SizedBox(height: ScreenUtil().setWidth(20)),
                        _buildCustomInputs(context),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // 确认按钮
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus(BuildContext context) {
    final baseFee = _gasEstimate.baseFee;
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (baseFee == null) {
      statusText = S.of(context).g_key_gas_network_normal;
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      // 根据 base fee 判断网络拥堵程度
      final baseFeeGwei = baseFee ~/ GasConstants.gweiInWei;
      if (baseFeeGwei < BigInt.from(GasConstants.networkIdleThresholdGwei)) {
        statusText = S.of(context).g_key_gas_network_idle;
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else if (baseFeeGwei < BigInt.from(GasConstants.networkBusyThresholdGwei)) {
        statusText = S.of(context).g_key_gas_network_normal;
        statusColor = Colors.orange;
        statusIcon = Icons.info;
      } else {
        statusText = S.of(context).g_key_gas_network_busy;
        statusColor = Colors.red;
        statusIcon = Icons.warning;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: ScreenUtil().setWidth(40)),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (baseFee != null)
                  Text(
                    'Base Fee: ${_formatGwei(baseFee)} Gwei',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomToggle(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).g_key_gas_custom,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          Switch(
            value: _isCustomMode,
            onChanged: (value) {
              setState(() {
                _isCustomMode = value;
              });
            },
            activeTrackColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha: 0.5),
            activeThumbColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInputs(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          _buildInputField(
            context,
            label: S.of(context).g_key_101, // Gas Limit
            controller: _gasLimitController,
            suffix: '',
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          if (_gasEstimate.supportsEIP1559) ...[
            _buildInputField(
              context,
              label: S.of(context).g_key_gas_priority_fee,
              controller: _maxPriorityFeeController,
              suffix: 'Gwei',
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            _buildInputField(
              context,
              label: S.of(context).g_key_gas_max_fee,
              controller: _maxFeeController,
              suffix: 'Gwei',
            ),
          ] else ...[
            _buildInputField(
              context,
              label: S.of(context).g_key_t_17, // Gas Price
              controller: _gasPriceController,
              suffix: 'Gwei',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    // 计算当前总费用
    final totalFee = _calculateTotalFee();
    final formatted = toEther(totalFee.toString(), _gasEstimate.decimals);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        border: Border(
          top: BorderSide(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_t_16, // Total Gas Fee
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              Text(
                '${Decimal.parse(formatted.toString())} ${_gasEstimate.unit}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          SizedBox(
            width: double.infinity,
            height: ScreenUtil().setWidth(88),
            child: buttonStyle2(
              context,
              _onConfirm,
              S.of(context).g_key_78, // Confirm
            ),
          ),
        ],
      ),
    );
  }

  BigInt _calculateTotalFee() {
    if (_isCustomMode) {
      final gasLimit = BigInt.tryParse(_gasLimitController.text) ?? _gasEstimate.gasLimit;
      BigInt gasPrice;
      if (_gasEstimate.supportsEIP1559) {
        gasPrice = _gweiToWei(_maxFeeController.text);
      } else {
        gasPrice = _gweiToWei(_gasPriceController.text);
      }
      return gasLimit * gasPrice;
    } else {
      return _gasEstimate.currentTotalFee;
    }
  }
}
