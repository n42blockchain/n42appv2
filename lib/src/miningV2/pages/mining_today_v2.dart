import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/pages/mining_background.dart';
import 'package:n42appv2/src/miningV2/pages/mining_setting.dart';

import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/miningV2/widgets/plans_widget.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/chart_histogram.dart';
import 'package:n42appv2/src/widgets/custom_popup_menu_wrap.dart';
import 'package:n42appv2/src/widgets/detail_refresh_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningTodayV2 extends StatefulWidget {
  const MiningTodayV2({super.key});

  @override
  State<MiningTodayV2> createState() => _MiningTodayV2State();
}

class _MiningTodayV2State extends State<MiningTodayV2> with AutomaticKeepAliveClientMixin{
  final DataUtils dataUtils = DataUtils();
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription=eventBus.on().listen((event) async {
      if (event is! EventPublic) return;
      if (event.type == EventPublicType.selectWallet) {
        await initData_wallet(EventPublicType.selectWallet);
      }
      if (event.type == EventPublicType.selectMiningWallet) {
        await initData_wallet(EventPublicType.selectMiningWallet);
      }
    });
  }

  Future<void> initData() async {
    var mv2=Provider.of<MiningV2Provider>(context,listen: false);
    await mv2.loadMiningData();
  }
  Future<void> initData_wallet(EventPublicType pt)async{
    MiningV2Provider mp=Provider.of<MiningV2Provider>(context,listen: false);
    if(pt==EventPublicType.selectWallet){
      if(mp.depositsEnable !=null)return;
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
  unLockAstMining() {
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
                  MiningV2Provider mp=Provider.of<MiningV2Provider>(context,listen: false);
                  if(mp.exitDepositLoad==Load.loading)return;
                  mp.createExitDepositUnsignedTx();

                } catch (err) {
                  debugPrint("err:${err.toString()}");
                } finally {
                  if (mounted) {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHomeTopBar(
              title: S.current.g_home_key3,
              titleChild: Consumer<MiningV2Provider>(
                  builder: (context, mpValue, child) {
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
                                mpValue.walletName,
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
                  child: Consumer<MiningV2Provider>(
                    builder: (context, mpValue, child) {
                      return Column(
                        children: [
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
                          miningStatusWidget(mpValue),
                          if(mpValue.depositsEnable==true)
                            Container(
                            decoration: BoxDecoration(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.itemBgColor.name),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(44)),
                            margin: EdgeInsets.only(bottom:ScreenUtil().setWidth(20),),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: ScreenUtil().setWidth(112),
                                      height: ScreenUtil().setWidth(112),
                                      decoration: BoxDecoration(
                                        color: AppThemeUtils.getColorByKey(
                                            context, AppThemeKeys.ff444444.name),
                                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(56)),
                                      ),
                                      padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                                      child: Image.asset('assets/mining/Mascot.png'),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /*
                                          * Low Risk

Moderately Low Risk

Moderately High Risk

High Risk
*
*
*
* Riesgo Bajo

Riesgo Moderadamente Bajo

Riesgo Moderadamente Alto

Riesgo Alto*/
                                          Text(
                                            // "High Risk",
                                            mpValue.inactivityTitle,
                                            style: TextStyle(
                                                color: AppThemeUtils.getColorByKey(
                                                    context, AppThemeKeys.itemTextColor.name),
                                                fontSize: ScreenUtil().setSp(30),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            // "Failing to complete tasks for four consecutive days will result in no earnings and a risk of penalty.,
                                            S.of(context).g_mining_key_75,
                                            style: TextStyle(
                                              color: AppThemeUtils.getColorByKey(
                                                  context, AppThemeKeys.itemSubtitleTextColor.name),
                                              fontSize: ScreenUtil().setSp(20),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setWidth(32),
                                ),
                                Row(
                                  children: [
                                    inactivityScoreWidget(mpValue.inactivityScore[0]),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    inactivityScoreWidget(mpValue.inactivityScore[1]),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    inactivityScoreWidget(mpValue.inactivityScore[2]),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    inactivityScoreWidget(mpValue.inactivityScore[3]),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setWidth(32),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      // "Risk Score",
                                      S.of(context).g_mining_key_76,
                                      style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(
                                            context, AppThemeKeys.itemTextColor.name),
                                        fontSize: ScreenUtil().setSp(30),
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Container(
                                      width: ScreenUtil().setWidth(40),
                                      height: ScreenUtil().setWidth(40),
                                      padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10),),
                                      child: Image.asset('assets/img/error.png',),
                                    ),
                                    Text(
                                      "${mpValue.inactivityScorePercentage}%",
                                      style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(
                                              context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(28),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if(mpValue.depositsEnable==true)
                          // 柱状图展示历史7天挖矿数据
                            ChartHistogram(
                              isLoading: mpValue.isLoading7DayData,
                              titleModel: TitleModel(),
                              barChartModel: mpValue.isShowDefaultBar
                                  ? BarChartModel(
                                bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColor_max: const Color.fromRGBO(25, 118, 249, 0.1),
                                touchColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                width: ScreenUtil().setWidth(20),
                                values: [10, 10, 10, 10, 10, 10, 10],
                              )
                                  : BarChartModel(
                                bgColor: const Color.fromRGBO(25, 118, 249, 0.1),
                                fgColor: const Color.fromRGBO(25, 118, 249, 1),
                                fgColor_max: const Color.fromRGBO(50, 215, 75, 1),
                                touchColor: Colors.yellowAccent,
                                width: ScreenUtil().setWidth(20),
                                values: mpValue.barchartValues,
                              ),
                              bottomTitle: BottomTitle(
                                titles: mpValue.isShowDefaultBar?['/','/','/','/','/','/','/']:mpValue.barchartTitle,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(22),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemSubtitleTextColor.name),
                                ),
                                // specialIndex: getMaxRewardIndex(),
                                specialStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemTextColor.name),
                                  fontWeight: FontWeight.w600,
                                ),
                                space: ScreenUtil().setWidth(36),
                              ),
                              alertMessageGroups: mpValue.barchartAlertMessageList,
                            ),
                          if(mpValue.depositsEnable==true)
                            SizedBox(
                              height: ScreenUtil().setWidth(20),
                            ),
                          backgroundMiningWidget(mpValue),
                          Row(
                            children: [
                              miningDataBroad(S.of(context).g_mining_key_10,
                                  "${dataUtils.formatNum(mpValue.todayCycleRewardsValue, 6)} ${CoinType.N.name}",
                                  imagePath: "assets/mining/broad_bg_4.png"),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              miningDataBroad(
                                // "Last Rewards",
                                  S.of(context).g_mining_key_11,
                                  "${dataUtils.formatNum(mpValue.yesterdayCycleRewardsValue, 6)} ${CoinType.N.name}",
                                  imagePath: "assets/mining/broad_bg_4.png",
                                  tipsText:
                                  // "Reward accumulates daily and is only sent to your N wallet when it reaches ~0.5 N.",
                                  S.of(context).g_mining_key_12,
                                  showTips: true),
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(20),
                          ),
                          Row(
                            children: [
                              miningDataBroad(
                                // "Total Rewards:",
                                S.of(context).g_mining_key_13,
                                '${dataUtils.formatNum(mpValue.miningTotalRevenue, 6)} ${CoinType.N.name}',
                                imagePath: "assets/mining/broad_bg_1.png",
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              miningDataBroad(S.of(context).g_mining_key_14,
                                  "\$${NumberFormat("#,##0.0#", "en_US").format((mpValue.nPrice * mpValue.miningTotalRevenue))}",
                                  imagePath: "assets/mining/broad_bg_2.png",
                                  tipsText:
                                  // "Calculated based on market price of N * the total N rewards.",
                                  S.of(context).g_mining_key_15,
                                  showTips: true),
                            ],
                          ),
                          if(mpValue.showRedemption==true && mpValue.redeem==false)
                            Container(
                              height: ScreenUtil().setWidth(88),
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical:ScreenUtil().setWidth(20),),
                              child: ButtonStyle6(context, (){
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
  Widget miningStatusWidget(MiningV2Provider mpValue) {
    final isActive = mpValue.miningStatus == true;
    final statusColor = isActive ? const Color(0xff32D74B) : const Color(0xffEB5851);
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: Row(
        children: [
          // 挖矿状态卡片
          Expanded(
            child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                border: Border.all(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Text(
                        S.of(context).g_mining_key_5,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(22),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // 状态指示器
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10),
                          vertical: ScreenUtil().setWidth(4),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(8),
                              height: ScreenUtil().setWidth(8),
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(6)),
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: ScreenUtil().setSp(20),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  // 状态文字
                  Text(
                    isActive ? S.current.g_key_193 : S.current.g_mining_key_47,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 余额卡片
          Expanded(
            child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                border: Border.all(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_key_29,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(22),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${mpValue.depositsEnable ?? false ? mpValue.balanceInBeacon : 0}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(6)),
                      Text(
                        CoinType.N.name,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(24),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget backgroundMiningWidget(MiningV2Provider mpValue) {
    if (mpValue.depositsEnable == false){
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      margin: EdgeInsets.only(bottom:ScreenUtil().setWidth(20) ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/mining/backgroundmining.png',
            height: ScreenUtil().setWidth(84),
            width: ScreenUtil().setWidth(84),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
              ),
              child: Text(
                // 'Background Mining',
                S.of(context).g_mining_key_9,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ButtonStyle3(
            context,
                () {
              if (mpValue.depositsEnable == true) {
                MiningBackground().background_start();
              }
            },
            S.of(context).g_key_wallet_c4,
            mpValue.depositsEnable == true
                ? const Color(0xffD1E4FE)
                : const Color(0xffEDEFF2),
            mpValue.depositsEnable == true
                ? const Color(0xff1976F9)
                : const Color(0xffBAC2CC),
            height: ScreenUtil().setWidth(55),
            borderRadius: ScreenUtil().setWidth(55),
            fontSize: ScreenUtil().setSp(22),
            paddingV:ScreenUtil().setWidth(12.0),
            paddingH: ScreenUtil().setWidth(32.0),
          ),
        ],
      ),
    );
  }
  /*
  miningActivityWidget(MiningV2Provider mpValue) {
    if (mpValue.depositsEnable == true) {
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // "Mining Activity",
              S.of(context).g_mining_key31,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(40),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                  topRight: Radius.circular(ScreenUtil().setWidth(16)),
                ),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TaskValueBar(),
                  mpValue.isLoadingTaskList
                      ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                        child: Loading(),
                      ))
                      : mpValue.taskList.isEmpty
                      ? Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(60)),
                          child: EmptyView(),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(120),
                        )
                      ],
                    ),
                  )
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 0),
                        itemBuilder: (context, index) {
                          var item = mpValue.taskList[index];
                          return GestureDetector(
                            onTap: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (_) => MiningTaskDetailV2(
                                    blockNumber:
                                    "${item["blockNumber"]}",
                                    nValue: dataUtils.formatNum(
                                        toEther(
                                            "${BigInt.tryParse(item["reward"])}",
                                            18).toDouble(),
                                        8),
                                  )));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(20)),
                              // //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
                              child: TaskItemWidget(
                                taskId:
                                "${BigInt.tryParse(item["blockNumber"])}",
                                astValue: dataUtils.formatNum(
                                    toEther(
                                        "${BigInt.tryParse(item["reward"])}",
                                        18).toDouble(),
                                    8),
                                time: dataUtils.getTimeByTimeStamp(
                                    "${item["timestamp"]}",
                                    format: "dd/MM HH:mm"),
                                status: "success",
                              ),
                            ),
                          );
                        },
                        itemCount: taskList.length,
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(120),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: ScreenUtil().setWidth(120),
    );
  }
  */
  Widget miningDataBroad(String titleText, String value,
      {bool showTips = false, String? imagePath, String? tipsText}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行
            Row(
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(22),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showTips)
                  CustomPopupMenuWrap(
                    key: ValueKey(titleText),
                    verticalMargin: ScreenUtil().setWidth(24),
                    defView: Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: ScreenUtil().setWidth(18),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    menuItemView: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60)),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                      child: Text(
                        tipsText ?? '',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            // 数值行
            Text(
              value,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
  Widget inactivityScoreWidget(double iScore){
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: iScore,
          backgroundColor:Color.fromRGBO(255, 228, 230, 1),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          minHeight:ScreenUtil().setWidth(16),
        ),
      ),
    );
  }

  //显示钱包列表
  void showChangeAddress() {
    // Use MiningV2Provider instead of WalletActionProvider
    MiningV2Provider miningProvider = Provider.of<MiningV2Provider>(context, listen: false);
    final walletList = miningProvider.miningWalletList;
    final currentIndex = miningProvider.currentMiningWalletIndex;
    
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
                    miningProvider.setMiningWalletByIndex(wInfo.index);
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
    SheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

