// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/models/non_evm_fee_model.dart';
import 'package:n42_wallet/features/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Non-EVM chain Gas settings page.
///
/// Allows the user to pick Slow/Standard/Fast tiers.
/// Editable chains (BTC UTXO etc.) also support custom sat/byte input.
///
/// Returns `NonEvmGasResult` via `Navigator.pop`.
class NonEvmGasSettingsPage extends StatefulWidget {
  final NonEvmFeeModel feeModel;

  const NonEvmGasSettingsPage({super.key, required this.feeModel});

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
      _customRateCtrl.text = _feeModel.currentOption.feeRate?.toString() ?? '';
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
        _customRateCtrl.text = _getOption(speed).feeRate?.toString() ?? '';
      }
    });
  }

  NonEvmFeeOption _getOption(NonEvmFeeSpeed speed) => switch (speed) {
    NonEvmFeeSpeed.slow => _feeModel.slow,
    NonEvmFeeSpeed.standard => _feeModel.standard,
    NonEvmFeeSpeed.fast => _feeModel.fast,
  };

  void _validateCustomRate(String value) {
    final rate = int.tryParse(value);
    setState(() {
      _customRateError = (rate == null || rate <= 0)
          ? S.current.g_key_t_43
          : '';
    });
  }

  void _confirm() {
    if (_isCustom && _customRateError.isNotEmpty) return;

    Navigator.pop(
      context,
      NonEvmGasResult(
        feeModel: _feeModel,
        customFeeRate: _isCustom ? int.tryParse(_customRateCtrl.text) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppColorTokens.of(context).brand;
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final itemBg = AppColorTokens.of(context).bgSurface;

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_gas_settings),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ScreenUtil().setWidth(20)),
                  NonEvmFeeSelector(
                    feeModel: _feeModel,
                    onSpeedChanged: _onSpeedChanged,
                    showDetails: true,
                  ),
                  if (_feeModel.isEditable) ...[
                    SizedBox(height: ScreenUtil().setWidth(20)),
                    _buildCustomRateSection(
                      context,
                      blueColor: blueColor,
                      mainText: mainText,
                      subtitleText: subtitleText,
                      itemBg: itemBg,
                    ),
                  ],
                  SizedBox(height: ScreenUtil().setWidth(30)),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(30),
            ),
            child: SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: AppButton(
                label: S.of(context).g_key_78,
                onPressed: _confirm,
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
    final feeRateUnit = _feeModel.currentOption.feeRateUnit ?? 'sat/byte';
    final borderColor = _customRateError.isNotEmpty
        ? AppColorTokens.of(context).danger
        : AppColorTokens.of(context).border;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(color: itemBg, borderRadius: AppRadius.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                size: ScreenUtil().setWidth(36),
                color: blueColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Flexible(
                child: Text(
                  S.of(context).g_key_gas_custom,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: mainText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(12),
            ),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgBase,
              borderRadius: AppRadius.brMd,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customRateCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTypography.body.copyWith(color: mainText),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_t_43,
                      hintStyle: AppTypography.bodySm.copyWith(color: subtitleText),
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
                  style: AppTypography.caption.copyWith(color: subtitleText),
                ),
              ],
            ),
          ),
          if (_customRateError.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              _customRateError,
              style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).danger),
            ),
          ],
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            '${S.of(context).g_key_t_37}: '
            '${_feeModel.standard.feeRate ?? '-'} $feeRateUnit',
            style: AppTypography.caption.copyWith(color: subtitleText),
          ),
        ],
      ),
    );
  }
}

/// Result returned from [NonEvmGasSettingsPage].
///
/// Callers should prefer [customFeeRate] (if non-null) over
/// [feeModel.currentOption.feeRate].
class NonEvmGasResult {
  final NonEvmFeeModel feeModel;
  final int? customFeeRate;

  int? get effectiveFeeRate => customFeeRate ?? feeModel.currentOption.feeRate;

  const NonEvmGasResult({required this.feeModel, this.customFeeRate});
}
