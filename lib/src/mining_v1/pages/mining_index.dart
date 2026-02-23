
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/mining_v1/pages/mining_settings.dart';
import 'package:n42_wallet/src/mining_v1/pages/summary_page.dart';
import 'package:n42_wallet/src/mining_v1/pages/today_mining_page.dart';
import 'package:n42_wallet/src/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/src/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/models/wallet_info.dart';
import 'package:n42_wallet/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/src/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/src/widgets/keep_state_widget.dart';
import 'package:n42_wallet/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiningIndex extends StatefulWidget {
  const MiningIndex({super.key});

  @override
  State<MiningIndex> createState() => _MiningIndexState();
}

class _MiningIndexState extends State<MiningIndex> with SingleTickerProviderStateMixin{
  int selectIndex = 0;
  late TabController _tabController;

  List<String> get tabs {
    return [
      S.current.g_mining_key_1,
      S.current.g_mining_key_2,
      //S.current.g_mining_key_3,
    ];
  }

  final pages = [
    const KeepStateWidget(
      wantKeepAlive: true,
      child: TodayMiningPage(),
    ),
    const KeepStateWidget(
      wantKeepAlive: true,
      child: SummaryPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(() {
      setState(() {
        selectIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHomeTopBar(
              title: S.current.g_home_key3,
              titleChild: InkWell(
                onTap: (){
                  showChangeAddress();
                },
                child: Container(
                  height: ScreenUtil().setWidth(80),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            globalMiningV1.walletName,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              fontSize: ScreenUtil().setSp(30),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if(AppConfig.isMainChainMining==false)
                          Text(
                            "${AppConfig.isMainChainMining==true?S.of(context).g_key_148:S.of(context).g_key_147}",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              fontSize: ScreenUtil().setSp(20),
                            ),
                          ),
                        ],
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
                Scaffold.of(context).openDrawer();
              },
              onLeftImageUri: "assets/wallet/menu.png",
              actions: [
                /*
                Consumer<PublicProvider>(
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MessageList()));
                      },
                      child: Container(
                          width: ScreenUtil().setWidth(60.0),
                          height: ScreenUtil().setWidth(60.0),
                          // margin: EdgeInsets.only(right: scr.setWidth(30.0)),
                          child: Stack(
                            children: [
                              Positioned(
                                top: ScreenUtil().setWidth(10),
                                left: ScreenUtil().setWidth(10),
                                right: ScreenUtil().setWidth(10),
                                bottom: ScreenUtil().setWidth(10),
                                child: Image.asset(
                                  "assets/home/notification.png",
                                  width: ScreenUtil().setWidth(40),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainBlueColor.name),
                                ),
                              ),
                              if (value.messageNotReadCount != 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: ScreenUtil().setWidth(30),
                                    height: ScreenUtil().setWidth(30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setWidth(30)),
                                      color: AppThemeUtils.getColorByKey(
                                          context,
                                          AppThemeKeys.errorTextColor.name),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${value.messageNotReadCount > 99 ? 99 : value.messageNotReadCount}",
                                      style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(
                                            context,
                                            AppThemeKeys.mainWhiteColor.name),
                                        fontSize: ScreenUtil().setSp(14),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          )),
                    );
                  },
                ),
                */
                SizedBox(
                  width: ScreenUtil().setWidth(10),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MiningSettings()));
                  },
                  child: Image.asset(
                    "assets/mining/set.png",
                    width: ScreenUtil().setWidth(40),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                )
              ],
            ),
            if(AppConfig.isMainChainMining==false)
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  "The test chain is being upgraded and blocks cannot be verified temporarily.",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(26)
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            TabBar(
              tabs: tabs
                  .map((e) => Container(
                  margin: EdgeInsets.only(
                    bottom: ScreenUtil().setWidth(24),
                    left: ScreenUtil().setWidth(15), right: ScreenUtil().setWidth(15),
                    top: ScreenUtil().setWidth(24),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                    vertical: ScreenUtil().setWidth(24),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
                      color: selectIndex == tabs.indexOf(e)
                          ? AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name)
                          : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name)),
                  child: Text(
                    e,
                    style: TextStyle(
                        color: selectIndex == tabs.indexOf(e)
                            ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name)
                            :AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name)),
                  )))
                  .toList(),
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: ScreenUtil().setSp(26.0),
                fontWeight: FontWeight.w500,
              ),
              indicatorPadding: const EdgeInsets.only(bottom: 0),
              labelColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              unselectedLabelColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              unselectedLabelStyle: TextStyle(fontSize: ScreenUtil().setSp(26.0)),
              isScrollable: true,
              indicator: const BoxDecoration(),
              indicatorSize: TabBarIndicatorSize.label,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(15),
              ),
              labelPadding: EdgeInsets.all(0,),
              tabAlignment: TabAlignment.start,
              // 自定义覆盖颜色 清除长按时灰色背景
              //overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
  //显示钱包列表
  showChangeAddress() {
    //WalletInfo nowWalletInfo=walletValue.walletInfoLsit[walletValue.walletIndex];
    WalletActionProvider walletValue = globalWapAdapter;
    MiningProvider miningValue=globalMiningV1;
    List<Widget> childs = [];
    childs.add(
      Container(
        height: ScreenUtil().setWidth(80),
        width: double.infinity,
        child: Text(
          S.of(context).g_key_16,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(36.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        alignment: Alignment.centerLeft,
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
      child: ListView.builder(
        itemCount: walletValue.walletInfoLsit.length,
        itemBuilder: (context, int index) {
          WalletInfo wInfo = walletValue.walletInfoLsit[index];
          Color walletColor = AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name);
          if (index == miningValue.walletIndex) {
            walletColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name);
          }
          if(wInfo.coinInfo?[CoinType.N.name]==null){
            return SizedBox();
          }
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  if (index == miningValue.walletIndex) {
                  } else {
                    miningValue.setWalletIndex(index);
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
                        wInfo.walletName??"",
                        style: TextStyle(
                          color: walletColor,
                          fontSize: ScreenUtil().setSp(36.0),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                endIndent: 0,
                indent: 0,
              )
            ],
          );
        },
      ),
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }

  tabWidget() {
    return Container(
      height: ScreenUtil().setWidth(82.0),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(30),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, int index) {
          Color backgroundColor = AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name);
          Color textColor =
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor4.name);
          if (selectIndex == index) {
            backgroundColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name);
            textColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonTextColor.name);
          }
          return GestureDetector(
            onTap: () {
              if (selectIndex == index) return;
              setState(() {
                selectIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40))),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return SizedBox(
            width: ScreenUtil().setWidth(30),
          );
        },
      ),
    );
  }
}
