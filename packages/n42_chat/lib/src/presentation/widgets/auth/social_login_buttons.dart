import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/wallet_login_credentials.dart';
import '../../../core/utils/sso_brand.dart';
import '../../../integration/wallet_bridge.dart';
import '../../../n42_chat.dart' show N42Chat;
import '../../../services/auth/auth_methods_service.dart' show AuthMethodsService, SsoProvider;
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
  bool _isWalletLoading = false;
  bool _isAppleAvailable = false;
  bool _isWeChatAvailable = false;
  bool _isSsoAvailable = false;

  bool get _isAnyLoading =>
      _isGoogleLoading ||
      _isAppleLoading ||
      _isSsoLoading ||
      _isFacebookLoading ||
      _isTwitterLoading ||
      _isWeChatLoading ||
      _isWalletLoading;

  bool get _isWalletAvailable => getIt.isRegistered<IWalletBridge>();

  void _setProviderLoading({
    bool? google,
    bool? apple,
    bool? sso,
    bool? facebook,
    bool? twitter,
    bool? weChat,
  }) {
    if (!mounted) return;
    setState(() {
      if (google != null) _isGoogleLoading = google;
      if (apple != null) _isAppleLoading = apple;
      if (sso != null) _isSsoLoading = sso;
      if (facebook != null) _isFacebookLoading = facebook;
      if (twitter != null) _isTwitterLoading = twitter;
      if (weChat != null) _isWeChatLoading = weChat;
    });
  }

  void _clearAllLoadingFlags() {
    _setProviderLoading(
      google: false,
      apple: false,
      sso: false,
      facebook: false,
      twitter: false,
      weChat: false,
    );
    if (mounted && _isWalletLoading) {
      setState(() => _isWalletLoading = false);
    }
  }

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
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
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
      debugLog('Error: $e');
    }

    // 检查 SSO 可用性（服务器需有配置 identity_providers）
    final config = N42Chat.config;
    if (config?.enableSsoLogin ?? false) {
      try {
        final homeserver = widget.homeserverBuilder().trim();
        if (homeserver.isNotEmpty) {
          final providers = await _authService.getSsoProviders(homeserver);
          if (mounted) {
            setState(() => _isSsoAvailable = providers.isNotEmpty);
          }
        }
      } catch (e) {
        debugLog('SSO availability check failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = context.textSecondary;
    final config = N42Chat.config;
    final isAnyLoading = _isAnyLoading;
    final buttons = <Widget>[
      if ((config?.enableGoogleLogin ?? true) && _isGoogleAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleGoogleSignIn,
          icon: Icons.g_mobiledata,
          isLoading: _isGoogleLoading,
          tooltip: S.of(context)?.authGoogleLabel ?? 'Google',
          backgroundColor: Colors.white,
          iconColor: Colors.red,
        ),
      if ((config?.enableAppleLogin ?? true) && _isAppleAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleAppleSignIn,
          icon: Icons.apple,
          isLoading: _isAppleLoading,
          tooltip: S.of(context)?.authAppleLabel ?? 'Apple',
          backgroundColor: isDark ? Colors.white : Colors.black,
          iconColor: isDark ? Colors.black : Colors.white,
        ),
      if ((config?.enableSsoLogin ?? false) && _isSsoAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleSsoSignIn,
          icon: Icons.login,
          isLoading: _isSsoLoading,
          tooltip: S.of(context)?.authSsoLabel ?? 'SSO',
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
        ),
      if ((config?.enableFacebookLogin ?? false) && _isFacebookAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleFacebookSignIn,
          icon: Icons.facebook,
          isLoading: _isFacebookLoading,
          tooltip: 'Facebook',
          backgroundColor: const Color(0xFF1877F2),
          iconColor: Colors.white,
        ),
      if ((config?.enableTwitterLogin ?? false) &&
          _authService.isTwitterSignInAvailable())
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleTwitterSignIn,
          icon: Icons.alternate_email,
          isLoading: _isTwitterLoading,
          tooltip: 'Twitter',
          backgroundColor: Colors.black,
          iconColor: Colors.white,
        ),
      if ((config?.enableWeChatLogin ?? false) && _isWeChatAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleWeChatSignIn,
          icon: Icons.chat_bubble,
          isLoading: _isWeChatLoading,
          tooltip: S.of(context)?.commonWechat ?? 'WeChat',
          // 微信登录按钮保留微信官方品牌绿以保证识别度
          backgroundColor: const Color(0xFF07C160),
          iconColor: Colors.white,
        ),
      if ((config?.enableWalletLogin ?? true) && _isWalletAvailable)
        _buildSocialButton(
          onTap: isAnyLoading ? null : _handleWalletSignIn,
          icon: Icons.account_balance_wallet,
          isLoading: _isWalletLoading,
          tooltip: 'Wallet',
          backgroundColor: AppColors.primary,
          iconColor: Colors.white,
        ),
    ];

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _clearAllLoadingFlags();
          widget.onLoginSuccess?.call();
        } else if (state.status == AuthStatus.error &&
            state.errorMessage != null) {
          _clearAllLoadingFlags();
          widget.onError?.call(
            resolveBlocMessage(context, state.errorMessage!),
          );
        } else if (state.status == AuthStatus.unauthenticated &&
            _isAnyLoading) {
          _clearAllLoadingFlags();
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
              color: context.dividerColor,
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

    _setProviderLoading(google: true);

    try {
      // 触发 Google 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthGoogleLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(google: false);
        widget.onError?.call(e.toString());
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

    _setProviderLoading(apple: true);

    try {
      // 触发 Apple 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthAppleLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(apple: false);
        widget.onError?.call(e.toString());
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

    _setProviderLoading(facebook: true);

    try {
      // 触发 Facebook 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthFacebookLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(facebook: false);
        widget.onError?.call(e.toString());
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

    _setProviderLoading(sso: true);

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
      final redirectUrl = redirectUri.toString();

      // 先获取服务器支持的 SSO provider 列表
      debugLog('SSO: fetching providers from $_homeserver');
      final providers = await _authService.getSsoProviders(_homeserver);
      debugLog('SSO: got ${providers.length} providers: ${providers.map((p) => "${p.id}/${p.name}").join(", ")}');

      if (!mounted) return;

      String loginUrl;
      if (providers.length == 1) {
        // 只有一个 provider，直接使用带 provider ID 的端点
        final pid = providers.first.id;
        loginUrl = pid == 'sso'
            ? _authService.getSsoLoginUrl(homeserver: _homeserver, redirectUrl: redirectUrl)
            : _authService.getSsoProviderLoginUrl(homeserver: _homeserver, providerId: pid, redirectUrl: redirectUrl);
      } else if (providers.length > 1) {
        // 多个 provider，弹出选择框
        _setProviderLoading(sso: false);
        final selected = await showModalBottomSheet<SsoProvider>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Choose login method',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              ...providers.map((p) {
                final brand = _ssoBrandVisual(
                  SsoBrandClassifier.classify('${p.id} ${p.name}'),
                );
                return ListTile(
                  leading: Icon(brand.$1, color: brand.$2),
                  title: Text(p.name),
                  onTap: () => Navigator.of(ctx).pop(p),
                );
              }),
            ],
          ),
        );
        if (selected == null || !mounted) return;
        _setProviderLoading(sso: true);
        loginUrl = _authService.getSsoProviderLoginUrl(
          homeserver: _homeserver,
          providerId: selected.id,
          redirectUrl: redirectUrl,
        );
      } else {
        // 服务器未配置任何 SSO provider，无法继续
        debugLog('SSO: no providers configured on server');
        _setProviderLoading(sso: false);
        widget.onError?.call(
          S.of(context)?.authSsoNotConfigured ??
              'This server has not configured SSO login providers',
        );
        return;
      }

      debugLog('SSO: launching URL: $loginUrl');
      final launched = await launchUrl(
        Uri.parse(loginUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _setProviderLoading(sso: false);
        widget.onError?.call('Failed to open SSO login page');
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(sso: false);
        widget.onError?.call(e.toString());
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

    _setProviderLoading(twitter: true);

    try {
      // 触发 Twitter 登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthTwitterLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(twitter: false);
        widget.onError?.call(e.toString());
      }
    }
  }

  /// 钱包/DID 登录：取地址 → 钱包对固定消息签名 → 派生凭据登录/注册
  Future<void> _handleWalletSignIn() async {
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
    if (!getIt.isRegistered<IWalletBridge>()) {
      widget.onError?.call('Wallet is not available');
      return;
    }

    _setWalletLoading(true);
    try {
      final bridge = getIt<IWalletBridge>();
      final address = bridge.walletAddress;
      if (address == null || address.isEmpty) {
        _setWalletLoading(false);
        widget.onError?.call('Please connect your wallet first');
        return;
      }
      final message = WalletLoginCredentials.canonicalLoginMessage(address);
      final signature = await bridge.signMessage(message);
      if (signature == null || signature.isEmpty) {
        _setWalletLoading(false);
        widget.onError?.call('Wallet login is not supported by this wallet');
        return;
      }
      if (!mounted) return;
      context.read<AuthBloc>().add(
        AuthWalletAuthRequested(
          homeserver: _homeserver,
          address: address,
          signature: signature,
        ),
      );
    } catch (e) {
      if (mounted) {
        _setWalletLoading(false);
        widget.onError?.call(e.toString());
      }
    }
  }

  void _setWalletLoading(bool value) {
    if (!mounted) return;
    setState(() => _isWalletLoading = value);
  }

  /// SSO 品牌 → (图标, 品牌色)
  (IconData, Color) _ssoBrandVisual(SsoBrand brand) {
    switch (brand) {
      case SsoBrand.google:
        return (Icons.g_mobiledata, Colors.red);
      case SsoBrand.apple:
        return (Icons.apple, context.textPrimary);
      case SsoBrand.microsoft:
        return (Icons.window, const Color(0xFF00A4EF));
      case SsoBrand.github:
        return (Icons.code, context.textPrimary);
      case SsoBrand.gitlab:
        return (Icons.merge_type, const Color(0xFFFC6D26));
      case SsoBrand.facebook:
        return (Icons.facebook, const Color(0xFF1877F2));
      case SsoBrand.twitter:
        return (Icons.alternate_email, context.textPrimary);
      case SsoBrand.discord:
        return (Icons.discord, const Color(0xFF5865F2));
      case SsoBrand.linkedin:
        return (Icons.business_center, const Color(0xFF0A66C2));
      case SsoBrand.wechat:
        return (Icons.chat_bubble, const Color(0xFF07C160));
      case SsoBrand.telegram:
        return (Icons.send, const Color(0xFF229ED9));
      case SsoBrand.generic:
        return (Icons.login, AppColors.primary);
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

    _setProviderLoading(weChat: true);

    try {
      // 触发微信登录事件
      if (mounted) {
        context.read<AuthBloc>().add(
          AuthWeChatLoginRequested(homeserver: _homeserver),
        );
      }
    } catch (e) {
      if (mounted) {
        _setProviderLoading(weChat: false);
        widget.onError?.call(e.toString());
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
