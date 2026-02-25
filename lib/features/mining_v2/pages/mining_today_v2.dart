import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_setting.dart';

import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v2/widgets/plans_widget.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_status_widget.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_risk_card.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_data_broad.dart';
import 'package:n42_wallet/features/mining_v2/widgets/background_mining_widget.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningTodayV2 extends ConsumerStatefulWidget {
  const MiningTodayV2({super.key});

  @override
  ConsumerState<MiningTodayV2> createState() => _MiningTodayV2State();
}

class _MiningTodayV2State extends ConsumerState<MiningTodayV2> with AutomaticKeepAliveClientMixin{
  final DataUtils dataUtils = DataUtils();
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription=eventBus.on().listen((event) async {
      if (event is! EventPublic) return;
      if (event.type == EventPublicType.selectWallet) {
        await initDataWallet(EventPublicType.selectWallet);
      }
      if (event.type == EventPublicType.selectMiningWallet) {
        await initDataWallet(EventPublicType.selectMiningWallet);
      }
    });
  }

  Future<void> initData() async {
    var mv2=ref.read(miningBridgeProvider);
    await mv2.loadMiningData();
  }
  Future<void> initDataWallet(EventPublicType pt)async{
    MiningV2Provider mp=ref.read(miningBridgeProvider);
    if(pt==EventPublicType.selectWallet){
      // BUGFIX: Skip initialization only if depositsEnable has already been set
      // Previously was `!= null` which incorrectly skipped when already initialized
      if(mp.depositsEnable == null)return;
    }
    mp.resetData();
    await mp.checkAddressMiningStatus();
    await initData();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
  ///解除质押
  void unLockAstMining() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(
            S.current.g_mining_key20,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.g_key_79),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text(S.current.g_key_78),
              onPressed: () async {
                try {
                  MiningV2Provider mp=ref.read(miningBridgeProvider);
                  if(mp.exitDepositLoad==Load.loading)return;
                  await mp.createExitDepositUnsignedTx();

                } catch (err) {
                  debugPrint("err:${err.toString()}");
                } finally {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                  }
                  //更新ui
                  //await initData();

                }
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHomeTopBar(
              title: S.current.g_home_key3,
              titleChild: Builder(
                  builder: (context) {
                    final walletName = ref.watch(miningBridgeProvider.select((p) => p.walletName));
                    return InkWell(
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
                                walletName,
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                  fontSize: ScreenUtil().setSp(28),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if(AppConfig.isMainChainMining==false)
                                Text(
                                  AppConfig.isMainChainMining==true?S.of(context).g_key_148:S.of(context).g_key_147,
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
                  );
                  },
              ),
              onLeftImageClick: () {
                Scaffold.of(context).openDrawer();
              },
              onLeftImageUri: "assets/wallet/menu.png",
              actions: [
                SizedBox(
                  width: ScreenUtil().setWidth(10),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MiningSetting()));
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
                  S.of(context).g_mining_key_74,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(26)
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              flex: 1,
              child: DetailRefreshWidget(
                callback: () async {
                  await initData();
                },
                childWidget: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(30),
                    right: ScreenUtil().setWidth(30),
                    //bottom: ScreenUtil().setWidth(30),
                  ),
                  child: Builder(
                    builder: (context) {
                      final mpValue = ref.watch(miningBridgeProvider);
                      return Column(
                        children: [
                          // 顶部渐变 Banner
                          _buildMiningBanner(context, mpValue),
                          //没有质押展示 选择plans
                          if (mpValue.depositsEnable == false)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: ScreenUtil().setWidth(18),
                                ),
                                PlansWidget(
                                  onTap: null,
                                ),
                                SizedBox(
                                  height: ScreenUtil().setWidth(10),
                                ),
                              ],
                            ),
                          MiningStatusWidget(mpValue: mpValue),
                          if(mpValue.depositsEnable==true)
                            MiningRiskCard(mpValue: mpValue),
                          if(mpValue.depositsEnable==true)
                          // 柱状图展示历史7天挖矿数据
                            ChartHistogram(
                              isLoading: mpValue.isLoading7DayData,
                              titleModel: TitleModel(),
                              barChartModel: mpValue.isShowDefaultBar
                                  ? BarChartModel(
                                bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColorMax: const Color.fromRGBO(25, 118, 249, 0.1),
                                touchColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                width: ScreenUtil().setWidth(20),
                                values: [10, 10, 10, 10, 10, 10, 10],
                              )
                                  : BarChartModel(
                                bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColor: const Color.fromRGBO(25, 118, 249, 1),
                                fgColorMax: const Color.fromRGBO(50, 215, 75, 1),
                                touchColor: Colors.yellowAccent,
                                width: ScreenUtil().setWidth(20),
                                values: mpValue.barChartValues,
                              ),
                              bottomTitle: BottomTitle(
                                titles: mpValue.isShowDefaultBar?['/','/','/','/','/','/','/']:mpValue.barChartTitle,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(18),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemSubtitleTextColor.name),
                                ),
                                // specialIndex: getMaxRewardIndex(),
                                specialStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(20),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemTextColor.name),
                                  fontWeight: FontWeight.w600,
                                ),
                                space: ScreenUtil().setWidth(30),
                              ),
                              alertMessageGroups: mpValue.barChartAlertMessageList,
                            ),
                          if(mpValue.depositsEnable==true)
                            SizedBox(
                              height: ScreenUtil().setWidth(20),
                            ),
                          BackgroundMiningWidget(mpValue: mpValue),
                          Row(
                            children: [
                              MiningDataBroad(
                                titleText: S.of(context).g_mining_key_10,
                                value: "${dataUtils.formatNum(mpValue.todayCycleRewardsValue, 6)} ${CoinType.N.name}",
                                imagePath: "assets/mining/broad_bg_4.png",
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              MiningDataBroad(
                                titleText: S.of(context).g_mining_key_11,
                                value: "${dataUtils.formatNum(mpValue.yesterdayCycleRewardsValue, 6)} ${CoinType.N.name}",
                                imagePath: "assets/mining/broad_bg_4.png",
                                tipsText: S.of(context).g_mining_key_12,
                                showTips: true,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(20),
                          ),
                          Row(
                            children: [
                              MiningDataBroad(
                                titleText: S.of(context).g_mining_key_13,
                                value: '${dataUtils.formatNum(mpValue.miningTotalRevenue, 6)} ${CoinType.N.name}',
                                imagePath: "assets/mining/broad_bg_1.png",
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              MiningDataBroad(
                                titleText: S.of(context).g_mining_key_14,
                                value: "\$${NumberFormat("#,##0.0#", "en_US").format((mpValue.nPrice * mpValue.miningTotalRevenue))}",
                                imagePath: "assets/mining/broad_bg_2.png",
                                tipsText: S.of(context).g_mining_key_15,
                                showTips: true,
                              ),
                            ],
                          ),
                          if(mpValue.showRedemption==true && mpValue.redeem==false)
                            Container(
                              height: ScreenUtil().setWidth(88),
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical:ScreenUtil().setWidth(20),),
                              child: buttonStyle6(context, (){
                                if(mpValue.exitDepositLoad==Load.finish){
                                  //解除质押
                                  unLockAstMining();
                                }
                              },
                                //"Redemption",
                                S.of(context).g_mining_key_77,
                                AppThemeUtils.getColorByKey(context,
                                    mpValue.exitDepositLoad==Load.loading?
                                    AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                                AppThemeUtils.getColorByKey(context,
                                    mpValue.exitDepositLoad==Load.loading?
                                    AppThemeKeys.mainButtonTextColor3.name:AppThemeKeys.mainButtonTextColor.name),
                                mpValue.exitDepositLoad==Load.loading,
                              ),//赎回
                            ),
                          if(mpValue.depositsEnable==true && mpValue.showRedemption==false)
                            Container(
                              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                              width: double.infinity,
                              child: Text(
                                S.of(context).g_mining_key_88,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                                ),
                              ),
                            ),
                          if(mpValue.depositsEnable==true && mpValue.redeem==true && mpValue.showRedemption2==true)
                            Container(
                              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                              width: double.infinity,
                              child: Text(
                                S.of(context).g_mining_key_115,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: ScreenUtil().setWidth(140),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }

  /// 顶部渐变 Banner：展示挖矿状态摘要
  Widget _buildMiningBanner(BuildContext context, MiningV2Provider mpValue) {
    final isActive = mpValue.miningStatus == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isActive ? const Color(0xFF32D74B) : const Color(0xFFFF9500);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F1D38), const Color(0xFF1A0B3B)]
              : [const Color(0xFF1565C0), const Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(isDark ? 50 : 70),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 挖矿图标
          Container(
            width: ScreenUtil().setWidth(72),
            height: ScreenUtil().setWidth(72),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Icon(
              Icons.developer_board_rounded,
              color: Colors.white.withAlpha(220),
              size: ScreenUtil().setWidth(38),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_home_key3,
                  style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontSize: ScreenUtil().setSp(22),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Row(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(10),
                      height: ScreenUtil().setWidth(10),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withAlpha(120),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      isActive
                          ? S.current.g_key_193
                          : S.current.g_mining_key_47,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // N余额
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                S.of(context).g_key_29,
                style: TextStyle(
                  color: Colors.white.withAlpha(140),
                  fontSize: ScreenUtil().setSp(20),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                mpValue.depositsEnable ?? false
                    ? '${mpValue.balanceInBeacon} N'
                    : '${mpValue.walletNBalance.toStringAsFixed(2)} N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //显示钱包列表
  void showChangeAddress() {
    // Use MiningV2Provider instead of WalletActionProvider
    MiningV2Provider miningProvider = ref.read(miningBridgeProvider);
    final walletList = miningProvider.miningWalletList;
    final currentIndex = miningProvider.currentMiningWalletIndex;
    
    List<Widget> childs = [];
    childs.add(
      Container(
        height: ScreenUtil().setWidth(80),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text(
          S.of(context).g_key_16,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(36.0),
            fontWeight: FontWeight.bold,
          ),
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
      child: ListView.builder(
        itemCount: walletList.length,
        itemBuilder: (context, int listIndex) {
          MiningWalletInfo wInfo = walletList[listIndex];
          Color walletColor = AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name);
          if (wInfo.index == currentIndex) {
            walletColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name);
          }
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  if (wInfo.index != currentIndex) {
                    ref.read(wapBridgeProvider).setWalletMiningIndex(wInfo.index);
                    //miningProvider.setMiningWalletByIndex(wInfo.index);
                  }
                },
                child: Container(
                  height: ScreenUtil().setWidth(80.0),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        wInfo.isMainWallet ? S.of(context).g_key_14 : S.of(context).g_key_6,
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
                        wInfo.name,
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

  @override
  bool get wantKeepAlive => true;
}

