import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bot_entity.dart';
import '../../widgets/common/common_widgets.dart';

/// Bot 市场发现页面
///
/// 展示内置和社区 Bot，支持分类筛选和搜索。
class BotMarketPage extends StatefulWidget {
  /// 如果提供 roomId，添加 Bot 时将自动关联到该群组
  final String? roomId;

  const BotMarketPage({super.key, this.roomId});

  @override
  State<BotMarketPage> createState() => _BotMarketPageState();
}

class _BotMarketPageState extends State<BotMarketPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  static const _categories = {
    'all': 'All',
    'defi': 'DeFi',
    'utility': 'Utility',
    'social': 'Social',
    'moderation': 'Moderation',
    'game': 'Game',
  };

  List<BotEntity> get _filteredBots {
    var bots = BotEntity.builtInBots.toList();
    if (_selectedCategory != 'all') {
      bots = bots.where((b) => b.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      bots = bots
          .where((b) =>
              b.name.toLowerCase().contains(q) ||
              b.description.toLowerCase().contains(q))
          .toList();
    }
    return bots;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: 'Bot Market',
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildCategoryTabs(isDark),
          Expanded(child: _buildBotList(isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search bots...',
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
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
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _categories.entries.map((entry) {
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
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
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

  Widget _buildBotList(bool isDark) {
    final bots = _filteredBots;

    if (bots.isEmpty) {
      return Center(
        child: Text(
          'No bots found',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bots.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 72,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
      itemBuilder: (context, index) => _buildBotTile(bots[index], isDark),
    );
  }

  Widget _buildBotTile(BotEntity bot, bool isDark) {
    final categoryIcon = switch (bot.category) {
      'defi' => Icons.trending_up,
      'moderation' => Icons.shield_outlined,
      'social' => Icons.people_outline,
      'game' => Icons.sports_esports_outlined,
      _ => Icons.smart_toy_outlined,
    };

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(categoryIcon, color: AppColors.primary, size: 24),
      ),
      title: Row(
        children: [
          Text(
            bot.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
          if (bot.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: AppColors.primary),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            bot.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (bot.commands.isNotEmpty)
                Text(
                  '${bot.commands.length} commands',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              if (bot.commands.isNotEmpty) const SizedBox(width: 12),
              Text(
                '${_formatCount(bot.installCount)} installs',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: OutlinedButton(
        onPressed: () => _addBot(bot),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minimumSize: const Size(0, 32),
        ),
        child: const Text('Add', style: TextStyle(fontSize: 13)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _addBot(BotEntity bot) {
    // Show bot detail / confirm dialog
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(bot.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bot.description),
            if (bot.commands.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Commands:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...bot.commands.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '/${c.command} — ${c.description}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${bot.name} added'),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            },
            child: Text(widget.roomId != null ? 'Add to Group' : 'Add'),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
