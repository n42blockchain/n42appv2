// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/utils/md5_util.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';

part 'reset_password_widgets.dart';

/// 重置密码页面（忘记密码流程）
class ResetPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const ResetPasswordPage({super.key, this.initialEmail});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static final RegExp _emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSendingCode = false;

  int _countdown = 0;
  Timer? _timer;

  // 当前步骤：0=输入邮箱, 1=输入验证码, 2=设置新密码
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_reset_password),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScreenUtil().setWidth(20)),

                // 步骤指示器
                _ResetPasswordStepIndicator(currentStep: _currentStep),

                SizedBox(height: ScreenUtil().setWidth(40)),

                // 根据步骤显示不同内容
                if (_currentStep == 0) _buildEmailStep(),
                if (_currentStep == 1) _buildCodeStep(),
                if (_currentStep == 2) _buildPasswordStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 步骤 UI ====================

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_reset_password_email_desc,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),
        _ResetPasswordInputField(
          controller: _emailController,
          label: S.of(context).g_key_email,
          hint: S.of(context).g_key_enter_email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).g_key_email_required;
            }
            if (!_emailRegExp.hasMatch(value)) {
              return S.of(context).g_key_email_invalid;
            }
            return null;
          },
        ),
        SizedBox(height: ScreenUtil().setWidth(48)),
        SizedBox(
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          child: buttonStyle6(
            context,
            _isSendingCode ? () {} : _sendVerificationCode,
            _isSendingCode
                ? '${S.of(context).g_key_106}...'
                : S.of(context).g_key_send_code,
            AppThemeUtils.getColorByKey(
              context,
              _isSendingCode
                  ? AppThemeKeys.mainButtonBgColor3.name
                  : AppThemeKeys.mainButtonBgColor.name,
            ),
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonTextColor.name,
            ),
            _isSendingCode,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_verification_code_sent(_emailController.text),
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),
        _ResetPasswordInputField(
          controller: _codeController,
          label: S.of(context).g_key_verification_code,
          hint: '000000',
          keyboardType: TextInputType.number,
          maxLength: 6,
          letterSpacing: 8,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).g_key_code_required;
            }
            if (value.length != 6) {
              return S.of(context).g_key_code_length;
            }
            return null;
          },
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _currentStep > 0
                  ? () => setState(() => _currentStep = 0)
                  : null,
              child: Text(
                S.of(context).g_key_change_email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: _countdown > 0 ? null : _resendCode,
              child: Text(
                _countdown > 0
                    ? '${S.of(context).g_key_resend_code} (${_countdown}s)'
                    : S.of(context).g_key_resend_code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: _countdown > 0
                      ? AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        )
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),
        SizedBox(
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          child: buttonStyle6(
            context,
            _verifyCode,
            S.of(context).g_key_next,
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonBgColor.name,
            ),
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonTextColor.name,
            ),
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_set_new_password_desc,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),
        _ResetPasswordField(
          controller: _passwordController,
          label: S.of(context).g_key_new_password,
          hint: S.of(context).g_key_enter_new_password,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        SizedBox(height: ScreenUtil().setWidth(24)),
        _ResetPasswordField(
          controller: _confirmPasswordController,
          label: S.of(context).g_key_confirm_new_password,
          hint: S.of(context).g_key_enter_confirm_password,
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(48)),
        SizedBox(
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          child: buttonStyle6(
            context,
            _isLoading ? () {} : _resetPassword,
            _isLoading
                ? '${S.of(context).g_key_106}...'
                : S.of(context).g_key_reset_password,
            AppThemeUtils.getColorByKey(
              context,
              _isLoading
                  ? AppThemeKeys.mainButtonBgColor3.name
                  : AppThemeKeys.mainButtonBgColor.name,
            ),
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainButtonTextColor.name,
            ),
            _isLoading,
          ),
        ),
      ],
    );
  }

  // ==================== 业务逻辑 ====================

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      ToastUtils.show(S.of(context).g_key_email_required);
      return;
    }

    if (!_emailRegExp.hasMatch(_emailController.text)) {
      ToastUtils.show(S.of(context).g_key_email_invalid);
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final result = await UserInfoApi().sendEmailCode(
        _emailController.text,
        'resetPwd',
      );

      if (!mounted) return;

      if (result['code'] == 200) {
        _startCountdown();
        setState(() => _currentStep = 1);
        ToastUtils.show(S.of(context).g_key_code_sent);
      } else {
        ToastUtils.show(result['err'] ?? 'Failed to send code');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _resendCode() async {
    await _sendVerificationCode();
  }

  void _verifyCode() {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      ToastUtils.show(S.of(context).g_key_code_length);
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty) {
      ToastUtils.show(S.of(context).g_key_password_required);
      return;
    }
    if (_passwordController.text.length < 6) {
      ToastUtils.show(S.of(context).g_key_password_min_length);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ToastUtils.show(S.of(context).g_key_passwords_not_match);
      return;
    }

    bool completedWithExit = false;
    setState(() => _isLoading = true);

    try {
      final pwdHash = Md5Util().generateMd5(_passwordController.text);

      final result = await UserInfoApi().emailResetPwd(
        _emailController.text,
        pwdHash,
        _codeController.text,
      );

      if (!mounted) return;

      if (result['code'] == 200) {
        ToastUtils.show(S.of(context).g_key_password_reset_success);
        completedWithExit = true;
        Navigator.pop(context, true);
      } else {
        ToastUtils.show(result['err'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _isLoading = false);
      }
    }
  }
}
