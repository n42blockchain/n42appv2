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
import 'package:n42_wallet/core/design_system/design_system.dart';

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
  static final _numericFilter = FilteringTextInputFormatter.allow(RegExp(r'[\d.]'));

  late GasEstimateModel _gasEstimate;
  late GasSpeed _selectedSpeed;
  bool _isCustomMode = false;

  final _gasLimitController = TextEditingController();
  final _gasPriceController = TextEditingController();
  final _maxPriorityFeeController = TextEditingController();
  final _maxFeeController = TextEditingController();

  Color _themeColor(BuildContext context, AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

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
    if (_isCustomMode) _applyCustomValues();
    Navigator.pop(context, _gasEstimate);
  }

  void _applyCustomValues() {
    final gasLimit = BigInt.tryParse(_gasLimitController.text) ?? _gasEstimate.gasLimit;

    final GasOption customOption;
    if (_gasEstimate.supportsEIP1559) {
      customOption = GasOption.eip1559(
        maxPriorityFeePerGas: _gweiToWei(_maxPriorityFeeController.text),
        maxFeePerGas: _gweiToWei(_maxFeeController.text),
        baseFee: _gasEstimate.baseFee ?? BigInt.zero,
        estimatedSeconds: 30,
      );
    } else {
      customOption = GasOption.legacy(
        gasPrice: _gweiToWei(_gasPriceController.text),
        estimatedSeconds: 60,
      );
    }

    _gasEstimate = GasEstimateModel(
      supportsEIP1559: _gasEstimate.supportsEIP1559,
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
                    _buildNetworkStatus(context),
                    SizedBox(height: ScreenUtil().setWidth(30)),
                    GasSelectorWidget(
                      gasEstimate: _gasEstimate,
                      onSpeedChanged: _onSpeedChanged,
                      showDetails: true,
                      expandable: true,
                      initialExpanded: true,
                    ),

                    SizedBox(height: ScreenUtil().setWidth(30)),

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

            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  ({String text, Color color, IconData icon}) _resolveNetworkStatus(BuildContext context) {
    final baseFee = _gasEstimate.baseFee;
    final l10n = S.of(context);
    if (baseFee == null) {
      return (text: l10n.g_key_gas_network_normal, color: Colors.green, icon: Icons.check_circle);
    }
    final baseFeeGwei = baseFee ~/ GasConstants.gweiInWei;
    if (baseFeeGwei < BigInt.from(GasConstants.networkIdleThresholdGwei)) {
      return (text: l10n.g_key_gas_network_idle, color: Colors.green, icon: Icons.check_circle);
    }
    if (baseFeeGwei < BigInt.from(GasConstants.networkBusyThresholdGwei)) {
      return (text: l10n.g_key_gas_network_normal, color: Colors.orange, icon: Icons.info);
    }
    return (text: l10n.g_key_gas_network_busy, color: Colors.red, icon: Icons.warning);
  }

  Widget _buildNetworkStatus(BuildContext context) {
    final baseFee = _gasEstimate.baseFee;
    final status = _resolveNetworkStatus(context);
    final su = ScreenUtil();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(su.setWidth(12)),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: su.setWidth(40)),
          SizedBox(width: su.setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.text,
                  style: TextStyle(
                    fontSize: su.setSp(28),
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                if (baseFee != null)
                  Text(
                    'Base Fee: ${_formatGwei(baseFee)} Gwei',
                    style: TextStyle(
                      fontSize: su.setSp(24),
                      color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
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
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_key_gas_custom,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: _themeColor(context, AppThemeKeys.mainTextColor),
              ),
            ),
          ),
          Switch(
            value: _isCustomMode,
            onChanged: (value) => setState(() => _isCustomMode = value),
            activeTrackColor: blueColor.withValues(alpha: 0.5),
            activeThumbColor: blueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInputs(BuildContext context) {
    final su = ScreenUtil();
    final l10n = S.of(context);
    final gap = SizedBox(height: su.setWidth(20));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(su.setWidth(16)),
      ),
      child: Column(
        children: [
          _buildInputField(context, label: l10n.g_key_101, controller: _gasLimitController, suffix: ''),
          gap,
          if (_gasEstimate.supportsEIP1559) ...[
            _buildInputField(context, label: l10n.g_key_gas_priority_fee, controller: _maxPriorityFeeController, suffix: 'Gwei'),
            gap,
            _buildInputField(context, label: l10n.g_key_gas_max_fee, controller: _maxFeeController, suffix: 'Gwei'),
          ] else
            _buildInputField(context, label: l10n.g_key_t_17, controller: _gasPriceController, suffix: 'Gwei'),
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
    final su = ScreenUtil();
    final subtitleColor = _themeColor(context, AppThemeKeys.itemSubtitleTextColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: su.setSp(26), color: subtitleColor),
        ),
        SizedBox(height: su.setWidth(8)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_numericFilter],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: su.setWidth(20),
              vertical: su.setWidth(16),
            ),
            filled: true,
            fillColor: _themeColor(context, AppThemeKeys.backGroundColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(su.setWidth(12)),
              borderSide: BorderSide.none,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(fontSize: su.setSp(26), color: subtitleColor),
          ),
          style: TextStyle(
            fontSize: su.setSp(28),
            color: _themeColor(context, AppThemeKeys.mainTextColor),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final totalFee = _calculateTotalFee();
    final formatted = toEther(totalFee.toString(), _gasEstimate.decimals);
    final su = ScreenUtil();

    return Container(
      padding: EdgeInsets.all(su.setWidth(30)),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.backGroundColor),
        border: Border(
          top: BorderSide(
            color: _themeColor(context, AppThemeKeys.dividerColor),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_t_16,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: su.setSp(28),
                    color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
                  ),
                ),
              ),
              Text(
                '${Decimal.parse(formatted.toString())} ${_gasEstimate.unit}',
                style: TextStyle(
                  fontSize: su.setSp(32),
                  fontWeight: FontWeight.bold,
                  color: _themeColor(context, AppThemeKeys.mainBlueColor),
                ),
              ),
            ],
          ),
          SizedBox(height: su.setWidth(20)),
          SizedBox(
            width: double.infinity,
            height: su.setWidth(88),
            child: AppButton(
              label: S.of(context).g_key_78,
              onPressed: _onConfirm,
            ),
          ),
        ],
      ),
    );
  }

  BigInt _calculateTotalFee() {
    if (!_isCustomMode) return _gasEstimate.currentTotalFee;

    final gasLimit = BigInt.tryParse(_gasLimitController.text) ?? _gasEstimate.gasLimit;
    final controller = _gasEstimate.supportsEIP1559 ? _maxFeeController : _gasPriceController;
    return gasLimit * _gweiToWei(controller.text);
  }
}
