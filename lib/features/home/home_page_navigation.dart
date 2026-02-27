part of 'home_page.dart';

// ── Navigation widgets for HomePage ──────────────────────────────────────────

extension on _HomePageState {
  /// iPad 横屏侧边导航栏
  Widget buildNavigationRail(int currentIndex) {
    final selectedColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final unselectedColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index < 4) {
          ref.read(homeTabIndexProvider.notifier).state = index;
        } else {
          _navigateToChat();
        }
      },
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      selectedIconTheme: IconThemeData(color: selectedColor),
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      labelType: NavigationRailLabelType.all,
      leading: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Image.asset(
            "assets/img/menu.png",
            width: 24,
            color: selectedColor,
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/wallet.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/wallet.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_key_6),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/setting/mining.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/setting/mining.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_home_key3),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/earn.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/earn.png", width: 22, height: 22, color: selectedColor),
          label: const Text('Earn'),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/news.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/news.png", width: 22, height: 22, color: selectedColor),
          label: const Text('Market'),
        ),
        NavigationRailDestination(
          icon: Image.asset("assets/home/tabbar/chat.png", width: 22, height: 22, color: unselectedColor),
          selectedIcon: Image.asset("assets/home/tabbar/chat.png", width: 22, height: 22, color: selectedColor),
          label: Text(S.of(context).g_key_squad),
        ),
      ],
    );
  }

  /// 底部导航栏（手机和 iPad 竖屏）
  Widget buildBottomNavBar(BuildContext context) {
    final isWide = ResponsiveUtils.isTablet(context);
    // iPad 竖屏：使用固定高度，不依赖 ScreenUtil
    final barHeight = isWide ? 64.0 : ScreenUtil().setWidth(116.0);
    final iconSize = isWide ? 22.0 : ScreenUtil().setWidth(40.0);
    final fontSize = isWide ? 11.0 : ScreenUtil().setSp(20.0);
    final borderWidth = isWide ? 0.5 : ScreenUtil().setWidth(0.8);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: barHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              width: borderWidth,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name).withAlpha(80)),
        ),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(60)
                : Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBottomItem(
              S.of(context).g_key_6, 0, "assets/home/tabbar/wallet.png",
              _tabTwo, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              S.of(context).g_home_key3, 1, "assets/home/setting/mining.png",
              _tabThree, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              'Earn', 2, "assets/home/tabbar/earn.png",
              _tabFour, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildBottomItem(
              'Market', 3, "assets/home/tabbar/news.png",
              _tabSix, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
          _buildChatBottomItem(
              S.of(context).g_key_squad, "assets/home/tabbar/chat.png",
              _tabFive, 5,
              fixedIconSize: isWide ? iconSize : null,
              fixedFontSize: isWide ? fontSize : null),
        ],
      ),
    );
  }

  /// 构建聊天 Tab（点击跳转到独立页面）
  Widget _buildChatBottomItem(String title, String imagePath, GlobalKey key, int pagesLength,
      {double? fixedIconSize, double? fixedFontSize}) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    final iSize = fixedIconSize ?? ScreenUtil().setWidth(40.0);
    final fSize = fixedFontSize ?? ScreenUtil().setSp(20.0);
    final unselectedColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name).withAlpha(100);

    return InkWell(
      onTap: _navigateToChat,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        key: key,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(18),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Image.asset(
                imagePath,
                width: iSize,
                height: iSize,
                fit: BoxFit.cover,
                color: unselectedColor,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(1)),
            Text(
              title,
              style: TextStyle(
                fontSize: fSize,
                height: 1.2,
                fontWeight: FontWeight.w400,
                color: unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(String title, int index, String imagePath, GlobalKey key, int pagesLength,
      {double? fixedIconSize, double? fixedFontSize}) {
    double width = MediaQuery.of(context).size.width / pagesLength;
    final currentIndex = ref.watch(homeTabIndexProvider);
    final iSize = fixedIconSize ?? ScreenUtil().setWidth(40.0);
    final fSize = fixedFontSize ?? ScreenUtil().setSp(20.0);
    final isSelected = currentIndex == index;

    final selectedColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final unselectedColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainTextColor.name).withAlpha(100);

    return InkWell(
      onTap: () {
        if (index == currentIndex) return;
        ref.read(homeTabIndexProvider.notifier).state = index;
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        key: key,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(18),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withAlpha(22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              child: Image.asset(
                imagePath,
                width: iSize,
                height: iSize,
                fit: BoxFit.cover,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(1)),
            Text(
              title,
              style: TextStyle(
                fontSize: fSize,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
