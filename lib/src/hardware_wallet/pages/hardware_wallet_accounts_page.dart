// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42appv2/src/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// 硬件钱包账户页面
class HardwareWalletAccountsPage extends StatefulWidget {
  final HardwareWalletProvider provider;
  const HardwareWalletAccountsPage({super.key, required this.provider});

  @override
  State<HardwareWalletAccountsPage> createState() => _HardwareWalletAccountsPageState();
}

class _HardwareWalletAccountsPageState extends State<HardwareWalletAccountsPage> {
  String _selectedCoinType = 'ETH';
  bool _isLoading = false;

  final List<Map<String, String>> _supportedCoins = [
    {'symbol': 'ETH', 'name': 'Ethereum'},
    {'symbol': 'BTC', 'name': 'Bitcoin'},
    {'symbol': 'BNB', 'name': 'BNB Smart Chain'},
    {'symbol': 'MATIC', 'name': 'Polygon'},
    {'symbol': 'ARB', 'name': 'Arbitrum'},
    {'symbol': 'OP', 'name': 'Optimism'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    final provider = widget.provider;
    await provider.loadAccounts(_selectedCoinType);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: 'Wallet Accounts',
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.provider,
          builder: (context, _) {
            final provider = widget.provider;
            if (!provider.isConnected) {
              return _buildNotConnectedState(context);
            }

            return Column(
              children: [
                // 设备信息
                _buildDeviceInfoCard(context, provider),

                // 币种选择
                _buildCoinSelector(context),

                // 账户列表
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _buildAccountsList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotConnectedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            'Device not connected',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context, HardwareWalletProvider provider) {
    final device = provider.currentDevice;
    if (device == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: ScreenUtil().setWidth(28),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinSelector(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(80),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _supportedCoins.length,
        itemBuilder: (context, index) {
          final coin = _supportedCoins[index];
          final isSelected = coin['symbol'] == _selectedCoinType;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCoinType = coin['symbol']!);
              _loadAccounts();
            },
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setWidth(12),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      )
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemBgColor.name,
                      ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              child: Row(
                children: [
                  Text(
                    coin['symbol']!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    coin['name']!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: isSelected
                          ? Colors.white70
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            'Loading accounts...\nPlease confirm on your device if prompted',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, HardwareWalletProvider provider) {
    final accounts = provider.accounts;

    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: ScreenUtil().setWidth(60),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'No accounts found',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              'Make sure the ${LedgerApps.getAppName(_selectedCoinType) ?? _selectedCoinType} app is open on your Ledger',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            ElevatedButton(
              onPressed: _loadAccounts,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildAccountItem(context, account);
      },
    );
  }

  Widget _buildAccountItem(BuildContext context, HardwareWalletAccount account) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setWidth(40),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${account.index + 1}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      account.derivationPath,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 复制按钮
              IconButton(
                onPressed: () => _copyAddress(context, account.address),
                icon: Icon(
                  Icons.copy,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                  size: ScreenUtil().setWidth(28),
                ),
              ),
              // 使用账户按钮
              IconButton(
                onPressed: () => _useAccount(context, account),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                  size: ScreenUtil().setWidth(28),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          // 地址
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ).withAlpha(10),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              account.address,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontFamily: 'monospace',
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _useAccount(BuildContext context, HardwareWalletAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Account'),
        content: Text(
          'Do you want to track this hardware wallet account?\n\n'
          'Address: ${account.shortAddress}\n'
          'Network: ${account.coinType}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _importAccount(context, account);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _importAccount(
      BuildContext context, HardwareWalletAccount account) async {
    try {
      final success = await widget.provider.importAccount(account);
      if (!context.mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Account ${account.shortAddress} added to tracking list'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account already imported'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
