part of 'mining_today_v2.dart';

/// Widget builder mixin for MiningTodayV2.
/// Provides extracted widget builder methods used in the build tree.
mixin _MiningTodayV2WidgetsMixin
    on ConsumerState<MiningTodayV2>, _MiningTodayV2LogicMixin {
  /// 顶部导航栏
  Widget buildTopBar(BuildContext context) {
    return AppHomeTopBar(
      title: S.current.g_home_key3,
      titleChild: Builder(
        builder: (context) {
          final walletName = ref.watch(
            miningBridgeProvider.select((p) => p.walletName),
          );
          final blueColor = AppColorTokens.of(context).brand;
          return InkWell(
            onTap: showChangeAddress,
            child: Container(
              height: ScreenUtil().setWidth(80),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        walletName,
                        style: TextStyle(
                          color: blueColor,
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!AppConfig.isMainChainMining)
                        Text(
                          S.of(context).g_key_147,
                          style: TextStyle(
                            color: blueColor,
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
                      color: blueColor,
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
        SizedBox(width: ScreenUtil().setWidth(10)),
        InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MiningSetting()));
          },
          child: Image.asset(
            "assets/mining/set.png",
            width: ScreenUtil().setWidth(40),
            color: AppColorTokens.of(context).brand,
          ),
        ),
      ],
    );
  }

  /// 测试网警告横幅
  Widget buildTestnetWarning(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).dangerBg,
        borderRadius: AppRadius.brSm,
      ),
      child: Text(
        S.of(context).g_mining_key_74,
        style: TextStyle(
          color: AppColorTokens.of(context).danger,
          fontSize: ScreenUtil().setSp(26),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 顶部渐变 Banner：展示挖矿状态摘要
  Widget buildMiningBanner(BuildContext context, MiningV2Provider mpValue) {
    final isActive = mpValue.miningStatus == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColorTokens.of(context);
    final statusColor = isActive ? c.success : c.warning;

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
        borderRadius: AppRadius.brLg,
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
          Container(
            width: ScreenUtil().setWidth(72),
            height: ScreenUtil().setWidth(72),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(
              Icons.developer_board_rounded,
              color: Colors.white.withAlpha(220),
              size: ScreenUtil().setWidth(38),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
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
                    Flexible(
                      child: Text(
                        isActive
                            ? S.current.g_key_193
                            : S.current.g_mining_key_47,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 柱状图展示历史7天挖矿数据
  Widget buildBarChart(BuildContext context, MiningV2Provider mpValue) {
    return ChartHistogram(
      isLoading: mpValue.isLoading7DayData,
      titleModel: TitleModel(),
      barChartModel: mpValue.isShowDefaultBar
          ? BarChartModel(
              bgColor: const Color.fromRGBO(25, 118, 249, 0.08),
              fgColor: const Color.fromRGBO(25, 118, 249, 0.22),
              fgColorMax: const Color.fromRGBO(25, 118, 249, 0.22),
              touchColor: const Color.fromRGBO(25, 118, 249, 0.3),
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
        titles: mpValue.isShowDefaultBar
            ? ['/', '/', '/', '/', '/', '/', '/']
            : mpValue.barChartTitle,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(18),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        specialStyle: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: AppColorTokens.of(context).textItem,
          fontWeight: FontWeight.w600,
        ),
        space: ScreenUtil().setWidth(30),
      ),
      alertMessageGroups: mpValue.barChartAlertMessageList,
    );
  }

  /// 数据面板行（今日/昨日收益 + 总收益/总价值）
  Widget buildDataBroadRows(BuildContext context, MiningV2Provider mpValue) {
    return Column(
      children: [
        Row(
          children: [
            MiningDataBroad(
              titleText: S.of(context).g_mining_key_10,
              value:
                  "${dataUtils.formatNum(mpValue.todayCycleRewardsValue, 6)} ${CoinType.N.name}",
              imagePath: "assets/mining/broad_bg_4.png",
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            MiningDataBroad(
              titleText: S.of(context).g_mining_key_11,
              value:
                  "${dataUtils.formatNum(mpValue.yesterdayCycleRewardsValue, 6)} ${CoinType.N.name}",
              imagePath: "assets/mining/broad_bg_4.png",
              tipsText: S.of(context).g_mining_key_12,
              showTips: true,
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(20)),
        Row(
          children: [
            MiningDataBroad(
              titleText: S.of(context).g_mining_key_13,
              value:
                  '${dataUtils.formatNum(mpValue.miningTotalRevenue, 6)} ${CoinType.N.name}',
              imagePath: "assets/mining/broad_bg_1.png",
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            MiningDataBroad(
              titleText: S.of(context).g_mining_key_14,
              value:
                  "\$${NumberFormat("#,##0.0#", "en_US").format((mpValue.nPrice * mpValue.miningTotalRevenue))}",
              imagePath: "assets/mining/broad_bg_2.png",
              tipsText: S.of(context).g_mining_key_15,
              showTips: true,
            ),
          ],
        ),
      ],
    );
  }

  /// 赎回按钮和提示区域
  Widget buildRedemptionSection(
    BuildContext context,
    MiningV2Provider mpValue,
  ) {
    final isLoading = mpValue.exitDepositLoad == Load.loading;
    return Column(
      children: [
        if (mpValue.showRedemption == true && mpValue.redeem == false)
          Container(
            height: ScreenUtil().setWidth(88),
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
            child: AppButton(
              label: S.of(context).g_mining_key_77,
              loading: isLoading,
              onPressed: () {
                if (!isLoading) unLockAstMining();
              },
            ),
          ),
        if (mpValue.depositsEnable == true && mpValue.showRedemption == false)
          _buildOrangeTip(S.of(context).g_mining_key_88),
        if (mpValue.depositsEnable == true &&
            mpValue.redeem == true &&
            mpValue.showRedemption2 == true)
          _buildOrangeTip(S.of(context).g_mining_key_115),
      ],
    );
  }

  Widget _buildOrangeTip(String text) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      width: double.infinity,
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: AppColorTokens.of(context).warning,
        ),
      ),
    );
  }
}
