import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/mini_app_entity.dart';
import '../../helpers/mini_app_launcher_helper.dart';

/// Mini App 市场页面
///
/// 展示内置和第三方 Mini App，用户可从聊天室内直接启动 DApps。
/// 这是 N42 对标 Telegram Mini App 的核心功能入口。
class MiniAppMarketPage extends StatefulWidget {
  /// 当前聊天室 ID（传给 Mini App Bridge）
  final String roomId;
  final MiniAppCategory? initialCategory;

  const MiniAppMarketPage({
    super.key,
    required this.roomId,
    this.initialCategory,
  });

  @override
  State<MiniAppMarketPage> createState() => _MiniAppMarketPageState();
}

class _MiniAppMarketPageState extends State<MiniAppMarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static final List<MiniAppCategory?> _categories = [
    null, // All
    ...MiniAppCategory.values,
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialCategory == null
        ? 0
        : _categories.indexOf(widget.initialCategory);
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          l10n?.miniAppMarketTitle ?? 'Mini Apps',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
          tabs: [
            Tab(text: l10n?.miniAppCategoryAll ?? 'All'),
            ...MiniAppCategory.values.map((c) => Tab(text: c.label)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.miniAppSearch ?? 'Search apps...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          // Featured Banner（仅 All 标签展示）
          TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildAppList(category, isDark, l10n);
            }).toList(),
          ).expanded(),
        ],
      ),
    );
  }

  Widget _buildAppList(MiniAppCategory? category, bool isDark, S? l10n) {
    var apps = category == null
        ? BuiltInMiniApps.all
        : BuiltInMiniApps.byCategory(category);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      apps = apps
          .where(
            (a) =>
                a.name.toLowerCase().contains(q) ||
                a.description.toLowerCase().contains(q),
          )
          .toList();
    }

    if (apps.isEmpty) {
      return Center(
        child: Text(
          l10n?.miniAppNoResults ?? 'No apps found',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Featured section (only on All tab)
        if (category == null && _searchQuery.isEmpty) ...[
          _buildFeaturedSection(isDark, l10n),
          const SizedBox(height: 20),
          Text(
            l10n?.miniAppAllApps ?? 'All Apps',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...apps.map(
          (app) => _AppListTile(
            app: app,
            isDark: isDark,
            onTap: () => _openApp(app),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(bool isDark, S? l10n) {
    final featured = BuiltInMiniApps.featured;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.miniAppFeatured ?? 'Featured',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _FeaturedCard(
              app: featured[index],
              isDark: isDark,
              onTap: () => _openApp(featured[index]),
            ),
          ),
        ),
      ],
    );
  }

  void _openApp(MiniAppEntity app) {
    unawaited(
      MiniAppLauncherHelper.openApp<void>(
        context,
        app: app,
        roomId: widget.roomId,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AppListTile extends StatelessWidget {
  final MiniAppEntity app;
  final bool isDark;
  final VoidCallback onTap;

  const _AppListTile({
    required this.app,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // App 图标
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _categoryColor(app.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(app.category),
                  color: _categoryColor(app.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (app.isBuiltIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Official',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (app.userCount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCount(app.userCount!)} users',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _FeaturedCard extends StatelessWidget {
  final MiniAppEntity app;
  final bool isDark;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.app,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _categoryColor(app.category).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _categoryIcon(app.category),
                color: _categoryColor(app.category),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              app.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              app.category.label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _categoryColor(MiniAppCategory category) => switch (category) {
  MiniAppCategory.defi => Colors.blue,
  MiniAppCategory.nft => Colors.deepPurple,
  MiniAppCategory.commerce => Colors.amber,
  MiniAppCategory.games => Colors.orange,
  MiniAppCategory.tools => Colors.teal,
  MiniAppCategory.social => Colors.pink,
  MiniAppCategory.finance => Colors.green,
};

IconData _categoryIcon(MiniAppCategory category) => switch (category) {
  MiniAppCategory.defi => Icons.swap_horiz_rounded,
  MiniAppCategory.nft => Icons.image_outlined,
  MiniAppCategory.commerce => Icons.storefront_outlined,
  MiniAppCategory.games => Icons.sports_esports_outlined,
  MiniAppCategory.tools => Icons.build_outlined,
  MiniAppCategory.social => Icons.people_outlined,
  MiniAppCategory.finance => Icons.account_balance_wallet_outlined,
};

extension on Widget {
  Widget expanded() => Expanded(child: this);
}
