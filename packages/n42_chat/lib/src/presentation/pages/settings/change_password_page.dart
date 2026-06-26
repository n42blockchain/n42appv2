import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 修改密码页面
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      context.read<AuthBloc>().add(
        AuthChangePasswordRequested(
          oldPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.settingsChangePassword ?? 'Change Password',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            _isSubmitting &&
            (previous.changePasswordStatus != current.changePasswordStatus ||
                previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          if (state.changePasswordStatus == ChangePasswordStatus.success) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.settingsPasswordChanged ??
                      'Password changed successfully. Please login with your new password.',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // 修改成功后会自动登出，返回登录页
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state.changePasswordStatus ==
              ChangePasswordStatus.failed) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      (S.of(context)?.settingsChangePasswordFailed ??
                          'Change password failed'),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = _isSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // 说明文字
                  _buildInfoCard(),

                  const SizedBox(height: 24),

                  // 当前密码
                  _buildCurrentPasswordField(),

                  const SizedBox(height: 16),

                  // 新密码
                  _buildNewPasswordField(),

                  const SizedBox(height: 16),

                  // 确认新密码
                  _buildConfirmPasswordField(),

                  const SizedBox(height: 8),

                  // 密码要求提示
                  _buildPasswordRequirements(),

                  const SizedBox(height: 32),

                  // 确认按钮
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
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
                  ),

                  const SizedBox(height: 16),

                  // 安全提示
                  _buildSecurityNote(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    final cardBgColor = context.surfaceColor;
    final textColor = context.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.of(context)?.settingsChangePasswordInfo ??
                  'After changing password, you will be logged out and need to login with the new password.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField() {
    final labelColor = context.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

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
          controller: _currentPasswordController,
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
                _obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: hintColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
          ),
          obscureText: _obscureCurrentPassword,
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

  Widget _buildNewPasswordField() {
    final labelColor = context.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.commonNewPassword ?? 'New Password',
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
          controller: _newPasswordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.settingsEnterNewPassword ?? 'Enter new password',
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
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: hintColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
          ),
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.settingsEnterNewPassword ??
                  'Please enter new password';
            }
            if (value.length < 8) {
              return S.of(context)?.commonPasswordMinLength ??
                  'Password must be at least 8 characters';
            }
            if (value == _currentPasswordController.text) {
              return S.of(context)?.settingsNewPasswordMustBeDifferent ??
                  'New password must be different from current password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    final labelColor = context.textSecondary;
    final inputBgColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.commonConfirmNewPassword ?? 'Confirm New Password',
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
          controller: _confirmPasswordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.commonReenterPassword ?? 'Re-enter password',
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
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
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
          onFieldSubmitted: (_) => _changePassword(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.commonReenterPassword ??
                  'Please re-enter password';
            }
            if (value != _newPasswordController.text) {
              return S.of(context)?.commonPasswordsDoNotMatch ??
                  'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final textColor = context.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.settingsPasswordRequirements ??
              'Password requirements:',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, height: 1.3, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          '• ${S.of(context)?.commonPasswordMinLength ?? 'At least 8 characters'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, height: 1.3, color: textColor),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    final textColor = context.textTertiary;

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
              S.of(context)?.settingsSecurityNote ??
                  'For security, you will need to re-login on all devices after changing password.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
