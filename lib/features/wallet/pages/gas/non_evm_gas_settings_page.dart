// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/non_evm_fee_model.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';

/// 非 EVM 链 Gas 设置页
///
/// 允许用户在 Slow/Standard/Fast 三档中选择，
/// 可编辑链（BTC 等 UTXO 链）还支持自定义 sat/byte 输入。
///
/// 通过 `Navigator.pop(context, NonEvmFeeModel)` 返回更新后的模型。
class NonEvmGasSettingsPage extends StatefulWidget {
  final NonEvmFeeModel feeModel;

  const NonEvmGasSettingsPage({
    super.key,
    required this.feeModel,
  });

  @override
  State<NonEvmGasSettingsPage> createState() => _NonEvmGasSettingsPageState();
}

class _NonEvmGasSettingsPageState extends State<NonEvmGasSettingsPage> {
  late NonEvmFeeModel _feeModel;
  bool _isCustom = false;
  final TextEditingController _customRateCtrl = TextEditingController();
  String _customRateError = '';

  @override
  void initState() {
    super.initState();
    // 复制模型——速度变更只影响本页，直到用户点确认才提交
    _feeModel = NonEvmFeeModel(
      chainSymbol: widget.feeModel.chainSymbol,
      unit: widget.feeModel.unit,
      decimals: widget.feeModel.decimals,
      slow: widget.feeModel.slow,
      standard: widget.feeModel.standard,
      fast: widget.feeModel.fast,
      isEditable: widget.feeModel.isEditable,
      selectedSpeed: widget.feeModel.selectedSpeed,
    );
    if (_feeModel.isEditable) {
      _customRateCtrl.text =
          _feeModel.currentOption.feeRate?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _customRateCtrl.dispose();
    super.dispose();
  }

  void _onSpeedChanged(NonEvmFeeSpeed speed) {
    setState(() {
      _isCustom = false;
      _customRateError = '';
      if (_feeModel.isEditable) {
        _customRateCtrl.text =
            _getOption(speed).feeRate?.toString() ?? '';
      }
    });
  }

  NonEvmFeeOption _getOption(NonEvmFeeSpeed speed) {
    switch (speed) {
      case NonEvmFeeSpeed.slow:
        return _feeModel.slow;
      case NonEvmFeeSpeed.standard:
        return _feeModel.standard;
      case NonEvmFeeSpeed.fast:
        return _feeModel.fast;
    }
  }

  void _validateCustomRate(String value) {
    final rate = int.tryParse(value);
    setState(() {
      _customRateError = (rate == null || rate <= 0)
          ? S.current.g_key_t_43 // "Enter a whole number greater than 0."
          : '';
    });
  }

  void _confirm() {
    // 如果自定义模式下输入有误，阻止提交
    if (_isCustom && _customRateError.isNotEmpty) return;

    Navigator.pop(context, NonEvmGasResult(
      feeModel: _feeModel,
      customFeeRate: _isCustom ? int.tryParse(_customRateCtrl.text) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_gas_settings,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 三档速度选择器
                  NonEvmFeeSelector(
                    feeModel: _feeModel,
                    onSpeedChanged: _onSpeedChanged,
                    showDetails: true,
                  ),

                  // 自定义费率输入（仅 BTC 等可编辑链）
                  if (_feeModel.isEditable) ...[
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    _buildCustomRateSection(context,
                        blueColor: blueColor,
                        mainText: mainText,
                        subtitleText: subtitleText,
                        itemBg: itemBg),
                  ],

                  SizedBox(height: ScreenUtil().setWidth(30)),
                ],
              ),
            ),
          ),

          // 确认按钮
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(30),
            ),
            child: SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: buttonStyle2(
                context,
                _confirm,
                S.of(context).g_key_78, // "Confirm"
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRateSection(
    BuildContext context, {
    required Color blueColor,
    required Color mainText,
    required Color subtitleText,
    required Color itemBg,
  }) {
    final feeRateUnit =
        _feeModel.currentOption.feeRateUnit ?? 'sat/byte';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(
                Icons.tune,
                size: ScreenUtil().setWidth(36),
                color: blueColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_gas_custom,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),

          // 费率输入框
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(12),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              border: Border.all(
                color: _customRateError.isNotEmpty
                    ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorTextColor.name)
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.dividerColor.name),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customRateCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: mainText,
                    ),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_t_43, // "Fee rate"
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        color: subtitleText,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) {
                      _isCustom = v.isNotEmpty;
                      _validateCustomRate(v);
                    },
                  ),
                ),
                Text(
                  feeRateUnit,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subtitleText,
                  ),
                ),
              ],
            ),
          ),

          // 错误提示
          if (_customRateError.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              _customRateError,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name),
              ),
            ),
          ],

          // 参考网络平均费率
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            '${S.of(context).g_key_t_37}: '
            '${_feeModel.standard.feeRate ?? '-'} $feeRateUnit',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

/// 从 `NonEvmGasSettingsPage` 弹出时携带的结果
///
/// 调用方应优先使用 [customFeeRate]（如果不为 null）
/// 而非 [feeModel.currentOption.feeRate]。
class NonEvmGasResult {
  final NonEvmFeeModel feeModel;
  final int? customFeeRate;

  /// 实际应用的费率：自定义输入 > 档位费率 > null
  int? get effectiveFeeRate =>
      customFeeRate ?? feeModel.currentOption.feeRate;

  const NonEvmGasResult({
    required this.feeModel,
    this.customFeeRate,
  });
}