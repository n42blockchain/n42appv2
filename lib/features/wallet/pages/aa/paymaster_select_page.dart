// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/paymaster/paymaster_service.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// Paymaster 选择页面
///
/// 展示当前链支持的 Gas 支付方式：
/// - 自付 ETH
/// - 赞助（免费，Pimlico 验证可用性）
/// - ERC-20 代币（从 [AAConfig.chainErc20Tokens] 加载正确地址）
class PaymasterSelectPage extends StatefulWidget {
  final PaymasterOption currentOption;
  final int chainId;
  final String chainSymbol;

  const PaymasterSelectPage({
    super.key,
    required this.currentOption,
    required this.chainId,
    this.chainSymbol = '',
  });

  @override
  State<PaymasterSelectPage> createState() => _PaymasterSelectPageState();
}

class _PaymasterSelectPageState extends State<PaymasterSelectPage> {
  late PaymasterOption _selectedOption;
  _LoadState _loadState = _LoadState.loading;
  List<PaymasterOption> _availableOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.currentOption;
    _loadPaymasterOptions();
  }

  Future<void> _loadPaymasterOptions() async {
    setState(() {
      _loadState = _LoadState.loading;
    });

    try {
      final symbol = widget.chainSymbol.isNotEmpty
          ? widget.chainSymbol
          : _chainSymbolFromId(widget.chainId);

      final options = await PaymasterService.loadOptions(
        chainId: widget.chainId,
        chainSymbol: symbol,
        apiKey: AAConfig.getBundlerApiKey(),
      );

      if (mounted) {
        setState(() {
          _availableOptions = options;
          _loadState = _LoadState.success;
          // Re-sync selected option — preserve type + tokenSymbol
          _selectedOption = _findMatchingOption(options, _selectedOption)
              ?? PaymasterOption.none;
        });
      }
    } catch (e) {
      // Do not expose raw exception messages (may leak API URLs / stack traces)
      assert(() {
        debugPrint('[PaymasterSelectPage] loadOptions error: $e');
        return true;
      }());
      if (mounted) {
        setState(() => _loadState = _LoadState.error);
      }
    }
  }

  /// Find the matching option after a reload (preserves user selection).
  PaymasterOption? _findMatchingOption(
      List<PaymasterOption> options, PaymasterOption current) {
    for (final o in options) {
      if (o.type != current.type) continue;
      if (o.type == PaymasterType.erc20) {
        if (o.tokenSymbol == current.tokenSymbol) return o;
      } else {
        return o;
      }
    }
    return null;
  }

  void _onOptionSelected(PaymasterOption option) {
    if (!option.isAvailable) return;
    setState(() => _selectedOption = option);
  }

  void _confirm() => Navigator.pop(context, _selectedOption);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_select_paymaster,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: ScreenUtil().setWidth(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
            onPressed: _loadPaymasterOptions,
            tooltip: S.of(context).g_key_aa_paymaster_retry,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoSection(),
          Expanded(
            child: switch (_loadState) {
              _LoadState.loading => _buildLoading(),
              _LoadState.error   => _buildError(),
              _LoadState.success => _buildOptionsList(),
            },
          ),
          if (_loadState == _LoadState.success) _buildConfirmButton(),
        ],
      ),
    );
  }

  // ── Info section ──────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    final blueColor = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.mainBlueColor.name,
    );
    final supportedChains = PaymasterService.supportedChainSymbols;
    final isCurrentChainSupported = AAConfig.isChainSupported(
      widget.chainSymbol.isNotEmpty
          ? widget.chainSymbol
          : _chainSymbolFromId(widget.chainId),
    );

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_gas_station,
                  size: ScreenUtil().setWidth(28), color: blueColor),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text(
                S.of(context).g_key_aa_gas_payment_options,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Text(
            S.of(context).g_key_aa_paymaster_description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          // Chain coverage row
          Row(
            children: [
              Icon(
                isCurrentChainSupported
                    ? Icons.check_circle
                    : Icons.cancel,
                size: ScreenUtil().setWidth(20),
                color: isCurrentChainSupported ? Colors.green : Colors.red,
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                '${S.of(context).g_key_aa_paymaster_coverage}: '
                '${supportedChains.length} ${S.of(context).g_key_aa_paymaster_chains_supported}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              const Spacer(),
              // Supported chain chips
              _buildChainChips(supportedChains),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainChips(List<String> chains) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final currentSymbol = widget.chainSymbol.isNotEmpty
        ? widget.chainSymbol.toUpperCase()
        : _chainSymbolFromId(widget.chainId).toUpperCase();

    return Row(
      children: chains.take(5).map((sym) {
        final isCurrent = sym.toUpperCase() == currentSymbol;
        return Container(
          margin: EdgeInsets.only(left: ScreenUtil().setWidth(4)),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(6),
            vertical: ScreenUtil().setWidth(2),
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? blueColor.withAlpha(30)
                : Colors.grey.withAlpha(20),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
            border: isCurrent
                ? Border.all(color: blueColor.withAlpha(80))
                : null,
          ),
          child: Text(
            sym,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
              color: isCurrent
                  ? blueColor
                  : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_aa_paymaster_checking,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: ScreenUtil().setWidth(64), color: Colors.red),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              S.of(context).g_key_aa_paymaster_load_failed,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
            ElevatedButton.icon(
              onPressed: _loadPaymasterOptions,
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context).g_key_aa_paymaster_retry),
            ),
          ],
        ),
      ),
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

  // ── Confirm button ────────────────────────────────────────────────────────

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
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
            _buildSelectedPreview(),
            SizedBox(height: ScreenUtil().setWidth(16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(14)),
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

  Widget _buildSelectedPreview() {
    final color = _getSelectedColor();
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(_getSelectedIcon(),
              size: ScreenUtil().setWidth(28), color: color),
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
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                Text(
                  _getSelectedTitle(),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedOption.type == PaymasterType.sponsored)
            _buildFreeBadge(),
        ],
      ),
    );
  }

  Widget _buildFreeBadge() {
    return Container(
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
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _getSelectedColor() {
    switch (_selectedOption.type) {
      case PaymasterType.none:
        return AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name);
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
        return '${S.of(context).g_key_aa_pay_with} ${_selectedOption.tokenSymbol ?? 'Token'}';
    }
  }

  /// Resolve chain symbol from chain ID using [AAConfig.chainIds].
  static String _chainSymbolFromId(int chainId) {
    for (final entry in AAConfig.chainIds.entries) {
      if (entry.value == chainId) return entry.key;
    }
    return '';
  }
}

enum _LoadState { loading, success, error }
