// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42appv2/src/hardware_wallet/pages/device_scan_page.dart';
import 'package:n42appv2/src/hardware_wallet/pages/hardware_wallet_accounts_page.dart';
import 'package:n42appv2/src/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';

/// 硬件钱包管理页面
class HardwareWalletPage extends StatefulWidget {
  const HardwareWalletPage({super.key});

  @override
  State<HardwareWalletPage> createState() => _HardwareWalletPageState();
}

class _HardwareWalletPageState extends State<HardwareWalletPage> {
  late HardwareWalletProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = HardwareWalletProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBarWidget(
          text: 'Hardware Wallet',
        ),
        body: SafeArea(
          child: Consumer<HardwareWalletProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 连接状态卡片
                    _buildConnectionStatusCard(context, provider),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 已保存的设备
                    if (provider.savedDevices.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Saved Devices'),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      ...provider.savedDevices.map(
                        (device) => _buildSavedDeviceCard(context, provider, device),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(24)),
                    ],

                    // 添加新设备按钮
                    _buildAddDeviceButton(context),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 支持的设备说明
                    _buildSupportedDevicesInfo(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(BuildContext context, HardwareWalletProvider provider) {
    final isConnected = provider.isConnected;
    final device = provider.currentDevice;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [Colors.green.shade600, Colors.green.shade400]
              : [
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
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
                isConnected ? Icons.check_circle : Icons.bluetooth_disabled,
                color: isConnected
                    ? Colors.white
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(40),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? Colors.white
                            : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                    if (isConnected && device != null) ...[
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        device.typeDisplayName,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isConnected)
                ElevatedButton(
                  onPressed: () => provider.disconnect(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                      vertical: ScreenUtil().setWidth(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                  ),
                  child: Text('Disconnect'),
                ),
            ],
          ),

          // 已连接设备的操作
          if (isConnected && device != null) ...[
            SizedBox(height: ScreenUtil().setWidth(20)),
            Divider(color: Colors.white24),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'View Accounts',
                    Icons.account_balance_wallet,
                    () => _navigateToAccounts(context),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Check App',
                    Icons.apps,
                    () => _checkCurrentApp(context, provider),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: ScreenUtil().setWidth(28)),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(30),
        fontWeight: FontWeight.bold,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      ),
    );
  }

  Widget _buildSavedDeviceCard(
    BuildContext context,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) {
    final isCurrentDevice = provider.currentDevice?.id == device.id;
    final isConnected = isCurrentDevice && provider.isConnected;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isConnected
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // 设备图标
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Icon(
                Icons.usb,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(32),
              ),
            ),
          ),

          SizedBox(width: ScreenUtil().setWidth(16)),

          // 设备信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
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
                    ),
                    if (isConnected)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10),
                          vertical: ScreenUtil().setWidth(4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                        ),
                        child: Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  device.typeDisplayName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                if (device.lastConnectedAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    'Last connected: ${_formatDate(device.lastConnectedAt!)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 操作按钮
          if (!isConnected) ...[
            IconButton(
              onPressed: () => _connectSavedDevice(context, provider, device),
              icon: Icon(
                Icons.bluetooth_connected,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(context, provider, device),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddDeviceButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToScan(context),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(36),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Text(
              'Connect New Device',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedDevicesInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supported Devices',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildDeviceInfoRow(context, 'Ledger Nano X', 'Bluetooth'),
          _buildDeviceInfoRow(context, 'Ledger Nano S Plus', 'Bluetooth'),
          _buildDeviceInfoRow(context, 'Ledger Stax', 'Bluetooth'),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(28),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  'Make sure your device is unlocked and Bluetooth is enabled before connecting.',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoRow(BuildContext context, String name, String connection) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: ScreenUtil().setWidth(24),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10),
              vertical: ScreenUtil().setWidth(4),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
            ),
            child: Text(
              connection,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _provider,
          child: const DeviceScanPage(),
        ),
      ),
    );
  }

  void _navigateToAccounts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _provider,
          child: const HardwareWalletAccountsPage(),
        ),
      ),
    );
  }

  Future<void> _checkCurrentApp(BuildContext context, HardwareWalletProvider provider) async {
    final app = await provider.getCurrentApp();
    if (!mounted) return;

    if (app != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current app: ${app.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No app is currently open'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _connectSavedDevice(
    BuildContext context,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) async {
    // 显示连接中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Connecting...'),
          ],
        ),
      ),
    );

    final success = await provider.reconnectDevice(device);

    if (!mounted) return;

    Navigator.pop(context); // 关闭对话框

    if (!success && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Device'),
        content: Text('Are you sure you want to remove "${device.name}" from saved devices?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeDevice(device.id);
              Navigator.pop(context);
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
