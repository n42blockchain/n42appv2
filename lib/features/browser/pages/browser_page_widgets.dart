part of 'browser_page.dart';

/// UI widget builders for BrowserPage.
extension _BrowserPageWidgets on _BrowserPageState {
  Color _mainTextColor() => AppColorTokens.of(context).textPrimary;

  Widget _buildBrowserContent() {
    final bValue = ref.watch(browserNotifierProvider);
    return Column(
      children: [
        _buildAddressBar(bValue),
        Expanded(child: _buildWebViewArea(bValue)),
        _buildProgressIndicator(bValue),
        if (!bValue.showWList) _buildMainToolbar(bValue),
        if (bValue.showWList) _buildTabListToolbar(bValue),
      ],
    );
  }

  Widget _buildAddressBar(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;

    return Container(
      alignment: Alignment.center,
      // minHeight: lets the 44pt tab buttons fit on 320pt screens.
      constraints: BoxConstraints(minHeight: sw(100.0)),
      padding: EdgeInsets.only(top: sw(10.0), right: sw(20.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: textFieldStyle2(
              context,
              controller: bValue.titleEditingController,
              focusNode: bValue.titleFocusNode,
              height: sw(80.0),
              style: AppTypography.bodySm.copyWith(
                color: _mainTextColor(),
                fontWeight: bValue.titleFocusNode?.hasFocus ?? false
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              leftWidget: _buildSecurityIcon(bValue),
              maxLines: 1,
              boxShadow: const BoxShadow(
                color: Color(0x00101828),
                offset: Offset.zero,
                blurRadius: 0,
                spreadRadius: 0,
              ),
              onEditingComplete: () {
                bValue.loadRequest();
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          SizedBox(width: sw(10.0)),
          _buildAddTabButton(bValue),
          _buildTabCountButton(bValue),
        ],
      ),
    );
  }

  Widget _buildSecurityIcon(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;
    final idx = bValue.wListIndex;
    final DAppSecurityInfo? securityInfo;
    if (idx >= 0 && idx < bValue.wInfoList.length) {
      final url = bValue.wInfoList[idx]['openUrl'] as String? ?? '';
      securityInfo = (url.startsWith('http://') || url.startsWith('https://'))
          ? DAppSecurityService.check(url)
          : null;
    } else {
      securityInfo = null;
    }

    return Container(
      width: sw(30.0),
      height: sw(30.0),
      margin: EdgeInsets.only(right: sw(15.0)),
      child: DAppSecurityIcon(info: securityInfo, size: 24),
    );
  }

  Widget _buildAddTabButton(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;

    return AppTapArea(
      onTap: () {
        bValue.wListAdd();
      },
      tooltip: S.of(context).g_a11y_new_tab,
      child: Container(
        height: sw(60.0),
        width: sw(60.0),
        padding: EdgeInsets.all(sw(10.0)),
        child: Image.asset(
          "assets/browser/add.png",
          color: _mainTextColor(),
          width: sw(40.0),
          height: sw(40.0),
        ),
      ),
    );
  }

  Widget _buildTabCountButton(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;

    return AppTapArea(
      onTap: () {
        bValue.setShowWList(true);
      },
      tooltip: S.of(context).g_a11y_tabs,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sw(10.0)),
        height: sw(40),
        width: sw(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sw(12.0)),
          border: Border.all(width: sw(2.0), color: _mainTextColor()),
        ),
        child: Text(
          "${bValue.wvcList.length}",
          style: AppTypography.captionSm.copyWith(color: _mainTextColor()),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BrowserProvider bValue) {
    if (bValue.showWList || bValue.wListIndex == -1) {
      return const SizedBox.shrink();
    }
    final info = bValue.wInfoList[bValue.wListIndex];
    final isLoading = info['load'] ?? false;
    if (!isLoading) return const SizedBox.shrink();
    return LinearProgressIndicator(
      value: info['progress'] ?? 0,
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonBgColor3.name,
      ),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonBgColor.name,
      ),
    );
  }

  Widget _buildWebViewArea(BrowserProvider bValue) {
    if (bValue.showWList) return _buildTabGridView(bValue);
    if (bValue.wListIndex == -1) return EmptyView();
    final controller = bValue.wvcList[bValue.wListIndex];
    return KeyedSubtree(
      key: ValueKey('browser_webview_${controller.hashCode}'),
      child: WebViewWidget(controller: controller),
    );
  }

  Widget _buildMainToolbar(BrowserProvider bValue) {
    return Container(
      alignment: Alignment.center,
      height: AppTouch.scaled(100),
      child: _toolbarRow([
          _toolbarAssetButton(
            "close",
            tooltip: S.of(context).g_a11y_close,
            onTap: () => Navigator.pop(context),
          ),
          _toolbarAssetButton(
            "refresh",
            tooltip: S.of(context).g_key_bridge_refresh,
            onTap: () async {
              await bValue.wvcList[bValue.wListIndex].reload();
            },
          ),
          _toolbarAssetButton(
            "arrow-left",
            tooltip: S.of(context).g_key_nft_220,
            colorKey: bValue.canBack
                ? AppThemeKeys.mainTextColor.name
                : AppThemeKeys.itemBorderColor.name,
            onTap: bValue.canBack
                ? () async {
                    final wv = bValue.wvcList[bValue.wListIndex];
                    if (await wv.canGoBack()) {
                      await wv.goBack();
                    } else {
                      if (!mounted) return;
                      Navigator.pop(context);
                    }
                  }
                : null,
          ),
          _toolbarAssetButton(
            "arrow-right",
            tooltip: S.of(context).g_a11y_forward,
            colorKey: bValue.canForward
                ? AppThemeKeys.mainTextColor.name
                : AppThemeKeys.itemBorderColor.name,
            onTap: bValue.canForward
                ? () async {
                    final wv = bValue.wvcList[bValue.wListIndex];
                    if (await wv.canGoForward()) {
                      await wv.goForward();
                    }
                  }
                : null,
          ),
          _toolbarAssetButton(
            bValue.collect ? "star" : "star_border",
            tooltip: S.of(context).g_browser_key5,
            onTap: () {
              if (bValue.collect) {
                bValue.deleteBrowserCollectionUrl();
              } else {
                bValue.addBrowserCollection(context);
              }
            },
          ),
          _toolbarIconButton(
            Icons.history,
            tooltip: S.of(context).g_browser_key18,
            onTap: () => _navigateAndLoad(bValue, const BrowserHistoryPage()),
          ),
          _toolbarAssetButton(
            "note",
            tooltip: S.of(context).g_browser_key3,
            onTap: () => _navigateAndLoad(bValue, BrowserCollectionList()),
          ),
          if (Platform.isAndroid)
            _toolbarIconButton(
              Icons.explore,
              tooltip: S.of(context).g_browser_key24,
              onTap: () => _navigateAndLoad(bValue, const DAppDirectoryPage()),
            ),
          _toolbarAssetButton(
            "setting",
            tooltip: S.of(context).g_key_94,
            onTap: () async {
              final wv = bValue.wvcList[bValue.wListIndex];
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BrowserSetting(webViewController: wv),
                ),
              );
              if (!mounted) return;
              bValue.getBrowserSetting();
            },
          ),
          if (ref.watch(wcpBridgeProvider).walletConnectState ==
              WalletConnectState.connect)
            _buildWalletConnectButton(),
      ]),
    );
  }

  Widget _buildWalletConnectButton() {
    final sw = ScreenUtil().setWidth;
    return _toolbarButton(
      onTap: () => WalletConnectSheet.show(context, ""),
      tooltip: S.of(context).g_wc_sessions,
      child: Image.asset(
        "assets/wallet/WalletConnect.png",
        width: sw(40.0),
        height: sw(40.0),
        color: _mainTextColor(),
      ),
    );
  }

  Widget _buildTabListToolbar(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return Container(
      alignment: Alignment.center,
      height: AppTouch.scaled(100),
      child: Row(
        children: [
          _tabToolbarItem(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: sp(30.0)),
            onTap: () async {
              final confirmed = await AppDialog.confirm(
                context,
                title: S.of(context).g_browser_key16,
                message: S.of(context).g_ui3_close_all_tabs_confirm,
                confirmText: S.of(context).g_browser_key16,
                danger: true,
              );
              if (!confirmed || !mounted) return;
              bValue.cleanWList();
            },
            child: Text(
              S.of(context).g_browser_key16,
              style: AppTypography.bodySm.copyWith(
                color: _mainTextColor(),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          _tabToolbarItem(
            alignment: Alignment.center,
            onTap: () async {
              bValue.wListAdd();
            },
            child: Image.asset(
              "assets/browser/add.png",
              semanticLabel: S.of(context).g_a11y_new_tab,
              color: _mainTextColor(),
              width: sw(40.0),
              height: sw(40.0),
            ),
          ),
          _tabToolbarItem(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: sp(30.0)),
            onTap: () async {
              bValue.setShowWList(false);
            },
            child: Text(
              S.of(context).g_browser_key17,
              style: AppTypography.bodySm.copyWith(
                color: _mainTextColor(),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A single item in the tab list toolbar.
  Widget _tabToolbarItem({
    required AlignmentGeometry alignment,
    required VoidCallback onTap,
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    final sw = ScreenUtil().setWidth;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: alignment,
          height: AppTouch.target,
          margin: margin,
          // No vertical padding: alignment centers the label, and 130% text
          // no longer overflows the 44pt row.
          padding: EdgeInsets.symmetric(horizontal: sw(10.0)),
          child: child,
        ),
      ),
    );
  }

  /// Toolbar button with an asset image from `assets/browser/`.
  Widget _toolbarAssetButton(
    String assetName, {
    required String tooltip,
    VoidCallback? onTap,
    String? colorKey,
  }) {
    final sw = ScreenUtil().setWidth;
    final color = AppThemeUtils.getColorByKey(
      context,
      colorKey ?? AppThemeKeys.mainTextColor.name,
    );

    return _toolbarButton(
      onTap: onTap,
      tooltip: tooltip,
      child: Image.asset(
        "assets/browser/$assetName.png",
        color: color,
        width: sw(40.0),
        height: sw(40.0),
      ),
    );
  }

  /// Toolbar button with a Material icon.
  Widget _toolbarIconButton(
    IconData icon, {
    required String tooltip,
    VoidCallback? onTap,
  }) {
    final sw = ScreenUtil().setWidth;

    return _toolbarButton(
      onTap: onTap,
      tooltip: tooltip,
      child: Icon(icon, color: _mainTextColor(), size: sw(40.0)),
    );
  }

  /// Spreads toolbar buttons evenly, but never narrower than the 44pt minimum:
  /// when the screen is too narrow for that, the row scrolls horizontally.
  Widget _toolbarRow(List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = AppTouch.minTarget * buttons.length;
        if (constraints.maxWidth >= minWidth) {
          return Row(children: buttons);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minWidth,
            child: Row(children: buttons),
          ),
        );
      },
    );
  }

  /// Shared toolbar button layout used by both asset and icon variants.
  Widget _toolbarButton({
    VoidCallback? onTap,
    required String tooltip,
    required Widget child,
  }) {
    final sw = ScreenUtil().setWidth;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            // 44pt on every width (sw(80) is 40pt@375, 34pt@320).
            height: AppTouch.target,
            width: sw(60.0),
            padding: EdgeInsets.symmetric(
              horizontal: sw(10.0),
              vertical: sw(20.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
