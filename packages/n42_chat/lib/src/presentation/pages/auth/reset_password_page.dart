import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../helpers/bloc_message_helper.dart';

/// 重置密码页面
///
/// 三步骤流程：
/// 1. 输入邮箱，发送验证码
/// 2. 输入验证码
/// 3. 设置新密码
class ResetPasswordPage extends StatefulWidget {
  final String homeserver;

  const ResetPasswordPage({
    super.key,
    required this.homeserver,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: 输入邮箱, 1: 输入验证码, 2: 设置新密码
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _sendVerificationCode() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.commonEnterEmailAddress ?? 'Please enter email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.commonInvalidEmailFormat ?? 'Please enter a valid email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthRequestPasswordResetRequested(
          homeserver: widget.homeserver,
          email: _emailController.text.trim(),
        ));
  }

  void _verifyCode() {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.commonEnterVerificationCode ?? 'Please enter verification code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthConfirmPasswordResetRequested(
            homeserver: widget.homeserver,
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
            newPassword: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor = context.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: textColor,
            size: AppDimensions.iconSizeSmall,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          S.of(context)?.authResetPassword ?? 'Reset Password',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineSmall.copyWith(color: textColor),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.passwordResetStatus == PasswordResetStatus.codeSent) {
            setState(() {
              _currentStep = 1;
            });
            _startResendCountdown();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context)?.authResetCodeSent(_emailController.text.trim()) ??
                    'Reset code sent to ${_emailController.text.trim()}'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.passwordResetStatus == PasswordResetStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context)?.authPasswordResetSuccess ??
                    'Password reset successful. Please login with your new password.'),
                backgroundColor: AppColors.success,
              ),
            );
            // 返回登录页
            Navigator.of(context).pop(true);
          } else if (state.passwordResetStatus == PasswordResetStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage != null
                    ? resolveBlocMessage(context, state.errorMessage!)
                    : (S.of(context)?.authResetPasswordFailed ?? 'Reset password failed')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.passwordResetStatus == PasswordResetStatus.sendingCode ||
              state.passwordResetStatus == PasswordResetStatus.resetting;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // 步骤指示器
                  _buildStepIndicator(isDark),

                  const SizedBox(height: 40),

                  // 根据步骤显示不同内容
                  if (_currentStep == 0) _buildEmailStep(isDark, isLoading),
                  if (_currentStep == 1) _buildCodeStep(isDark, isLoading, state),
                  if (_currentStep == 2) _buildPasswordStep(isDark, isLoading),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    const activeColor = AppColors.primary;
    final inactiveColor = context.dividerColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0, activeColor, inactiveColor),
        Container(
          width: 40,
          height: 2,
          color: _currentStep >= 1 ? activeColor : inactiveColor,
        ),
        _buildStepDot(1, activeColor, inactiveColor),
        Container(
          width: 40,
          height: 2,
          color: _currentStep >= 2 ? activeColor : inactiveColor,
        ),
        _buildStepDot(2, activeColor, inactiveColor),
      ],
    );
  }

  Widget _buildStepDot(int step, Color activeColor, Color inactiveColor) {
    final isActive = _currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(bool isDark, bool isLoading) {
    final labelColor = context.textSecondary;
    final inputBgColor = isDark ? AppColors.surfaceDark : AppColors.inputBackground;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authEnterRegisteredEmail ?? 'Enter the email address you registered with',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: textColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.authEmailAddress ?? 'Email Address',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText: S.of(context)?.commonEnterEmailAddress ?? 'Enter email address',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: hintColor,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _sendVerificationCode(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _sendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    S.of(context)?.authSendResetCode ?? 'Send Reset Code',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep(bool isDark, bool isLoading, AuthState state) {
    final labelColor = context.textSecondary;
    final inputBgColor = isDark ? AppColors.surfaceDark : AppColors.inputBackground;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authResetCodeSent(_emailController.text.trim()) ??
              'Reset code sent to ${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: textColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.authEnterResetCode ?? 'Enter reset code',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          style: TextStyle(color: textColor, fontSize: 24, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: S.of(context)?.authVerificationCodePlaceholder ?? '------',
            hintStyle: TextStyle(color: hintColor, letterSpacing: 8),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _verifyCode(),
        ),
        const SizedBox(height: 16),
        // 重新发送按钮
        Center(
          child: TextButton(
            onPressed: _resendCountdown > 0
                ? null
                : () {
                    _sendVerificationCode();
                  },
            child: Text(
              _resendCountdown > 0
                  ? S.of(context)?.authCanResendAfter(_resendCountdown) ?? 'Can resend after $_resendCountdown seconds'
                  : S.of(context)?.authResendVerificationCode ?? 'Resend verification code',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.3,
                color: _resendCountdown > 0 ? hintColor : AppColors.textLink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              S.of(context)?.commonConfirm ?? 'Confirm',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(bool isDark, bool isLoading) {
    final labelColor = context.textSecondary;
    final inputBgColor = isDark ? AppColors.surfaceDark : AppColors.inputBackground;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authSetNewPassword ?? 'Set New Password',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            color: textColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          S.of(context)?.commonNewPassword ?? 'New Password',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText: S.of(context)?.authPasswordHint ?? 'Min 8 characters',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: hintColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: hintColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.authEnterPassword ?? 'Please enter password';
            }
            if (value.length < 8) {
              return S.of(context)?.commonPasswordMinLength ?? 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context)?.commonConfirmNewPassword ?? 'Confirm New Password',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText: S.of(context)?.commonReenterPassword ?? 'Re-enter password',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: hintColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: hintColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _resetPassword(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.commonReenterPassword ?? 'Please re-enter password';
            }
            if (value != _passwordController.text) {
              return S.of(context)?.commonPasswordsDoNotMatch ?? 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    S.of(context)?.authResetPassword ?? 'Reset Password',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
