import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/browser/data/recommended_dapps.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// DApp discovery page showing categorized recommended DApps.
///
/// Returns the selected DApp URL via `Navigator.pop(context, url)`.
class DAppDirectoryPage extends StatefulWidget {
  const DAppDirectoryPage({super.key});

  @override
  State<DAppDirectoryPage> createState() => _DAppDirectoryPageState();
}

class _DAppDirectoryPageState extends State<DAppDirectoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: DAppCategory.all.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _categoryLabel(DAppCategory cat) {
    final s = S.of(context);
    switch (cat.key) {
      case 'popular':
        return s.g_browser_key25;
      case 'dex':
        return s.g_browser_key26;
      case 'defi':
        return s.g_browser_key27;
      case 'nft':
        return s.g_browser_key28;
      case 'bridge':
        return s.g_browser_key29;
      case 'tools':
        return s.g_browser_key30;
      default:
        return cat.labelEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_browser_key24,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
        unselectedLabelColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name),
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
        indicatorWeight: 2,
        dividerHeight: 0,
        tabs: DAppCategory.all.map((cat) {
          return Tab(text: _categoryLabel(cat));
        }).toList(),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: DAppCategory.all.map((cat) {
        final dapps = RecommendedDApps.byCategory(cat);
        return _buildDAppList(dapps);
      }).toList(),
    );
  }

  Widget _buildDAppList(List<RecommendedDApp> dapps) {
    if (dapps.isEmpty) {
      return Center(
        child: Text(
          'No DApps',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(16),
      ),
      itemCount: dapps.length,
      itemBuilder: (context, index) {
        return _buildDAppItem(dapps[index]);
      },
    );
  }

  Widget _buildDAppItem(RecommendedDApp dapp) {
    final host = Uri.tryParse(dapp.url)?.host ?? dapp.url;
    // First letter as avatar
    final letter = dapp.name.isNotEmpty ? dapp.name[0].toUpperCase() : '?';

    return InkWell(
      onTap: () {
        Navigator.pop(context, dapp.url);
      },
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(24),
          vertical: ScreenUtil().setWidth(20),
        ),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(20)),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
        ),
        child: Row(
          children: [
            // DApp icon placeholder (first letter)
            Container(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              decoration: BoxDecoration(
                color: _colorForLetter(letter),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            // DApp info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dapp.name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    dapp.description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    host,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.ff888888.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              size: ScreenUtil().setWidth(40),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate a deterministic color from a letter for the avatar.
  Color _colorForLetter(String letter) {
    const colors = [
      Color(0xFF5B8DEF), // Blue
      Color(0xFFE74C3C), // Red
      Color(0xFF2ECC71), // Green
      Color(0xFFF39C12), // Orange
      Color(0xFF9B59B6), // Purple
      Color(0xFF1ABC9C), // Teal
      Color(0xFFE67E22), // Dark orange
      Color(0xFF3498DB), // Light blue
    ];
    final index = letter.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
