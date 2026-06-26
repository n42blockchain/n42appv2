import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import '../../../domain/repositories/sticker_repository.dart';

/// 贴纸商店页面
class StickerStorePage extends StatefulWidget {
  const StickerStorePage({super.key});

  @override
  State<StickerStorePage> createState() => _StickerStorePageState();
}

class _StickerStorePageState extends State<StickerStorePage>
    with SingleTickerProviderStateMixin {
  late final IStickerRepository _repository;
  late final TabController _tabController;

  List<StickerCategory> _categories = [];
  List<StickerPack> _installedPacks = [];
  List<StickerPack> _storePacks = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<IStickerRepository>();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _repository.getCategories();
      final installed = await _repository.getInstalledPacks();
      final store = await _repository.getStorePacks();

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _installedPacks = installed;
        _storePacks = store;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _installPack(StickerPack pack) async {
    final success = await _repository.installPack(pack.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        _installedPacks.add(pack.copyWith(isInstalled: true));
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Installed "${pack.name}"')));
      }
    }
  }

  Future<void> _uninstallPack(StickerPack pack) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Sticker Pack'),
        content: Text('Remove "${pack.name}" from your stickers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _repository.uninstallPack(pack.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        _installedPacks.removeWhere((p) => p.id == pack.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Removed "${pack.name}"')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Sticker Store'),
        backgroundColor: context.surfaceColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Store'),
            Tab(text: 'My Stickers'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildStoreTab(isDark), _buildMyStickersTab(isDark)],
            ),
    );
  }

  Widget _buildStoreTab(bool isDark) {
    return Column(
      children: [
        // 分类标签
        _buildCategoryTabs(isDark),

        // 贴纸包列表
        Expanded(child: _buildStoreList(isDark)),
      ],
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      height: 44,
      color: context.surfaceColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              'All',
              '🌟',
              _selectedCategory == null,
              () => setState(() => _selectedCategory = null),
              isDark,
            );
          }

          final category = _categories[index - 1];
          return _buildCategoryChip(
            category.name,
            category.icon ?? '📦',
            _selectedCategory == category.id,
            () => setState(() => _selectedCategory = category.id),
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    String icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: AppColors.primary) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: isSelected
                      ? AppColors.primary
                      : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList(bool isDark) {
    final filteredPacks = _storePacks.where((pack) {
      if (_selectedCategory == null) return true;
      switch (_selectedCategory) {
        case 'popular':
        case 'new':
          return true;
        case 'animals':
          return pack.id.contains('animal');
        case 'emotions':
          return pack.id.contains('emotion');
        case 'food':
          return pack.id.contains('food');
        case 'celebration':
          return pack.id.contains('celebration');
        default:
          return false;
      }
    }).toList();

    if (filteredPacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No stickers found',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredPacks.length,
      itemBuilder: (context, index) {
        final pack = filteredPacks[index];
        final isInstalled = _installedPacks.any((p) => p.id == pack.id);
        return _buildPackCard(pack, isInstalled, isDark);
      },
    );
  }

  Widget _buildPackCard(StickerPack pack, bool isInstalled, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: context.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息
            Row(
              children: [
                // 贴纸包图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: pack.stickers.isNotEmpty
                        ? Text(
                            pack.stickers.first.emoji ?? '📦',
                            style: const TextStyle(fontSize: 28),
                          )
                        : const Icon(Icons.emoji_emotions),
                  ),
                ),
                const SizedBox(width: 12),

                // 名称和描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pack.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (pack.isOfficial) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      if (pack.author != null)
                        Text(
                          'by ${pack.author}',
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

                // 安装/已安装按钮
                if (isInstalled)
                  OutlinedButton(
                    onPressed: () => _uninstallPack(pack),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Remove'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _installPack(pack),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // 贴纸预览
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pack.previewStickers.length,
                itemBuilder: (context, index) {
                  final sticker = pack.previewStickers[index];
                  return Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        sticker.emoji ?? '?',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 统计信息
            Row(
              children: [
                Icon(
                  Icons.download,
                  size: 14,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pack.downloadCount}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.emoji_emotions_outlined,
                  size: 14,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pack.stickerCount} stickers',
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
          ],
        ),
      ),
    );
  }

  Widget _buildMyStickersTab(bool isDark) {
    if (_installedPacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No stickers installed',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get stickers from the store',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.store),
              label: const Text('Browse Store'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _installedPacks.length,
      itemBuilder: (context, index) {
        final pack = _installedPacks[index];
        return _buildPackCard(pack, true, isDark);
      },
    );
  }
}
