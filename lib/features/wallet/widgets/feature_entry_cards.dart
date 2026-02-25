import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// ENS 功能入口卡片
class EnsEntryCard extends StatelessWidget {
  final String? ensName;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onRegisterTap;

  const EnsEntryCard({
    super.key,
    this.ensName,
    this.avatarUrl,
    required this.onTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEns = ensName != null && ensName!.isNotEmpty;

    return GestureDetector(
      onTap: hasEns ? onTap : onRegisterTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5B8DEF).withValues(alpha:0.12),
              const Color(0xFF8B5CF6).withValues(alpha:0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: const Color(0xFF5B8DEF).withValues(alpha:0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B8DEF).withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ENS Logo / Avatar
            Container(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B8DEF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
              ),
              child: hasEns && avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                      child: Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildEnsIcon(),
                      ),
                    )
                  : _buildEnsIcon(),
            ),
            SizedBox(width: ScreenUtil().setWidth(24)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasEns ? ensName! : S.of(context).g_key_ens_get_your_name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Text(
                    hasEns
                        ? S.of(context).g_key_ens_manage_your_identity
                        : S.of(context).g_key_ens_register_description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: ScreenUtil().setWidth(56),
              height: ScreenUtil().setWidth(56),
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DEF).withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
              ),
              child: Icon(
                hasEns ? Icons.settings_outlined : Icons.add_rounded,
                color: const Color(0xFF5B8DEF),
                size: ScreenUtil().setWidth(32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnsIcon() {
    return Center(
      child: Text(
        'ENS',
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// AA 智能账户入口卡片
class SmartAccountEntryCard extends StatelessWidget {
  final bool hasSmartAccount;
  final String? accountAddress;
  final bool isDeployed;
  final VoidCallback onTap;
  final VoidCallback onCreateTap;

  const SmartAccountEntryCard({
    super.key,
    this.hasSmartAccount = false,
    this.accountAddress,
    this.isDeployed = false,
    required this.onTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasSmartAccount ? onTap : onCreateTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B6B).withValues(alpha:0.12),
              const Color(0xFFFFE66D).withValues(alpha:0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withValues(alpha:0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha:0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // AA Icon
            Container(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: ScreenUtil().setWidth(40),
                  ),
                  if (hasSmartAccount)
                    Positioned(
                      right: ScreenUtil().setWidth(4),
                      bottom: ScreenUtil().setWidth(4),
                      child: Container(
                        width: ScreenUtil().setWidth(24),
                        height: ScreenUtil().setWidth(24),
                        decoration: BoxDecoration(
                          color: isDeployed ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          isDeployed ? Icons.check : Icons.hourglass_empty,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(24)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          hasSmartAccount
                              ? S.of(context).g_key_aa_smart_account
                              : S.of(context).g_key_aa_create_smart_account,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.w600,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSmartAccount) ...[
                        SizedBox(width: ScreenUtil().setWidth(10)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10),
                            vertical: ScreenUtil().setWidth(4),
                          ),
                          decoration: BoxDecoration(
                            color: isDeployed
                                ? const Color(0xFF4CAF50).withValues(alpha:0.2)
                                : const Color(0xFFFF9800).withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                          ),
                          child: Text(
                            isDeployed
                                ? S.of(context).g_key_aa_deployed
                                : S.of(context).g_key_aa_not_deployed,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              color: isDeployed ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Text(
                    hasSmartAccount
                        ? _formatAddress(accountAddress ?? '')
                        : S.of(context).g_key_aa_gasless_transactions,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: ScreenUtil().setWidth(56),
              height: ScreenUtil().setWidth(56),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
              ),
              child: Icon(
                hasSmartAccount ? Icons.arrow_forward_ios_rounded : Icons.add_rounded,
                color: const Color(0xFFFF6B6B),
                size: ScreenUtil().setWidth(28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length < 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 8)}';
  }
}

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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(8),
              bottom: ScreenUtil().setWidth(16),
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
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3)),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Text(
                  S.of(context).g_key_advanced_features,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
          SizedBox(height: ScreenUtil().setWidth(20)),
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

/// 横向滚动的功能入口（更紧凑的设计）
class FeatureEntryHorizontal extends StatelessWidget {
  final String? ensName;
  final bool hasSmartAccount;
  final bool isSmartAccountDeployed;
  final VoidCallback onEnsTap;
  final VoidCallback onSmartAccountTap;

  const FeatureEntryHorizontal({
    super.key,
    this.ensName,
    this.hasSmartAccount = false,
    this.isSmartAccountDeployed = false,
    required this.onEnsTap,
    required this.onSmartAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(160),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        children: [
          // ENS 小卡片
          _buildMiniCard(
            context: context,
            icon: Icons.alternate_email_rounded,
            title: ensName ?? 'ENS',
            subtitle: ensName != null
                ? S.of(context).g_key_ens_your_identity
                : S.of(context).g_key_ens_register_now,
            gradientColors: const [Color(0xFF5B8DEF), Color(0xFF8B5CF6)],
            onTap: onEnsTap,
            showBadge: ensName != null,
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          // AA 小卡片
          _buildMiniCard(
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
            showBadge: hasSmartAccount,
            badgeColor: isSmartAccountDeployed ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool showBadge = false,
    Color badgeColor = const Color(0xFF4CAF50),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().setWidth(320),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors.map((c) => c.withValues(alpha:0.12)).toList(),
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: gradientColors[0].withValues(alpha:0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha:0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(32)),
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
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),
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
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
