import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/social/social_profile.dart';
import '../../../domain/entities/social/social_recommendation.dart';
import '../../blocs/social/social_graph_bloc.dart';
import '../../blocs/social/social_graph_event.dart';
import '../../blocs/social/social_graph_state.dart';
import '../../widgets/social/similarity_card.dart';
import '../../widgets/social/social_graph_visualization.dart';
import 'user_similarity_page.dart';

/// Full-screen page showing the on-chain social graph.
///
/// Layout (top to bottom):
/// 1. AppBar: "Social Graph"
/// 2. User profile card (address, ENS, portfolio, chains)
/// 3. Graph visualization (compact, interactive)
/// 4. "Recommended Connections" list
///
/// Supports pull-to-refresh, loading, empty, and error states.
class SocialGraphPage extends StatefulWidget {
  /// The wallet address to display the social graph for.
  final String address;

  /// Called when a recommendation's "Connect" button is pressed.
  final ValueChanged<String>? onConnect;

  const SocialGraphPage({
    super.key,
    required this.address,
    this.onConnect,
  });

  @override
  State<SocialGraphPage> createState() => _SocialGraphPageState();
}

class _SocialGraphPageState extends State<SocialGraphPage> {
  int _selectedNodeIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<SocialGraphBloc>();
    bloc.add(SocialGraphLoadProfile(widget.address));
    bloc.add(SocialGraphLoadRecommendations(widget.address));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Social Graph'),
        backgroundColor: isDark ? AppColors.navBarDark : AppColors.navBar,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SocialGraphBloc, SocialGraphState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadData(),
            child: _buildBody(context, state, isDark),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SocialGraphState state,
    bool isDark,
  ) {
    if (state.profile == null &&
        state.recommendations.isEmpty &&
        state.hasProfileError &&
        state.hasRecommendationsError) {
      return _buildErrorState(
        state.recommendationsErrorMessage ??
            state.profileErrorMessage ??
            'Unknown error',
        isDark,
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Profile card
        SliverToBoxAdapter(
          child: _buildProfileCard(state.profile, isDark),
        ),

        // Graph visualization (if there are recommendations)
        if (state.recommendations.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildGraphSection(state, isDark),
          ),

        // Section header
        SliverToBoxAdapter(
          child: _buildSectionHeader('Recommended Connections', isDark),
        ),

        // Content
        if (state.isRecommendationsLoading && state.recommendations.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (state.hasRecommendationsError && state.recommendations.isEmpty)
          SliverFillRemaining(
            child: _buildErrorState(
              state.recommendationsErrorMessage ?? 'Unknown error',
              isDark,
            ),
          )
        else if (state.recommendations.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(isDark),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rec = state.recommendations[index];
                return SimilarityCard(
                  recommendation: rec,
                  onTap: () => _onRecommendationTapped(rec),
                  onConnect: widget.onConnect != null
                      ? () => widget.onConnect!(rec.profile.address)
                      : null,
                );
              },
              childCount: state.recommendations.length,
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildProfileCard(SocialProfile? profile, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: profile == null
          ? _buildProfileSkeleton(isDark)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address row
                Row(
                  children: [
                    _buildProfileAvatar(profile.address),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _shortenAddress(profile.address),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stats row
                Row(
                  children: [
                    _buildStat(
                      'Portfolio',
                      '\$${_formatValue(profile.portfolioValueUsd)}',
                      isDark,
                    ),
                    _buildStatDivider(isDark),
                    _buildStat(
                      'Chains',
                      '${profile.chains.length}',
                      isDark,
                    ),
                    _buildStatDivider(isDark),
                    _buildStat(
                      'Tokens',
                      '${profile.tokenCount}',
                      isDark,
                    ),
                    _buildStatDivider(isDark),
                    _buildStat(
                      'NFTs',
                      '${profile.nftCount}',
                      isDark,
                    ),
                  ],
                ),

                // Chain badges
                if (profile.chains.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: profile.chains.take(8).map((chain) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          chain.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildProfileAvatar(String address) {
    final color = AppColorPalettes.getAvatarColor(address);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSkeleton(bool isDark) {
    return SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      color: isDark ? AppColors.dividerDark : AppColors.divider,
    );
  }

  Widget _buildGraphSection(SocialGraphState state, bool isDark) {
    final centerLabel = state.profile?.displayName ?? _shortenAddress(widget.address);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 260,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SocialGraphVisualization(
          centerLabel: centerLabel,
          recommendations: state.recommendations.take(8).toList(),
          selectedIndex: _selectedNodeIndex,
          onNodeTapped: (index) {
            setState(() => _selectedNodeIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 56,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No connections found',
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connections appear as you build on-chain activity',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load social graph',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRecommendationTapped(SocialRecommendation rec) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<SocialGraphBloc>(),
          child: UserSimilarityPage(
            addressA: widget.address,
            addressB: rec.profile.address,
            displayNameA: _shortenAddress(widget.address),
            displayNameB: rec.profile.displayName,
          ),
        ),
      ),
    );
  }

  String _shortenAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  String _formatValue(double value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
