// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'feature_entry_cards.dart';

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

    return GestureDetector(
      onTap: hasEns ? onTap : onRegisterTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ensBlue.withValues(alpha: 0.12),
              ensPurple.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: ensBlue.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ensBlue.withValues(alpha: 0.08),
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
                  colors: [ensBlue, ensPurple],
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
                color: ensBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
              ),
              child: Icon(
                hasEns ? Icons.settings_outlined : Icons.add_rounded,
                color: ensBlue,
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
    const deployedGreen = Color(0xFF4CAF50);
    const pendingOrange = Color(0xFFFF9800);

    return GestureDetector(
      onTap: hasSmartAccount ? onTap : onCreateTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardRed.withValues(alpha: 0.12),
              cardYellow.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: cardRed.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cardRed.withValues(alpha: 0.08),
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
                  colors: [cardRed, cardYellow],
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
                          color: isDeployed ? deployedGreen : pendingOrange,
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
                                ? deployedGreen.withValues(alpha: 0.2)
                                : pendingOrange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                          ),
                          child: Text(
                            isDeployed
                                ? S.of(context).g_key_aa_deployed
                                : S.of(context).g_key_aa_not_deployed,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              color: isDeployed ? deployedGreen : pendingOrange,
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
                color: cardRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
              ),
              child: Icon(
                hasSmartAccount ? Icons.arrow_forward_ios_rounded : Icons.add_rounded,
                color: cardRed,
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
