// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// 修改邮箱页面（两步流程）
///
/// Step 0 – 输入新邮箱地址并发送验证码
/// Step 1 – 输入 6 位验证码并提交修改
///
/// 返回值 `true` 表示修改成功，调用方可刷新本地用户信息。
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  int _step = 0;

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();

  bool _sendingCode = false;
  bool _submitting = false;
  int _countdown = 0;
  Timer? _timer;

  String? _emailError;
  String? _codeError;

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(v.trim());

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter a new email address');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Invalid email address');
      return;
    }
    if (email == (AppGlobals.userInfo?.email ?? '')) {
      setState(
          () => _emailError = 'New email must differ from your current email');
      return;
    }

    setState(() {
      _emailError = null;
      _sendingCode = true;
    });

    try {
      final data = await UserInfoApi().sendEmailCode(email, 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        _startCountdown();
        setState(() => _step = 1);
        ToastUtils.show('Verification code sent');
      } else {
        ToastUtils.show(
            (data['err'] ?? data['msg'] ?? 'Failed to send code').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _resendCode() async {
    if (_countdown > 0) return;
    // Re-validate and send
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) return;

    setState(() => _sendingCode = true);
    try {
      final data = await UserInfoApi().sendEmailCode(email, 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        _startCountdown();
        ToastUtils.show('Verification code resent');
      } else {
        ToastUtils.show(
            (data['err'] ?? data['msg'] ?? 'Failed to resend').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _confirmChange() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _codeError = 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      _codeError = null;
      _submitting = true;
    });

    try {
      final result =
          await UserInfoApi().changeEmail(_emailCtrl.text.trim(), code);
      if (!mounted) return;
      if (result.error == false) {
        AppGlobals.userInfo?.email = _emailCtrl.text.trim();
        ToastUtils.showSuccess('Email updated successfully');
        // 尝试引导用户同步 Chat 账户邮箱
        await _offerChatEmailSync();
        if (mounted) Navigator.pop(context, true);
      } else {
        ToastUtils.show(result.data?.toString() ?? 'Failed to change email');
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// N42 邮箱改完后，若 Chat 已初始化且已登录，提示用户可选同步 Chat 邮箱
  Future<void> _offerChatEmailSync() async {
    if (!mounted) return;
    if (!N42Chat.isInitialized || !N42Chat.isLoggedIn) return;

    final newEmail = _emailCtrl.text.trim();
    final shouldSync = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final accentColor = AppThemeUtils.getColorByKey(
            ctx, AppThemeKeys.mainBlueColor.name);
        final textColor =
            AppThemeUtils.getColorByKey(ctx, AppThemeKeys.mainTextColor.name);
        final bgColor = AppThemeUtils.getColorByKey(
            ctx, AppThemeKeys.itemBgColor.name);
        return AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Sync Chat Account',
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          content: Text(
            'Your N42 profile email has been updated to:\n$newEmail\n\nWould you also like to update your Chat account email?',
            style: TextStyle(fontSize: 14.sp, color: textColor.withAlpha(200)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Not Now',
                  style: TextStyle(color: textColor.withAlpha(150))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sync Chat',
                  style: TextStyle(
                      color: accentColor, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (shouldSync == true && mounted) {
      await N42Chat.openChangeEmailPage(context);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final fillColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name);
    final lineColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name);

    return Scaffold(
      appBar: AppBarWidget(text: 'Change Email'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step indicator ──────────────────────────────────────────────
            _StepIndicator(
              currentStep: _step,
              accentColor: accentColor,
              lineColor: lineColor,
              textColor: textColor,
            ),
            SizedBox(height: 36.h),

            // ── Step 0: Enter new email ─────────────────────────────────────
            if (_step == 0) ...[
              Text('Current email',
                  style: TextStyle(fontSize: 13.sp, color: subColor)),
              SizedBox(height: 4.h),
              Text(
                AppGlobals.userInfo?.email ?? '',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              ),
              SizedBox(height: 28.h),
              Text('New email address',
                  style: TextStyle(fontSize: 13.sp, color: subColor)),
              SizedBox(height: 8.h),
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: TextStyle(fontSize: 15.sp, color: textColor),
                decoration: _buildInputDecoration(
                  hint: 'Enter new email address',
                  fillColor: fillColor,
                  accentColor: accentColor,
                  subColor: subColor,
                  errorText: _emailError,
                ),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                onSubmitted: (_) => _sendCode(),
              ),
              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _sendingCode ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _sendingCode
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Send Verification Code',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            // ── Step 1: Enter verification code ────────────────────────────
            if (_step == 1) ...[
              Text('Code sent to',
                  style: TextStyle(fontSize: 13.sp, color: subColor)),
              SizedBox(height: 4.h),
              Text(
                _emailCtrl.text.trim(),
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: accentColor),
              ),
              SizedBox(height: 28.h),
              Text('Enter 6-digit code',
                  style: TextStyle(fontSize: 13.sp, color: subColor)),
              SizedBox(height: 8.h),
              TextField(
                controller: _codeCtrl,
                focusNode: _codeFocus,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 8),
                decoration: _buildInputDecoration(
                  hint: '------',
                  fillColor: fillColor,
                  accentColor: accentColor,
                  subColor: subColor,
                  errorText: _codeError,
                  counterText: '',
                ),
                onChanged: (_) {
                  if (_codeError != null) setState(() => _codeError = null);
                },
                onSubmitted: (_) => _confirmChange(),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (_countdown > 0 || _sendingCode) ? null : _resendCode,
                    child: Text(
                      _countdown > 0
                          ? 'Resend in ${_countdown}s'
                          : 'Resend code',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _countdown > 0 ? subColor : accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _confirmChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Confirm Change',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _step = 0;
                    _codeCtrl.clear();
                    _codeError = null;
                  }),
                  child: Text('← Change email address',
                      style: TextStyle(color: subColor, fontSize: 13.sp)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required Color fillColor,
    required Color accentColor,
    required Color subColor,
    String? errorText,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subColor),
      errorText: errorText,
      counterText: counterText,
      filled: true,
      fillColor: fillColor,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final Color accentColor;
  final Color lineColor;
  final Color textColor;

  const _StepIndicator({
    required this.currentStep,
    required this.accentColor,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(
          label: '1',
          done: currentStep > 0,
          active: currentStep == 0,
          accentColor: accentColor,
          textColor: textColor,
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: currentStep > 0 ? accentColor : lineColor,
          ),
        ),
        _StepDot(
          label: '2',
          done: false,
          active: currentStep == 1,
          accentColor: accentColor,
          textColor: textColor,
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final Color accentColor;
  final Color textColor;

  const _StepDot({
    required this.label,
    required this.done,
    required this.active,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = done || active;
    final color = highlighted ? accentColor : textColor.withAlpha(80);
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? accentColor.withAlpha(26) : Colors.transparent,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: done
            ? Icon(Icons.check, size: 14.sp, color: accentColor)
            : Text(
                label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
      ),
    );
  }
}
