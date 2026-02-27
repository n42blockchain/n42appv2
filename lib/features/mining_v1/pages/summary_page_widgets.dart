part of 'summary_page.dart';

/// Widget builder mixin for SummaryPage.
/// Provides extracted widget builder methods used in the build tree.
mixin _SummaryPageWidgetsMixin on State<SummaryPage>, _SummaryPageLogicMixin {

  /// 柱状图展示历史7天挖矿数据
  Widget buildBarChart(BuildContext context) {
    return ChartHistogram(
      isLoading: isLoading7DayData,
      titleModel: TitleModel(),
      barChartModel: isShowDefaultBar
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
              values: barValues,
            ),
      bottomTitle: BottomTitle(
        titles: getPast7DaysDate(),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
        specialStyle: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemTextColor.name),
          fontWeight: FontWeight.w600,
        ),
        space: ScreenUtil().setWidth(36),
      ),
      alertMessageGroups: alertMessageList,
    );
  }

  /// Summary 数据卡片
  Widget buildSummaryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16))),
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(44)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
            context,
            // "Total Rewards"
            S.current.g_mining_key_13,
            '${dataUtils.doubleFixed(totalValue, 4)} ${CoinType.N.name}',
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            // "Total Value Mined"
            S.current.g_mining_key_20,
            "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * totalValue))}",
          ),
          //未发放奖励
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            // "Accumulated Rewards"
            S.current.g_mining_key_59,
            '${dataUtils.doubleFixed(accumulatedRewards, 4)} ${CoinType.N.name}',
          ),
          //已发放奖励
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            // "Rewards received"
            S.current.g_mining_key_60,
            '${dataUtils.doubleFixed(rewardsReceived, 4)} ${CoinType.N.name}',
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            // "Mining Since"
            S.current.g_mining_key_21,
            lockTimeStr == null
                ? "00/00/00"
                : getYearAgoTime(lockTimeStr ?? ''),
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildUnlockRow(context),
        ],
      ),
    );
  }

  /// 通用 summary 行：左侧 label，右侧 value
  Widget _buildSummaryRow(
      BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.ff888888.name),
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        Text(
          value,
          style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// 解锁日期行（含 unlock 按钮）
  Widget _buildUnlockRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          // "Unlock date"
          S.current.g_mining_key7,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.ff888888.name),
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        Row(
          children: [
            if (!isCanUnlock)
              Text(
                lockTimeStr ?? "00/00/00",
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.bold),
              ),
            if (isCanUnlock)
              GestureDetector(
                onTap: () {
                  //解除质押
                  unLockAstMining();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffD1E4FE),
                      borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(86))),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                      vertical: ScreenUtil().setWidth(14)),
                  child: Text(
                    // "To unlock"
                    S.of(context).g_mining_key_50,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(22),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        )
      ],
    );
  }

  /// Reward History 列表
  Widget buildRewardHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ScreenUtil().setWidth(16),
        ),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          _buildRewardHistoryHeader(context),
          Column(
            children: [
              if (rewardsList.isEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: ScreenUtil().setWidth(180),
                    ),
                    EmptyView(),
                    SizedBox(
                      height: ScreenUtil().setWidth(180),
                    )
                  ],
                ),
              ListView.builder(
                shrinkWrap: true,
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  var item = rewardsList[index];
                  return GestureDetector(
                    onTap: () async {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(20)),
                      child: TaskItem(
                        taskId:
                        "${BigInt.tryParse(item["blockNumber"])}",
                        astValue:
                        "${dataUtils.formatNum(toEther("${BigInt.tryParse(item["value"])}", 18).toDouble(), 2)} ${CoinType.N.name}",
                        time: dataUtils.getTimeByTimeStamp(
                            "${hexToInt(item["timestamp"])}",
                            format: "dd/MM/yyyy"),
                        status: "success",
                      ),
                    ),
                  );
                },
                itemCount: rewardsList.length,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reward History 表头
  Widget _buildRewardHistoryHeader(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(72),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromRGBO(135, 161, 255, 1),
              Color.fromRGBO(60, 133, 255, 1),
              Color.fromRGBO(25, 118, 249, 1),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil().setWidth(16)),
            topRight: Radius.circular(ScreenUtil().setWidth(16)),
          )),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  EdgeInsets.only(left: ScreenUtil().setWidth(48)),
              child: Text(
                S.of(context).g_key_wallet_k54,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainWhiteColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              S.of(context).g_key_44,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainWhiteColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  EdgeInsets.only(right: ScreenUtil().setWidth(48)),
              child: Text(
                S.of(context).g_key_wallet_k25,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainWhiteColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
