// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 修改邮箱页面
///
/// 流程：
/// - 未登录 Chat（或 Chat 未初始化）：2 步
///     Step 0 – 输入新邮箱
///     Step 1 – 输入 N42 验证码 → 确认修改
///
/// - 已登录 Chat（可选同步）：3 步
///     Step 0 – 输入新邮箱 + 密码（开启同步时）
///     Step 1 – 输入 N42 验证码 → 确认 N42 修改
///     Step 2 – 自动请求 Chat 验证码 → 输入 Chat 验证码 → 确认
///              失败时：显示错误 + [重试] / [跳过]
///
/// 返回 `true` 表示 N42 邮箱已成功修改（无论 Chat 同步状态）。
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  // ── Step ────────────────────────────────────────────────────────────────────
  int _step = 0;
  bool _chatAvailable = false; // Chat 已初始化且已登录
  bool _chatSyncEnabled = true; // 用户是否开启 Chat 同步

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _n42CodeCtrl = TextEditingController();
  final _chatCodeCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _n42CodeFocus = FocusNode();
  final _chatCodeFocus = FocusNode();
  bool _obscurePassword = true;

  // ── Loading ──────────────────────────────────────────────────────────────────
  bool _sendingN42Code = false;
  bool _confirmingN42 = false;
  bool _requestingChatCode = false;
  bool _confirmingChat = false;

  // ── State flags ──────────────────────────────────────────────────────────────
  bool _chatCodeSent = false;

  // ── Errors ───────────────────────────────────────────────────────────────────
  String? _emailError;
  String? _passwordError;
  String? _n42CodeError;
  String? _chatSyncError; // Chat 同步过程中的错误（请求码 / 确认均用此字段）

  // ── Countdown ────────────────────────────────────────────────────────────────
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _chatAvailable = N42Chat.isInitialized && N42Chat.isLoggedIn;
    _chatSyncEnabled = _chatAvailable;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _n42CodeCtrl.dispose();
    _chatCodeCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _n42CodeFocus.dispose();
    _chatCodeFocus.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(v.trim());

  void _startCountdown() {
    _countdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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

  // ─── Step 0 → 1: 发送 N42 验证码 ────────────────────────────────────────────

  Future<void> _sendN42Code() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = S.of(context).g_email_error_empty);
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = S.of(context).g_email_error_invalid);
      return;
    }
    if (email == (AppGlobals.userInfo?.email ?? '')) {
      setState(() => _emailError = S.of(context).g_email_error_same);
      return;
    }
    if (_chatSyncEnabled && _chatAvailable && _passwordCtrl.text.isEmpty) {
      setState(() => _passwordError = S.of(context).g_email_pwd_required);
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
      _sendingN42Code = true;
    });

    try {
      final data =
          await UserInfoApi().sendEmailCode(email, 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        _startCountdown();
        setState(() => _step = 1);
        ToastUtils.show(S.of(context).g_email_code_sent_to(email));
      } else {
        ToastUtils.show(
            (data['err'] ?? data['msg'] ?? 'Failed to send code').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _sendingN42Code = false);
    }
  }

  Future<void> _resendN42Code() async {
    if (_countdown > 0 || _sendingN42Code) return;
    setState(() => _sendingN42Code = true);
    try {
      final data = await UserInfoApi()
          .sendEmailCode(_emailCtrl.text.trim(), 'changeEmail');
      if (!mounted) return;
      if (data['code'] == 200) {
        _startCountdown();
        ToastUtils.show(S.of(context).g_email_code_resent);
      } else {
        ToastUtils.show((data['err'] ?? 'Failed to resend').toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.show(e.toString());
    } finally {
      if (mounted) setState(() => _sendingN42Code = false);
    }
  }

  // ─── Step 1: 确认 N42 邮箱修改 ──────────────────────────────────────────────

  Future<void> _confirmN42() async {
    final code = _n42CodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _n42CodeError = S.of(context).g_email_code_invalid);
      return;
    }

    setState(() {
      _n42CodeError = null;
      _confirmingN42 = true;
    });

    try {
      final result =
          await UserInfoApi().changeEmail(_emailCtrl.text.trim(), code);
      if (!mounted) return;
      if (result.error == false) {
        AppGlobals.userInfo?.email = _emailCtrl.text.trim();
        _countdownTimer?.cancel();

        if (_chatSyncEnabled && _chatAvailable) {
          // 进入 Step 2：自动请求 Chat 验证码
          setState(() => _step = 2);
          await _requestChatCode();
        } else {
          ToastUtils.showSuccess(S.of(context).g_email_success);
          Navigator.pop(context, true);
        }
      } else {
        setState(() => _n42CodeError =
            result.data?.toString() ?? S.of(context).g_email_code_wrong);
      }
    } catch (e) {
      if (mounted) setState(() => _n42CodeError = e.toString());
    } finally {
      if (mounted) setState(() => _confirmingN42 = false);
    }
  }

  // ─── Step 2: Chat 同步 ───────────────────────────────────────────────────────

  Future<void> _requestChatCode() async {
    setState(() {
      _requestingChatCode = true;
      _chatSyncError = null;
      _chatCodeSent = false;
      _chatCodeCtrl.clear();
    });
    try {
      await N42Chat.requestChatEmailChange(
        _passwordCtrl.text,
        _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _chatCodeSent = true;
        _requestingChatCode = false;
      });
      _startCountdown();
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatSyncError = e.toString();
          _requestingChatCode = false;
        });
      }
    }
  }

  Future<void> _resendChatCode() async {
    if (_countdown > 0 || _requestingChatCode) return;
    await _requestChatCode();
  }

  Future<void> _confirmChat() async {
    final code = _chatCodeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _chatSyncError = S.of(context).g_email_code_invalid);
      return;
    }

    setState(() {
      _chatSyncError = null;
      _confirmingChat = true;
    });

    try {
      await N42Chat.confirmChatEmailChange(
        _emailCtrl.text.trim(),
        code,
      );
      if (!mounted) return;
      ToastUtils.showSuccess(S.of(context).g_email_both_success);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatSyncError = e.toString();
          _confirmingChat = false;
        });
      }
    }
  }

  /// 跳过 Chat 同步：N42 邮箱已更新，Chat 留给用户稍后手动处理
  void _skipChatSync() {
    ToastUtils.show(S.of(context).g_email_n42_only);
    Navigator.pop(context, true);
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

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

    final totalSteps = (_chatSyncEnabled && _chatAvailable) ? 3 : 2;

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_email_change_title),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(
              currentStep: _step,
              totalSteps: totalSteps,
              accentColor: accentColor,
              lineColor: lineColor,
              textColor: textColor,
            ),
            SizedBox(height: 36.h),
            if (_step == 0)
              _buildStep0(
                  textColor, subColor, accentColor, fillColor, lineColor),
            if (_step == 1)
              _buildStep1(textColor, subColor, accentColor, fillColor),
            if (_step == 2)
              _buildStep2(
                  textColor, subColor, accentColor, fillColor, lineColor),
          ],
        ),
      ),
    );
  }

  // ── Step 0 ──────────────────────────────────────────────────────────────────

  Widget _buildStep0(Color textColor, Color subColor, Color accentColor,
      Color fillColor, Color lineColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).g_email_current_label,
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

        Text(S.of(context).g_email_new_label,
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 8.h),
        TextField(
          controller: _emailCtrl,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: TextStyle(fontSize: 15.sp, color: textColor),
          decoration: _inputDeco(
            hint: S.of(context).g_email_new_hint,
            fillColor: fillColor,
            accentColor: accentColor,
            subColor: subColor,
            errorText: _emailError,
          ),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) {
            if (_chatSyncEnabled && _chatAvailable) {
              _passwordFocus.requestFocus();
            } else {
              _sendN42Code();
            }
          },
        ),

        // ── Chat sync section ──────────────────────────────────────────────
        if (_chatAvailable) ...[
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color:
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2.name),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context).g_email_also_sync,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textColor)),
                          SizedBox(height: 3.h),
                          Text('Both accounts will be updated in one flow',
                              style: TextStyle(
                                  fontSize: 12.sp, color: subColor)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _chatSyncEnabled,
                      onChanged: (v) => setState(() {
                        _chatSyncEnabled = v;
                        _passwordError = null;
                      }),
                      activeTrackColor: accentColor,
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
                if (_chatSyncEnabled) ...[
                  SizedBox(height: 12.h),
                  Divider(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.dividerColor.name),
                      height: 1),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).g_email_pwd_label,
                        style: TextStyle(fontSize: 13.sp, color: subColor)),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _passwordCtrl,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    style: TextStyle(fontSize: 15.sp, color: textColor),
                    decoration: _inputDeco(
                      hint: S.of(context).g_email_pwd_hint,
                      fillColor: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                      accentColor: accentColor,
                      subColor: subColor,
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: subColor,
                          size: 20.sp,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onSubmitted: (_) => _sendN42Code(),
                  ),
                ],
              ],
            ),
          ),
        ],

        SizedBox(height: 36.h),
        _primaryButton(
          label: S.of(context).g_email_send_code,
          onPressed: _sendN42Code,
          loading: _sendingN42Code,
          accentColor: accentColor,
        ),
      ],
    );
  }

  // ── Step 1: N42 验证码 ──────────────────────────────────────────────────────

  Widget _buildStep1(Color textColor, Color subColor, Color accentColor,
      Color fillColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).g_email_n42_updated + ' →',
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

        Text(S.of(context).g_email_enter_code,
            style: TextStyle(fontSize: 13.sp, color: subColor)),
        SizedBox(height: 8.h),
        _codeField(
          ctrl: _n42CodeCtrl,
          focus: _n42CodeFocus,
          textColor: textColor,
          fillColor: fillColor,
          accentColor: accentColor,
          subColor: subColor,
          errorText: _n42CodeError,
          onChanged: (_) {
            if (_n42CodeError != null) setState(() => _n42CodeError = null);
          },
          onSubmitted: (_) => _confirmN42(),
        ),
        SizedBox(height: 12.h),
        _resendRow(
          countdown: _countdown,
          loading: _sendingN42Code,
          onTap: _resendN42Code,
          accentColor: accentColor,
          subColor: subColor,
        ),
        SizedBox(height: 32.h),
        _primaryButton(
          label: _chatSyncEnabled && _chatAvailable
              ? S.of(context).g_email_confirm_continue
              : S.of(context).g_email_confirm_change,
          onPressed: _confirmN42,
          loading: _confirmingN42,
          accentColor: accentColor,
        ),
        SizedBox(height: 12.h),
        _backButton(
          label: S.of(context).g_email_back_to_email,
          onPressed: () => setState(() {
            _step = 0;
            _n42CodeCtrl.clear();
            _n42CodeError = null;
          }),
          subColor: subColor,
        ),
      ],
    );
  }

  // ── Step 2: Chat 同步 ───────────────────────────────────────────────────────

  Widget _buildStep2(Color textColor, Color subColor, Color accentColor,
      Color fillColor, Color lineColor) {
    const successColor = Color(0xFF22C55E);
    const errorColor = Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // N42 成功状态行
        Row(
          children: [
            Icon(Icons.check_circle, color: successColor, size: 20.sp),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).g_email_n42_updated,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                Text(_emailCtrl.text.trim(),
                    style: TextStyle(fontSize: 12.sp, color: subColor)),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Divider(color: lineColor, height: 1),
        SizedBox(height: 20.h),

        // Chat 同步标题
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: accentColor, size: 18.sp),
            SizedBox(width: 8.w),
            Text(S.of(context).g_email_chat_sync_title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
        SizedBox(height: 20.h),

        // ── 状态：正在请求 Chat 验证码 ─────────────────────────────────────
        if (_requestingChatCode)
          Center(
            child: Column(
              children: [
                SizedBox(height: 16.h),
                CircularProgressIndicator(color: accentColor, strokeWidth: 2),
                SizedBox(height: 12.h),
                Text(S.of(context).g_email_chat_sending,
                    style: TextStyle(fontSize: 13.sp, color: subColor)),
                SizedBox(height: 8.h),
                Text('Code will be sent to ${_emailCtrl.text.trim()}',
                    style: TextStyle(fontSize: 12.sp, color: subColor)),
              ],
            ),
          ),

        // ── 状态：请求 Chat 验证码失败（连密码都没过） ─────────────────────
        if (!_requestingChatCode && _chatSyncError != null && !_chatCodeSent)
          ..._buildChatRequestError(
              errorColor, subColor, accentColor, textColor, lineColor),

        // ── 状态：Chat 验证码已发送，等待用户输入 ──────────────────────────
        if (_chatCodeSent && !_requestingChatCode)
          ..._buildChatCodeInput(
              textColor, subColor, accentColor, fillColor, errorColor),
      ],
    );
  }

  List<Widget> _buildChatRequestError(Color errorColor, Color subColor,
      Color accentColor, Color textColor, Color lineColor) {
    return [
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: errorColor.withAlpha(20),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: errorColor.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: errorColor, size: 16.sp),
                SizedBox(width: 6.w),
                Text(S.of(context).g_email_chat_send_fail,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: errorColor)),
              ],
            ),
            SizedBox(height: 4.h),
            Text(_chatSyncError!,
                style: TextStyle(fontSize: 12.sp, color: subColor)),
          ],
        ),
      ),
      SizedBox(height: 16.h),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _skipChatSync,
              style: OutlinedButton.styleFrom(
                foregroundColor: subColor,
                side: BorderSide(color: lineColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(S.of(context).g_email_skip,
                  style: TextStyle(fontSize: 15.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _requestChatCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text('Retry',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildChatCodeInput(Color textColor, Color subColor,
      Color accentColor, Color fillColor, Color errorColor) {
    return [
      Text(S.of(context).g_email_chat_code_sent_to,
          style: TextStyle(fontSize: 13.sp, color: subColor)),
      SizedBox(height: 4.h),
      Text(
        _emailCtrl.text.trim(),
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: accentColor),
      ),
      SizedBox(height: 20.h),

      Text(S.of(context).g_email_chat_code_hint,
          style: TextStyle(fontSize: 13.sp, color: subColor)),
      SizedBox(height: 8.h),
      _codeField(
        ctrl: _chatCodeCtrl,
        focus: _chatCodeFocus,
        textColor: textColor,
        fillColor: fillColor,
        accentColor: accentColor,
        subColor: subColor,
        errorText: null,
        onChanged: (_) {
          if (_chatSyncError != null) setState(() => _chatSyncError = null);
        },
        onSubmitted: (_) => _confirmChat(),
      ),

      // Chat 错误（验证码错误等）
      if (_chatSyncError != null) ...[
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: errorColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: errorColor.withAlpha(80)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: errorColor, size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                  child: Text(_chatSyncError!,
                      style:
                          TextStyle(fontSize: 12.sp, color: errorColor))),
            ],
          ),
        ),
      ],

      SizedBox(height: 12.h),
      _resendRow(
        countdown: _countdown,
        loading: _requestingChatCode,
        onTap: _resendChatCode,
        accentColor: accentColor,
        subColor: subColor,
      ),
      SizedBox(height: 28.h),
      _primaryButton(
        label: S.of(context).g_email_chat_confirm,
        onPressed: _confirmChat,
        loading: _confirmingChat,
        accentColor: accentColor,
      ),
      SizedBox(height: 12.h),
      Center(
        child: TextButton(
          onPressed: _skipChatSync,
          child: Text(
            S.of(context).g_email_skip_full,
            style: TextStyle(color: subColor, fontSize: 13.sp),
          ),
        ),
      ),
    ];
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────────

  Widget _codeField({
    required TextEditingController ctrl,
    required FocusNode focus,
    required Color textColor,
    required Color fillColor,
    required Color accentColor,
    required Color subColor,
    String? errorText,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return TextField(
      controller: ctrl,
      focusNode: focus,
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
      decoration: _inputDeco(
        hint: '------',
        fillColor: fillColor,
        accentColor: accentColor,
        subColor: subColor,
        errorText: errorText,
        counterText: '',
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  Widget _resendRow({
    required int countdown,
    required bool loading,
    required VoidCallback onTap,
    required Color accentColor,
    required Color subColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: (countdown > 0 || loading) ? null : onTap,
          child: Text(
            countdown > 0 ? S.of(context).g_email_resend_countdown(countdown) : S.of(context).g_email_resend,
            style: TextStyle(
              fontSize: 13.sp,
              color: countdown > 0 ? subColor : accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required Future<void> Function() onPressed,
    required bool loading,
    required Color accentColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ),
        child: loading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(label,
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _backButton({
    required String label,
    required VoidCallback onPressed,
    required Color subColor,
  }) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(label,
            style: TextStyle(color: subColor, fontSize: 13.sp)),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required Color fillColor,
    required Color accentColor,
    required Color subColor,
    String? errorText,
    String? counterText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subColor),
      errorText: errorText,
      counterText: counterText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: accentColor, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
    );
  }
}

// ─── Step Indicator (supports 2 or 3 steps) ──────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final Color lineColor;
  final Color textColor;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          _StepDot(
            label: '${i + 1}',
            done: currentStep > i,
            active: currentStep == i,
            accentColor: accentColor,
            textColor: textColor,
          ),
          if (i < totalSteps - 1)
            Expanded(
              child: Container(
                  height: 1.5,
                  color: currentStep > i ? accentColor : lineColor),
            ),
        ],
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
            : Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
      ),
    );
  }
}
