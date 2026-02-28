// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/login/services/social_auth_service.dart';
import 'package:n42_wallet/features/utils/device_info_util.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Social login buttons widget
/// Displays Google and Apple sign-in buttons
class SocialLoginButtons extends ConsumerStatefulWidget {
  final bool isSelectedUserProtocol;
  final VoidCallback? onLoginSuccess;
  final Function(String)? onError;

  const SocialLoginButtons({
    super.key,
    required this.isSelectedUserProtocol,
    this.onLoginSuccess,
    this.onError,
  });

  @override
  ConsumerState<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  final SocialAuthService _authService = SocialAuthService();
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isAppleAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAppleAvailability();
  }

  Future<void> _checkAppleAvailability() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final available = await _authService.isAppleSignInAvailable();
      if (mounted) {
        setState(() => _isAppleAvailable = available);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "or" text
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                child: Text(
                  S.of(context).g_key_or,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign-In
            _buildSocialButton(
              onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
              icon: 'assets/login/icon_google.png',
              isLoading: _isGoogleLoading,
              tooltip: 'Google',
            ),

            SizedBox(width: ScreenUtil().setWidth(40)),

            // Apple Sign-In (only on iOS/macOS)
            if (_isAppleAvailable)
              _buildSocialButton(
                onTap: _isAppleLoading ? null : _handleAppleSignIn,
                icon: 'assets/login/icon_apple.png',
                isLoading: _isAppleLoading,
                tooltip: 'Apple',
                isApple: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required String icon,
    required bool isLoading,
    required String tooltip,
    bool isApple = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        child: Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setWidth(100),
          decoration: BoxDecoration(
            color: isApple && isDark
                ? Colors.white
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemBgColor.name,
                  ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            border: Border.all(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ).withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setWidth(40),
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
                : Image.asset(
                    icon,
                    width: ScreenUtil().setWidth(48),
                    height: ScreenUtil().setWidth(48),
                    color: isApple && isDark ? Colors.black : null,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon if image not found
                      return Icon(
                        isApple ? Icons.apple : Icons.g_mobiledata,
                        size: ScreenUtil().setWidth(48),
                        color: isApple
                            ? (isDark ? Colors.black : Colors.black87)
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() => _handleSocialSignIn(
    provider: 'google',
    signIn: _authService.signInWithGoogle,
    setLoading: (v) => setState(() => _isGoogleLoading = v),
  );

  Future<void> _handleAppleSignIn() => _handleSocialSignIn(
    provider: 'apple',
    signIn: _authService.signInWithApple,
    setLoading: (v) => setState(() => _isAppleLoading = v),
  );

  Future<void> _handleSocialSignIn({
    required String provider,
    required Future<SocialAuthResult> Function() signIn,
    required void Function(bool) setLoading,
  }) async {
    if (!widget.isSelectedUserProtocol) {
      ToastUtils.show(S.of(context).selected_user_protocol);
      return;
    }

    setLoading(true);

    try {
      final result = await signIn();

      if (!mounted) return;

      if (result.cancelled) return; // user dismissed — no toast
      if (!result.success) {
        final errorMsg = result.error ?? '$provider sign-in failed';
        widget.onError?.call(errorMsg);
        ToastUtils.show(errorMsg);
        return;
      }

      await _loginWithSocialToken(
        provider: provider,
        idToken: result.idToken!,
        accessToken: result.accessToken,
        rawNonce: result.rawNonce,
      );
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
        ToastUtils.show(e.toString());
      }
    } finally {
      if (mounted) setLoading(false);
    }
  }

  Future<void> _loginWithSocialToken({
    required String provider,
    required String idToken,
    String? accessToken,
    String? rawNonce,
  }) async {
    try {
      final api = UserInfoApi();
      final deviceInfo = await DeviceInfoUtil().getFullDeviceInfo();
      dynamic data;

      if (provider == 'google') {
        data = await api.loginWithGoogle(idToken, accessToken: accessToken, deviceInfo: deviceInfo);
      } else if (provider == 'apple') {
        data = await api.loginWithApple(
          idToken,
          accessToken ?? '',
          rawNonce: rawNonce,
          deviceInfo: deviceInfo,
        );
      } else {
        throw Exception('Unsupported provider: $provider');
      }

      if (!mounted) return;

      if (data != null && data['code'] == 200) {
        UserInfo userInfo = UserInfo.fromJson(data['data']);
        await SPUtil().saveUserInfo(userInfo);

        if (!mounted) return;

        // Update Riverpod state
        ref.read(currentUserProvider.notifier).setUser(
          SharedUserInfo.fromLegacyUserInfo(userInfo),
        );

        await AppGlobals.login(userInfo);

        if (!mounted) return;

        ToastUtils.show(S.of(context).g_key_login_success);
        widget.onLoginSuccess?.call();
      } else {
        final errorMsg = data?['err'] ?? 'Login failed';
        widget.onError?.call(errorMsg);
        ToastUtils.show(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
        ToastUtils.show(e.toString());
      }
    }
  }
}
