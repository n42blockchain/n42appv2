import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../n42_chat.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../main/chat_main_page.dart';
import '../../helpers/bloc_message_helper.dart';

/// 注册页面
///
/// 微信风格的注册界面
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final _formKey = GlobalKey<FormState>();
  final _homeserverController = TextEditingController(
    text: N42Chat.config?.defaultHomeserver ?? AppConstants.defaultHomeserver,
  );
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // 内置邀请码
  final _inviteCodeController = TextEditingController(
    text: 'c321fb4d6ce5e93984452cbd11427f5dfc8c02a2c728234ce8d6e5ce317e9a81',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showInviteCode = false; // 控制是否显示邀请码输入框
  bool _anonymousMode = false;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final url = Uri.parse('https://www.n42.ai/static/terms_of_use.html');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final url = Uri.parse('https://www.n42.ai/static/terms_of_use.html');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      };
  }

  @override
  void dispose() {
    _homeserverController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _handleAuthSuccess() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(Routes.conversationList);
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: ChatMainPage(
            onBackToMain: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  void _onRegister() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.authPleaseAgreeToTerms ??
                'Please read and agree to the Terms of Service and Privacy Policy',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final inviteCode = _inviteCodeController.text.trim();
      if (_anonymousMode) {
        context.read<AuthBloc>().add(
          AuthAnonymousRegisterRequested(
            homeserver: _homeserverController.text.trim(),
            password: _passwordController.text,
            registrationToken: inviteCode.isNotEmpty ? inviteCode : null,
          ),
        );
      } else {
        final email = _emailController.text.trim();
        context.read<AuthBloc>().add(
          AuthRegisterRequested(
            homeserver: _homeserverController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            email: email.isNotEmpty ? email : null,
            registrationToken: inviteCode.isNotEmpty ? inviteCode : null,
          ),
        );
      }
    }
  }

  void _checkHomeserver() {
    final homeserver = _homeserverController.text.trim();
    if (homeserver.isNotEmpty) {
      context.read<AuthBloc>().add(AuthHomeserverCheckRequested(homeserver));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = AppColors.bgOf(isDark);
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          S.of(context)?.authRegister ?? 'Sign Up',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineSmall.copyWith(color: textColor),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            final message = state.errorMessage != null
                ? resolveBlocMessage(context, state.errorMessage!)
                : (S.of(context)?.authRegisterFailed ?? 'Registration failed');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          if (state.isAuthenticated) {
            _handleAuthSuccess();
          }
        },
        builder: (context, state) {
          final isDarkMode = context.isDarkMode;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // 服务器输入
                  _buildServerInput(context, state, isDarkMode),

                  const SizedBox(height: 10),

                  _buildAnonymousModeToggle(context, isDarkMode),

                  const SizedBox(height: 10),

                  if (_anonymousMode) ...[
                    _buildAnonymousInfoCard(context, isDarkMode),
                    const SizedBox(height: 10),
                  ] else ...[
                    // 用户名输入
                    _buildUsernameInput(context, isDarkMode),
                    const SizedBox(height: 10),
                    // 邮箱输入
                    _buildEmailInput(context, isDarkMode),
                    const SizedBox(height: 10),
                  ],

                  // 密码输入
                  _buildPasswordInput(context, isDarkMode),

                  const SizedBox(height: 10),

                  // 确认密码输入
                  _buildConfirmPasswordInput(context, isDarkMode),

                  const SizedBox(height: 10),

                  // 邀请码输入（可折叠）
                  _buildInviteCodeInput(context, isDarkMode),

                  const SizedBox(height: 12),

                  // 同意协议
                  _buildAgreementCheckbox(context),

                  const SizedBox(height: 16),

                  // 注册按钮
                  _buildRegisterButton(state),

                  const SizedBox(height: 12),

                  // 已有账号
                  _buildLoginLink(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServerInput(BuildContext context, AuthState state, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authServerAddress ?? 'Server Address',
          style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _homeserverController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.authServerAddressHint ??
                (N42Chat.config?.defaultHomeserver ??
                    AppConstants.defaultHomeserver),
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
            suffixIcon: state.isCheckingHomeserver
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : state.isHomeserverValid
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : IconButton(
                    icon: Icon(Icons.refresh, color: hintColor),
                    onPressed: _checkHomeserver,
                  ),
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          onEditingComplete: _checkHomeserver,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.authEnterServerAddress ??
                  'Please enter server address';
            }
            if (!value.startsWith('http://') && !value.startsWith('https://')) {
              return S.of(context)?.authEnterValidServerAddress ??
                  'Please enter a valid server address';
            }
            return null;
          },
        ),
        if (state.isHomeserverValid && state.homeserverInfo != null) ...[
          const SizedBox(height: 4),
          Text(
            '✓ ${S.of(context)?.authConnectedTo(state.homeserverInfo!.serverName) ?? 'Connected to ${state.homeserverInfo!.serverName}'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.success),
          ),
        ],
      ],
    );
  }

  Widget _buildAnonymousModeToggle(BuildContext context, bool isDark) {
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final cardColor = AppColors.inputBgOf(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        value: _anonymousMode,
        onChanged: (value) {
          setState(() {
            _anonymousMode = value;
          });
        },
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
        title: Text(
          'Anonymous Registration',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Create an account without binding phone or email. A username will be generated automatically.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildAnonymousInfoCard(BuildContext context, bool isDark) {
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final cardColor = AppColors.inputBgOf(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anonymous mode is on',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The app will create a random Matrix username for you. You can still sign in later with your generated account and password.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameInput(BuildContext context, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authUsername ?? 'Username',
          style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          maxLength: 20,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.authUsernameHint ??
                '3-20 chars, letters/numbers/_',
            hintStyle: TextStyle(color: hintColor, fontSize: 14, height: 1.3),
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
            prefixIcon: Icon(Icons.person_outline, color: hintColor),
            counterText: '',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (_anonymousMode) {
              return null;
            }
            if (value == null || value.isEmpty) {
              return S.of(context)?.authEnterUsername ??
                  'Please enter username';
            }
            if (value.length < 3) {
              return S.of(context)?.authUsernameMinLength ??
                  'Username must be at least 3 characters';
            }
            if (value.length > 20) {
              return S.of(context)?.authUsernameMaxLength ??
                  'Username must be at most 20 characters';
            }
            if (!_usernameRegex.hasMatch(value)) {
              return S.of(context)?.authUsernameFormat ??
                  'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailInput(BuildContext context, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context)?.authEmailAddress ?? 'Email Address',
              style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
            ),
            const SizedBox(width: 4),
            Text(
              '(${S.of(context)?.authOptional ?? 'Optional'})',
              style: TextStyle(fontSize: 12, color: hintColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.commonEnterEmailAddress ?? 'Enter email address',
            hintStyle: TextStyle(color: hintColor, fontSize: 14, height: 1.3),
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
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (_anonymousMode) {
              return null;
            }
            // 邮箱是可选的，但如果填写了需要验证格式
            if (value != null && value.isNotEmpty) {
              if (!_emailRegex.hasMatch(value)) {
                return S.of(context)?.commonInvalidEmailFormat ??
                    'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          S.of(context)?.authEmailRecoveryHint ?? 'Used for password recovery',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, height: 1.3, color: hintColor),
        ),
      ],
    );
  }

  Widget _buildPasswordInput(BuildContext context, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authPassword ?? 'Password',
          style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.3),
          decoration: InputDecoration(
            hintText: S.of(context)?.authPasswordHint ?? 'Min 8 characters',
            hintStyle: TextStyle(color: hintColor, fontSize: 14, height: 1.3),
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
              return S.of(context)?.authEnterPassword ??
                  'Please enter password';
            }
            if (value.length < 8) {
              return S.of(context)?.commonPasswordMinLength ??
                  'Password must be at least 8 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordInput(BuildContext context, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context)?.authConfirmPassword ?? 'Confirm Password',
          style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
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
          onFieldSubmitted: (_) => _onRegister(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context)?.commonReenterPassword ??
                  'Please re-enter password';
            }
            if (value != _passwordController.text) {
              return S.of(context)?.commonPasswordsDoNotMatch ??
                  'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInviteCodeInput(BuildContext context, bool isDark) {
    final labelColor = context.textSecondary;
    final inputBgColor = AppColors.inputBgOf(isDark);
    final textColor = context.textPrimary;
    final hintColor = context.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 展开/折叠按钮
        GestureDetector(
          onTap: () {
            setState(() {
              _showInviteCode = !_showInviteCode;
            });
          },
          child: Row(
            children: [
              Icon(
                _showInviteCode ? Icons.expand_less : Icons.expand_more,
                color: labelColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  S.of(context)?.authInviteCodeBuiltIn ??
                      'Invite Code (Built-in)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.3, color: labelColor),
                ),
              ),
              const Spacer(),
              if (!_showInviteCode)
                Text(
                  S.of(context)?.authFilled ?? 'Filled',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
        ),
        // 邀请码输入框（可折叠）
        if (_showInviteCode) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _inviteCodeController,
            style: TextStyle(color: textColor, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  S.of(context)?.authEnterInviteCode ?? 'Enter invite code',
              hintStyle: TextStyle(color: hintColor),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.vpn_key_outlined, color: hintColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context)?.authInviteCodeBuiltInNote ??
                'Invite code is built-in, usually no need to modify',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, height: 1.4, color: hintColor),
          ),
        ],
      ],
    );
  }

  Widget _buildAgreementCheckbox(BuildContext context) {
    final textColor = context.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: AbsorbPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (_) {},
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                side: BorderSide(color: textColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text:
                  S.of(context)?.authIHaveReadAndAgree ??
                  'I have read and agree to ',
              style: TextStyle(fontSize: 13, color: textColor),
              children: [
                TextSpan(
                  text:
                      S.of(context)?.authTermsOfService ?? 'Terms of Service',
                  style: const TextStyle(color: AppColors.link),
                  recognizer: _termsRecognizer,
                ),
                TextSpan(text: S.of(context)?.authAnd ?? ' and '),
                TextSpan(
                  text: S.of(context)?.authPrivacyPolicy ?? 'Privacy Policy',
                  style: const TextStyle(color: AppColors.link),
                  recognizer: _privacyRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(AuthState state) {
    final isEnabled = !state.isLoading && _agreeToTerms;

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? _onRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                S.of(context)?.authRegister ?? 'Sign Up',
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

  Widget _buildLoginLink(BuildContext context) {
    final textColor = context.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context)?.authAlreadyHaveAccount ?? 'Already have an account?',
          style: TextStyle(fontSize: 14, color: textColor),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            S.of(context)?.authLoginNow ?? 'Log In Now',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.link,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
