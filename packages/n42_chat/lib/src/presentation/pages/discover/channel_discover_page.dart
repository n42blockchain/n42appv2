import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../n42_chat.dart';
import '../../widgets/common/common_widgets.dart';

/// 频道分类
enum ChannelCategory {
  all,
  tech,
  defi,
  nft,
  social,
}

/// 推荐频道数据
class _RecommendedChannel {
  final String name;
  final String description;
  final String alias;
  final int subscriberCount;
  final ChannelCategory category;

  const _RecommendedChannel({
    required this.name,
    required this.description,
    required this.alias,
    required this.subscriberCount,
    required this.category,
  });
}

/// 频道发现页面
///
/// 展示公开频道列表，支持按分类筛选和搜索。
/// 用户可加入频道并直接跳转到频道聊天页面。
class ChannelDiscoverPage extends StatefulWidget {
  const ChannelDiscoverPage({super.key});

  @override
  State<ChannelDiscoverPage> createState() => _ChannelDiscoverPageState();
}

class _ChannelDiscoverPageState extends State<ChannelDiscoverPage> {
  ChannelCategory _selectedCategory = ChannelCategory.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// 正在加入中的频道别名集合
  final Set<String> _joiningChannels = {};

  /// 已加入的频道别名集合
  final Set<String> _joinedChannels = {};

  // 内置推荐频道列表（后续接 Matrix room directory）
  static const _channels = <_RecommendedChannel>[
    _RecommendedChannel(
      name: 'N42 Announcements',
      description: 'Official announcements and updates from N42',
      alias: '#announcements:n42.ai',
      subscriberCount: 5200,
      category: ChannelCategory.tech,
    ),
    _RecommendedChannel(
      name: 'DeFi Alpha',
      description: 'DeFi opportunities, yield strategies, and protocol updates',
      alias: '#defi-alpha:n42.ai',
      subscriberCount: 3800,
      category: ChannelCategory.defi,
    ),
    _RecommendedChannel(
      name: 'NFT Drops',
      description: 'Upcoming NFT drops, mints, and collection highlights',
      alias: '#nft-drops:n42.ai',
      subscriberCount: 2900,
      category: ChannelCategory.nft,
    ),
    _RecommendedChannel(
      name: 'Web3 Dev Hub',
      description: 'Smart contract development, tools, and best practices',
      alias: '#web3-dev:n42.ai',
      subscriberCount: 4100,
      category: ChannelCategory.tech,
    ),
    _RecommendedChannel(
      name: 'Crypto News',
      description: 'Breaking news and market analysis',
      alias: '#crypto-news:n42.ai',
      subscriberCount: 8700,
      category: ChannelCategory.social,
    ),
    _RecommendedChannel(
      name: 'N42 Community',
      description: 'General discussion and community events',
      alias: '#community:n42.ai',
      subscriberCount: 6300,
      category: ChannelCategory.social,
    ),
    _RecommendedChannel(
      name: 'Yield Farming',
      description: 'Yield farming strategies across chains',
      alias: '#yield:n42.ai',
      subscriberCount: 2100,
      category: ChannelCategory.defi,
    ),
    _RecommendedChannel(
      name: 'Security Alerts',
      description: 'Smart contract vulnerabilities and security advisories',
      alias: '#security:n42.ai',
      subscriberCount: 3400,
      category: ChannelCategory.tech,
    ),
  ];

  List<_RecommendedChannel> get _filteredChannels {
    var filtered = _channels.toList();
    if (_selectedCategory != ChannelCategory.all) {
      filtered =
          filtered.where((c) => c.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.description.toLowerCase().contains(query))
          .toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.channelDiscoverTitle ?? 'Discover Channels',
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(isDark, l10n),
          // 分类标签
          _buildCategoryTabs(isDark),
          // 频道列表
          Expanded(child: _buildChannelList(isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, S? l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: l10n?.channelDiscoverSearch ?? 'Search channels...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    final labels = {
      ChannelCategory.all: 'All',
      ChannelCategory.tech: 'Tech',
      ChannelCategory.defi: 'DeFi',
      ChannelCategory.nft: 'NFT',
      ChannelCategory.social: 'Social',
    };

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: labels.entries.map((entry) {
          final selected = _selectedCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _selectedCategory = entry.key),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                fontSize: 13,
              ),
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surface,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChannelList(bool isDark, S? l10n) {
    final channels = _filteredChannels;

    if (channels.isEmpty) {
      return Center(
        child: Text(
          'No channels found',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: channels.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 72,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _buildChannelTile(channel, isDark, l10n);
      },
    );
  }

  Widget _buildChannelTile(
    _RecommendedChannel channel,
    bool isDark,
    S? l10n,
  ) {
    final isJoining = _joiningChannels.contains(channel.alias);
    final isJoined = _joinedChannels.contains(channel.alias);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.campaign,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            channel.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatCount(channel.subscriberCount)} ${l10n?.channelSubscribers ?? 'subscribers'}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: _buildJoinButton(channel, isJoining, isJoined, l10n),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildJoinButton(
    _RecommendedChannel channel,
    bool isJoining,
    bool isJoined,
    S? l10n,
  ) {
    if (isJoined) {
      return TextButton(
        onPressed: () => _openChannel(channel),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.success,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minimumSize: const Size(0, 32),
        ),
        child: Text(
          l10n?.channelJoined ?? 'Joined',
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    if (isJoining) {
      return const SizedBox(
        width: 64,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: () => _joinChannel(channel),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      child: Text(
        l10n?.channelJoin ?? 'Join',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Future<void> _joinChannel(_RecommendedChannel channel) async {
    if (_joiningChannels.contains(channel.alias)) return;

    setState(() => _joiningChannels.add(channel.alias));

    try {
      final groupRepository = GetIt.I<IGroupRepository>();
      final roomId = await groupRepository.joinGroupByAlias(channel.alias);

      if (!mounted) return;

      setState(() {
        _joiningChannels.remove(channel.alias);
        _joinedChannels.add(channel.alias);
      });

      await N42Chat.openConversation(roomId, context: context);
    } catch (e) {
      debugLog('ChannelDiscover: Failed to join ${channel.alias}: $e');

      if (!mounted) return;

      setState(() => _joiningChannels.remove(channel.alias));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join ${channel.name}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openChannel(_RecommendedChannel channel) async {
    // Already joined — just navigate, skip redundant join call
    try {
      await N42Chat.openConversation(channel.alias, context: context);
    } catch (e) {
      debugLog('ChannelDiscover: Failed to open ${channel.alias}: $e');
    }
  }
}
