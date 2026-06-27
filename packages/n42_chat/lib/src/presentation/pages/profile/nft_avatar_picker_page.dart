import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/nft_metadata_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../integration/wallet_bridge.dart';

/// NFT avatar picker page — Status.im inspired.
///
/// Allows users to bind an on-chain NFT as their profile avatar.
/// The selected NFT image URL is stored and displayed with a gold ring
/// ("NFT Verified" badge) across the app.
///
/// Flow:
/// 1. User enters NFT contract address + token ID + chain ID
/// 2. App resolves the NFT image URL (via metadata URI)
/// 3. User confirms → avatar URL is returned to caller
///
/// Popular collections are shown as quick-pick shortcuts.
class NftAvatarPickerPage extends StatefulWidget {
  /// Called when the user confirms an NFT as their avatar.
  /// [imageUrl] — the resolved image URL.
  /// [contractAddress] — ERC-721 contract.
  /// [tokenId] — token ID within the contract.
  /// [chainId] — chain where the NFT lives.
  final void Function({
    required String imageUrl,
    required String contractAddress,
    required int tokenId,
    required int chainId,
  })
  onConfirm;

  const NftAvatarPickerPage({super.key, required this.onConfirm});

  @override
  State<NftAvatarPickerPage> createState() => _NftAvatarPickerPageState();
}

