// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// Trezor USB 连接页面
///
/// 显示 USB 连接步骤指引，然后通过平台通道连接 Trezor 设备。
/// 连接成功后 pop 并将 [HardwareWalletDevice] 返回给调用方。
class TrezorConnectPage extends StatefulWidget {
  final HardwareWalletProvider provider;

  const TrezorConnectPage({super.key, required this.provider});

  @override
  State<TrezorConnectPage> createState() => _TrezorConnectPageState();
}

class _TrezorConnectPageState extends State<TrezorConnectPage>
    with SingleTickerProviderStateMixin {
  bool _isConnecting = false;
  String? _errorMessage;
  String? _statusMessage;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _connectTrezor() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _statusMessage = S.of(context).g_key_hw_trezor_connecting;
    });
    _pulseController.repeat(reverse: true);

    final device = await widget.provider.connectTrezor();

    if (!mounted) return;
    _pulseController.stop();

    if (device != null) {
      setState(() {
        _isConnecting = false;
        _statusMessage = S.of(context).g_key_hw_trezor_connected;
      });
      // Brief success feedback, then pop
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, device);
    } else {
      setState(() {
        _isConnecting = false;
        _errorMessage = widget.provider.errorMessage ??
            S.of(context).g_key_hw_trezor_connect_failed;
        _statusMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_hw_trezor_connect_title),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 设备图标区域
              Expanded(
                child: Center(
                  child: _buildDeviceIcon(),
                ),
              ),

              // 步骤说明
              _buildStepsCard(context, s),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // 状态信息
              if (_statusMessage != null) ...[
                _buildStatusRow(context, _statusMessage!, Colors.blue),
                SizedBox(height: ScreenUtil().setWidth(16)),
              ],
              if (_errorMessage != null) ...[
                _buildStatusRow(context, _errorMessage!, Colors.red),
                SizedBox(height: ScreenUtil().setWidth(16)),
              ],

              // 连接按钮
              _buildConnectButton(context, s),
              SizedBox(height: ScreenUtil().setWidth(24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);
    final size = ScreenUtil().setWidth(160);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: itemBg.withAlpha(_isConnecting ? 200 : 255),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(32)),
          border: Border.all(
            color: _isConnecting ? Colors.blue : blueColor,
            width: 2,
          ),
          boxShadow: _isConnecting
              ? [
                  BoxShadow(
                    color: Colors.blue.withAlpha(60),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.usb, size: ScreenUtil().setWidth(64), color: blueColor),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              'Trezor',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, S s) {
    final itemBg = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemBgColor.name);
    final mainText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_hw_trezor_usb_hint,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: mainText,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ..._stepTexts.indexed.map((e) =>
              _buildStep(context, '${e.$1 + 1}', e.$2)),
        ],
      ),
    );
  }

  // Step text helpers (not i18n-key'd to reduce key explosion; these are
  // supplementary guidance text that matches Trezor's own wording)
  static const _stepTexts = [
    'Connect Trezor to your phone with a USB-OTG cable',
    'Enter your PIN on the Trezor device if prompted',
    'Tap "Connect" below to establish the connection',
  ];

  Widget _buildStep(BuildContext context, String number, String text) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final circleSize = ScreenUtil().setWidth(32);

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: blueColor.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String message, Color color) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          if (_isConnecting)
            SizedBox(
              width: ScreenUtil().setWidth(20),
              height: ScreenUtil().setWidth(20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(
              color == Colors.red ? Icons.error_outline : Icons.check_circle,
              color: color,
              size: ScreenUtil().setWidth(24),
            ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, S s) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final spinnerSize = ScreenUtil().setWidth(24);

    return ElevatedButton(
      onPressed: _isConnecting ? null : _connectTrezor,
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: blueColor.withAlpha(100),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
      ),
      child: _isConnecting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: spinnerSize,
                  height: spinnerSize,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Text(
                  s.g_key_hw_trezor_connecting,
                  style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                ),
              ],
            )
          : Text(
              s.g_key_hw_connect_new_trezor,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
