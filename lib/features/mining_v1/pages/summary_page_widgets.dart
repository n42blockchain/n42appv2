part of 'summary_page.dart';

/// Widget builder mixin for SummaryPage.
/// Provides extracted widget builder methods used in the build tree.
mixin _SummaryPageWidgetsMixin on State<SummaryPage>, _SummaryPageLogicMixin {
  Widget buildBarChart(BuildContext context) {
    const defaultBlue = Color.fromRGBO(25, 118, 249, 0.1);
    final barWidth = ScreenUtil().setWidth(20);

    return ChartHistogram(
      isLoading: isLoading7DayData,
      titleModel: TitleModel(),
      barChartModel: isShowDefaultBar
          ? BarChartModel(
              bgColor: defaultBlue,
              fgColor: defaultBlue,
              fgColorMax: defaultBlue,
              touchColor: defaultBlue,
              width: barWidth,
              values: [10, 10, 10, 10, 10, 10, 10],
            )
          : BarChartModel(
              bgColor: defaultBlue,
              fgColor: const Color.fromRGBO(25, 118, 249, 1),
              fgColorMax: const Color.fromRGBO(50, 215, 75, 1),
              touchColor: Colors.yellowAccent,
              width: barWidth,
              values: barValues,
            ),
      bottomTitle: BottomTitle(
        titles: getPast7DaysDate(),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        specialStyle: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: AppColorTokens.of(context).textItem,
          fontWeight: FontWeight.w600,
        ),
        space: ScreenUtil().setWidth(36),
      ),
      alertMessageGroups: alertMessageList,
    );
  }

  Widget buildSummaryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(44),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
            context,
            S.current.g_mining_key_13,
            '${dataUtils.doubleFixed(totalValue, 4)} ${CoinType.N.name}',
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            S.current.g_mining_key_20,
            "\$${NumberFormat("#,##0.0#", "en_US").format((astPrice * totalValue))}",
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            S.current.g_mining_key_59,
            '${dataUtils.doubleFixed(accumulatedRewards, 4)} ${CoinType.N.name}',
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
            S.current.g_mining_key_60,
            '${dataUtils.doubleFixed(rewardsReceived, 4)} ${CoinType.N.name}',
          ),
          SizedBox(height: ScreenUtil().setWidth(32)),
          _buildSummaryRow(
            context,
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

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.ff888888.name,
            ),
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColorTokens.of(context).textPrimary,
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            S.current.g_mining_key_7,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.ff888888.name,
              ),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
        ),
        if (isCanUnlock)
          GestureDetector(
            onTap: unLockAstMining,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffD1E4FE),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(86)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setWidth(14),
              ),
              child: Text(
                S.of(context).g_mining_key_50,
                style: TextStyle(
                  color: AppColorTokens.of(context).brand,
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          Text(
            lockTimeStr ?? "00/00/00",
            style: TextStyle(
              color: AppColorTokens.of(context).textPrimary,
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget buildRewardHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppColorTokens.of(context).bgSurface,
      ),
      child: Column(
        children: [
          _buildRewardHistoryHeader(context),
          Column(
            children: [
              if (rewardsList.isEmpty)
                Column(
                  children: [
                    SizedBox(height: ScreenUtil().setWidth(180)),
                    EmptyView(),
                    SizedBox(height: ScreenUtil().setWidth(180)),
                  ],
                ),
              ListView.builder(
                shrinkWrap: true,
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = rewardsList[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                    ),
                    child: TaskItem(
                      taskId: "${BigInt.tryParse(item["blockNumber"])}",
                      astValue:
                          "${dataUtils.formatNum(toEther("${BigInt.tryParse(item["value"])}", 18).toDouble(), 2)} ${CoinType.N.name}",
                      time: dataUtils.getTimeByTimeStamp(
                        "${hexToInt(item["timestamp"])}",
                        format: "dd/MM/yyyy",
                      ),
                      status: "success",
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

  Widget _buildRewardHistoryHeader(BuildContext context) {
    final headerStyle = TextStyle(
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainWhiteColor.name,
      ),
      fontSize: ScreenUtil().setSp(30),
    );

    return Container(
      height: ScreenUtil().setWidth(72),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(48)),
              child: Text(
                S.of(context).g_key_wallet_k54,
                style: headerStyle,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            child: Text(
              S.of(context).g_key_44,
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
              child: Text(
                S.of(context).g_key_wallet_k25,
                style: headerStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
