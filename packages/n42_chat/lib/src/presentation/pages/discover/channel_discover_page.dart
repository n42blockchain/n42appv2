import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../../core/di/injection.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../n42_chat.dart';
import '../../widgets/common/common_widgets.dart';

enum ChannelCategory { all, tech, defi, nft, social }

class _PublicChannel {
  final String roomId;
  final String name;
  final String description;
  final String? avatarUrl;
  final int subscriberCount;
  final ChannelCategory category;

  const _PublicChannel({
    required this.roomId,
    required this.name,
    required this.description,
    this.avatarUrl,
    required this.subscriberCount,
    required this.category,
  });
}

/// Live Matrix room-directory browser. It intentionally contains no hardcoded
/// rooms: every visible channel can be joined and opened.
class ChannelDiscoverPage extends StatefulWidget {
  const ChannelDiscoverPage({super.key});

  @override
  State<ChannelDiscoverPage> createState() => _ChannelDiscoverPageState();
}

class _ChannelDiscoverPageState extends State<ChannelDiscoverPage> {
  ChannelCategory _selectedCategory = ChannelCategory.all;
  final _searchController = TextEditingController();
  List<_PublicChannel> _channels = const [];
  final Set<String> _joining = <String>{};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_PublicChannel> get _filteredChannels =>
      _selectedCategory == ChannelCategory.all
      ? _channels
      : _channels
            .where((channel) => channel.category == _selectedCategory)
            .toList();

  Future<void> _loadChannels() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final client = MatrixClientManager.instance.client;
    if (client == null || !client.isLogged()) {
      setState(() {
        _loading = false;
        _error = 'Sign in to discover public channels';
      });
      return;
    }

    try {
      final query = _searchController.text.trim();
      final response = await client.queryPublicRooms(
        limit: 50,
        filter: query.isEmpty
            ? null
            : matrix.PublicRoomQueryFilter(genericSearchTerm: query),
      );
      final channels =
          response.chunk
              .where((room) => room.roomType != 'm.space')
              .map(_mapChannel)
              .toList()
            ..sort((a, b) => b.subscriberCount.compareTo(a.subscriberCount));
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  _PublicChannel _mapChannel(matrix.PublishedRoomsChunk room) {
    final name = room.name?.trim().isNotEmpty == true
        ? room.name!
        : room.roomId;
    final topic = room.topic?.trim() ?? '';
    return _PublicChannel(
      roomId: room.roomId,
      name: name,
      description: topic,
      avatarUrl: room.avatarUrl?.toString(),
      subscriberCount: room.numJoinedMembers,
      category: _inferCategory('$name $topic'),
    );
  }

  ChannelCategory _inferCategory(String value) {
    final text = value.toLowerCase();
    if (text.contains('nft') || text.contains('collectible')) {
      return ChannelCategory.nft;
    }
    if (text.contains('defi') ||
        text.contains('yield') ||
        text.contains('token')) {
      return ChannelCategory.defi;
    }
    if (text.contains('tech') ||
        text.contains('develop') ||
        text.contains('security')) {
      return ChannelCategory.tech;
    }
    return ChannelCategory.social;
  }

  Future<void> _joinChannel(_PublicChannel channel) async {
    if (_joining.contains(channel.roomId)) return;
    setState(() => _joining.add(channel.roomId));
    try {
      final client = MatrixClientManager.instance.client;
      if (client == null || !client.isLogged()) {
        throw Exception('Sign in first');
      }
      await getIt<IGroupRepository>().joinGroup(channel.roomId);
      if (!mounted) return;
      await N42Chat.openConversation(channel.roomId, context: context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to join ${channel.name}: $error')),
      );
    } finally {
      if (mounted) setState(() => _joining.remove(channel.roomId));
    }
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadChannels(),
              decoration: InputDecoration(
                hintText: l10n?.channelDiscoverSearch ?? 'Search channels...',
                prefixIcon: const Icon(AppIcons.search, size: 20),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _loadChannels,
                  icon: const Icon(Icons.arrow_forward),
                ),
                filled: true,
                fillColor: context.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _buildCategoryTabs(context),
          const SizedBox(height: 4),
          Expanded(child: _buildChannelList(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    const labels = {
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
              onSelected: (_) => setState(() => _selectedCategory = entry.key),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : context.textPrimary,
                fontSize: 13,
              ),
              backgroundColor: context.surfaceColor,
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChannelList(BuildContext context, S? l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _DirectoryMessage(
        icon: Icons.cloud_off_outlined,
        message: _error!,
        onRetry: _loadChannels,
      );
    }
    final channels = _filteredChannels;
    if (channels.isEmpty) {
      return _DirectoryMessage(
        icon: Icons.campaign_outlined,
        message: 'No public channels found',
        onRetry: _loadChannels,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChannels,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: channels.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 76, color: context.dividerColor),
        itemBuilder: (context, index) {
          final channel = channels[index];
          final joining = _joining.contains(channel.roomId);
          return ListTile(
            leading: N42Avatar(
              name: channel.name,
              imageUrl: channel.avatarUrl,
              size: 48,
              borderRadius: 12,
            ),
            title: Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (channel.description.isNotEmpty)
                  Text(
                    channel.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${_formatCount(channel.subscriberCount)} '
                  '${l10n?.channelSubscribers ?? 'subscribers'}',
                  style: TextStyle(color: context.textSecondary, fontSize: 11),
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: joining ? null : () => _joinChannel(channel),
              child: joining
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.channelJoin ?? 'Join'),
            ),
          );
        },
      ),
    );
  }

  String _formatCount(int count) => count >= 1000
      ? '${(count / 1000).toStringAsFixed(1)}K'
      : count.toString();
}

class _DirectoryMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _DirectoryMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: context.textTertiary),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
