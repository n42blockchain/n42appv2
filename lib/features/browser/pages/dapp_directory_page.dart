import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
    return switch (cat.key) {
      'popular' => s.g_browser_key25,
      'dex' => s.g_browser_key26,
      'defi' => s.g_browser_key27,
      'nft' => s.g_browser_key28,
      'bridge' => s.g_browser_key29,
      'tools' => s.g_browser_key30,
      _ => cat.labelEn,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_browser_key24),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final blueColor = AppColorTokens.of(context).brand;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColorTokens.of(context).border,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: blueColor,
        unselectedLabelColor: AppColorTokens.of(context).textSubtitle,
        labelStyle: AppTypography.bodyStrong.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.body.copyWith(
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: blueColor,
        indicatorWeight: 2,
        dividerHeight: 0,
        tabs: DAppCategory.all
            .map((cat) => Tab(text: _categoryLabel(cat)))
            .toList(),
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
          S.of(context).g_ui_no_dapps,
          style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      itemCount: dapps.length,
      itemBuilder: (context, index) {
        return _buildDAppItem(dapps[index]);
      },
    );
  }

  Widget _buildDAppItem(RecommendedDApp dapp) {
    final host = Uri.tryParse(dapp.url)?.host ?? dapp.url;
    final letter = dapp.name.isNotEmpty ? dapp.name[0].toUpperCase() : '?';
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final radius = ScreenUtil().setWidth(20);

    return InkWell(
      onTap: () => Navigator.pop(context, dapp.url),
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.space2),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space6,
          vertical: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: AppColorTokens.of(context).bgSurface,
        ),
        child: Row(
          children: [
            _buildAvatar(letter),
            SizedBox(width: AppSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _singleLineText(
                    dapp.name,
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  _singleLineText(
                    dapp.description,
                    style: AppTypography.caption.copyWith(color: subtitleColor),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  _singleLineText(
                    host,
                    style: AppTypography.caption.copyWith(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.ff888888.name,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: subtitleColor,
              size: ScreenUtil().setWidth(40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String letter) {
    return Container(
      width: ScreenUtil().setWidth(80),
      height: ScreenUtil().setWidth(80),
      decoration: BoxDecoration(
        color: _colorForLetter(letter),
        borderRadius: AppRadius.brMd,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTypography.headline.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _singleLineText(String text, {required TextStyle style}) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Generate a deterministic color from a letter for the avatar.
  Color _colorForLetter(String letter) {
    const colors = [
      Color(0xFF5E97F6), // Blue
      Color(0xFFEF4444), // Red
      Color(0xFF2ECC71), // Green
      Color(0xFFF7931A), // Orange
      Color(0xFF9B59B6), // Purple
      Color(0xFF1ABC9C), // Teal
      Color(0xFFE67E22), // Dark orange
      Color(0xFF3498DB), // Light blue
    ];
    final index = letter.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
