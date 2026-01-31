// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// Paymaster 选择页面
class PaymasterSelectPage extends StatefulWidget {
  final PaymasterOption currentOption;
  final int chainId;

  const PaymasterSelectPage({
    super.key,
    required this.currentOption,
    required this.chainId,
  });

  @override
  State<PaymasterSelectPage> createState() => _PaymasterSelectPageState();
}

class _PaymasterSelectPageState extends State<PaymasterSelectPage> {
  late PaymasterOption _selectedOption;
  bool _isLoading = true;
  List<PaymasterOption> _availableOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentOption;
    _loadPaymasterOptions();
  }

  Future<void> _loadPaymasterOptions() async {
    // 模拟加载 Paymaster 选项
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _availableOptions = [
          // 自付 Gas
          PaymasterOption.none,
          // 免费 Paymaster (赞助)
          const PaymasterOption(
            type: PaymasterType.sponsored,
            isAvailable: true,
          ),
          // USDC Paymaster
          const PaymasterOption(
            type: PaymasterType.erc20,
            tokenSymbol: 'USDC',
            tokenAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            exchangeRate: 3000.0,
            isAvailable: true,
          ),
          // USDT Paymaster
          const PaymasterOption(
            type: PaymasterType.erc20,
            tokenSymbol: 'USDT',
            tokenAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
            exchangeRate: 3000.0,
            isAvailable: true,
          ),
          // DAI Paymaster (不可用示例)
          const PaymasterOption(
            type: PaymasterType.erc20,
            tokenSymbol: 'DAI',
            tokenAddress: '0x6B175474E89094C44Da98b954EesdfXAD3A564',
            exchangeRate: 3000.0,
            isAvailable: false,
            unavailableReason: 'Insufficient DAI balance',
          ),
        ];
      });
    }
  }

  void _onOptionSelected(PaymasterOption option) {
    if (!option.isAvailable) return;
    setState(() => _selectedOption = option);
  }

  void _confirm() {
    Navigator.pop(context, _selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_select_paymaster,
      ),
      body: Column(
        children: [
          // 说明信息
          _buildInfoSection(),
          // 选项列表
          Expanded(
            child: _isLoading ? _buildLoading() : _buildOptionsList(),
          ),
          // 确认按钮
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(20),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                size: ScreenUtil().setWidth(28),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_aa_gas_payment_options,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_aa_paymaster_description,
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
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildOptionsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      itemCount: _availableOptions.length,
      itemBuilder: (context, index) {
        final option = _availableOptions[index];
        final isSelected = _isOptionSelected(option);

        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: PaymasterOptionCard(
            option: option,
            isSelected: isSelected,
            onTap: () => _onOptionSelected(option),
          ),
        );
      },
    );
  }

  bool _isOptionSelected(PaymasterOption option) {
    if (option.type != _selectedOption.type) return false;
    if (option.type == PaymasterType.erc20) {
      return option.tokenSymbol == _selectedOption.tokenSymbol;
    }
    return true;
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 选中的选项预览
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
              decoration: BoxDecoration(
                color: _getSelectedColor().withAlpha(15),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                border: Border.all(
                  color: _getSelectedColor().withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSelectedIcon(),
                    size: ScreenUtil().setWidth(28),
                    color: _getSelectedColor(),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).g_key_aa_selected,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                          ),
                        ),
                        Text(
                          _getSelectedTitle(),
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontWeight: FontWeight.w600,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedOption.type == PaymasterType.sponsored)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10),
                        vertical: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                      child: Text(
                        S.of(context).g_key_aa_free,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
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
                child: Text(
                  S.of(context).g_key_78,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSelectedColor() {
    switch (_selectedOption.type) {
      case PaymasterType.none:
        return AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        );
      case PaymasterType.sponsored:
        return Colors.green;
      case PaymasterType.erc20:
        return Colors.purple;
    }
  }

  IconData _getSelectedIcon() {
    switch (_selectedOption.type) {
      case PaymasterType.none:
        return Icons.account_balance_wallet;
      case PaymasterType.sponsored:
        return Icons.card_giftcard;
      case PaymasterType.erc20:
        return Icons.token;
    }
  }

  String _getSelectedTitle() {
    switch (_selectedOption.type) {
      case PaymasterType.none:
        return S.of(context).g_key_aa_pay_with_eth;
      case PaymasterType.sponsored:
        return S.of(context).g_key_aa_sponsored;
      case PaymasterType.erc20:
        return '${S.of(context).g_key_aa_pay_with} ${_selectedOption.tokenSymbol}';
    }
  }
}
