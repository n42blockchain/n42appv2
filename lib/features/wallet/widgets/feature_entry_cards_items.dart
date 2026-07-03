// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'feature_entry_cards.dart';

// ── Shared card decoration helper ─────────────────────────────────────────

/// Builds the standard gradient card decoration used by entry cards.
BoxDecoration _cardDecoration({
  required Color primaryColor,
  required Color secondaryColor,
  required BorderRadius borderRadius,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: 0.12),
        secondaryColor.withValues(alpha: 0.12),
      ],
    ),
    borderRadius: borderRadius,
    border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: 1),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Builds a circular icon container with a gradient background.
Widget _gradientCircle({
  required double size,
  required Color startColor,
  required Color endColor,
  required Widget child,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
      borderRadius: BorderRadius.circular(size / 2),
    ),
    child: child,
  );
}

/// Builds the trailing circular action indicator.
Widget _trailingAction({
  required double size,
  required Color color,
  required IconData icon,
  required double iconSize,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(size / 2),
    ),
    child: Icon(icon, color: color, size: iconSize),
  );
}

// ============================================
// ENS Entry Card
// ============================================

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
    const ensBlue = Color(0xFF5B8DEF);
    const ensPurple = Color(0xFF8B5CF6);
    final su = ScreenUtil();
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final circleSize = su.setWidth(80);

    return InkWell(
      onTap: hasEns ? onTap : onRegisterTap,
      borderRadius: AppRadius.brLg,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space6),
        decoration: _cardDecoration(
          primaryColor: ensBlue,
          secondaryColor: ensPurple,
          borderRadius: AppRadius.brLg,
        ),
        child: Row(
          children: [
            _gradientCircle(
              size: circleSize,
              startColor: ensBlue,
              endColor: ensPurple,
              child: hasEns && avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(circleSize / 2),
                      child: Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildEnsIcon(),
                      ),
                    )
                  : _buildEnsIcon(),
            ),
            SizedBox(width: AppSpacing.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasEns ? ensName! : S.of(context).g_key_ens_get_your_name,
                    style: AppTypography.bodyStrong.copyWith(
                      fontWeight: FontWeight.w600,
                      color: mainText,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    hasEns
                        ? S.of(context).g_key_ens_manage_your_identity
                        : S.of(context).g_key_ens_register_description,
                    style: AppTypography.caption.copyWith(color: subtitleColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _trailingAction(
              size: su.setWidth(56),
              color: ensBlue,
              icon: hasEns ? Icons.settings_outlined : Icons.add_rounded,
              iconSize: su.setWidth(32),
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
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ============================================
// Smart Account Entry Card
// ============================================

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
    const cardRed = Color(0xFFFF6B6B);
    const cardYellow = Color(0xFFFFE66D);
    final statusColor = isDeployed
        ? AppColorTokens.of(context).success
        : AppColorTokens.of(context).warning;
    final su = ScreenUtil();
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final circleSize = su.setWidth(80);

    return InkWell(
      onTap: hasSmartAccount ? onTap : onCreateTap,
      borderRadius: AppRadius.brLg,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space6),
        decoration: _cardDecoration(
          primaryColor: cardRed,
          secondaryColor: cardYellow,
          borderRadius: AppRadius.brLg,
        ),
        child: Row(
          children: [
            _gradientCircle(
              size: circleSize,
              startColor: cardRed,
              endColor: cardYellow,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: su.setWidth(40),
                  ),
                  if (hasSmartAccount)
                    Positioned(
                      right: su.setWidth(4),
                      bottom: su.setWidth(4),
                      child: Container(
                        width: su.setWidth(24),
                        height: su.setWidth(24),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(su.setWidth(12)),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          isDeployed ? Icons.check : Icons.hourglass_empty,
                          color: Colors.white,
                          size: su.setWidth(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.space6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          hasSmartAccount
                              ? S.of(context).g_key_aa_title
                              : S.of(context).g_key_aa_create_account,
                          style: AppTypography.bodyStrong.copyWith(
                            fontWeight: FontWeight.w600,
                            color: mainText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSmartAccount) ...[
                        SizedBox(width: AppSpacing.space2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: su.setWidth(4),
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: AppRadius.brSm,
                          ),
                          child: Text(
                            isDeployed
                                ? S.of(context).g_key_aa_deployed
                                : S.of(context).g_key_aa_not_deployed,
                            style: AppTypography.captionSm.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    hasSmartAccount
                        ? _formatAddress(accountAddress ?? '')
                        : S.of(context).g_key_aa_gasless_transactions,
                    style: AppTypography.caption.copyWith(color: subtitleColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _trailingAction(
              size: su.setWidth(56),
              color: cardRed,
              icon: hasSmartAccount
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.add_rounded,
              iconSize: su.setWidth(28),
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
