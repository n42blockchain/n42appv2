import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
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
class ChannelDiscoverPage extends StatefulWidget {
  const ChannelDiscoverPage({super.key});

  @override
  State<ChannelDiscoverPage> createState() => _ChannelDiscoverPageState();
}

class _ChannelDiscoverPageState extends State<ChannelDiscoverPage> {
  ChannelCategory _selectedCategory = ChannelCategory.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.channelDiscoverTitle ?? 'Discover Channels',
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context, l10n),
          // 分类标签
          _buildCategoryTabs(context),
          // 频道列表
          Expanded(child: _buildChannelList(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, S? l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: l10n?.channelDiscoverSearch ?? 'Search channels...',
          hintStyle: TextStyle(
            color: context.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(AppIcons.search, size: 20),
          filled: true,
          fillColor: context.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
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
                color: selected ? Colors.white : context.textPrimary,
                fontSize: 13,
              ),
              backgroundColor: context.surfaceColor,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChannelList(BuildContext context, S? l10n) {
    final channels = _filteredChannels;

    if (channels.isEmpty) {
      return Center(
        child: Text(
          'No channels found',
          style: TextStyle(
            color: context.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: channels.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 76,
        color: context.dividerColor,
      ),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _buildChannelTile(context, channel, l10n);
      },
    );
  }

  Widget _buildChannelTile(
    BuildContext context,
    _RecommendedChannel channel,
    S? l10n,
  ) {
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
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
              height: 1.35,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatCount(channel.subscriberCount)} ${l10n?.channelSubscribers ?? 'subscribers'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
      trailing: OutlinedButton(
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
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  void _joinChannel(_RecommendedChannel channel) {
    // TODO: 通过 Matrix room directory 加入频道
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${channel.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
