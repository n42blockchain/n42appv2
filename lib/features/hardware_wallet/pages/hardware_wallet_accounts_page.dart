// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'hardware_wallet_accounts_widgets.dart';

/// 硬件钱包账户页面
///
/// 支持的链：ETH / BTC / BNB / MATIC / ARB / OP / BASE / AVAX / SOL / LTC / DOGE / BCH / ATOM / DOT / TRX
class HardwareWalletAccountsPage extends StatefulWidget {
  final HardwareWalletProvider provider;
  const HardwareWalletAccountsPage({super.key, required this.provider});

  @override
  State<HardwareWalletAccountsPage> createState() =>
      _HardwareWalletAccountsPageState();
}

class _HardwareWalletAccountsPageState
    extends State<HardwareWalletAccountsPage> {
  String _selectedCoinType = 'ETH';
  bool _isLoading = false;
  bool _isLoadingMore = false;

  /// 支持的链列表（symbol, name）
  static const List<Map<String, String>> _supportedCoins = [
    // EVM 链 — 共用 Ledger Ethereum app
    {'symbol': 'ETH', 'name': 'Ethereum'},
    {'symbol': 'BNB', 'name': 'BNB Chain'},
    {'symbol': 'MATIC', 'name': 'Polygon'},
    {'symbol': 'ARB', 'name': 'Arbitrum'},
    {'symbol': 'OP', 'name': 'Optimism'},
    {'symbol': 'BASE', 'name': 'Base'},
    {'symbol': 'AVAX', 'name': 'Avalanche'},
    // UTXO 链
    {'symbol': 'BTC', 'name': 'Bitcoin'},
    {'symbol': 'LTC', 'name': 'Litecoin'},
    {'symbol': 'DOGE', 'name': 'Dogecoin'},
    {'symbol': 'BCH', 'name': 'Bitcoin Cash'},
    // 其他链
    {'symbol': 'SOL', 'name': 'Solana'},
    {'symbol': 'ATOM', 'name': 'Cosmos'},
    {'symbol': 'DOT', 'name': 'Polkadot'},
    {'symbol': 'TRX', 'name': 'Tron'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      await widget.provider.loadAccounts(_selectedCoinType);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreAccounts() async {
    setState(() => _isLoadingMore = true);
    try {
      await widget.provider.loadMoreAccounts();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_hw_wallet_accounts),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.provider,
          builder: (context, _) {
            final provider = widget.provider;
            if (!provider.isConnected) {
              return _HWNotConnectedView(
                onGoBack: () => Navigator.pop(context),
              );
            }

            return Column(
              children: [
                // 设备信息
                if (provider.currentDevice != null)
                  _HWDeviceInfoCard(device: provider.currentDevice!),

                // 币种选择
                _HWCoinSelector(
                  coins: _supportedCoins,
                  selectedCoinType: _selectedCoinType,
                  onCoinSelected: (symbol) {
                    setState(() => _selectedCoinType = symbol);
                    _loadAccounts();
                  },
                ),

                // 账户列表
                Expanded(
                  child: _isLoading
                      ? const _HWLoadingView()
                      : _buildAccountsList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    HardwareWalletProvider provider,
  ) {
    final accounts = provider.accounts;

    if (accounts.isEmpty) {
      final appName =
          LedgerApps.getAppName(_selectedCoinType) ?? _selectedCoinType;
      return _HWEmptyAccountsView(appName: appName, onRetry: _loadAccounts);
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space8),
      // +1 for the "Load More" button at the end
      itemCount: accounts.length + 1,
      itemBuilder: (context, index) {
        if (index == accounts.length) {
          return _HWLoadMoreButton(
            isLoading: _isLoadingMore,
            onLoadMore: _loadMoreAccounts,
          );
        }
        return _HWAccountItem(
          account: accounts[index],
          onCopy: (address) => _copyAddress(context, address),
          onUse: (account) => _useAccount(context, account),
        );
      },
    );
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_hw_address_copied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _useAccount(BuildContext context, HardwareWalletAccount account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).g_key_hw_add_account),
        content: SingleChildScrollView(
          child: Text(
            S
                .of(context)
                .g_key_hw_add_account_content(
                  account.shortAddress,
                  account.coinType,
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).g_key_79),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _importAccount(context, account);
            },
            child: Text(S.of(context).g_key_hw_add),
          ),
        ],
      ),
    );
  }

  Future<void> _importAccount(
    BuildContext context,
    HardwareWalletAccount account,
  ) async {
    try {
      final success = await widget.provider.importAccount(account);
      if (!context.mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).g_key_hw_account_added(account.shortAddress),
            ),
            backgroundColor: AppColorTokens.of(context).success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_hw_account_already_imported),
            backgroundColor: AppColorTokens.of(context).warning,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_hw_import_failed(e.toString())),
          backgroundColor: AppColorTokens.of(context).danger,
        ),
      );
    }
  }
}
