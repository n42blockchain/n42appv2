import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 欢迎页面
///
/// 首次打开应用显示的欢迎/引导页面
class WelcomePage extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onBack;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onPrivacyPolicy;

  const WelcomePage({
    super.key,
    this.onLogin,
    this.onRegister,
    this.onBack,
    this.onTermsOfService,
    this.onPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 返回按钮
            _buildBackButton(context, isDark),

            // 主内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo和标题
                    _buildHeader(context, isDark),

                    const Spacer(flex: 3),

                    // 特性列表
                    _buildFeatures(context, isDark),

                    const Spacer(flex: 2),

                    // 按钮
                    _buildButtons(context, isDark),

                    const SizedBox(height: 32),

                    // 协议
                    _buildAgreement(context, isDark),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Back',
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'N42 Chat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context)?.authSecureDecentralizedChat ?? 'Secure, decentralized messaging',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context, bool isDark) {
    return Column(
      children: [
        _FeatureItem(
          icon: Icons.security,
          title: S.of(context)?.commonEndToEndEncryption ?? 'End-to-end encryption',
          description: S.of(context)?.authMessagesOnlyYouCanSee ?? 'Messages visible only to you and the recipient',
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.public,
          title: S.of(context)?.authDecentralized ?? 'Decentralized',
          description: S.of(context)?.authBasedOnMatrix ?? 'Built on the Matrix open protocol',
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.account_balance_wallet,
          title: S.of(context)?.authWalletIntegration ?? 'Wallet Integration',
          description: S.of(context)?.authEasyCryptoTransfer ?? 'Easy cryptocurrency transfers',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // 登录按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: Text(
              S.of(context)?.authLogin ?? 'Log In',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 注册按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              S.of(context)?.authRegister ?? 'Sign Up',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreement(BuildContext context, bool isDark) {
    final tertiaryColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final linkColor = AppColors.textLink.withValues(alpha: 0.8);
    const textStyle = TextStyle(fontSize: 12);

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          S.of(context)?.authAgreeTerms ?? 'By logging in, you agree to ',
          style: textStyle.copyWith(color: tertiaryColor),
        ),
        GestureDetector(
          onTap: onTermsOfService,
          child: Text(
            S.of(context)?.authTermsOfService ?? 'Terms of Service',
            style: textStyle.copyWith(color: linkColor),
          ),
        ),
        Text(
          ' ${S.of(context)?.authAnd ?? 'and'} ',
          style: textStyle.copyWith(color: tertiaryColor),
        ),
        GestureDetector(
          onTap: onPrivacyPolicy,
          child: Text(
            S.of(context)?.authPrivacyPolicy ?? 'Privacy Policy',
            style: textStyle.copyWith(color: linkColor),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

