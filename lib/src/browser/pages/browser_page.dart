import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/src/widgets/dapp_security_badge.dart';
import 'package:n42_wallet/src/browser/pages/browser_collection_list.dart';
import 'package:n42_wallet/src/browser/pages/browser_history_page.dart';
import 'package:n42_wallet/src/browser/pages/dapp_directory_page.dart';
import 'package:n42_wallet/src/browser/pages/browser_setting.dart';
import 'package:n42_wallet/src/browser/provider/browser_provider.dart';
import 'package:n42_wallet/src/browser/widgets/dapp_signing_sheet.dart';
import 'package:n42_wallet/features/browser/presentation/providers/browser_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/empty.dart';
import 'package:n42_wallet/src/widgets/prompt_widget.dart';
import 'package:n42_wallet/src/widgets/sheet_bottom.dart';
import 'package:n42_wallet/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';


class BrowserPage extends ConsumerStatefulWidget {
  final String openUrl;
  const BrowserPage(this.openUrl,{super.key});

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  BrowserProvider? _browserProvider;
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    // 延迟到首帧后再初始化，避免在构建阶段触发通知
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _browserProvider = ref.read(browserNotifierProvider);
      if (!_inited) {
        _inited = true;
        walletConnect();
      }
    });
  }

  @override
  void dispose() {
    // 使用缓存引用，避免在已卸载状态下通过 context 查找祖先
    _browserProvider?.connectDAPPCallBack = null;
    _browserProvider?.phishingCallBack = null;
    if (_browserProvider?.dappHandler != null) {
      _browserProvider!.dappHandler!.onSigningRequest = null;
    }
    _browserProvider?.browserDispose();
    super.dispose();
  }
  void walletConnect(){
    _browserProvider ??= ref.read(browserNotifierProvider);
    final bp = _browserProvider!;
    bp.connectDAPPCallBack = (String url, bool connect) {
      if (connect) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WalletConnectPage(url)));
      } else {
        showAlertWidgetConnectDapp(url);
      }
    };
    bp.phishingCallBack = (String url, VoidCallback proceed) {
      _showPhishingWarning(url, proceed);
    };

    // Initialize EIP-1193 DApp handler
    bp.initDAppHandler();
    if (bp.dappHandler != null) {
      bp.dappHandler!.onSigningRequest = _showDAppSigningSheet;
    }

    bp.browserInit();
    bp.addUrl(widget.openUrl);
  }

  /// Show a signing confirmation bottom sheet for DApp requests.
  /// Returns true if approved, false if rejected.
  Future<bool> _showDAppSigningSheet({
    required String origin,
    required String method,
    required Map<String, dynamic> details,
  }) async {
    // Resolve origin from current page URL
    final bp = _browserProvider;
    String displayOrigin = origin;
    if (bp != null && bp.wListIndex >= 0 && bp.wListIndex < bp.wInfoList.length) {
      final url = bp.wInfoList[bp.wListIndex]['openUrl'] as String? ?? '';
      displayOrigin = Uri.tryParse(url)?.host ?? origin;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(ctx, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(16.0))),
        ),
        child: SafeArea(
          child: DAppSigningSheet(
            origin: displayOrigin,
            method: method,
            details: details,
          ),
        ),
      ),
    );
    return result ?? false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: listWebViewWidget(),
        ),
      ),
    );
  }
  Widget listWebViewWidget(){
    final bValue = ref.watch(browserNotifierProvider);
    return Builder(builder: (context){
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: ScreenUtil().setWidth(100.0),
            padding: EdgeInsets.only(top:ScreenUtil().setWidth(10.0),right: ScreenUtil().setWidth(20.0)),
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
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(26.0),
                      fontWeight: bValue.titleFocusNode?.hasFocus??false?FontWeight.bold:FontWeight.normal,
                    ),
                    leftWidget: Container(
                      width: ScreenUtil().setWidth(30.0),
                      height: ScreenUtil().setWidth(30.0),
                      margin: EdgeInsets.only(right:ScreenUtil().setWidth(15.0)),
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
                    ),
                    maxLines: 1,
                    boxShadow:BoxShadow(
                      color: Color(0x00101828),  //底色,阴影颜色(透明)
                      offset: Offset.zero,
                      blurRadius: 0,
                      spreadRadius: 0, ),
                    onEditingComplete: (){
                      bValue.loadRequest();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10.0),),
                InkWell(
                  onTap: (){
                    bValue.wListAdd();
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(60.0),
                    width: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                    child: Image.asset(
                      "assets/browser/add.png",
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      width: ScreenUtil().setWidth(40.0),
                      height: ScreenUtil().setWidth(40.0),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    bValue.setShowWList(true);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(40),
                    width: ScreenUtil().setWidth(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12.0)),
                      border: Border.all(width:ScreenUtil().setWidth(2.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),),
                    ),
                    child: Text(
                      "${bValue.wList.length}",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: webViewWidget(bValue),
          ),
          if(bValue.showWList==false && bValue.wListIndex !=-1)
            if(bValue.wInfoList[bValue.wListIndex]['load']??false)
            LinearProgressIndicator(
              value: bValue.wInfoList[bValue.wListIndex]['progress']??0,
              backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
          if (!bValue.showWList)
            Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  _toolbarAssetButton("close", onTap: () => Navigator.pop(context)),
                  _toolbarAssetButton("refresh", onTap: () async {
                    await bValue.wvcList[bValue.wListIndex].reload();
                  }),
                  _toolbarAssetButton(
                    "arrow-left",
                    colorKey: bValue.canBack ? AppThemeKeys.mainTextColor.name : AppThemeKeys.itemBorderColor.name,
                    onTap: bValue.canBack ? () async {
                      final wv = bValue.wvcList[bValue.wListIndex];
                      if (await wv.canGoBack()) {
                        await wv.goBack();
                      } else {
                        if (!mounted) return;
                        Navigator.pop(this.context);
                      }
                    } : null,
                  ),
                  _toolbarAssetButton(
                    "arrow-right",
                    colorKey: bValue.canForward ? AppThemeKeys.mainTextColor.name : AppThemeKeys.itemBorderColor.name,
                    onTap: bValue.canForward ? () async {
                      final wv = bValue.wvcList[bValue.wListIndex];
                      if (await wv.canGoForward()) {
                        await wv.goForward();
                      }
                    } : null,
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
                  _toolbarIconButton(Icons.history, onTap: () => _navigateAndLoad(bValue, const BrowserHistoryPage())),
                  _toolbarAssetButton("note", onTap: () => _navigateAndLoad(bValue, BrowserCollectionList())),
                  _toolbarIconButton(Icons.explore, onTap: () => _navigateAndLoad(bValue, const DAppDirectoryPage())),
                  _toolbarAssetButton("setting", onTap: () async {
                    final wv = bValue.wvcList[bValue.wListIndex];
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => BrowserSetting(webViewController: wv)));
                    bValue.getBrowserSetting();
                  }),
                ],
              ),
            ),
          if(bValue.showWList)
            Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.cleanWList();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: ScreenUtil().setWidth(80.0),
                        margin: EdgeInsets.only(left: ScreenUtil().setSp(30.0)),
                        child: Text(
                          S.of(context).g_browser_key16,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.wListAdd();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: ScreenUtil().setWidth(80.0),
                        width: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Image.asset(
                          "assets/browser/add.png",
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          width: ScreenUtil().setWidth(40.0),
                          height: ScreenUtil().setWidth(40.0),
                        ),
                      ),
                    ),),
                  Expanded(
                    child: InkWell(
                      onTap: ()async{
                        bValue.setShowWList(false);
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        height: ScreenUtil().setWidth(80.0),
                        margin: EdgeInsets.only(right: ScreenUtil().setSp(30.0)),
                        child: Text(
                          S.of(context).g_browser_key17,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
        ],
      );
    });
  }
  Widget webViewWidget(BrowserProvider bValue){
    if(bValue.showWList){
      return GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0),
          vertical: ScreenUtil().setWidth(16.0),
        ),
        itemCount: bValue.wList.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: ScreenUtil().setWidth(30),
          mainAxisSpacing: ScreenUtil().setWidth(30),
        ),
        itemBuilder: (context,int index){
          final isActive = index == bValue.wListIndex;
          final title = bValue.wInfoList[index]['title'] as String? ?? '';
          final openUrl = bValue.wInfoList[index]['openUrl'] as String? ?? '';
          final host = Uri.tryParse(openUrl)?.host ?? '';
          // First letter of host as favicon placeholder
          final letter = host.isNotEmpty
              ? host.replaceFirst('www.', '')[0].toUpperCase()
              : '?';

          return Dismissible(
            key: ValueKey('tab_${bValue.wvcList[index].hashCode}'),
            direction: DismissDirection.up,
            onDismissed: (_) {
              bValue.wListDelete(index);
            },
            background: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(50),
              ),
            ),
            child: GestureDetector(
              onTap: (){
                bValue.wListShow(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24.0)),
                  border: Border.all(
                    width: isActive ? ScreenUtil().setWidth(3.0) : ScreenUtil().setWidth(1.5),
                    color: AppThemeUtils.getColorByKey(context, isActive?AppThemeKeys.mainBlueColor.name:AppThemeKeys.itemLineColor.name),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // WebView preview
                    Positioned.fill(
                      child: IgnorePointer(
                        child: bValue.wList[index],
                      ),
                    ),
                    // Overlay to intercept taps
                    Positioned.fill(
                      child: Container(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.transparentBgColor.name),
                      ),
                    ),
                    // Header bar with title, host, close button
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(8.0),
                          horizontal: ScreenUtil().setWidth(12.0),
                        ),
                        child: Row(
                          children: [
                            // Favicon placeholder
                            Container(
                              width: ScreenUtil().setWidth(32),
                              height: ScreenUtil().setWidth(32),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            // Title + host
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title.isNotEmpty ? title : host,
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      fontSize: ScreenUtil().setSp(20.0),
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (title.isNotEmpty && host.isNotEmpty)
                                    Text(
                                      host,
                                      style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                        fontSize: ScreenUtil().setSp(16.0),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            // Close button
                            GestureDetector(
                              onTap: (){
                                bValue.wListDelete(index);
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(36.0),
                                height: ScreenUtil().setWidth(36.0),
                                padding: EdgeInsets.all(ScreenUtil().setWidth(4.0)),
                                child: Image.asset(
                                  "assets/browser/close.png",
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                  width: ScreenUtil().setWidth(28.0),
                                  height: ScreenUtil().setWidth(28.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    else{
      if(bValue.wListIndex==-1){
        return EmptyView();
      }
      return bValue.wList[bValue.wListIndex];
    }
  }
  /// Show a phishing warning dialog and, if the user accepts the risk,
  /// invoke [proceed] to whitelist the URL and retry navigation.
  void _showPhishingWarning(String url, VoidCallback proceed) {
    showPhishingWarningDialog(context, url).then((approved) {
      if (approved == true) {
        proceed();
      }
    });
  }

  /// Push a page and load the returned URL into the current WebView tab.
  Future<void> _navigateAndLoad(BrowserProvider bValue, Widget page) async {
    final url = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => page));
    if (url != null) {
      bValue.wvcList[bValue.wListIndex].loadRequest(Uri.parse(url));
    }
  }

  /// Toolbar button with an asset image from `assets/browser/`.
  Widget _toolbarAssetButton(String assetName, {VoidCallback? onTap, String? colorKey}) {
    final color = AppThemeUtils.getColorByKey(context, colorKey ?? AppThemeKeys.mainTextColor.name);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(80.0),
          width: ScreenUtil().setWidth(60.0),
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0), vertical: ScreenUtil().setWidth(20.0)),
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
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10.0), vertical: ScreenUtil().setWidth(20.0)),
          child: Icon(
            icon,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            size: ScreenUtil().setWidth(40.0),
          ),
        ),
      ),
    );
  }

  void showAlertWidgetConnectDapp(String uri) {
    sheetBottom(context, S.of(context).g_browser_key14, Column(
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
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              IconButton(
                onPressed: (){
                  ToastUtils.init(context);
                  Clipboard.setData(ClipboardData(
                      text: uri));
                  //toast 已经复制
                  ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                },
                icon: Icon(Icons.copy,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
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
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(88),
          child: Row(
            children: [
              Expanded(child: buttonStyle1(context, (){
                Navigator.pop(context);
              }, S.of(context).g_key_79),),
              SizedBox(width: ScreenUtil().setWidth(30),),
              Expanded(child: buttonStyle2(context, ()async{
                Navigator.pop(context);
              }, S.of(context).g_key_78),),
            ],
          ),
        ),
      ],
    ));
  }
}
