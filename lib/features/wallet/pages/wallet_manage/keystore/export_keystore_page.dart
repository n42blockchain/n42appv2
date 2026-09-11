// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:async';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Keystore JSON 展示页。
///
/// 安全特性：
/// - 复制后自动在 [_kAutoClrSeconds] 秒内清除系统剪贴板（倒计时可见）
/// - 用户也可以手动提前清除
/// - 页面 dispose 时强制清除剪贴板（防止用户直接返回而剪贴板残留）
class ExportKeystorePage extends StatefulWidget {
  final String keystoreJson;
  const ExportKeystorePage({required this.keystoreJson, super.key});

  @override
  State<ExportKeystorePage> createState() => _ExportKeystorePageState();
}

class _ExportKeystorePageState extends State<ExportKeystorePage> {
  static const int _kAutoClrSeconds = 60;

  Timer? _clipTimer;
  int _countdown = 0;

  bool get _isCopied => _countdown > 0;

  @override
  void dispose() {
    _stopTimer();
    Clipboard.setData(const ClipboardData(text: ''));
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.keystoreJson));
    if (mounted) ToastUtils.show(S.of(context).g_key_ex_keystore_11);
    _startClearCountdown();
  }

  void _startClearCountdown() {
    _stopTimer();
    setState(() => _countdown = _kAutoClrSeconds);
    _clipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _clearClipboard(fromTimer: true);
      }
    });
  }

  void _stopTimer() {
    _clipTimer?.cancel();
    _clipTimer = null;
  }

  void _clearClipboard({bool fromTimer = false}) {
    _stopTimer();
    Clipboard.setData(const ClipboardData(text: ''));
    if (!mounted) return;
    setState(() => _countdown = 0);
    if (!fromTimer) ToastUtils.show(S.of(context).g_key_ex_keystore_12);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scr = ScreenUtil();
    final pad30 = scr.setWidth(30);
    final bottomBarHeight = scr.setWidth(148);

    return Scaffold(
      appBar: AppBarWidget(text: s.g_key_ex_keystore),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItem(s.g_key_ex_keystore_5, s.g_key_ex_keystore_6),
                    _buildItem(s.g_key_ex_keystore_7, s.g_key_ex_keystore_8),
                    _buildItem(s.g_key_ex_keystore_9, s.g_key_ex_keystore_10),
                    SizedBox(height: scr.setWidth(40)),
                    _buildKeystoreBox(),
                    if (_isCopied) ...[
                      SizedBox(height: scr.setWidth(8)),
                      _ClipboardCountdownHint(
                        seconds: _countdown,
                        textColor: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.ff888888.name,
                        ),
                      ),
                    ],
                    SizedBox(height: bottomBarHeight),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: scr.setWidth(1)),
                  Container(
                    height: bottomBarHeight,
                    width: double.infinity,
                    padding: EdgeInsets.all(pad30),
                    color: AppColorTokens.of(context).bgBase,
                    child: _isCopied
                        ? AppButton(
                            label: '${s.g_key_ex_keystore_12} (${_countdown}s)',
                            onPressed: _clearClipboard,
                          )
                        : AppButton(
                            label: s.g_key_119,
                            onPressed: _copyToClipboard,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeystoreBox() {
    final scr = ScreenUtil();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scr.setWidth(16)),
        color: AppColorTokens.of(context).bgSurface,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scr.setWidth(30),
        vertical: scr.setWidth(24),
      ),
      margin: EdgeInsets.symmetric(vertical: scr.setWidth(24)),
      child: Text(
        widget.keystoreJson,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textItem,
        ),
      ),
    );
  }

  Widget _buildItem(String title, String action) {
    final mainTextColor = AppColorTokens.of(context).textPrimary;
    final scr = ScreenUtil();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scr.setWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline.copyWith(
              color: mainTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: scr.setWidth(12)),
          Text(
            action,
            style: AppTypography.body.copyWith(color: mainTextColor),
          ),
        ],
      ),
    );
  }
}

/// 剪贴板倒计时提示文字。
class _ClipboardCountdownHint extends StatelessWidget {
  final int seconds;
  final Color textColor;

  const _ClipboardCountdownHint({
    required this.seconds,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: ScreenUtil().setWidth(32),
          color: textColor,
        ),
        SizedBox(width: AppSpacing.space2),
        Text(
          S.of(context).g_ui_clipboard_clear(seconds),
          style: AppTypography.caption.copyWith(color: textColor),
        ),
      ],
    );
  }
}
