// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/pages/aa/paymaster_select_page.dart';
import 'package:n42appv2/src/wallet/widgets/aa/aa_transaction_preview.dart';
import 'package:n42appv2/src/wallet/widgets/aa/gas_sponsorship_badge.dart';
import 'package:n42appv2/src/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// AA 转账页面
class AASendPage extends StatefulWidget {
  final SmartAccount account;
  final String walletAddress;

  const AASendPage({
    super.key,
    required this.account,
    required this.walletAddress,
  });

  @override
  State<AASendPage> createState() => _AASendPageState();
}

class _AASendPageState extends State<AASendPage> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _toFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  String _selectedToken = 'ETH';
  PaymasterOption _selectedPaymaster = PaymasterOption.none;
  bool _isEstimating = false;
  bool _isSending = false;

  BigInt? _estimatedGas;
  BigInt? _maxFeePerGas;

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _toFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _estimateGas() async {
    if (_toController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() => _isEstimating = true);

    // 模拟 Gas 估算
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isEstimating = false;
        _estimatedGas = BigInt.from(150000);
        _maxFeePerGas = BigInt.from(50 * 1e9); // 50 Gwei
      });
    }
  }

  void _selectPaymaster() async {
    final result = await Navigator.push<PaymasterOption>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymasterSelectPage(
          currentOption: _selectedPaymaster,
          chainId: widget.account.chainId,
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedPaymaster = result);
      _estimateGas();
    }
  }

  void _showTransactionPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AATransactionPreview(
        data: AATransactionPreviewData(
          fromAddress: widget.account.address,
          toAddress: _toController.text,
          amount: _amountController.text,
          tokenSymbol: _selectedToken,
          estimatedGas: _estimatedGas,
          maxFeePerGas: _maxFeePerGas,
          isGasSponsored: _selectedPaymaster.type == PaymasterType.sponsored,
        ),
        onConfirm: () {
          Navigator.pop(context);
          _sendTransaction();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _sendTransaction() async {
    setState(() => _isSending = true);

    // 模拟发送交易
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_140),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_48,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 发送方信息
                _buildFromSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // 接收方地址
                _buildToSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // 金额输入
                _buildAmountSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // Paymaster 选择
                _buildPaymasterSection(),
                SizedBox(height: ScreenUtil().setWidth(24)),

                // Gas 估算
                _buildGasSection(),
                SizedBox(height: ScreenUtil().setWidth(32)),

                // 发送按钮
                _buildSendButton(),
              ],
            ),
          ),
          if (_isSending)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFromSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_75,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E97F6).withAlpha(25),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: ScreenUtil().setWidth(24),
                  color: const Color(0xFF5E97F6),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    Text(
                      widget.account.shortAddress,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        fontFamily: 'monospace',
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  'AA',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_38,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextField(
          controller: _toController,
          focusNode: _toFocusNode,
          onChanged: (_) => _estimateGas(),
          decoration: InputDecoration(
            hintText: S.of(context).g_key_41,
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // 扫码
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                IconButton(
                  onPressed: () {
                    // 地址簿
                  },
                  icon: const Icon(Icons.contacts_outlined),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_44,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '${S.of(context).g_key_43}: 1.5 $_selectedToken',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _amountController.text = '1.5';
                    _estimateGas();
                  },
                  child: Text(S.of(context).g_key_197),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _estimateGas(),
                decoration: InputDecoration(
                  hintText: '0.0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                ),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(14),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedToken,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymasterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_gas_payment,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            TextButton(
              onPressed: _selectPaymaster,
              child: Text(S.of(context).g_key_aa_change),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        GestureDetector(
          onTap: _selectPaymaster,
          child: PaymasterOptionCard(
            option: _selectedPaymaster,
            isSelected: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGasSection() {
    final isSponsored = _selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: isSponsored
            ? Colors.green.withAlpha(15)
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isSponsored ? Border.all(color: Colors.green.withAlpha(30)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_gas_station,
                    size: ScreenUtil().setWidth(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    S.of(context).g_key_aa_estimated_gas,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isEstimating)
                SizedBox(
                  width: ScreenUtil().setWidth(20),
                  height: ScreenUtil().setWidth(20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_estimatedGas != null)
                Text(
                  isSponsored ? S.of(context).g_key_aa_free : _formatGasCost(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSponsored
                        ? Colors.green
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                  ),
                )
              else
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
            ],
          ),
          if (isSponsored && _estimatedGas != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            GasSponsorshipBadge(
              isSponsored: true,
              savedAmount: _formatGasCost(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = _toController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _estimatedGas != null &&
        !_isEstimating &&
        !_isSending;

    return ElevatedButton(
      onPressed: canSend ? _showTransactionPreview : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        disabledBackgroundColor: Colors.grey,
      ),
      child: Text(
        S.of(context).g_key_48,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatGasCost() {
    if (_estimatedGas == null || _maxFeePerGas == null) return '-';
    final cost = _estimatedGas! * _maxFeePerGas!;
    final ethValue = cost / BigInt.from(10).pow(18);
    return '${ethValue.toStringAsFixed(6)} ETH';
  }
}
