part of 'browser_page.dart';

/// UI widget builders for BrowserPage.
extension _BrowserPageWidgets on _BrowserPageState {
  Widget _buildBrowserContent() {
    final bValue = ref.watch(browserNotifierProvider);
    return Builder(builder: (context) {
      return Column(
        children: [
          _buildAddressBar(bValue),
          Expanded(flex: 1, child: _buildWebViewArea(bValue)),
          _buildProgressIndicator(bValue),
          if (!bValue.showWList) _buildMainToolbar(bValue),
          if (bValue.showWList) _buildTabListToolbar(bValue),
        ],
      );
    });
  }

  Widget _buildAddressBar(BrowserProvider bValue) {
    return Container(
      alignment: Alignment.center,
      height: ScreenUtil().setWidth(100.0),
      padding: EdgeInsets.only(
          top: ScreenUtil().setWidth(10.0),
          right: ScreenUtil().setWidth(20.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: textFieldStyle2(
              context,
              controller: bValue.titleEditingController,
              focusNode: bValue.titleFocusNode,
              height: ScreenUtil().setWidth(80.0),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setWidth(26.0),
                fontWeight: bValue.titleFocusNode?.hasFocus ?? false
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              leftWidget: _buildSecurityIcon(bValue),
              maxLines: 1,
              boxShadow: BoxShadow(
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
          SizedBox(width: ScreenUtil().setWidth(10.0)),
          _buildAddTabButton(bValue),
          _buildTabCountButton(bValue),
        ],
      ),
    );
  }

  Widget _buildSecurityIcon(BrowserProvider bValue) {
    return Container(
      width: ScreenUtil().setWidth(30.0),
      height: ScreenUtil().setWidth(30.0),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(15.0)),
      child: DAppSecurityIcon(
        info: (() {
          final idx = bValue.wListIndex;
          if (idx < 0 || idx >= bValue.wInfoList.length) return null;
          final url = bValue.wInfoList[idx]['openUrl'] as String? ?? '';
          if (url.startsWith('http://') || url.startsWith('https://')) {
            return DAppSecurityService.check(url);
          }
          return null;
        })(),
        size: 24,
      ),
    );
  }

  Widget _buildAddTabButton(BrowserProvider bValue) {
    return InkWell(
      onTap: () { bValue.wListAdd(); },
      child: Container(
        height: ScreenUtil().setWidth(60.0),
        width: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
        child: Image.asset(
          "assets/browser/add.png",
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          width: ScreenUtil().setWidth(40.0),
          height: ScreenUtil().setWidth(40.0),
        ),
      ),
    );
  }

  Widget _buildTabCountButton(BrowserProvider bValue) {
    return InkWell(
      onTap: () { bValue.setShowWList(true); },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0)),
        height: ScreenUtil().setWidth(40),
        width: ScreenUtil().setWidth(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12.0)),
          border: Border.all(
            width: ScreenUtil().setWidth(2.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        child: Text(
          "${bValue.wList.length}",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(20.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BrowserProvider bValue) {
    if (bValue.showWList || bValue.wListIndex == -1) return SizedBox.shrink();
    final isLoading = bValue.wInfoList[bValue.wListIndex]['load'] ?? false;
    if (!isLoading) return SizedBox.shrink();
    return LinearProgressIndicator(
      value: bValue.wInfoList[bValue.wListIndex]['progress'] ?? 0,
      backgroundColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainButtonBgColor3.name),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainButtonBgColor.name),
    );
  }

  Widget _buildWebViewArea(BrowserProvider bValue) {
    if (bValue.showWList) {
      return _buildTabGridView(bValue);
    }
    if (bValue.wListIndex == -1) {
      return EmptyView();
    }
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
    return Container(
      alignment: Alignment.center,
      height: ScreenUtil().setWidth(100.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async { bValue.cleanWList(); },
              child: Container(
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setWidth(80.0),
                margin: EdgeInsets.only(left: ScreenUtil().setSp(30.0)),
                child: Text(
                  S.of(context).g_browser_key16,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async { bValue.wListAdd(); },
              child: Container(
                alignment: Alignment.center,
                height: ScreenUtil().setWidth(80.0),
                width: ScreenUtil().setWidth(60.0),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(10.0),
                    vertical: ScreenUtil().setWidth(20.0)),
                child: Image.asset(
                  "assets/browser/add.png",
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async { bValue.setShowWList(false); },
              child: Container(
                alignment: Alignment.centerRight,
                height: ScreenUtil().setWidth(80.0),
                margin: EdgeInsets.only(right: ScreenUtil().setSp(30.0)),
                child: Text(
                  S.of(context).g_browser_key17,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toolbar button with an asset image from `assets/browser/`.
  Widget _toolbarAssetButton(String assetName,
      {VoidCallback? onTap, String? colorKey}) {
    final color = AppThemeUtils.getColorByKey(
        context, colorKey ?? AppThemeKeys.mainTextColor.name);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(80.0),
          width: ScreenUtil().setWidth(60.0),
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10.0),
              vertical: ScreenUtil().setWidth(20.0)),
          child: Image.asset(
            "assets/browser/$assetName.png",
            color: color,
            width: ScreenUtil().setWidth(40.0),
            height: ScreenUtil().setWidth(40.0),
          ),
        ),
      ),
    );
  }

  /// Toolbar button with a Material icon.
  Widget _toolbarIconButton(IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(80.0),
          width: ScreenUtil().setWidth(60.0),
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10.0),
              vertical: ScreenUtil().setWidth(20.0)),
          child: Icon(
            icon,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            size: ScreenUtil().setWidth(40.0),
          ),
        ),
      ),
    );
  }

  void _showAlertWidgetConnectDapp(String uri) {
    sheetBottom(
      context,
      S.of(context).g_browser_key14,
      Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Uri",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
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
            padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
            alignment: Alignment.centerLeft,
            child: Text(
              uri,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(88),
            child: Row(
              children: [
                Expanded(
                  child: buttonStyle1(context, () {
                    Navigator.pop(context);
                  }, S.of(context).g_key_79),
                ),
                SizedBox(width: ScreenUtil().setWidth(30)),
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
