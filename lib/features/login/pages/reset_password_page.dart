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

/// 重置密码页面（忘记密码流程）
class ResetPasswordPage extends StatefulWidget {
  final String? initialEmail;

  const ResetPasswordPage({super.key, this.initialEmail});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
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
      appBar: AppBarWidget(
        text: S.of(context).g_key_reset_password,
      ),
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
                _buildStepIndicator(),

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

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, S.of(context).g_key_step_email),
        _buildStepLine(0),
        _buildStepDot(1, S.of(context).g_key_step_verify),
        _buildStepLine(1),
        _buildStepDot(2, S.of(context).g_key_step_password),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: ScreenUtil().setWidth(40),
          height: ScreenUtil().setWidth(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: isCurrent
                ? Border.all(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? Icon(Icons.check, color: Colors.white, size: ScreenUtil().setWidth(24))
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: isActive
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name)
                : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(32)),
        color: isActive
            ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_reset_password_email_desc,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),

        // 邮箱输入
        Text(
          S.of(context).g_key_email,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
          decoration: InputDecoration(
            hintText: S.of(context).g_key_enter_email,
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).g_key_email_required;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return S.of(context).g_key_email_invalid;
            }
            return null;
          },
        ),

        SizedBox(height: ScreenUtil().setWidth(48)),

        // 发送验证码按钮
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
              _isSendingCode ? AppThemeKeys.mainButtonBgColor3.name : AppThemeKeys.mainButtonBgColor.name,
            ),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
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
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),

        // 验证码输入
        Text(
          S.of(context).g_key_verification_code,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              letterSpacing: 8,
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            counterText: '',
          ),
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

        // 重新发送
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _currentStep > 0 ? () => setState(() => _currentStep = 0) : null,
              child: Text(
                S.of(context).g_key_change_email,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
            TextButton(
              onPressed: _countdown > 0 ? null : _resendCode,
              child: Text(
                _countdown > 0
                    ? '${S.of(context).g_key_resend_code} (${_countdown}s)'
                    : S.of(context).g_key_resend_code,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: _countdown > 0
                      ? AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name)
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: ScreenUtil().setWidth(32)),

        // 下一步按钮
        SizedBox(
          width: double.infinity,
          height: ScreenUtil().setWidth(88),
          child: buttonStyle6(
            context,
            _verifyCode,
            S.of(context).g_key_next,
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
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
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(32)),

        // 新密码
        _buildPasswordField(
          controller: _passwordController,
          label: S.of(context).g_key_new_password,
          hint: S.of(context).g_key_enter_new_password,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),

        SizedBox(height: ScreenUtil().setWidth(24)),

        // 确认密码
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: S.of(context).g_key_confirm_new_password,
          hint: S.of(context).g_key_enter_confirm_password,
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),

        SizedBox(height: ScreenUtil().setWidth(48)),

        // 重置密码按钮
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
              _isLoading ? AppThemeKeys.mainButtonBgColor3.name : AppThemeKeys.mainButtonBgColor.name,
            ),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
            _isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            filled: true,
            fillColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).g_key_password_required;
            }
            if (value.length < 6) {
              return S.of(context).g_key_password_min_length;
            }
            return null;
          },
        ),
      ],
    );
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ToastUtils.show(S.of(context).g_key_email_invalid);
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final result = await UserInfoApi().sendEmailCode(_emailController.text, 'resetPwd');

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
        Navigator.pop(context, true);
      } else {
        ToastUtils.show(result['err'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
