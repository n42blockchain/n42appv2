import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/models/social/social_similarity_model.dart';
import '../../blocs/social/social_graph_bloc.dart';
import '../../blocs/social/social_graph_event.dart';
import '../../blocs/social/social_graph_state.dart';

/// Detail page showing the similarity breakdown between two on-chain addresses.
///
/// Layout:
/// 1. Two user address cards side by side
/// 2. Circular similarity score indicator
/// 3. Dimension breakdown with individual progress bars
/// 4. Lists of common items (tokens, NFTs, chains)
class UserSimilarityPage extends StatefulWidget {
  /// First address (typically the current user).
  final String addressA;

  /// Second address (the compared user).
  final String addressB;

  /// Optional display name for address A.
  final String? displayNameA;

  /// Optional display name for address B.
  final String? displayNameB;

  const UserSimilarityPage({
    super.key,
    required this.addressA,
    required this.addressB,
    this.displayNameA,
    this.displayNameB,
  });

  @override
  State<UserSimilarityPage> createState() => _UserSimilarityPageState();
}

class _UserSimilarityPageState extends State<UserSimilarityPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    context.read<SocialGraphBloc>().add(
          SocialGraphCalculateSimilarity(widget.addressA, widget.addressB),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Similarity'),
        backgroundColor: context.navBarColor,
        foregroundColor: context.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SocialGraphBloc, SocialGraphState>(
        builder: (context, state) {
          final similarity = _currentSimilarity(state);

          if (state.isSimilarityLoading ||
              (similarity == null &&
                  state.similarityStatus != SocialGraphStatus.error)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.hasSimilarityError) {
            return _buildError(
              state.similarityErrorMessage ?? 'Unknown error',
            );
          }

          final resolvedSimilarity = similarity!;
          final score = resolvedSimilarity.totalScore;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Two address cards
                _buildAddressRow(isDark),

                const SizedBox(height: 24),

                // Circular similarity score
                _buildScoreIndicator(score, isDark),

                const SizedBox(height: 28),

                // Dimension breakdown
                _buildBreakdownSection(resolvedSimilarity, isDark),

                const SizedBox(height: 24),

                // Common items
                _buildCommonItemsSection(resolvedSimilarity),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressRow(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildAddressCard(widget.addressA, widget.displayNameA, isDark)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.compare_arrows,
            color: context.textSecondary,
            size: 24,
          ),
        ),
        Expanded(child: _buildAddressCard(widget.addressB, widget.displayNameB, isDark)),
      ],
    );
  }

  Widget _buildAddressCard(String address, String? displayName, bool isDark) {
    final color = AppColorPalettes.getAvatarColor(address);
    final label = displayName ?? _shortenAddress(address);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
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
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                address.length >= 4
                    ? address.substring(2, 4).toUpperCase()
                    : '??',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _shortenAddress(address),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: context.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(double score, bool isDark) {
    final percent = (score * 100).round();

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final animatedScore = score * _animController.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _CircularScorePainter(
              score: animatedScore,
              isDark: isDark,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(animatedScore * 100).round()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor(percent),
                    ),
                  ),
                  Text(
                    'Similarity',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownSection(
    SocialSimilarityModel similarity,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breakdown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildDimensionBar(
            'Token Holdings',
            similarity.tokenOverlap,
            '43%',
            isDark,
          ),
          const SizedBox(height: 10),
          _buildDimensionBar(
            'NFT Collections',
            similarity.nftOverlap,
            '36%',
            isDark,
          ),
          const SizedBox(height: 10),
          _buildDimensionBar(
            'Chain Usage',
            similarity.chainUsage,
            '21%',
            isDark,
          ),
          if (similarity.transactionInteraction > 0) ...[
            const SizedBox(height: 10),
            _buildDimensionBar(
              'Transactions',
              similarity.transactionInteraction,
              'Not weighted',
              isDark,
            ),
          ],
          if (similarity.daoMembership > 0) ...[
            const SizedBox(height: 10),
            _buildDimensionBar(
              'DAO Membership',
              similarity.daoMembership,
              'Not weighted',
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDimensionBar(
    String label,
    double value,
    String weight,
    bool isDark,
  ) {
    final percent = (value * 100).round();
    final color = _scoreColor(percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percent% (weight: $weight)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value * _animController.value,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommonItemsSection(
    SocialSimilarityModel similarity,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Common On-Chain Activity',
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
          _buildCommonItemRow(
            Icons.token_outlined,
            'Shared Tokens',
            _formatCommonItems(
              similarity.commonTokens,
              emptyLabel: 'No shared tokens found',
            ),
          ),
          const Divider(height: 20),
          _buildCommonItemRow(
            Icons.collections_outlined,
            'Shared NFT Collections',
            _formatCommonItems(
              similarity.commonNftCollections,
              emptyLabel: 'No shared NFT collections found',
            ),
          ),
          const Divider(height: 20),
          _buildCommonItemRow(
            Icons.link,
            'Shared Chains',
            _formatCommonItems(
              similarity.commonChains,
              emptyLabel: 'No shared chains found',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonItemRow(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to calculate similarity',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                context.read<SocialGraphBloc>().add(
                      SocialGraphCalculateSimilarity(
                        widget.addressA,
                        widget.addressB,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int percent) {
    if (percent >= 60) return AppColors.primary;
    if (percent >= 30) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _shortenAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  SocialSimilarityModel? _currentSimilarity(SocialGraphState state) {
    final similarity = state.similarity;
    if (similarity == null) return null;

    final addressA = widget.addressA.toLowerCase();
    final addressB = widget.addressB.toLowerCase();
    final resultA = similarity.addressA.toLowerCase();
    final resultB = similarity.addressB.toLowerCase();

    if ((resultA == addressA && resultB == addressB) ||
        (resultA == addressB && resultB == addressA)) {
      return similarity;
    }

    return null;
  }

  String _formatCommonItems(
    List<String> items, {
    required String emptyLabel,
  }) {
    if (items.isEmpty) {
      return emptyLabel;
    }

    final normalizedItems = items
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList(growable: false);
    if (normalizedItems.isEmpty) {
      return emptyLabel;
    }

    const maxPreviewItems = 3;
    final previewItems = normalizedItems.take(maxPreviewItems).join(', ');
    final remaining = normalizedItems.length - maxPreviewItems;
    if (remaining > 0) {
      return '$previewItems +$remaining more';
    }
    return previewItems;
  }
}

/// Circular progress painter for the similarity score.
class _CircularScorePainter extends CustomPainter {
  final double score;
  final bool isDark;

  _CircularScorePainter({required this.score, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Background track
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Score arc
    final percent = (score * 100).round();
    final color = percent >= 60
        ? AppColors.primary
        : percent >= 30
            ? AppColors.warning
            : AppColors.textSecondary;

    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * score;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularScorePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.isDark != isDark;
  }
}
