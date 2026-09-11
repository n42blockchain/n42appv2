import 'package:n42_wallet/generated/l10n.dart';
// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 设备扫描页面
class DeviceScanPage extends StatefulWidget {
  final HardwareWalletProvider provider;
  const DeviceScanPage({super.key, required this.provider});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  /// 常用主题色快捷方法
  Color _blueColor(BuildContext context) => AppColorTokens.of(context).brand;

  Color _subtitleColor(BuildContext context) =>
      AppColorTokens.of(context).textSubtitle;

  Color _textColor(BuildContext context) =>
      AppColorTokens.of(context).textPrimary;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // 开始扫描
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startScan();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    final provider = widget.provider;

    // 检查蓝牙权限
    final hasPermission = await provider.requestPermissions();
    if (!hasPermission) {
      if (mounted) _showPermissionDialog();
      return;
    }

    // 检查蓝牙是否可用
    final isAvailable = await provider.checkBluetoothAvailable();
    if (!isAvailable) {
      if (mounted) _showBluetoothDisabledDialog();
      return;
    }

    _animationController.repeat();
    await provider.startScan();
  }

  void _stopScan() {
    _animationController.stop();
    widget.provider.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_hw_connect_new_device),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.provider,
          builder: (context, _) {
            final provider = widget.provider;
            return Column(
              children: [
                // 扫描动画区域
                _buildScanAnimation(context, provider),

                // 设备列表
                Expanded(child: _buildDeviceList(context, provider)),

                // 底部按钮
                _buildBottomActions(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScanAnimation(
    BuildContext context,
    HardwareWalletProvider provider,
  ) {
    final isScanning = provider.isScanning;
    final blueColor = _blueColor(context);
    final su = ScreenUtil();

    return Container(
      padding: EdgeInsets.all(su.setWidth(40)),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 扫描波纹
              if (isScanning)
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final value =
                          (_animationController.value + index * 0.33) % 1.0;
                      final size = su.setWidth(200 + value * 100);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: blueColor.withAlpha(
                              (255 * (1 - value)).toInt(),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  );
                }),

              // 中心图标
              Container(
                width: su.setWidth(120),
                height: su.setWidth(120),
                decoration: BoxDecoration(
                  color: blueColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bluetooth_searching,
                  size: su.setWidth(60),
                  color: blueColor,
                ),
              ),
            ],
          ),

          SizedBox(height: su.setWidth(24)),

          Text(
            isScanning ? 'Searching for devices...' : 'Search complete',
            style: AppTypography.headline.copyWith(color: _textColor(context)),
          ),

          SizedBox(height: su.setWidth(8)),

          Text(
            isScanning
                ? 'Make sure your Ledger is unlocked and Bluetooth is enabled'
                : '${provider.discoveredDevices.length} device(s) found',
            style: AppTypography.caption.copyWith(
              color: _subtitleColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(
    BuildContext context,
    HardwareWalletProvider provider,
  ) {
    final devices = provider.discoveredDevices;
    final su = ScreenUtil();

    if (devices.isEmpty) {
      final subtitle = _subtitleColor(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.isScanning
                  ? Icons.bluetooth_searching
                  : Icons.bluetooth_disabled,
              size: su.setWidth(60),
              color: subtitle,
            ),
            SizedBox(height: su.setWidth(16)),
            Text(
              provider.isScanning
                  ? 'Looking for devices...'
                  : 'No devices found',
              style: AppTypography.body.copyWith(color: subtitle),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      itemCount: devices.length,
      itemBuilder: (context, index) =>
          _buildDeviceItem(context, provider, devices[index]),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    HardwareWalletProvider provider,
    BluetoothDeviceInfo device,
  ) {
    final isConnecting =
        provider.connectionState == HardwareWalletConnectionState.connecting;
    final blueColor = _blueColor(context);
    final su = ScreenUtil();

    return GestureDetector(
      onTap: isConnecting
          ? null
          : () => _connectDevice(context, provider, device),
      child: Container(
        margin: EdgeInsets.only(bottom: su.setWidth(12)),
        padding: EdgeInsets.all(su.setWidth(20)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.circular(su.setWidth(12)),
        ),
        child: Row(
          children: [
            // 设备图标
            Container(
              width: su.setWidth(56),
              height: su.setWidth(56),
              decoration: BoxDecoration(
                color: blueColor.withAlpha(30),
                borderRadius: BorderRadius.circular(su.setWidth(12)),
              ),
              child: Icon(Icons.usb, color: blueColor, size: su.setWidth(32)),
            ),

            SizedBox(width: su.setWidth(16)),

            // 设备信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: AppTypography.bodyStrong.copyWith(
                      color: _textColor(context),
                    ),
                  ),
                  SizedBox(height: su.setWidth(4)),
                  Row(
                    children: [
                      // 信号强度
                      ...List.generate(4, (index) {
                        return Container(
                          width: su.setWidth(6),
                          height: su.setWidth(8 + index * 4),
                          margin: EdgeInsets.only(right: su.setWidth(2)),
                          decoration: BoxDecoration(
                            color: index < device.signalStrength
                                ? AppColorTokens.of(context).success
                                : AppColorTokens.of(
                                    context,
                                  ).textTertiary.withAlpha(50),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      SizedBox(width: su.setWidth(8)),
                      Text(
                        device.isLedger ? 'Ledger Device' : 'Unknown',
                        style: AppTypography.caption.copyWith(
                          color: _subtitleColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 连接按钮
            if (isConnecting)
              SizedBox(
                width: su.setWidth(32),
                height: su.setWidth(32),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, color: _subtitleColor(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    HardwareWalletProvider provider,
  ) {
    final su = ScreenUtil();
    return Padding(
      padding: EdgeInsets.all(su.setWidth(30)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isScanning ? _stopScan : _startScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.isScanning
                ? AppColorTokens.of(context).warning
                : _blueColor(context),
            padding: EdgeInsets.symmetric(vertical: su.setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(su.setWidth(12)),
            ),
          ),
          child: Text(
            provider.isScanning ? 'Stop Scanning' : 'Scan Again',
            style: AppTypography.headline.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _connectDevice(
    BuildContext context,
    HardwareWalletProvider provider,
    BluetoothDeviceInfo device,
  ) async {
    _stopScan();

    final success = await provider.connectDevice(device);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_ui_device_connected(device.name)),
          backgroundColor: AppColorTokens.of(context).success,
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColorTokens.of(context).danger,
        ),
      );
    }
  }

  void _showPermissionDialog() {
    _showAlertDialog(
      title: 'Bluetooth Permission Required',
      content:
          'Please grant Bluetooth permission to scan for hardware wallets.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).g_key_79),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _startScan();
          },
          child: Text(S.of(context).g_swap_key_6),
        ),
      ],
    );
  }

  void _showBluetoothDisabledDialog() {
    _showAlertDialog(
      title: 'Bluetooth Disabled',
      content:
          'Please enable Bluetooth in your device settings to connect to your hardware wallet.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).g_key_78),
        ),
      ],
    );
  }

  void _showAlertDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: actions,
      ),
    );
  }
}
