// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'hardware_wallet_page.dart';

/// 业务逻辑扩展
///
/// 包含导航、设备连接、应用检查、删除对话框等交互逻辑。
extension _HardwareWalletPageLogic on _HardwareWalletPageState {
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
                const SnackBar(
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
        content: SingleChildScrollView(
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(s.g_key_hw_connecting)),
            ],
          ),
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
        content: SingleChildScrollView(child: Text(s.g_key_hw_remove_device_confirm(device.name))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.g_key_79),
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
}
