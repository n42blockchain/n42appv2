import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../n42_chat.dart' show N42Chat;
import '../../../services/auth/auth_methods_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../core/utils/debug_log.dart';
import '../../helpers/bloc_message_helper.dart';

/// 社交登录按钮组件
///
/// 显示 Google 和 Apple 登录按钮
class SocialLoginButtons extends StatefulWidget {
  /// 是否已同意用户协议
  final bool isAgreedToTerms;

  /// 服务器地址获取器
  final String Function() homeserverBuilder;

  /// 协议未同意时的回调
  final VoidCallback? onTermsNotAgreed;

  /// 登录成功回调
  final VoidCallback? onLoginSuccess;

  /// 错误回调
  final void Function(String)? onError;

  const SocialLoginButtons({
    super.key,
    required this.isAgreedToTerms,
    required this.homeserverBuilder,
    this.onTermsNotAgreed,
    this.onLoginSuccess,
    this.onError,
  });

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  final AuthMethodsService _authService = AuthMethodsService();
  bool _isGoogleAvailable = false;
  bool _isFacebookAvailable = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isSsoLoading = false;
  bool _isFacebookLoading = false;
  bool _isTwitterLoading = false;
  bool _isWeChatLoading = false;
  bool _isAppleAvailable = false;
  bool _isWeChatAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    if (mounted) {
      setState(() {
        _isGoogleAvailable = _authService.isGoogleSignInAvailable();
        _isFacebookAvailable = _authService.isFacebookSignInAvailable();
      });
    }

    // 检查 Apple 登录可用性
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final available = await _authService.isAppleSignInAvailable();
        if (mounted) {
          setState(() => _isAppleAvailable = available);
        }
      } catch (e) {
        // Apple Sign-In 不可用
        debugLog('Error: $e');
      }
    }

    // 检查微信登录可用性
    try {
      final available = await _authService.isWeChatSignInAvailable();
      if (mounted) {
        setState(() => _isWeChatAvailable = available);
      }
    } catch (e) {
      // WeChat 不可用
      debugLog('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final config = N42Chat.config;
    final buttons = <Widget>[
      if ((config?.enableGoogleLogin ?? true) && _isGoogleAvailable)
        _buildSocialButton(
          onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
          icon: Icons.g_mobiledata,
          isLoading: _isGoogleLoading,
          tooltip: S.of(context)?.authGoogleLabel ?? 'Google',
          backgroundColor: Colors.white,
          iconColor: Colors.red,
        ),
      if ((config?.enableAppleLogin ?? true) && _isAppleAvailable)
        _buildSocialButton(
          onTap: _isAppleLoading ? null : _handleAppleSignIn,
          icon: Icons.apple,
          isLoading: _isAppleLoading,
          tooltip: S.of(context)?.authAppleLabel ?? 'Apple',
          backgroundColor: isDark ? Colors.white : Colors.black,
          iconColor: isDark ? Colors.black : Colors.white,
        ),
      if (config?.enableSsoLogin ?? false)
        _buildSocialButton(
          onTap: _isSsoLoading ? null : _handleSsoSignIn,
          icon: Icons.login,
          isLoading: _isSsoLoading,
          tooltip: S.of(context)?.authSsoLabel ?? 'SSO',
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
        ),
      if ((config?.enableFacebookLogin ?? false) && _isFacebookAvailable)
        _buildSocialButton(
          onTap: _isFacebookLoading ? null : _handleFacebookSignIn,
          icon: Icons.facebook,
          isLoading: _isFacebookLoading,
          tooltip: 'Facebook',
          backgroundColor: const Color(0xFF1877F2),
          iconColor: Colors.white,
        ),
      if ((config?.enableTwitterLogin ?? false) &&
          _authService.isTwitterSignInAvailable())
        _buildSocialButton(
          onTap: _isTwitterLoading ? null : _handleTwitterSignIn,
          icon: Icons.alternate_email,
          isLoading: _isTwitterLoading,
          tooltip: 'Twitter',
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
      if ((config?.enableWeChatLogin ?? false) && _isWeChatAvailable)
        _buildSocialButton(
          onTap: _isWeChatLoading ? null : _handleWeChatSignIn,
          icon: Icons.chat_bubble,
          isLoading: _isWeChatLoading,
          tooltip: S.of(context)?.commonWechat ?? 'WeChat',
          backgroundColor: const Color(0xFF07C160),
          iconColor: Colors.white,
        ),
    ];

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          widget.onLoginSuccess?.call();
        } else if (state.status == AuthStatus.error &&
            state.errorMessage != null) {
          widget.onError?.call(
            resolveBlocMessage(context, state.errorMessage!),
          );
        }
      },
      child: Column(
        children: [
          // 分隔线
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: textColor.withValues(alpha: 0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    S.of(context)?.authOtherLoginMethods ??
                        'Other login methods',
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ),
                Expanded(
                  child: Divider(color: textColor.withValues(alpha: 0.3)),
                ),
              ],
            ),
          ),

          // 社交登录按钮
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: buttons,
          ),
        ],
      ),
    );
  }

  String get _homeserver => widget.homeserverBuilder().trim();

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required IconData icon,
    required bool isLoading,
    required String tooltip,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    final isDark = context.isDarkMode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Icon(icon, size: 28, color: iconColor),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isGoogleLoading = true);

    try {
      // 触发 Google 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthGoogleLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isAppleLoading = true);

    try {
      // 触发 Apple 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthAppleLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isFacebookLoading = true);

    try {
      // 触发 Facebook 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthFacebookLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  Future<void> _handleSsoSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isSsoLoading = true);

    try {
      final config = N42Chat.config;
      final configuredRedirect = config?.ssoRedirectUrl.trim() ?? '';
      final baseRedirect = configuredRedirect.isNotEmpty
          ? configuredRedirect
          : 'n42://auth/sso';
      final baseRedirectUri = Uri.parse(baseRedirect);
      final redirectUri = baseRedirectUri.replace(
        queryParameters: <String, String>{
          ...baseRedirectUri.queryParameters,
          'homeserver': _homeserver,
        },
      );
      final loginUri = Uri.parse(
        _authService.getSsoLoginUrl(
          homeserver: _homeserver,
          redirectUrl: redirectUri.toString(),
        ),
      );

      final launched = await launchUrl(
        loginUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        widget.onError?.call('Failed to open SSO login page');
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSsoLoading = false);
      }
    }
  }

  Future<void> _handleTwitterSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isTwitterLoading = true);

    try {
      // 触发 Twitter 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthTwitterLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isTwitterLoading = false);
      }
    }
  }

  Future<void> _handleWeChatSignIn() async {
    if (!widget.isAgreedToTerms) {
      widget.onTermsNotAgreed?.call();
      return;
    }

    if (_homeserver.isEmpty) {
      widget.onError?.call(
        S.of(context)?.authEnterServerAddressFirst ??
            'Please enter server address first',
      );
      return;
    }

    setState(() => _isWeChatLoading = true);

    try {
      // 触发微信登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthWeChatLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isWeChatLoading = false);
      }
    }
  }
}

/// 单独的 Google 登录按钮
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, color: Colors.red),
      label: Text(
        S.of(context)?.commonGoogleLogin ?? 'Sign in with Google',
        style: const TextStyle(color: Colors.black87),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

/// 单独的 Apple 登录按钮
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppleSignInButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.apple, color: isDark ? Colors.black : Colors.white),
      label: Text(
        S.of(context)?.commonAppleLogin ?? 'Sign in with Apple',
        style: TextStyle(color: isDark ? Colors.black : Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
