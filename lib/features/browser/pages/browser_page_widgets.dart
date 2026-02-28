part of 'browser_page.dart';

/// UI widget builders for BrowserPage.
extension _BrowserPageWidgets on _BrowserPageState {
  Color _mainTextColor() => AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainTextColor.name,
      );

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
      height: sw(100.0),
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
              style: TextStyle(
                color: _mainTextColor(),
                fontSize: sw(26.0),
                fontWeight: bValue.titleFocusNode?.hasFocus ?? false
                    ? FontWeight.bold
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

    return InkWell(
      onTap: () { bValue.wListAdd(); },
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
    final sp = ScreenUtil().setSp;

    return InkWell(
      onTap: () { bValue.setShowWList(true); },
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
          "${bValue.wList.length}",
          style: TextStyle(fontSize: sp(20.0), color: _mainTextColor()),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BrowserProvider bValue) {
    if (bValue.showWList || bValue.wListIndex == -1) return const SizedBox.shrink();
    final info = bValue.wInfoList[bValue.wListIndex];
    final isLoading = info['load'] ?? false;
    if (!isLoading) return const SizedBox.shrink();
    return LinearProgressIndicator(
      value: info['progress'] ?? 0,
      backgroundColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainButtonBgColor3.name),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainButtonBgColor.name),
    );
  }

  Widget _buildWebViewArea(BrowserProvider bValue) {
    if (bValue.showWList) return _buildTabGridView(bValue);
    if (bValue.wListIndex == -1) return EmptyView();
    return bValue.wList[bValue.wListIndex];
  }

  Widget _buildMainToolbar(BrowserProvider bValue) {
    return Container(
      alignment: Alignment.center,
      height: ScreenUtil().setWidth(100.0),
      child: Row(
        children: [
          _toolbarAssetButton("close",
              onTap: () => Navigator.pop(context)),
          _toolbarAssetButton("refresh", onTap: () async {
            await bValue.wvcList[bValue.wListIndex].reload();
          }),
          _toolbarAssetButton(
            "arrow-left",
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
            onTap: () {
              if (bValue.collect) {
                bValue.deleteBrowserCollectionUrl();
              } else {
                bValue.addBrowserCollection(context);
              }
            },
          ),
          _toolbarIconButton(Icons.history,
              onTap: () =>
                  _navigateAndLoad(bValue, const BrowserHistoryPage())),
          _toolbarAssetButton("note",
              onTap: () =>
                  _navigateAndLoad(bValue, BrowserCollectionList())),
          _toolbarIconButton(Icons.explore,
              onTap: () =>
                  _navigateAndLoad(bValue, const DAppDirectoryPage())),
          _toolbarAssetButton("setting", onTap: () async {
            final wv = bValue.wvcList[bValue.wListIndex];
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => BrowserSetting(webViewController: wv)));
            bValue.getBrowserSetting();
          }),
        ],
      ),
    );
  }

  Widget _buildTabListToolbar(BrowserProvider bValue) {
    final sw = ScreenUtil().setWidth;
    final sp = ScreenUtil().setSp;

    return Container(
      alignment: Alignment.center,
      height: sw(100.0),
      child: Row(
        children: [
          _tabToolbarItem(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: sp(30.0)),
            onTap: () async { bValue.cleanWList(); },
            child: Text(
              S.of(context).g_browser_key16,
              style: TextStyle(fontSize: sp(26.0), color: _mainTextColor()),
            ),
          ),
          _tabToolbarItem(
            alignment: Alignment.center,
            onTap: () async { bValue.wListAdd(); },
            child: Image.asset(
              "assets/browser/add.png",
              color: _mainTextColor(),
              width: sw(40.0),
              height: sw(40.0),
            ),
          ),
          _tabToolbarItem(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: sp(30.0)),
            onTap: () async { bValue.setShowWList(false); },
            child: Text(
              S.of(context).g_browser_key17,
              style: TextStyle(fontSize: sp(26.0), color: _mainTextColor()),
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
          height: sw(80.0),
          margin: margin,
          padding: EdgeInsets.symmetric(
            horizontal: sw(10.0),
            vertical: sw(20.0),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Toolbar button with an asset image from `assets/browser/`.
  Widget _toolbarAssetButton(String assetName,
      {VoidCallback? onTap, String? colorKey}) {
    final sw = ScreenUtil().setWidth;
    final color = AppThemeUtils.getColorByKey(
        context, colorKey ?? AppThemeKeys.mainTextColor.name);

    return _toolbarButton(
      onTap: onTap,
      child: Image.asset(
        "assets/browser/$assetName.png",
        color: color,
        width: sw(40.0),
        height: sw(40.0),
      ),
    );
  }

  /// Toolbar button with a Material icon.
  Widget _toolbarIconButton(IconData icon, {VoidCallback? onTap}) {
    final sw = ScreenUtil().setWidth;

    return _toolbarButton(
      onTap: onTap,
      child: Icon(icon, color: _mainTextColor(), size: sw(40.0)),
    );
  }

  /// Shared toolbar button layout used by both asset and icon variants.
  Widget _toolbarButton({VoidCallback? onTap, required Widget child}) {
    final sw = ScreenUtil().setWidth;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          height: sw(80.0),
          width: sw(60.0),
          padding: EdgeInsets.symmetric(
            horizontal: sw(10.0),
            vertical: sw(20.0),
          ),
          child: child,
        ),
      ),
    );
  }

  void _showAlertWidgetConnectDapp(String uri) {
    final sp = ScreenUtil().setSp;
    final sw = ScreenUtil().setWidth;

    sheetBottom(
      context,
      S.of(context).g_browser_key14,
      Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: sw(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Uri",
                  style: TextStyle(
                    fontSize: sp(28),
                    color: _mainTextColor(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: uri));
                    ToastUtils.showFtToast(
                        child: successViewV1(S.of(context).copy), duration: 3);
                  },
                  icon: Icon(Icons.copy,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: sw(30)),
            alignment: Alignment.centerLeft,
            child: Text(
              uri,
              style: TextStyle(
                fontSize: sp(28),
                color: _mainTextColor(),
              ),
            ),
          ),
          SizedBox(
            height: sw(88),
            child: Row(
              children: [
                Expanded(
                  child: buttonStyle1(context, () {
                    Navigator.pop(context);
                  }, S.of(context).g_key_79),
                ),
                SizedBox(width: sw(30)),
                Expanded(
                  child: buttonStyle2(context, () async {
                    Navigator.pop(context);
                  }, S.of(context).g_key_78),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
