// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
        _errorMessage =
            widget.provider.errorMessage ??
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
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 设备图标区域
              Expanded(child: Center(child: _buildDeviceIcon())),

              // 步骤说明
              _buildStepsCard(context, s),
              SizedBox(height: AppSpacing.space6),

              // 状态信息
              if (_statusMessage != null) ...[
                _buildStatusRow(
                  context,
                  _statusMessage!,
                  AppColorTokens.of(context).brand,
                ),
                SizedBox(height: AppSpacing.space4),
              ],
              if (_errorMessage != null) ...[
                _buildStatusRow(
                  context,
                  _errorMessage!,
                  AppColorTokens.of(context).danger,
                  isError: true,
                ),
                SizedBox(height: AppSpacing.space4),
              ],

              // 连接按钮
              _buildConnectButton(context, s),
              SizedBox(height: AppSpacing.space6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    final blueColor = AppColorTokens.of(context).brand;
    final itemBg = AppColorTokens.of(context).bgSurface;
    final mainText = AppColorTokens.of(context).textPrimary;
    final size = ScreenUtil().setWidth(160);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: itemBg.withAlpha(_isConnecting ? 200 : 255),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(32)),
          border: Border.all(color: blueColor, width: 2),
          boxShadow: _isConnecting
              ? [
                  BoxShadow(
                    color: blueColor.withAlpha(60),
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
            SizedBox(height: AppSpacing.space4),
            Text(
              'Trezor',
              style: AppTypography.body.copyWith(
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
    final itemBg = AppColorTokens.of(context).bgSurface;
    final mainText = AppColorTokens.of(context).textPrimary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(color: itemBg, borderRadius: AppRadius.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_hw_trezor_usb_hint,
            style: AppTypography.bodySm.copyWith(color: mainText),
          ),
          SizedBox(height: AppSpacing.space4),
          ..._stepTexts.indexed.map(
            (e) => _buildStep(context, '${e.$1 + 1}', e.$2),
          ),
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
    final blueColor = AppColorTokens.of(context).brand;
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
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: blueColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
              child: Text(
                text,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String message,
    Color color, {
    bool isError = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.brSm,
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          if (_isConnecting)
            SizedBox(
              width: ScreenUtil().setWidth(20),
              height: ScreenUtil().setWidth(20),
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: color,
              size: ScreenUtil().setWidth(24),
            ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, S s) {
    final blueColor = AppColorTokens.of(context).brand;
    final spinnerSize = ScreenUtil().setWidth(24);

    return ElevatedButton(
      onPressed: _isConnecting ? null : _connectTrezor,
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: blueColor.withAlpha(100),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
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
                SizedBox(width: AppSpacing.space4),
                Text(s.g_key_hw_trezor_connecting, style: AppTypography.body),
              ],
            )
          : Text(
              s.g_key_hw_connect_new_trezor,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
    );
  }
}
