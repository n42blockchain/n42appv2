import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/social/social_connection.dart';
import '../../../domain/entities/social/social_recommendation.dart';

/// Card widget for displaying a social graph recommendation.
///
/// Shows:
/// - Jazzicon-style avatar derived from the address hash
/// - Display name (ENS or shortened address)
/// - Similarity percentage badge
/// - Connection type icons
/// - Brief reason text
class SimilarityCard extends StatelessWidget {
  /// The recommendation data to display.
  final SocialRecommendation recommendation;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the "Connect" button is pressed.
  final VoidCallback? onConnect;

  const SimilarityCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = recommendation.profile;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(profile.address, isDark),
            const SizedBox(width: 12),

            // Name + reason
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSimilarityBadge(isDark),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.reason,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Connection type icons
                      ..._buildConnectionIcons(isDark),
                      const Spacer(),
                      // Connect button
                      if (onConnect != null)
                        _buildConnectButton(context, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String address, bool isDark) {
    // Generate a deterministic color from the address
    final color = _addressColor(address);
    final initials = address.length >= 4
        ? address.substring(2, 4).toUpperCase()
        : address.toUpperCase();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSimilarityBadge(bool isDark) {
    final percent = recommendation.similarityPercent;
    final badgeColor = percent >= 60
        ? AppColors.primary
        : percent >= 30
            ? AppColors.warning
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  List<Widget> _buildConnectionIcons(bool isDark) {
    final types = recommendation.topConnectionTypes;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return types.take(4).map((type) {
      final icon = _iconForType(type);
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Tooltip(
          message: _labelForType(type),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      );
    }).toList();
  }

  Widget _buildConnectButton(BuildContext context, bool isDark) {
    return SizedBox(
      height: 28,
      child: TextButton(
        onPressed: onConnect,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Connect'),
      ),
    );
  }

  /// Generate a deterministic color from an Ethereum address.
  Color _addressColor(String address) {
    if (address.length < 6) return AppColors.primary;
    final hash = address.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return AppColorPalettes.avatarColors[
        hash % AppColorPalettes.avatarColors.length];
  }

  IconData _iconForType(ConnectionType type) {
    switch (type) {
      case ConnectionType.commonTokens:
        return Icons.token_outlined;
      case ConnectionType.commonNfts:
        return Icons.collections_outlined;
      case ConnectionType.transactionHistory:
        return Icons.swap_horiz;
      case ConnectionType.commonDaos:
        return Icons.groups_outlined;
      case ConnectionType.commonChains:
        return Icons.link;
    }
  }

  String _labelForType(ConnectionType type) {
    switch (type) {
      case ConnectionType.commonTokens:
        return 'Common tokens';
      case ConnectionType.commonNfts:
        return 'Shared NFTs';
      case ConnectionType.transactionHistory:
        return 'Transaction history';
      case ConnectionType.commonDaos:
        return 'Common DAOs';
      case ConnectionType.commonChains:
        return 'Same chains';
    }
  }
}
