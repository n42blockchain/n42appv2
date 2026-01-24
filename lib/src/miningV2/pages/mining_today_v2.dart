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
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
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
        await initDataWallet(EventPublicType.selectWallet);
      }
      if (event.type == EventPublicType.selectMiningWallet) {
        await initDataWallet(EventPublicType.selectMiningWallet);
      }
    });
  }

  Future<void> initData() async {
    var mv2=Provider.of<MiningV2Provider>(context,listen: false);
    await mv2.loadMiningData();
  }
  Future<void> initDataWallet(EventPublicType pt)async{
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
    super.build(context);
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
                                  "AppConfig.isMainChainMining==true?S.of(context).g_key_148:S.of(context).g_key_147",
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
                            _buildRiskCard(mpValue),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                  color: isDark ? Colors.white.withValues(alpha:0.06) : Colors.black.withValues(alpha:0.04),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setWidth(36),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                        ),
                        child: Icon(
                          isActive ? Icons.verified_outlined : Icons.pause_circle_outline,
                          size: ScreenUtil().setWidth(20),
                          color: statusColor,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Expanded(
                        child: Text(
                          S.of(context).g_mining_key_5,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(22),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if(mpValue.depositsEnable==true)
                      InkWell(
                        onTap: (){
                          if(isActive){
                            mpValue.disconnectWebSocket();
                          }
                          else{
                            mpValue.checkAddressMiningStatus();
                          }
                        },
                        child: SizedBox(
                          width: ScreenUtil().setWidth(36),
                          height: ScreenUtil().setWidth(36),
                          /*decoration: BoxDecoration(
                            color: const Color(0xffEB5851).withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                          ),*/
                          child: Icon(
                            isActive?Icons.pause_circle_outline:Icons.play_circle_outline,
                            size: ScreenUtil().setWidth(36),
                            color: isActive?const Color(0xffEB5851):const Color(0xff32D74B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  // 状态文字 + 状态指示器
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isActive ? S.current.g_key_193 : S.current.g_mining_key_47,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: ScreenUtil().setSp(30),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 状态指示点
                      Container(
                        width: ScreenUtil().setWidth(14),
                        height: ScreenUtil().setWidth(14),
                        margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha:0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  color: isDark ? Colors.white.withValues(alpha:0.06) : Colors.black.withValues(alpha:0.04),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setWidth(36),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: ScreenUtil().setWidth(20),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Expanded(
                        child: Text(
                          S.of(context).g_key_29,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(22),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          mpValue.depositsEnable ?? false 
                              ? '${mpValue.balanceInBeacon}' 
                              : mpValue.walletNBalance.toStringAsFixed(2),
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        CoinType.N.name,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = mpValue.depositsEnable == true;
    
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: isEnabled 
            ? LinearGradient(
                colors: [
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.08),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: isEnabled 
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.2)
              : (isDark ? Colors.white.withValues(alpha:0.06) : Colors.black.withValues(alpha:0.04)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 图标容器
          Container(
            width: ScreenUtil().setWidth(72),
            height: ScreenUtil().setWidth(72),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18)),
            ),
            child: Center(
              child: Image.asset(
                'assets/mining/backgroundmining.png',
                height: ScreenUtil().setWidth(44),
                width: ScreenUtil().setWidth(44),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 标题和状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_mining_key_9,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(6)),
                Text(
                  isEnabled ? 'Available' : 'Requires staking',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: isEnabled 
                        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                        : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          // 启动按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? () => MiningBackground().backgroundStart() : null,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(28),
                  vertical: ScreenUtil().setWidth(14),
                ),
                decoration: BoxDecoration(
                  gradient: isEnabled 
                      ? LinearGradient(
                          colors: [
                            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isEnabled ? null : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
                  boxShadow: isEnabled ? [
                    BoxShadow(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Text(
                  S.of(context).g_key_wallet_c4,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.white : const Color(0xFFBAC2CC),
                  ),
                ),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 根据标题选择不同的主题色
    Color accentColor;
    IconData iconData;
    if (titleText.contains('Today') || titleText.toLowerCase().contains('今日')) {
      accentColor = const Color(0xFF4CAF50); // 绿色 - 今日奖励
      iconData = Icons.today_outlined;
    } else if (titleText.contains('Yesterday') || titleText.contains('Last') || titleText.toLowerCase().contains('昨日')) {
      accentColor = const Color(0xFFFF9800); // 橙色 - 昨日奖励
      iconData = Icons.history_outlined;
    } else if (titleText.contains('Total') || titleText.toLowerCase().contains('总')) {
      accentColor = const Color(0xFF2196F3); // 蓝色 - 总奖励
      iconData = Icons.account_balance_outlined;
    } else if (titleText.contains('Value') || titleText.toLowerCase().contains('价值')) {
      accentColor = const Color(0xFF9C27B0); // 紫色 - 价值
      iconData = Icons.attach_money_outlined;
    } else {
      accentColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
      iconData = Icons.analytics_outlined;
    }
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha:0.06) : Colors.black.withValues(alpha:0.04),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行
            Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Icon(
                    iconData,
                    size: ScreenUtil().setWidth(18),
                    color: accentColor,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Expanded(
                  child: Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(20),
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
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(18)),
                      child: Text(
                        tipsText ?? '',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(24),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(14)),
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
  /// 美化后的风险卡片
  Widget _buildRiskCard(MiningV2Provider mpValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 根据风险等级设置颜色
    final scoreValue = double.tryParse(mpValue.inactivityScorePercentage) ?? 0.0;
    Color riskColor;
    if (scoreValue <= 33.33) {
      riskColor = const Color(0xFF4CAF50); // 绿色 - 低风险
    } else if (scoreValue <= 66.66) {
      riskColor = const Color(0xFFFF9800); // 橙色 - 中风险
    } else {
      riskColor = const Color(0xFFF44336); // 红色 - 高风险
    }

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部区域 - 风险图标和标题
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Row(
              children: [
                // 风险图标
                Container(
                  width: ScreenUtil().setWidth(80),
                  height: ScreenUtil().setWidth(80),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        riskColor.withValues(alpha:0.2),
                        riskColor.withValues(alpha:0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/mining/Mascot.png',
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(50),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(20)),
                // 风险标题和描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mpValue.inactivityTitle,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            width: ScreenUtil().setWidth(12),
                            height: ScreenUtil().setWidth(12),
                            decoration: BoxDecoration(
                              color: riskColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setWidth(8)),
                      Text(
                        S.of(context).g_mining_key_75,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(22),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 风险进度条
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? ScreenUtil().setWidth(8) : 0),
                    child: _buildProgressBar(mpValue.inactivityScore[index], riskColor),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          // 风险分数
          Container(
            margin: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(24),
              0,
              ScreenUtil().setWidth(24),
              ScreenUtil().setWidth(24),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(16),
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha:0.04)
                  : riskColor.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: ScreenUtil().setWidth(28),
                      color: riskColor,
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Text(
                      S.of(context).g_mining_key_76,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  ),
                  child: Text(
                    "${mpValue.inactivityScorePercentage}%",
                    style: TextStyle(
                      color: riskColor,
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //提醒
          if(mpValue.balanceInBeacon<32)
          Container(
            margin: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(24),
              0,
              ScreenUtil().setWidth(24),
              ScreenUtil().setWidth(24),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(26),
            ),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name).withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: ScreenUtil().setWidth(28),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  flex: 1,
                  child: Text(
                  S.of(context).g_mining_key_116(32),
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                  ),
                ),),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 美化后的进度条
  Widget _buildProgressBar(double value, Color color) {
    return Container(
      height: ScreenUtil().setWidth(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha:0.8), color],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
          ),
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
                    Provider.of<WalletActionProvider>(context,listen: false).setWalletMiningIndex(wInfo.index);
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

