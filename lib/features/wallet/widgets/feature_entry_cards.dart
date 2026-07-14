import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'feature_entry_cards_items.dart';

// ============================================
// Feature Entry Section (vertical layout)
// ============================================

/// 功能入口区域组件
class FeatureEntrySection extends StatelessWidget {
  final String? ensName;
  final String? ensAvatar;
  final bool hasSmartAccount;
  final String? smartAccountAddress;
  final bool isSmartAccountDeployed;
  final VoidCallback onEnsTap;
  final VoidCallback onEnsRegisterTap;
  final VoidCallback onSmartAccountTap;
  final VoidCallback onSmartAccountCreateTap;

  const FeatureEntrySection({
    super.key,
    this.ensName,
    this.ensAvatar,
    this.hasSmartAccount = false,
    this.smartAccountAddress,
    this.isSmartAccountDeployed = false,
    required this.onEnsTap,
    required this.onEnsRegisterTap,
    required this.onSmartAccountTap,
    required this.onSmartAccountCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.space2,
              bottom: AppSpacing.space4,
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(6),
                  height: ScreenUtil().setWidth(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5B8DEF), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: AppRadius.brSm,
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                Flexible(
                  child: Text(
                    S.of(context).g_key_advanced_features,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // ENS Card
          EnsEntryCard(
            ensName: ensName,
            avatarUrl: ensAvatar,
            onTap: onEnsTap,
            onRegisterTap: onEnsRegisterTap,
          ),
          SizedBox(height: AppSpacing.space4),
          // Smart Account Card
          SmartAccountEntryCard(
            hasSmartAccount: hasSmartAccount,
            accountAddress: smartAccountAddress,
            isDeployed: isSmartAccountDeployed,
            onTap: onSmartAccountTap,
            onCreateTap: onSmartAccountCreateTap,
          ),
        ],
      ),
    );
  }
}

// ============================================
// Feature Entry Horizontal (compact scroll)
// ============================================

/// 横向滚动的功能入口（更紧凑的设计）
class FeatureEntryHorizontal extends StatelessWidget {
  final String? ensName;
  final bool hasSmartAccount;
  final bool isSmartAccountDeployed;
  final bool ensEnabled;
  final bool smartAccountEnabled;
  final VoidCallback onEnsTap;
  final VoidCallback onSmartAccountTap;

  const FeatureEntryHorizontal({
    super.key,
    this.ensName,
    this.hasSmartAccount = false,
    this.isSmartAccountDeployed = false,
    this.ensEnabled = true,
    this.smartAccountEnabled = true,
    required this.onEnsTap,
    required this.onSmartAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(160),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        children: [
          // ENS 小卡片
          _buildMiniCard(
            automationKey: const ValueKey<String>('wallet_feature_ens'),
            context: context,
            icon: Icons.alternate_email_rounded,
            title: ensName ?? 'ENS',
            subtitle: ensName != null
                ? S.of(context).g_key_ens_your_identity
                : S.of(context).g_key_ens_register_now,
            gradientColors: const [Color(0xFF5B8DEF), Color(0xFF8B5CF6)],
            onTap: onEnsTap,
            enabled: ensEnabled,
            showBadge: ensName != null,
          ),
          SizedBox(width: AppSpacing.space4),
          // AA 小卡片
          _buildMiniCard(
            automationKey: const ValueKey<String>(
              'wallet_feature_smart_account',
            ),
            context: context,
            icon: Icons.account_balance_wallet_rounded,
            title: S.of(context).g_key_aa_smart_wallet,
            subtitle: hasSmartAccount
                ? (isSmartAccountDeployed
                      ? S.of(context).g_key_aa_ready
                      : S.of(context).g_key_aa_pending)
                : S.of(context).g_key_aa_gasless,
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
            onTap: onSmartAccountTap,
            enabled: smartAccountEnabled,
            showBadge: hasSmartAccount,
            badgeColor: isSmartAccountDeployed
                ? AppColorTokens.of(context).success
                : AppColorTokens.of(context).warning,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    Key? automationKey,
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool enabled = true,
    bool showBadge = false,
    Color? badgeColor,
  }) {
    return InkWell(
      key: automationKey,
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Container(
        width: ScreenUtil().setWidth(320),
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors
                .map((c) => c.withValues(alpha: 0.12))
                .toList(),
          ),
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: gradientColors[0].withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(64),
                    height: ScreenUtil().setWidth(64),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: ScreenUtil().setWidth(32),
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: ScreenUtil().setWidth(20),
                        height: ScreenUtil().setWidth(20),
                        decoration: BoxDecoration(
                          color:
                              badgeColor ?? AppColorTokens.of(context).success,
                          borderRadius: AppRadius.brSm,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.space2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        style: AppTypography.captionSm.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
