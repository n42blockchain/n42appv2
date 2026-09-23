// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/home/setting/change_email_api.dart';
import 'package:n42_wallet/features/home/setting/change_email_ui_helpers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

enum _ChangeEmailStep { email, code, update }

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key, this.api});

  @visibleForTesting
  final ChangeEmailApi? api;

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  late final _api = widget.api ?? ChangeEmailApi();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  _ChangeEmailStep _step = _ChangeEmailStep.email;
  Timer? _timer;
  int _countdown = 0;
  bool _loading = false;
  String? _emailError;
  String? _codeError;
  String? _statusText;
  bool _statusIsError = false;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_validateEmail(email)) return;
    await _runRequest(
      successMessage: S.of(context).g_ui_email_code_sent,
      request: () => _api.sendUpdateEmailCode(email),
      onSuccess: () {
        _step = _ChangeEmailStep.code;
        _startCountdown();
        _codeFocus.requestFocus();
      },
    );
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    if (!_validateEmail(email)) return;
    await _runRequest(
      successMessage: S.of(context).g_ui_email_code_sent,
      request: () => _api.sendUpdateEmailCode(email),
      onSuccess: _startCountdown,
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (!_validateCode(code)) return;
    await _runRequest(
      successMessage: S.of(context).g_ui_email_code_accepted,
      request: () => _api.verifyUpdateEmailCode(code),
      onSuccess: () => _step = _ChangeEmailStep.update,
    );
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (!_validateEmail(email) || !_validateCode(code)) return;
    await _runRequest(
      successMessage: S.of(context).g_key_185,
      request: () => _api.updateEmail(newEmail: email, code: code),
      onSuccess: () async {
        await _syncLocalEmail(email);
      },
    );
  }

  Future<void> _runRequest({
    required String successMessage,
    required Future<dynamic> Function() request,
    required FutureOr<void> Function() onSuccess,
  }) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _statusText = S.of(context).g_ui_sending_request;
      _statusIsError = false;
    });
    try {
      await request();
      await onSuccess();
      if (!mounted) return;
      setState(() {
        _statusText = successMessage;
        _statusIsError = false;
      });
      ToastUtils.showSuccess(successMessage);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString();
      setState(() {
        _statusText = message;
        _statusIsError = true;
      });
      ToastUtils.showError(message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _validateEmail(String email) {
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    setState(() {
      _emailError = ok ? null : S.of(context).g_ui_invalid_email;
    });
    return ok;
  }

  bool _validateCode(String code) {
    final ok = RegExp(r'^\d{6}$').hasMatch(code);
    setState(() {
      _codeError = ok ? null : S.of(context).g_google_auth_key4;
    });
    return ok;
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown -= 1;
        if (_countdown <= 0) {
          _countdown = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _syncLocalEmail(String email) async {
    final current = AppGlobals.userInfo;
    if (current == null) return;
    final updated = current.copyWith(email: email);
    AppGlobals.userInfo = updated;
    ref
        .read(currentUserProvider.notifier)
        .setUser(SharedUserInfo.fromLegacyUserInfo(updated));
    await Future.wait([
      SPUtil().saveUserInfo(updated),
      SecureStorage().saveEmail(email),
      SecureStorage().saveUserInfo(updated.toJson()),
    ]);
  }

  void _resetToEmailStep() {
    setState(() {
      _step = _ChangeEmailStep.email;
      _codeController.clear();
      _codeError = null;
      _statusText = null;
      _statusIsError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_ui_change_email),
      backgroundColor: colors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pageHorizontal.add(
            EdgeInsets.only(top: AppSpacing.space8, bottom: AppSpacing.space16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors),
              SizedBox(height: AppSpacing.space8),
              _buildStepIndicator(colors),
              SizedBox(height: AppSpacing.space8),
              _buildCurrentStep(colors),
              if (_statusText != null) ...[
                SizedBox(height: AppSpacing.space6),
                _buildStatus(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorTokens colors) {
    final currentEmail = AppGlobals.currentUserEmail;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInset,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_ui_account_email,
            style: AppTypography.headline.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            currentEmail == null || currentEmail.isEmpty
                ? S.of(context).g_ui_no_cached_email
                : currentEmail,
            style: AppTypography.bodySm.copyWith(color: colors.textSubtitle),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AppColorTokens colors) {
    return Row(
      children: [
        _StepPill(
          label: S.of(context).g_ui_new_email,
          active: _step.index >= _ChangeEmailStep.email.index,
          colors: colors,
        ),
        SizedBox(width: AppSpacing.space2),
        _StepPill(
          label: S.of(context).g_ui_verify_code,
          active: _step.index >= _ChangeEmailStep.code.index,
          colors: colors,
        ),
        SizedBox(width: AppSpacing.space2),
        _StepPill(
          label: S.of(context).g_ui_update,
          active: _step.index >= _ChangeEmailStep.update.index,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildCurrentStep(AppColorTokens colors) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInset,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: switch (_step) {
        _ChangeEmailStep.email => _buildEmailStep(colors),
        _ChangeEmailStep.code => _buildCodeStep(colors),
        _ChangeEmailStep.update => _buildUpdateStep(colors),
      },
    );
  }

  Widget _buildEmailStep(AppColorTokens colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_ui_new_email,
          style: AppTypography.bodyStrong.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: AppSpacing.space4),
        TextField(
          key: const Key('change_email_email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          decoration: changeEmailInputDeco(
            hint: S.of(context).login_email,
            fillColor: colors.bgElevated,
            accentColor: colors.brand,
            subColor: colors.textSubtitle,
            errorText: _emailError,
            suffixIcon: Icon(Icons.mail_outline, color: colors.textSubtitle),
          ),
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          onSubmitted: (_) => _sendCode(),
        ),
        SizedBox(height: AppSpacing.space8),
        changeEmailPrimaryButton(
          label: S.of(context).g_ui_send_code,
          onPressed: _sendCode,
          loading: _loading,
          accentColor: colors.brand,
        ),
      ],
    );
  }

  Widget _buildCodeStep(AppColorTokens colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_ui_verification_code,
          style: AppTypography.bodyStrong.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: AppSpacing.space4),
        changeEmailCodeField(
          ctrl: _codeController,
          focus: _codeFocus,
          textColor: colors.textPrimary,
          fillColor: colors.bgElevated,
          accentColor: colors.brand,
          subColor: colors.textSubtitle,
          errorText: _codeError,
          onChanged: (_) {
            if (_codeError != null) {
              setState(() => _codeError = null);
            }
          },
          onSubmitted: (_) => _verifyCode(),
        ),
        changeEmailResendRow(
          context: context,
          countdown: _countdown,
          loading: _loading,
          onTap: _resendCode,
          accentColor: colors.brand,
          subColor: colors.textSubtitle,
        ),
        SizedBox(height: AppSpacing.space4),
        changeEmailPrimaryButton(
          label: S.of(context).g_ui_verify_code,
          onPressed: _verifyCode,
          loading: _loading,
          accentColor: colors.brand,
        ),
        changeEmailBackButton(
          label: S.of(context).g_ui_back_email,
          onPressed: _loading ? () {} : _resetToEmailStep,
          subColor: colors.textSubtitle,
        ),
      ],
    );
  }

  Widget _buildUpdateStep(AppColorTokens colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_ui_confirm_update,
          style: AppTypography.bodyStrong.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: AppSpacing.space2),
        Text(
          _emailController.text.trim(),
          style: AppTypography.bodySm.copyWith(color: colors.textSubtitle),
        ),
        SizedBox(height: AppSpacing.space8),
        changeEmailPrimaryButton(
          label: S.of(context).g_ui_update_email,
          onPressed: _updateEmail,
          loading: _loading,
          accentColor: colors.brand,
        ),
        changeEmailBackButton(
          label: S.of(context).g_ui_back_code,
          onPressed: _loading
              ? () {}
              : () => setState(() => _step = _ChangeEmailStep.code),
          subColor: colors.textSubtitle,
        ),
      ],
    );
  }

  Widget _buildStatus(AppColorTokens colors) {
    final color = _statusIsError ? colors.danger : colors.success;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInset,
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        _statusText!,
        style: AppTypography.bodySm.copyWith(color: color),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.label,
    required this.active,
    required this.colors,
  });

  final String label;
  final bool active;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final fg = active ? colors.brand : colors.textSubtitle;
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: active ? colors.brandSubtle : colors.bgSurface,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: active ? colors.brand : colors.border),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppTypography.captionSm.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}
