// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/src/hardware_wallet/pages/device_scan_page.dart';
import 'package:n42_wallet/src/hardware_wallet/pages/hardware_wallet_accounts_page.dart';
import 'package:n42_wallet/src/hardware_wallet/pages/keystone_sign_page.dart';
import 'package:n42_wallet/src/hardware_wallet/pages/trezor_connect_page.dart';
import 'package:n42_wallet/src/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/src/hardware_wallet/service/keystone_service.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// 硬件钱包管理页面
///
/// 支持三种设备类型：
/// - **Ledger**（蓝牙连接）: 扫描 BLE 设备
/// - **Trezor**（USB 连接）: USB-OTG / HID 平台通道
/// - **Keystone**（气隙 QR）: 扫描设备 xpub QR 完成配对，交易用 QR 签名
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
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: 'Hardware Wallet'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _provider,
          builder: (context, _) {
            final provider = _provider;
            return SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 连接状态卡片
                  _buildConnectionStatusCard(context, s, provider),

                  SizedBox(height: ScreenUtil().setWidth(24)),

                  // 已保存的设备
                  if (provider.savedDevices.isNotEmpty) ...[
                    _buildSectionTitle(context, s.g_key_hw_saved_devices),
                    SizedBox(height: ScreenUtil().setWidth(12)),
                    ...provider.savedDevices.map(
                      (device) =>
                          _buildSavedDeviceCard(context, s, provider, device),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(24)),
                  ],

                  // 添加新设备按钮
                  _buildAddDeviceSection(context, s),

                  SizedBox(height: ScreenUtil().setWidth(24)),

                  // 支持的设备说明
                  _buildSupportedDevicesInfo(context, s),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== Connection status card ====================

  Widget _buildConnectionStatusCard(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
  ) {
    final isConnected = provider.isConnected;
    final device = provider.currentDevice;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [Colors.green.shade600, Colors.green.shade400]
              : [
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
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
                isConnected
                    ? Icons.check_circle
                    : (device?.isKeystone ?? false)
                        ? Icons.qr_code
                        : Icons.bluetooth_disabled,
                color: isConnected
                    ? Colors.white
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(40),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? s.g_key_hw_connected
                          : s.g_key_hw_not_connected_label,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? Colors.white
                            : AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
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
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                  ),
                  child: Text(s.g_key_hw_disconnect),
                ),
            ],
          ),

          // 已连接设备的操作按钮
          if (isConnected && device != null) ...[
            SizedBox(height: ScreenUtil().setWidth(20)),
            const Divider(color: Colors.white24),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    s.g_key_hw_view_accounts,
                    Icons.account_balance_wallet,
                    () => _navigateToAccounts(context),
                  ),
                ),
                if (!device.isKeystone) ...[
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      s.g_key_hw_check_app,
                      Icons.apps,
                      () => _checkCurrentApp(context, provider),
                    ),
                  ),
                ],
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Section title ====================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(30),
        fontWeight: FontWeight.bold,
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      ),
    );
  }

  // ==================== Saved device card ====================

  Widget _buildSavedDeviceCard(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) {
    final isCurrentDevice = provider.currentDevice?.id == device.id;
    final isConnected = isCurrentDevice && provider.isConnected;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isConnected ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Row(
        children: [
          // 设备图标
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Icon(
                _deviceIcon(device.type),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
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
                              context, AppThemeKeys.mainTextColor.name),
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
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(6)),
                        ),
                        child: Text(
                          s.g_key_hw_connected,
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
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                if (device.lastConnectedAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    s.g_key_hw_last_connected(
                      _formatDate(context, s, device.lastConnectedAt!),
                    ),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 操作按钮（未连接时显示）
          if (!isConnected) ...[
            IconButton(
              onPressed: () =>
                  _connectSavedDevice(context, s, provider, device),
              icon: Icon(
                _connectionIcon(device.type),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            IconButton(
              onPressed: () =>
                  _showDeleteDialog(context, s, provider, device),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  IconData _deviceIcon(HardwareWalletType type) {
    switch (type) {
      case HardwareWalletType.ledgerNanoX:
      case HardwareWalletType.ledgerNanoSPlus:
      case HardwareWalletType.ledgerStax:
        return Icons.bluetooth;
      case HardwareWalletType.trezorModelT:
      case HardwareWalletType.trezorOne:
        return Icons.usb;
      case HardwareWalletType.keystoneModel:
        return Icons.qr_code;
    }
  }

  IconData _connectionIcon(HardwareWalletType type) {
    switch (type) {
      case HardwareWalletType.trezorModelT:
      case HardwareWalletType.trezorOne:
        return Icons.usb;
      case HardwareWalletType.keystoneModel:
        return Icons.qr_code_scanner;
      default:
        return Icons.bluetooth_connected;
    }
  }

  // ==================== Add device section ====================

  Widget _buildAddDeviceSection(BuildContext context, S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, s.g_key_hw_connect_new_device),
        SizedBox(height: ScreenUtil().setWidth(12)),
        _buildConnectOption(
          context,
          icon: Icons.bluetooth,
          label: s.g_key_hw_connect_new_ledger,
          onTap: () => _navigateToLedgerScan(context),
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        _buildConnectOption(
          context,
          icon: Icons.usb,
          label: s.g_key_hw_connect_new_trezor,
          onTap: () => _navigateToTrezorConnect(context),
        ),
        SizedBox(height: ScreenUtil().setWidth(10)),
        _buildConnectOption(
          context,
          icon: Icons.qr_code_scanner,
          label: s.g_key_hw_connect_new_keystone,
          onTap: () => _navigateToKeystonePair(context),
        ),
      ],
    );
  }

  Widget _buildConnectOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color:
              AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(32),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w500,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              size: ScreenUtil().setWidth(28),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Supported devices info ====================

  Widget _buildSupportedDevicesInfo(BuildContext context, S s) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_hw_supported_devices,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // Ledger 设备
          _buildDeviceInfoRow(context, 'Ledger Nano X', 'Bluetooth'),
          _buildDeviceInfoRow(context, 'Ledger Nano S Plus', 'Bluetooth'),
          _buildDeviceInfoRow(context, 'Ledger Stax', 'Bluetooth'),
          SizedBox(height: ScreenUtil().setWidth(8)),
          // Trezor 设备
          _buildDeviceInfoRow(context, 'Trezor Model T', 'USB'),
          _buildDeviceInfoRow(context, 'Trezor One', 'USB'),
          SizedBox(height: ScreenUtil().setWidth(8)),
          // Keystone 设备
          _buildDeviceInfoRow(context, 'Keystone Essential', 'QR (Air-gap)'),
          _buildDeviceInfoRow(context, 'Keystone Pro', 'QR (Air-gap)'),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(28),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  s.g_key_hw_ble_hint,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoRow(
      BuildContext context, String name, String connection) {
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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10),
              vertical: ScreenUtil().setWidth(4),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
            ),
            child: Text(
              connection,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Date formatting ====================

  String _formatDate(BuildContext context, S s, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return s.g_key_hw_today;
    if (diff.inDays == 1) return s.g_key_hw_yesterday;
    if (diff.inDays < 7) return s.g_key_hw_days_ago(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==================== Navigation ====================

  void _navigateToLedgerScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceScanPage(provider: _provider),
      ),
    );
  }

  void _navigateToTrezorConnect(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrezorConnectPage(provider: _provider),
      ),
    );
  }

  void _navigateToKeystonePair(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeystonePairPage(
          onPaired: (xpub, fingerprint) async {
            final accountInfo = KeystoneAccountInfo(
              xpub: xpub,
              masterFingerprint: fingerprint,
              deviceName: 'Keystone',
            );
            await _provider.registerKeystone(accountInfo);
            if (context.mounted) {
              Navigator.pop(context);
              // 配对成功，提示用户
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Keystone paired successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToAccounts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HardwareWalletAccountsPage(provider: _provider),
      ),
    );
  }

  // ==================== App check ====================

  Future<void> _checkCurrentApp(
    BuildContext context,
    HardwareWalletProvider provider,
  ) async {
    final s = S.of(context);
    final app = await provider.getCurrentApp();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          app != null
              ? s.g_key_hw_current_app_label(app.name)
              : s.g_key_hw_no_app_open,
        ),
        backgroundColor: app != null ? Colors.green : Colors.orange,
      ),
    );
  }

  // ==================== Connect saved device ====================

  Future<void> _connectSavedDevice(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) async {
    if (device.isKeystone) {
      // Keystone 是气隙设备，直接激活无需物理连接
      await provider.reconnectDevice(device);
      return;
    }

    if (device.isTrezor) {
      // 导航到 Trezor 连接页
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrezorConnectPage(provider: provider),
        ),
      );
      return;
    }

    // Ledger BLE 重连
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: 20),
            Text(s.g_key_hw_connecting),
          ],
        ),
      ),
    );

    final success = await provider.reconnectDevice(device);

    if (!context.mounted) return;
    Navigator.pop(context); // 关闭 loading 对话框

    if (!success && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== Delete dialog ====================

  void _showDeleteDialog(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.g_key_hw_remove_device),
        content: Text(s.g_key_hw_remove_device_confirm(device.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.g_key_hw_cancel),
          ),
          TextButton(
            onPressed: () {
              provider.removeDevice(device.id);
              Navigator.pop(ctx);
            },
            child: Text(
              s.g_key_hw_remove,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
