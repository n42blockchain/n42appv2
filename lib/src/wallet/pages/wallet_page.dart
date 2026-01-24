import 'dart:math';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/pay/moonpay/moonpay.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_chain_add.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/payment_page.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/set_amount.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_chain_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_chain_info_xrp.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/widgets/create_wallet_button.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_board.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_search_coin.dart';
import 'package:n42appv2/src/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  late ScrollController _scrollController;
  bool showAddTokenButton = false; //显示底部添加代币按钮
  setShowAddTokenButton(bool value) {
    if (showAddTokenButton == value) return;
    setState(() {
      showAddTokenButton = value;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<WalletActionProvider>(context,listen: false).initWallet(initCoinInfo:true);
    /*if(AppGlobals.userInfo==null){
      Provider.of<WalletActionProvider>(context,listen: false).initWallet(initCoinInfo:true);
    }else{
      Timer(Duration(seconds: 1),(){
        eventBus.fire(EventPublic(EventPublicType.selectWallet,
            intValue: 1));
      });
    }*/
    _scrollController = ScrollController()
      ..addListener(() {
        var maxScroll = _scrollController.position.maxScrollExtent;
        var pixel = _scrollController.position.pixels;
        if (maxScroll - pixel < 50) {
          setShowAddTokenButton(true);
        } else {
          setShowAddTokenButton(false);
        }
      });
    super.initState();
  }

  walletConnect() async {
    WalletConnectProvider walletConnectProvider=Provider.of<WalletConnectProvider>(context,listen: false);
    if (walletConnectProvider.walletConnectState ==
        WalletConnectState.disconnect ||
        walletConnectProvider.walletConnectState ==
            WalletConnectState.loading ||
        walletConnectProvider.walletConnectState ==
            WalletConnectState.connectOK) {
      String scanStr = await scan();
      if (!mounted) return;
      if (scanStr.contains('relay-protocol') && scanStr.contains('symKey')) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletConnectPage(scanStr)));
        if (!mounted) return;
        walletConnectProvider.refresh();
      } else {
        if (scanStr != ""){
          int index=scanStr.indexOf(AppConfig.apiUrl['walletamazeBrowser']);
          if(index !=-1){
            Uri uri=Uri.parse(scanStr);
            final Map<String, dynamic> params = uri.queryParameters;
            if (params['type'] !=null) {
              if(params["type"]=="payment"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentPage(params["amount"],params["user"],params["coinType"],params["address"])));
              }
              return;
            }
          }
          //ToastUtils.show(S.of(context).g_key_203);
        }
      }
    } else {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => WalletConnectPage("")));
      if (!mounted) return;
      walletConnectProvider.refresh();
    }
  }
  //扫码
  scan() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      return scanValue;
    } else {
      return "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WalletActionProvider>(
          builder: (context, waValue, child){
            if(waValue.walletIndex==-1) {
              return Loading();
            }
            if(waValue.buildwallet) {
              return Loading();
            }
            return Stack(
              children: [
                /*Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: ScreenUtil().setWidth(630.0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.backGroundColor2.name),
                    height: double.infinity,
                    child: Image.asset(
                      'assets/wallet/wallet_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),*/
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        AppHomeTopBar(
                          //title: S.of(context).g_key_6,
                          titleChild: InkWell(
                            onTap: (){
                              showChangeAddress();
                            },
                            child: SizedBox(
                              height: ScreenUtil().setWidth(60),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    waValue.WalletName,
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      fontSize: ScreenUtil().setSp(30),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(40),
                                    width: ScreenUtil().setWidth(40),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      size: ScreenUtil().setWidth(40),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onLeftImageClick: () {
                            Scaffold.of(this.context).openDrawer();
                          },
                          onLeftImageUri: "assets/img/menu.png",
                          actions: [
                            // QR Code 图标 - 扫描和显示二维码
                            PopupMenuButton<int>(
                              icon: Icon(
                                Icons.qr_code_rounded,
                                size: ScreenUtil().setWidth(52.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainBlueColor.name),
                              ),
                              offset: Offset(0, ScreenUtil().setWidth(80)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                              ),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                              onSelected: (value) async {
                                if (value == 0) {
                                  // 扫描二维码
                                  walletConnect();
                                } else if (value == 1) {
                                  // 显示我的二维码（接收）
                                  showSearchCoin(1);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        size: ScreenUtil().setWidth(40),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      ),
                                      SizedBox(width: ScreenUtil().setWidth(20)),
                                      Text(
                                        S.of(context).g_key_4,  // Scan QR code
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code,
                                        size: ScreenUtil().setWidth(40),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      ),
                                      SizedBox(width: ScreenUtil().setWidth(20)),
                                      Text(
                                        S.of(context).g_key_33,  // Receive
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Consumer<WalletConnectProvider>(builder: (context,wc,child){
                              return InkWell(
                                onTap: () {
                                  walletConnect();
                                },
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(60.0),
                                  height: ScreenUtil().setWidth(60.0),
                                  child: (wc.walletConnectState !=
                                      WalletConnectState.disconnect &&
                                      wc.dAppTopic != null)
                                      ? ImageNetWork(
                                    imageUrl:wc.metadata!.icons.isEmpty
                                        ? ""
                                        : wc.metadata!.icons[0],
                                    placeholder: "assets/img/list_default.png",
                                  )
                                      : Image.asset(
                                    "assets/wallet/WalletConnect.png",
                                    color: AppThemeUtils.getColorByKey(
                                        context,
                                        AppThemeKeys.mainBlueColor.name),
                                  ),
                                ),
                              );
                            }),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => FaceUserNotice()));
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(40.0),
                                height: ScreenUtil().setWidth(40.0),
                                margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
                                //padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                                child: Image.asset(
                                  "assets/face/portrait.png",
                                  color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.mainBlueColor.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ///下拉刷新操作
                              if (waValue.load == Load.refresh ||
                                  waValue.load == Load.loading) {
                                return;
                              }
                              await waValue.refreshWalletCoinInfo();
                            },
                            backgroundColor: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainButtonBgColor.name),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainButtonTextColor.name),
                            displacement: 72,
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: false,
                              primary: false,
                              slivers: <Widget>[
                                //钱包看板
                                SliverToBoxAdapter(
                                  // margin: const EdgeInsets.symmetric(
                                  //   horizontal: 30,
                                  //   vertical: 30,
                                  // ),
                                  child: WalletBoard(
                                      accountPrice: waValue.balanceTotal,
                                      walletName: waValue.WalletName,
                                      sendTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await TipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          showSearchCoin(0);
                                        }
                                      },
                                      receiveTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await TipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          showSearchCoin(1);
                                        }
                                      },
                                      swapTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await TipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SwapAstHome()));
                                        }
                                      },
                                      paymentCodeTap: () async{
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SetAmount()));
                                      },
                                      buyTap:()async{
                                        Navigator.push(context, MaterialPageRoute(builder: (content)=>Moonpay(type:0)));
                                      },
                                      sellTap:()async{
                                        Navigator.push(context, MaterialPageRoute(builder: (content)=>Moonpay(type:1)));
                                      },
                                    ),
                                ),
                                coinListHeaderWidget(waValue),
                                coinListWidget(waValue),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: ScreenUtil().setWidth(300.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
                Positioned(
                  bottom: ScreenUtil().setWidth(180.0),
                  left: 0,
                  right: 0,
                  height: ScreenUtil().setWidth(70.0),
                  child: Visibility(
                    visible: showAddTokenButton,
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          showAddToken();
                        },
                        child: addIcon(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: ScreenUtil().setWidth(120.0),
                  left: ScreenUtil().setWidth(30.0),
                  right: ScreenUtil().setWidth(30.0),
                  child: Visibility(
                    visible: waValue.walletInfo.password=="",
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20.0),
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.of(context).g_key_wallet_c35,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                                fontSize: ScreenUtil().setSp(28),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(
                                    name: 'BackupOne',
                                  ),
                                  builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(20)),
                              child: Text(
                                S.of(context).g_key_wallet_c36,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //walletConnectWidget(wc),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget addIcon() {
    return Container(
        //margin: const EdgeInsets.only(left: 5),
        width: ScreenUtil().setWidth(50.0),
        height: ScreenUtil().setWidth(50.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(50.0))),
            border: Border.all(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name))),
        alignment: Alignment.center,
        child: Center(
          child: Icon(
            Icons.add,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            size: ScreenUtil().setWidth(38.0),
          ),
        ));
  }

  Widget coinListHeaderWidget(WalletActionProvider waValue) {
    String networkStr = S.of(context).g_token_m_key_4;
    if (waValue.walletInfo.networkIndex != -1) {
      networkStr = waValue.coinModels[waValue.walletInfo.networkIndex].coin['name'] ?? "";
    }
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: ScreenUtil().setWidth(165.0),
        maxHeight: ScreenUtil().setWidth(165.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(24),
            vertical: ScreenUtil().setWidth(18),
          ),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(ScreenUtil().setWidth(28)),
              topLeft: Radius.circular(ScreenUtil().setWidth(28)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.03),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 顶部行：Tokens标题 + 添加按钮 + 网络选择
              Row(
                children: [
                  Text(
                    S.of(context).g_token_m_key_11,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  // 添加代币按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showAddToken(),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                      child: Container(
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setWidth(36),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(22),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 网络选择器
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showChangeNetwork(waValue),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(14),
                          vertical: ScreenUtil().setWidth(8),
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              networkStr,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                fontWeight: FontWeight.w500,
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              size: ScreenUtil().setWidth(22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 底部行：排序选项
              Row(
                children: [
                  // 按名称排序
                  _buildSortButton(
                    S.of(context).g_browser_key6,
                    "name",
                    waValue.walletInfo.coinSort['name'] ?? -1,
                    () => waValue.setCoinSortAssets("name"),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(24)),
                  // 按资产排序
                  _buildSortButton(
                    S.of(context).g_key_198,
                    "assets",
                    waValue.walletInfo.coinSort['assets'] ?? -1,
                    () => waValue.setCoinSortAssets("assets"),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 排序按钮组件
  Widget _buildSortButton(String label, String key, int sortValue, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(8),
            vertical: ScreenUtil().setWidth(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(4)),
              SizedBox(
                width: ScreenUtil().setWidth(16),
                height: ScreenUtil().setWidth(16),
                child: Image.asset(
                  "assets/wallet/assets$sortValue.png",
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget coinListWidget(WalletActionProvider waValue) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return coinListWidget1(waValue);
          },
          childCount: 1,
        ));
  }

  Widget coinListWidget1(WalletActionProvider waValue) {
    // 使用 shrinkWrap 和自适应高度，避免固定高度导致溢出
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          border: Border.all(
              width: 2,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name))),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      // 添加底部安全边距，避免被底部导航栏遮挡
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(waValue.loadBalance==Load.loading)
          Container(
            width: double.infinity,
            height: ScreenUtil().setWidth(60.0),
            alignment: Alignment.center,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.textColorOrange.name),
            child: Text(
              S.of(context).g_key_208,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainWhiteColor.name)
              ),
            ),
          ),
          if (waValue.coinList.isEmpty)
            Container(
              height: ScreenUtil().setWidth(300.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
              child: const EmptyView(),
            ),
          if (waValue.coinList.isNotEmpty)
            ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: waValue.coinList.length,
              itemBuilder: (context, int index) {
                return _mainCoin(waValue.coinList[index],"c$index","coin_list");
              },
            ),
        ],
      ),
    );
  }

  Widget _mainCoin(CoinModel coinInfo, String key, String group,) {
    String balanceStr = "";
    double balance = coinInfo.value;
    if (balance >= 1000000000) {
      balanceStr = regular.getMoneyAbbreviation(balance);
    }else if(balance>0 && balance <0.0000000009){
      balanceStr=regular.getMoneyAbbreviationDecimal(balance);
    } else {
      balanceStr = oCcy.format(balance);
    }
    String valueBalanceStr="";
    double valueBalance=coinInfo.balanceDoubleAll();
    if(valueBalance>1000000000){
      valueBalanceStr=regular.getMoneyAbbreviation(valueBalance);
    }else if(valueBalance>0 && valueBalance <0.0000000009){
      valueBalanceStr=regular.getMoneyAbbreviationDecimal(valueBalance);
    }else{
      valueBalanceStr=coinInfo.balanceString();
    }
    Widget? mainImage;
    Widget image;
    if (coinInfo.coin['icon'] == "") {
      image = Image.asset("assets/img/list_default.png");
    } else {
      image = ImageNetWork(imageUrl:
      coinInfo.coin['icon'] ?? "",
        placeholder: "assets/img/list_default.png",
      );
    }
    if (coinInfo.coin['isContract']) {
      mainImage = ImageNetWork(imageUrl:
        coinInfo.mainCoinIcon ?? "",
        placeholder: "assets/img/list_default.png",
      );
    }
    Color deleteColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    if(coinInfo.coin['canEdit']==false){
      deleteColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorGrey.name);
    }
    Widget refreshWidget = const SizedBox();
    /*if (coinInfo.isRefresh) {
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(6.0),
        ),
        child: const CircularProgressIndicator(),
      );
    }
    else */
    if (coinInfo.loadError) {
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(6.0),
        ),
        child: Image.asset("assets/img/error.png",color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),),
      );
    }
    return InkWell(
      onTap: () {
        if(coinInfo.coin['coinType']==CoinType.BTC.name){
          //Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfoBtc(coinInfo)));
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfo(coinInfo)));
        }else if(coinInfo.coin['coinType']==CoinType.XRP.name){
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfoXRP(coinInfo)));
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfo(coinInfo)));
        }
      },
      child:Slidable(
        key: ValueKey(key),
        groupTag: group,
        closeOnScroll: true,
        enabled: true,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) async {
                if(coinInfo.coin['canEdit']==true){
                  if(coinInfo.coin['isContract']){
                    Provider.of<WalletActionProvider>(context,listen: false).removeWalletChainToken(coinInfo.coin,symbol:coinInfo.coin["coinType"],miniName:coinInfo.coin['miniName']);
                  }else{
                    Provider.of<WalletActionProvider>(context,listen: false).removeWalletChain(coinInfo.coin['mKey'],coinInfo.coin['unit']);
                  }
                }
              },
              backgroundColor:
              deleteColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              //label: S.of(context).g_key_113,
              autoClose: true,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 错误/加载指示器
              refreshWidget,
              // 币种图标
              Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(14)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                      child: image,
                    ),
                    if (mainImage != null)
                      Positioned(
                        top: -2,
                        left: -2,
                        height: ScreenUtil().setWidth(20),
                        width: ScreenUtil().setWidth(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                            border: Border.all(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                            child: mainImage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 币种信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 第一行：币种名称 + 余额数量
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          valueBalanceStr,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    // 第二行：单价+涨跌幅 + 总价值
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "\$${coinInfo.coinPriceString()}",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            percentageWidget(context, coinInfo.percentage),
                          ],
                        ),
                        Text(
                          "\$$balanceStr",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 涨跌幅百分比
  Widget percentageWidget(BuildContext context, var percentage) {
    final isPositive = percentage >= 0;
    final color = isPositive
        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name)
        : AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        "${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%",
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 保留旧的百分比组件（向后兼容）
  // ignore: unused_element
  Widget _oldPercentageWidget(BuildContext context, var percentage) {
    if (percentage >= 0) {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.rightTextColor.name),
            height: 1.5,
          ));
    } else {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
            height: 1.5,
          ));
    }
  }
  //切换网络
  showChangeNetwork(WalletActionProvider walletValue) {
    List<Widget> childs = [];
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(600.0),
      ),
      child: ListView.separated(
        itemCount: walletValue.coinModels.length + 1,
        itemBuilder: (context, int index) {
          bool selected = false;
          if (walletValue.walletInfo.networkIndex == index - 1) {
            selected = true;
          }
          if (index == 0) {
            return InkWell(
              onTap: () {
                walletValue.setNetworkIndex(-1);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(30.0),
                  horizontal: ScreenUtil().setWidth(20.0),
                ),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        width: ScreenUtil().setWidth(1.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemLineColor.name),
                      )),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).g_token_m_key_4,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, "mainTextColor"),
                          fontWeight: FontWeight.bold),
                    ),
                    if (selected)
                      Icon(
                        Icons.check,
                        size: ScreenUtil().setWidth(40.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                      ),
                  ],
                ),
              ),
            );
          }
          CoinModel coinInfo = walletValue.coinModels[index - 1];
          Widget image;
          if (coinInfo.coin['miniName'] == CoinType.N.name) {
            image = Image.asset('assets/img/ast.png');
          } else {
            image = ImageNetWork(imageUrl:
              coinInfo.coin['icon'],
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              walletValue.setNetworkIndex(index - 1);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(20.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      width: ScreenUtil().setWidth(1.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name),
                    )),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(52.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: image,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(coinInfo.coin['name'],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemSubtitleTextColor.name),
                            )),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: ScreenUtil().setWidth(1.0),
          );
        },
      ),
    ));
    SheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  //显示钱包列表
  showChangeAddress() {
    //WalletInfo nowWalletInfo=walletValue.walletInfoLsit[walletValue.walletIndex];
    WalletActionProvider walletValue = Provider.of<WalletActionProvider>(context,listen: false);
    List<Widget> childs = [];
    childs.add(
      Container(
        height: ScreenUtil().setWidth(80),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              S.of(context).g_key_13,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletList()));
              },
              child: Icon(
                Icons.settings,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        ),
      ),
    );
    childs.add(
      Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
      ),
    );
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(500.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: ListView.separated(
        itemCount: walletValue.walletInfoLsit.length,
        itemBuilder: (context, int index) {
          WalletInfo wInfo = walletValue.walletInfoLsit[index];
          Color walletColor = AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name);
          if (index == walletValue.walletIndex) {
            walletColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name);
          }
          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              if (index == walletValue.walletIndex) {
              } else {
                await walletValue.setWalletIndex(index);
              }
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    wInfo.mainWallet?S.of(context).g_key_14:S.of(context).g_key_6,
                    style: TextStyle(
                      color: walletColor,
                      fontSize: ScreenUtil().setSp(36.0),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(20.0),
                  ),
                  Text(
                    wInfo.walletName!,
                    style: TextStyle(
                      color: walletColor,
                      fontSize: ScreenUtil().setSp(36.0),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Spacer(),
                  if(wInfo.mainWallet==true || Provider.of<WalletActionProvider>(context,listen: false).walletIndex == index)
                    Icon(Icons.lock,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainGreyColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: ScreenUtil().setWidth(1.0),
          );
        },
      ),
    ));
    childs.add(CreateWalletButton());
    /*childs.add(
      Container(
        height: ScreenUtil().setWidth(88.0),
        width: double.infinity,
        child: ButtonStyle2(context, () async {
          Navigator.pop(context);
          //添加钱包
          await Navigator.pushNamed(
              context,"/CreateWallet");
        }, S.of(context).g_key_159),
      )
    );*/

    SheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }


  //显示选择币列表
  showSearchCoin(int type) {
    SheetBottom(
      context,
      S.of(context).g_token_m_key_12,
      WalletSearchCoin(type),
    );
  }
  //显示添加代币和链
  showAddToken()async{
    WalletInfo wi=Provider.of<WalletActionProvider>(context,listen: false).walletInfo;
    if(wi.privateKey !=null){
      String? cType=wi.coinInfo?.keys.toList()[0];
      bool? r = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WalletCoinAddAll("",coinType: cType,)
          ));
      if (!mounted) return;
      if (r==true) {
        Provider.of<WalletActionProvider>(context,listen: false).initWallet(initCoinInfo: true);
      }
      return;
    }
    Widget child=Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: ()async{
              String? cType;
              WalletInfo wi=Provider.of<WalletActionProvider>(context,listen: false).walletInfo;
              if(wi.privateKey !=null){
                cType=wi.coinInfo?.keys.toList()[0];
              }
              bool? r = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletCoinAddAll("",coinType: cType,)
                  ));
              if (!mounted) return;
              if (r==true) {
                Provider.of<WalletActionProvider>(context,listen: false).initWallet(initCoinInfo: true);
              }
              Navigator.pop(context);
            },
            child: Container(
              height: ScreenUtil().setWidth(88),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_token_m_key_20,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            endIndent: 0,
            indent: 0,
          ),
          InkWell(
            onTap: ()async{
              bool? r = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletChainAdd()
                  ));
              if (!mounted) return;
              if (r==true) {
                Provider.of<WalletActionProvider>(context,listen: false).initWallet(initCoinInfo: true);
              }
              Navigator.pop(context);
            },
            child: Container(
              height: ScreenUtil().setWidth(88),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_token_m_key_19,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    SheetBottom(
      context,
      "",
      child,
    );
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
