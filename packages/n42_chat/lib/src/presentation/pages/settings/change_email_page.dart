import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 修改邮箱页面
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscurePassword = true;
  int _currentStep = 0; // 0: 输入密码和邮箱, 1: 输入验证码
  int _countdown = 0;
  Timer? _countdownTimer;
  _ChangeEmailAction? _pendingAction;

  @override
  void initState() {
    super.initState();
    // 获取当前绑定的邮箱
    context.read<AuthBloc>().add(const AuthGetBoundEmailRequested());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (!mounted) {
      return;
    }
    setState(() {
      _countdown = 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _requestCode() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _pendingAction = _ChangeEmailAction.requestCode;
      });
      context.read<AuthBloc>().add(
        AuthRequestChangeEmailRequested(
          password: _passwordController.text,
          newEmail: _emailController.text.trim(),
        ),
      );
    }
  }

  void _confirmChange() {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.commonEnterVerificationCode ??
                'Please enter verification code',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _pendingAction = _ChangeEmailAction.confirmChange;
    });
    context.read<AuthBloc>().add(
      AuthConfirmChangeEmailRequested(
        newEmail: _emailController.text.trim(),
        code: _codeController.text.trim(),
      ),
    );
  }

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context)?.commonEnterEmailAddress ??
          'Please enter email address';
    }
    if (!_emailRegex.hasMatch(value)) {
      return S.of(context)?.commonInvalidEmailFormat ?? 'Invalid email format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.commonChangeEmail ?? 'Change Email',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            _pendingAction != null &&
            (previous.changeEmailStatus != current.changeEmailStatus ||
                previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          if (_pendingAction == _ChangeEmailAction.requestCode &&
              state.changeEmailStatus == ChangeEmailStatus.codeSent) {
            // 验证码发送成功，进入下一步
            setState(() {
              _currentStep = 1;
              _pendingAction = null;
            });
            _startCountdown();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.settingsVerificationCodeSent ??
                      'Verification code sent',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (_pendingAction == _ChangeEmailAction.confirmChange &&
              state.changeEmailStatus == ChangeEmailStatus.success) {
            setState(() {
              _pendingAction = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.settingsEmailChangedSuccess ??
                      'Email changed successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state.changeEmailStatus == ChangeEmailStatus.failed) {
            setState(() {
              _pendingAction = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      (S.of(context)?.settingsChangeEmailFailed ??
                          'Change email failed'),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = _pendingAction != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // 当前绑定邮箱
                  if (state.boundEmail != null)
                    _buildCurrentEmailCard(isDark, state.boundEmail!),

                  const SizedBox(height: 24),

                  if (_currentStep == 0) ...[
                    // 步骤 1: 输入密码和新邮箱
                    _buildPasswordField(isDark),
                    const SizedBox(height: 16),
                    _buildNewEmailField(isDark),
                    const SizedBox(height: 32),
                    _buildSendCodeButton(isDark, isLoading),
                  ] else ...[
                    // 步骤 2: 输入验证码
                    _buildCodeField(isDark),
                    const SizedBox(height: 16),
                    _buildResendButton(isDark, isLoading),
                    const SizedBox(height: 32),
                    _buildConfirmButton(isDark, isLoading),
                  ],

                  const SizedBox(height: 16),
                  _buildSecurityNote(isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentEmailCard(bool isDark, String email) {
    final cardBgColor = context.surfaceColor;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final labelColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context)?.settingsCurrentBoundEmail ??
                      'Current bound email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, height: 1.3, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.settingsCurrentPassword ?? 'Current Password',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.settingsEnterCurrentPassword ??
                'Enter current password',
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
            prefixIcon: Icon(Icons.lock_outline, color: hintColor),
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
              return S.of(context)?.settingsEnterCurrentPassword ??
                  'Please enter current password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNewEmailField(bool isDark) {
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.settingsNewEmailAddress ?? 'New Email Address',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.settingsEnterNewEmail ??
                'Enter new email address',
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
            prefixIcon: Icon(Icons.email_outlined, color: hintColor),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildCodeField(bool isDark) {
    final labelColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.settingsVerificationCode ?? 'Verification Code',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${S.of(context)?.settingsCodeSentTo ?? 'Verification code sent to'} ${_emailController.text}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, height: 1.3, color: hintColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.commonEnterVerificationCode ??
                'Enter verification code',
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
            prefixIcon: Icon(Icons.verified_outlined, color: hintColor),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _confirmChange(),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(bool isDark, bool isLoading) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _requestCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                S.of(context)?.commonSendVerificationCode ??
                    'Send Verification Code',
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
    );
  }

  Widget _buildResendButton(bool isDark, bool isLoading) {
    final canResend = _countdown == 0 && !isLoading;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            S.of(context)?.settingsDidNotReceiveCode ??
                "Didn't receive the code?",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.3, color: textColor),
          ),
        ),
        TextButton(
          onPressed: canResend ? _requestCode : null,
          child: Text(
            _countdown > 0
                ? '${S.of(context)?.settingsResend ?? 'Resend'} (${_countdown}s)'
                : S.of(context)?.settingsResend ?? 'Resend',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              color: canResend ? AppColors.primary : textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(bool isDark, bool isLoading) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _confirmChange,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  Widget _buildSecurityNote(bool isDark) {
    final textColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              S.of(context)?.settingsEmailSecurityNote ??
                  'Your email is used for password recovery. Please keep it secure.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChangeEmailAction { requestCode, confirmChange }
