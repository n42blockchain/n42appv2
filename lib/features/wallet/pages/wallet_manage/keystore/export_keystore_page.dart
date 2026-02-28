// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:async';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
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
  int _countdown = 0; // 0 = 未复制状态

  bool get _isCopied => _countdown > 0;

  // ── 生命周期 ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _stopTimer();
    // 离开页面时强制清除剪贴板，防止未手动清除而残留
    Clipboard.setData(const ClipboardData(text: ''));
    super.dispose();
  }

  // ── 剪贴板操作 ───────────────────────────────────────────────────────────

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.keystoreJson));
    if (mounted) {
      ToastUtils.show(S.of(context).g_key_ex_keystore_11); // "Copied"
    }
    _startClearCountdown();
  }

  /// 开始自动清除倒计时。
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

  /// 停止计时器（不清除剪贴板）。
  void _stopTimer() {
    _clipTimer?.cancel();
    _clipTimer = null;
  }

  /// 清除剪贴板并重置状态。
  void _clearClipboard({bool fromTimer = false}) {
    _stopTimer();
    Clipboard.setData(const ClipboardData(text: ''));
    if (!mounted) return;
    setState(() => _countdown = 0);
    if (!fromTimer) {
      // 手动清除时给用户反馈
      ToastUtils.show(S.of(context).g_key_ex_keystore_12); // "Copy cancelled"
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pad30 = ScreenUtil().setWidth(30);
    final bottomBarHeight = ScreenUtil().setWidth(148);

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
                    SizedBox(height: ScreenUtil().setWidth(40)),
                    _buildKeystoreBox(),
                    if (_isCopied) ...[
                      SizedBox(height: ScreenUtil().setWidth(8)),
                      _ClipboardCountdownHint(
                        seconds: _countdown,
                        textColor: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                      ),
                    ],
                    SizedBox(height: bottomBarHeight),
                  ],
                ),
              ),
            ),

            // ── 底部按钮 ──────────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: ScreenUtil().setWidth(1)),
                  Container(
                    height: bottomBarHeight,
                    width: double.infinity,
                    padding: EdgeInsets.all(pad30),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.backGroundColor.name),
                    child: _isCopied
                        ? buttonStyle2(
                            context,
                            _clearClipboard,
                            '${s.g_key_ex_keystore_12} (${_countdown}s)',
                          )
                        : buttonStyle2(
                            context,
                            _copyToClipboard,
                            s.g_key_119,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(24),
      ),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
      child: Text(
        widget.keystoreJson,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemTextColor.name),
          fontSize: ScreenUtil().setSp(28),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildItem(String title, String action) {
    final mainTextColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: mainTextColor,
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            action,
            style: TextStyle(
              color: mainTextColor,
              fontSize: ScreenUtil().setSp(28),
            ),
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
        SizedBox(width: ScreenUtil().setWidth(8)),
        Text(
          'Clipboard auto-clears in ${seconds}s',
          style: TextStyle(
            color: textColor,
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      ],
    );
  }
}
