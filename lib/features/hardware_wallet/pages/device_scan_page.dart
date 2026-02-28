// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // 开始扫描
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    // 检查蓝牙是否可用
    final isAvailable = await provider.checkBluetoothAvailable();
    if (!isAvailable) {
      if (mounted) {
        _showBluetoothDisabledDialog();
      }
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
      appBar: AppBarWidget(
        text: 'Find Device',
      ),
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
                Expanded(
                  child: _buildDeviceList(context, provider),
                ),

                // 底部按钮
                _buildBottomActions(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScanAnimation(BuildContext context, HardwareWalletProvider provider) {
    final isScanning = provider.isScanning;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
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
                      final value = (_animationController.value + index * 0.33) % 1.0;
                      return Container(
                        width: ScreenUtil().setWidth(200 + value * 100),
                        height: ScreenUtil().setWidth(200 + value * 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainBlueColor.name,
                            ).withAlpha((255 * (1 - value)).toInt()),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  );
                }),

              // 中心图标
              Container(
                width: ScreenUtil().setWidth(120),
                height: ScreenUtil().setWidth(120),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bluetooth_searching,
                  size: ScreenUtil().setWidth(60),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(24)),

          Text(
            isScanning ? 'Searching for devices...' : 'Search complete',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),

          SizedBox(height: ScreenUtil().setWidth(8)),

          Text(
            isScanning
                ? 'Make sure your Ledger is unlocked and Bluetooth is enabled'
                : '${provider.discoveredDevices.length} device(s) found',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, HardwareWalletProvider provider) {
    final devices = provider.discoveredDevices;

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
              size: ScreenUtil().setWidth(60),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              provider.isScanning ? 'Looking for devices...' : 'No devices found',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
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

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceItem(context, provider, device);
      },
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    HardwareWalletProvider provider,
    BluetoothDeviceInfo device,
  ) {
    final isConnecting =
        provider.connectionState == HardwareWalletConnectionState.connecting;

    return GestureDetector(
      onTap: isConnecting ? null : () => _connectDevice(context, provider, device),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          children: [
            // 设备图标
            Container(
              width: ScreenUtil().setWidth(56),
              height: ScreenUtil().setWidth(56),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ).withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Icon(
                Icons.usb,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ),
                size: ScreenUtil().setWidth(32),
              ),
            ),

            SizedBox(width: ScreenUtil().setWidth(16)),

            // 设备信息
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
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Row(
                    children: [
                      // 信号强度
                      ...List.generate(4, (index) {
                        return Container(
                          width: ScreenUtil().setWidth(6),
                          height: ScreenUtil().setWidth(8 + index * 4),
                          margin: EdgeInsets.only(right: ScreenUtil().setWidth(2)),
                          decoration: BoxDecoration(
                            color: index < device.signalStrength
                                ? Colors.green
                                : Colors.grey.withAlpha(50),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Text(
                        device.isLedger ? 'Ledger Device' : 'Unknown',
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
                ],
              ),
            ),

            // 连接按钮
            if (isConnecting)
              SizedBox(
                width: ScreenUtil().setWidth(32),
                height: ScreenUtil().setWidth(32),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, HardwareWalletProvider provider) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isScanning ? _stopScan : _startScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.isScanning
                ? Colors.orange
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
          child: Text(
            provider.isScanning ? 'Stop Scanning' : 'Scan Again',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
          content: Text('Connected to ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPermissionDialog() {
    _showAlertDialog(
      title: 'Bluetooth Permission Required',
      content: 'Please grant Bluetooth permission to scan for hardware wallets.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _startScan();
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  void _showBluetoothDisabledDialog() {
    _showAlertDialog(
      title: 'Bluetooth Disabled',
      content: 'Please enable Bluetooth in your device settings to connect to your hardware wallet.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
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
        content: Text(content),
        actions: actions,
      ),
    );
  }
}
