// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/passkey/passkey_platform_adapter.dart';
import 'package:n42_wallet/core/passkey/passkey_service.dart';
import 'package:n42_wallet/core/di/injection.dart';
// l10n key: g_key_sign_in_with_passkey — regenerate l10n after adding ARB entries
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Passkey sign-in button displayed on the login page.
///
/// Only visible when:
/// 1. The platform supports Passkeys
/// 2. The user has at least one registered Passkey
class PasskeyLoginButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const PasskeyLoginButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  State<PasskeyLoginButton> createState() => _PasskeyLoginButtonState();
}

class _PasskeyLoginButtonState extends State<PasskeyLoginButton> {
  bool _isLoading = false;
  bool _isAvailable = false;
  late final PasskeyService _passkeyService;

  @override
  void initState() {
    super.initState();
    _passkeyService = getIt<PasskeyService>();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final supported = await PasskeyPlatformAdapter.isSupported();
    if (!supported) return;
    final enabled = await _passkeyService.isEnabled();
    if (mounted) {
      setState(() => _isAvailable = enabled);
    }
  }

  Future<void> _handlePasskeyLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _passkeyService.authenticate();
      if (!mounted) return;
      widget.onSuccess?.call();
    } on PasskeyException catch (e) {
      if (!mounted) return;
      if (!e.isCancelled) {
        widget.onError?.call(e.message);
      }
    } catch (e) {
      if (!mounted) return;
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setWidth(88),
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handlePasskeyLogin,
          icon: _isLoading
              ? SizedBox(
                  width: ScreenUtil().setWidth(36),
                  height: ScreenUtil().setWidth(36),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.fingerprint,
                  size: ScreenUtil().setWidth(40),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
          label: Text(
            'Sign in with Passkey',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
          ),
        ),
      ),
    );
  }
}
