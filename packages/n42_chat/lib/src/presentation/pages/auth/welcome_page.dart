import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';

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
      key: const ValueKey<String>('chat_welcome_page'),
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildBackButton(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildFeatures(context),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildFixedBottom(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.spacingS,
          top: AppDimensions.spacingS,
        ),
        child: IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: Icon(
            AppIcons.back,
            color: context.textPrimary,
            size: AppDimensions.iconSizeSmall,
          ),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          splashRadius: 22,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Text(
          'N42 Chat',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          S.of(context)?.authSecureDecentralizedChat ??
              'Secure, decentralized messaging',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      children: [
        _FeatureItem(
          icon: Icons.security,
          title:
              S.of(context)?.commonEndToEndEncryption ??
              'End-to-end encryption',
          description:
              S.of(context)?.authMessagesOnlyYouCanSee ??
              'Messages visible only to you and the recipient',
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.public,
          title: S.of(context)?.authDecentralized ?? 'Decentralized',
          description:
              S.of(context)?.authBasedOnMatrix ??
              'Built on the Matrix open protocol',
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.account_balance_wallet,
          title: S.of(context)?.authWalletIntegration ?? 'Wallet Integration',
          description:
              S.of(context)?.authEasyCryptoTransfer ??
              'Easy cryptocurrency transfers',
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, bool isDark) {
    final loginText = S.of(context)?.authLogin ?? 'Log In';
    final signupText = S.of(context)?.authRegister ?? 'Sign Up';
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: const ValueKey<String>('chat_welcome_login'),
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: Text(
              loginText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacing),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            key: const ValueKey<String>('chat_welcome_register'),
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              signupText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreement(BuildContext context) {
    final tertiaryColor = context.textTertiary;
    final linkColor = AppColors.link.withValues(alpha: 0.85);
    final textStyle = AppTextStyles.captionSmall.copyWith(fontSize: 12);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          S.of(context)?.authAgreeTerms ?? 'By logging in, you agree to ',
          style: textStyle.copyWith(color: tertiaryColor),
        ),
        GestureDetector(
          onTap: onTermsOfService,
          behavior: HitTestBehavior.opaque,
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
          behavior: HitTestBehavior.opaque,
          child: Text(
            S.of(context)?.authPrivacyPolicy ?? 'Privacy Policy',
            style: textStyle.copyWith(color: linkColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedBottom(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
      decoration: BoxDecoration(
        color: AppColors.bgOf(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButtons(context, isDark),
          const SizedBox(height: 16),
          _buildAgreement(context),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppDimensions.iconSize,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
