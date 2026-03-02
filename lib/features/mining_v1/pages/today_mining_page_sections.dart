part of 'today_mining_page.dart';

/// Large section widgets for [_TodayMiningPageState].
///
/// Depends on [_WidgetsMixin] for shared helper widgets and
/// [_LogicMixin] (transitively) for all state fields.
/// Contains background mining and mining activity sections.
mixin _SectionsMixin on _WidgetsMixin {
  Widget backgroundMiningWidget(MiningProvider mpValue) {
    if (mpValue.depositsEnable == false) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
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
          buttonStyle3(
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
            paddingV: ScreenUtil().setWidth(12.0),
            paddingH: ScreenUtil().setWidth(32.0),
          ),
        ],
      ),
    );
  }

  Widget miningActivityWidget(MiningProvider mpValue) {
    if (mpValue.depositsEnable == true) {
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).g_mining_key31,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40)),
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
                  isLoadingTaskList
                      ? Center(
                          child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(60)),
                          child: Loading(),
                        ))
                      : taskList.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(60)),
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
                                    var item = taskList[index];
                                    if (item == null) {
                                      return GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      MiningTaskList(
                                                        address: astAddress,
                                                      )));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  AppThemeUtils.getColorByKey(
                                                      context,
                                                      AppThemeKeys
                                                          .itemBgColor.name)),
                                          child: Center(
                                            child: Text(
                                              "${S.of(context).g_mining_key_49}...",
                                              style: TextStyle(
                                                  color: AppThemeUtils
                                                      .getColorByKey(
                                                          context,
                                                          AppThemeKeys
                                                              .mainBlueColor.name),
                                                  fontSize:
                                                      ScreenUtil().setSp(30)),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (_) => TaskDetailPage(
                                                      blockNumber:
                                                          "${item["blockNumber"]}",
                                                      astValue:
                                                          dataUtils.formatNum(
                                                              toEther(
                                                                      "${BigInt.tryParse(item["reward"])}",
                                                                      18)
                                                                  .toDouble(),
                                                              8),
                                                    )));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                ScreenUtil().setWidth(20)),
                                        child: TaskItem(
                                          taskId:
                                              "${BigInt.tryParse(item["blockNumber"])}",
                                          astValue: dataUtils.formatNum(
                                              toEther(
                                                      "${BigInt.tryParse(item["reward"])}",
                                                      18)
                                                  .toDouble(),
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

  Widget yourTierWidget() {
    return Row(
      children: [
        _tierCard(
          title: S.of(context).g_mining_key38,
          value: '$currDepositsOfValue ${CoinType.N.name}',
        ),
        SizedBox(width: ScreenUtil().setWidth(24)),
        _tierCard(
          title: "Tier Value",
          value: "\$${NumberFormat("#,##0.0#", "en_US").format(astPrice * currDepositsOfValue)}",
        ),
      ],
    );
  }

  Widget _tierCard({required String title, required String value}) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(26),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(30)),
            Text(
              value,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nextRewardInWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/mining/next_reward_in.png',
            height: ScreenUtil().setWidth(84),
            width: ScreenUtil().setWidth(84),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
              ),
              child: Text(
                '24H Reward',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Text(
            "${dataUtils.doubleFixed(last24HValue, 3)}${CoinType.N.name}",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26)),
          )
        ],
      ),
    );
  }
}
