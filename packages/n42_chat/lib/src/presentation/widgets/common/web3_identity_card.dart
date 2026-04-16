import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'ens_badge.dart';
import 'n42_avatar.dart';

/// Web3 identity card widget.
///
/// Displays an on-chain identity resolved from a wallet address or ENS name.
/// Used in search results, contact detail pages, and profile headers to give
/// a visual anchor for decentralized identity — inspired by Status.im's
/// user profile cards.
///
/// ```
/// ┌───────────────────────────────────┐
/// │  [Avatar]   vitalik.eth           │
/// │   🏷 NFT    ✓ ENS Verified        │
/// │             0x71C...6b6e          │
/// │  [📋 Copy Address]  [💬 Message]  │
/// └───────────────────────────────────┘
/// ```
class Web3IdentityCard extends StatelessWidget {
  /// ENS name (e.g. "vitalik.eth"), null if not resolved.
  final String? ensName;

  /// The resolved or provided wallet address.
  final String walletAddress;

  /// Avatar URL — ENS avatar, NFT image, or fallback.
  final String? avatarUrl;

  /// Display name from profile, ENS, or abbreviated address.
  final String? displayName;

  /// Whether this identity is a registered N42/Matrix user.
  final bool isN42User;

  /// Whether the address owns the ENS name (verified).
  final bool isEnsVerified;

  /// Whether the avatar is an on-chain NFT.
  final bool isNftAvatar;

  /// Message button callback. Null = button hidden.
  final VoidCallback? onMessage;

  final bool isDark;

  const Web3IdentityCard({
    super.key,
    required this.walletAddress,
    this.ensName,
    this.avatarUrl,
    this.displayName,
    this.isN42User = false,
    this.isEnsVerified = false,
    this.isNftAvatar = false,
    this.onMessage,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final effectiveName = displayName ??
        ensName ??
        _abbreviateAddress(walletAddress);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: avatar + name + badges ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with optional NFT ring
                _AvatarWithRing(
                  avatarUrl: avatarUrl,
                  name: effectiveName,
                  isNftAvatar: isNftAvatar,
                  size: 56,
                ),
                const SizedBox(width: 12),

                // Name + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display name
                      Text(
                        effectiveName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Badges row
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (ensName != null)
                            EnsBadge(
                              ensName: ensName!,
                              showIcon: isEnsVerified,
                            ),
                          if (isNftAvatar) _NftAvatarBadge(l10n: l10n),
                          if (isN42User) _N42Badge(l10n: l10n),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : AppColors.divider,
            ),
            const SizedBox(height: 12),

            // ── Address row ─────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 15,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _abbreviateAddress(walletAddress),
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                // Copy address
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: walletAddress));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.web3AddressCopied ?? 'Address copied',
                          style: const TextStyle(fontSize: 13),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          l10n?.web3Copy ?? 'Copy',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Message button ───────────────────────────────────────────
            if (onMessage != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    isN42User
                        ? (l10n?.web3SendMessage ?? 'Send Message')
                        : (l10n?.web3SendToWallet ?? 'Message Wallet'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (!isN42User) ...[
                const SizedBox(height: 8),
                Text(
                  l10n?.web3WalletOnlyHint ??
                      'This address has no N42 account yet. Message will be delivered when they join.',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// "0x71C7...6b6e" — show first 6 + last 4 chars.
  static String _abbreviateAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

// ─── Avatar with optional NFT ring ───────────────────────────────────────────

class _AvatarWithRing extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final bool isNftAvatar;
  final double size;

  const _AvatarWithRing({
    required this.avatarUrl,
    required this.name,
    required this.isNftAvatar,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = N42Avatar(
      imageUrl: avatarUrl,
      name: name,
      size: size,
      borderRadius: size / 2, // Circle
    );

    if (!isNftAvatar) return avatar;

    // Gold gradient ring for NFT avatars
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFFD700)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(child: avatar),
        ),
      ),
    );
  }
}

// ─── Small badges ─────────────────────────────────────────────────────────────

class _NftAvatarBadge extends StatelessWidget {
  final S? l10n;

  const _NftAvatarBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🖼', style: TextStyle(fontSize: 9)),
          const SizedBox(width: 2),
          Text(
            l10n?.web3NftAvatar ?? 'NFT',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _N42Badge extends StatelessWidget {
  final S? l10n;

  const _N42Badge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: const Text(
        'N42',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