class _NftAvatarPickerPageState extends State<NftAvatarPickerPage>
    with SingleTickerProviderStateMixin {
  final _contractController = TextEditingController();
  final _tokenIdController = TextEditingController();

  int _selectedChainId = 1; // Ethereum mainnet default
  bool _isResolving = false;
  String? _resolvedImageUrl;
  String? _errorText;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _contractController.dispose();
    _tokenIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Resolution ──────────────────────────────────────────────────────────

  Future<void> _resolveNft() async {
    final contract = _contractController.text.trim();
    final tokenIdStr = _tokenIdController.text.trim();

    if (contract.isEmpty || tokenIdStr.isEmpty) {
      setState(
        () => _errorText =
            S.of(context)?.nftPickerEnterBoth ?? 'Enter contract and token ID',
      );
      return;
    }

    final tokenId = int.tryParse(tokenIdStr);
    if (tokenId == null) {
      setState(
        () => _errorText =
            S.of(context)?.nftPickerInvalidTokenId ?? 'Invalid token ID',
      );
      return;
    }

    setState(() {
      _isResolving = true;
      _errorText = null;
      _resolvedImageUrl = null;
    });

    try {
      final walletBridge = getIt<IWalletBridge>();

      // Verify ownership
      final balance = await walletBridge.getErc721Balance(
        contractAddress: contract,
        chainId: _selectedChainId,
      );
      if (!mounted) return;

      if (balance <= 0) {
        setState(() {
          _isResolving = false;
          _errorText =
              S.of(context)?.nftPickerNotOwned ?? 'You do not own this NFT';
        });
        return;
      }

      // 获取 tokenURI 并解析元数据中的图片 URL
      String? imageUrl;
      final tokenUri = await walletBridge.getErc721TokenUri(
        contractAddress: contract,
        tokenId: tokenId,
        chainId: _selectedChainId,
      );

      if (tokenUri != null && tokenUri.isNotEmpty) {
        final metadataService = getIt.isRegistered<NftMetadataService>()
            ? getIt<NftMetadataService>()
            : NftMetadataService();
        imageUrl = await metadataService.resolveImageUrl(tokenUri);
      }
      if (!mounted) return;

      setState(() {
        _isResolving = false;
        _resolvedImageUrl =
            imageUrl ?? 'nft://$contract/$tokenId@$_selectedChainId';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResolving = false;
        _errorText = e.toString();
      });
    }
  }

  void _confirmSelection(String imageUrl, String contract, int tokenId) {
    widget.onConfirm(
      imageUrl: imageUrl,
      contractAddress: contract,
      tokenId: tokenId,
      chainId: _selectedChainId,
    );
    Navigator.of(context).pop();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            size: 20,
            color: context.textPrimary,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.nftPickerTitle ?? 'Select NFT Avatar',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.textSecondary,
          tabs: [
            Tab(text: l10n?.nftPickerTabPopular ?? 'Popular'),
            Tab(text: l10n?.nftPickerTabCustom ?? 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPopularTab(isDark, l10n),
          _buildCustomTab(isDark, l10n),
        ],
      ),
    );
  }

  // ─── Popular tab ─────────────────────────────────────────────────────────

  Widget _buildPopularTab(bool isDark, S? l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoBanner(l10n: l10n),
        const SizedBox(height: 16),
        Text(
          l10n?.nftPickerPopularCollections ?? 'Popular Collections',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _popularCollections.length,
          itemBuilder: (context, i) => _CollectionCard(
            collection: _popularCollections[i],
            isDark: isDark,
            onTap: () {
              _contractController.text = _popularCollections[i].contract;
              _tabController.animateTo(1); // Switch to custom tab
            },
          ),
        ),
        const SizedBox(height: 24),
        _WalletConnectHint(isDark: isDark, l10n: l10n),
      ],
    );
  }

  // ─── Custom tab ──────────────────────────────────────────────────────────

  Widget _buildCustomTab(bool isDark, S? l10n) {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryColor = context.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chain selector
          Text(
            l10n?.nftPickerChain ?? 'Chain',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _ChainSelector(
            selectedChainId: _selectedChainId,
            isDark: isDark,
            onChanged: (id) => setState(() => _selectedChainId = id),
          ),

          const SizedBox(height: 16),

          // Contract address
          Text(
            l10n?.nftPickerContract ?? 'Contract Address',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.dividerOf(isDark),
              ),
            ),
            child: TextField(
              controller: _contractController,
              style: TextStyle(fontSize: 14, height: 1.3, color: textColor),
              decoration: InputDecoration(
                hintText: '0x...',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste_rounded, size: 18),
                  color: AppColors.primary,
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (!mounted) return;
                    if (data?.text != null) {
                      _contractController.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Token ID
          Text(
            l10n?.nftPickerTokenId ?? 'Token ID',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.dividerOf(isDark),
              ),
            ),
            child: TextField(
              controller: _tokenIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 14, height: 1.3, color: textColor),
              decoration: InputDecoration(
                hintText: '1234',
                hintStyle: TextStyle(color: secondaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Error
          if (_errorText != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorText!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

          if (_errorText != null) const SizedBox(height: 16),

          // Preview
          if (_resolvedImageUrl != null) ...[
            _NftPreview(
              imageUrl: _resolvedImageUrl!,
              l10n: l10n,
              onConfirm: () {
                final tokenId = int.tryParse(_tokenIdController.text.trim());
                if (tokenId == null) return; // Guard: text may have changed
                _confirmSelection(
                  _resolvedImageUrl!,
                  _contractController.text.trim(),
                  tokenId,
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Resolve button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isResolving ? null : _resolveNft,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isResolving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n?.nftPickerVerifyOwnership ??
                          'Verify Ownership & Preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NFT Preview ─────────────────────────────────────────────────────────────

class _NftPreview extends StatelessWidget {
  final String imageUrl;
  final S? l10n;
  final VoidCallback onConfirm;

  const _NftPreview({
    required this.imageUrl,
    required this.l10n,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          l10n?.nftPickerPreview ?? 'Preview',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // NFT avatar with gold ring preview
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFFD700)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: imageUrl.startsWith('nft://')
                    ? Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🖼', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                l10n?.web3NftAvatar ?? 'NFT Avatar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: Text(l10n?.nftPickerUseAsAvatar ?? 'Use as Avatar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─── Info banner ─────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final S? l10n;

  const _InfoBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🖼', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.nftPickerInfoTitle ?? 'NFT Avatar — Verified On-Chain',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.nftPickerInfoDesc ??
                      'Bind an NFT you own as your avatar. Anyone can verify ownership on-chain. Displayed with a gold ring across N42.',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chain selector ──────────────────────────────────────────────────────────

class _ChainSelector extends StatelessWidget {
  final int selectedChainId;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _ChainSelector({
    required this.selectedChainId,
    required this.isDark,
    required this.onChanged,
  });

  static const _chains = [
    (id: 1, name: 'Ethereum', icon: '⟠'),
    (id: 56, name: 'BNB Chain', icon: '🔶'),
    (id: 137, name: 'Polygon', icon: '🟣'),
    (id: 42161, name: 'Arbitrum', icon: '🔵'),
    (id: 8453, name: 'Base', icon: '🔷'),
    (id: 10, name: 'Optimism', icon: '🔴'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chains.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final chain = _chains[i];
          final selected = chain.id == selectedChainId;
          return GestureDetector(
            onTap: () => onChanged(chain.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : (isDark
                          ? Colors.white10
                          : AppColors.primary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Text(chain.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    chain.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Collection card ─────────────────────────────────────────────────────────

class _CollectionCard extends StatelessWidget {
  final _NftCollection collection;
  final bool isDark;
  final VoidCallback onTap;

  const _CollectionCard({
    required this.collection,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.dividerOf(isDark),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(collection.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              collection.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'ERC-721',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wallet connect hint ──────────────────────────────────────────────────────

class _WalletConnectHint extends StatelessWidget {
  final bool isDark;
  final S? l10n;

  const _WalletConnectHint({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: context.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.nftPickerWalletHint ??
                  'Connect your N42 wallet to automatically discover your NFTs across 236+ chains.',
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _NftCollection {
  final String name;
  final String emoji;
  final String contract;

  const _NftCollection({
    required this.name,
    required this.emoji,
    required this.contract,
  });
}

const _popularCollections = [
  _NftCollection(
    name: 'BAYC',
    emoji: '🐒',
    contract: '0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D',
  ),
  _NftCollection(
    name: 'CryptoPunks',
    emoji: '👾',
    contract: '0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB',
  ),
  _NftCollection(
    name: 'Azuki',
    emoji: '🌸',
    contract: '0xED5AF388653567Af2F388E6224dC7C4b3241C544',
  ),
  _NftCollection(
    name: 'Doodles',
    emoji: '🎨',
    contract: '0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e',
  ),
  _NftCollection(
    name: 'CloneX',
    emoji: '🤖',
    contract: '0x49cF6f5d44E70224e2E23fDcdd2C053F30aDA28B',
  ),
  _NftCollection(
    name: 'Moonbirds',
    emoji: '🦉',
    contract: '0x23581767a106ae21c074b2276D25e5C3e136a68b',
  ),
];
