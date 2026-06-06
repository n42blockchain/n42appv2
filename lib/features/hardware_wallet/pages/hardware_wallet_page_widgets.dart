// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'hardware_wallet_page.dart';

/// Widget 构建方法扩展
///
/// 包含连接状态卡片、已保存设备卡片、添加设备区域、支持设备信息等 UI 组件。
extension _HardwareWalletPageWidgets on _HardwareWalletPageState {
  // ==================== Connection status card ====================

  Widget _buildConnectionStatusCard(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
  ) {
    final isConnected = provider.isConnected;
    final device = provider.currentDevice;
    final itemBgColor = _themeColor(context, AppThemeKeys.itemBgColor);
    final subtitleColor = _themeColor(
      context,
      AppThemeKeys.itemSubtitleTextColor,
    );
    final mainTextColor = _themeColor(context, AppThemeKeys.mainTextColor);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [Colors.green.shade600, Colors.green.shade400]
              : [itemBgColor, itemBgColor],
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
                _statusIcon(isConnected, device),
                color: isConnected ? Colors.white : subtitleColor,
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
                        color: isConnected ? Colors.white : mainTextColor,
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
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(8),
                      ),
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

  IconData _statusIcon(bool isConnected, HardwareWalletDevice? device) {
    if (isConnected) return Icons.check_circle;
    if (device?.isKeystone ?? false) return Icons.qr_code;
    return Icons.bluetooth_disabled;
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

  // ==================== Saved device card ====================

  Widget _buildSavedDeviceCard(
    BuildContext context,
    S s,
    HardwareWalletProvider provider,
    HardwareWalletDevice device,
  ) {
    final isCurrentDevice = provider.currentDevice?.id == device.id;
    final isConnected = isCurrentDevice && provider.isConnected;
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor);
    final mainTextColor = _themeColor(context, AppThemeKeys.mainTextColor);
    final subtitleColor = _themeColor(
      context,
      AppThemeKeys.itemSubtitleTextColor,
    );

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor),
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
              color: blueColor.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Icon(
                _deviceIcon(device.type),
                color: blueColor,
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
                          color: mainTextColor,
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
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setWidth(6),
                          ),
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
                    color: subtitleColor,
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
                      color: subtitleColor,
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
              icon: Icon(_connectionIcon(device.type), color: blueColor),
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(context, s, provider, device),
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
      case HardwareWalletType.ledgerNanoX:
      case HardwareWalletType.ledgerNanoSPlus:
      case HardwareWalletType.ledgerStax:
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
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: _themeColor(context, AppThemeKeys.itemBgColor),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(color: blueColor.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(icon, color: blueColor, size: ScreenUtil().setWidth(32)),
            SizedBox(width: ScreenUtil().setWidth(16)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w500,
                  color: _themeColor(context, AppThemeKeys.mainTextColor),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
              size: ScreenUtil().setWidth(28),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Theme helper ====================

  Color _themeColor(BuildContext context, AppThemeKeys key) {
    return AppThemeUtils.getColorByKey(context, key.name);
  }
}
