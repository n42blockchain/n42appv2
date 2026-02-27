part of 'today_mining_page.dart';

/// UI widget builder methods for [_TodayMiningPageState].
///
/// Depends on [_LogicMixin] for all shared state and business methods.
/// Contains status cards, time displays, data boards, and tier widgets.
mixin _WidgetsMixin on _LogicMixin {
  miningStatusWidget(MiningProvider mpValue) {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(18),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(26),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // "Mining Status",
                          S.of(context).g_mining_key_5,
                          maxLines: 2,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setWidth(32),
                        width: ScreenUtil().setWidth(32),
                        margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                        decoration: BoxDecoration(
                          color: mpValue.miningType != null &&
                                  mpValue.miningStatus == true
                              ? const Color.fromRGBO(50, 215, 75, 0.2)
                              : const Color.fromRGBO(235, 88, 81, 0.2),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                        ),
                        child: Container(
                          height: ScreenUtil().setWidth(16),
                          width: ScreenUtil().setWidth(16),
                          decoration: BoxDecoration(
                            color: mpValue.miningType != null &&
                                    mpValue.miningStatus == true
                                ? const Color(0xff32D74B)
                                : const Color(0xffEB5851),
                            borderRadius:
                                BorderRadius.circular(ScreenUtil().setWidth(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mpValue.miningType != null &&
                                mpValue.miningStatus == true
                            ? S.current.g_key_193
                            : S.current.g_mining_key_47,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (miningStartLoad == Load.loading) {
                            return;
                          }
                          if (mpValue.miningType == null) {
                            //未开启挖矿
                            return;
                          }
                          setState(() {
                            miningStartLoad = Load.loading;
                          });
                          if (mpValue.miningStatus == true) {
                            //停止
                            SPUtil().setMiningOpen(false);
                            globalMiningV1
                                .setMiningStatus(false);
                            await MiningUtils.stopMining();
                          } else {
                            //开启
                            SPUtil().setMiningOpen(true);
                            globalMiningV1.setMiningStatus(true);
                            await MiningUtils.startMining();
                          }
                          setState(() {
                            miningStartLoad = Load.finish;
                          });
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(40),
                          width: ScreenUtil().setWidth(40),
                          child: miningStartLoad == Load.finish
                              ? Image.asset(
                                  "assets/mining/${mpValue.miningType != null && mpValue.miningStatus == true ? 'stop' : 'play'}.png",
                                  color: AppThemeUtils.getColorByKey(
                                      context,
                                      mpValue.miningType != null &&
                                              mpValue.miningStatus == true
                                          ? AppThemeKeys.mainBlueColor.name
                                          : AppThemeKeys.iconTextDisableColor.name),
                                  height: ScreenUtil().setWidth(40),
                                  width: ScreenUtil().setWidth(40),
                                )
                              : CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(22),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(26),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).g_mining_key38,
                    // "Your Tier",
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mpValue.miningType == null
                            ? "0 ${CoinType.N.name}"
                            : '$currDepositsOfValue ${CoinType.N.name}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
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

  dayMiningTimeWidget(MiningProvider mpValue) {
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
            'assets/mining/daily_mining_time.png',
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
                // 'Current Mining Time',
                S.of(context).g_mining_key_8,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          showTimeWidget(currentMiningTimes[0], currentMiningTimes[1],
              currentMiningTimes[2])
        ],
      ),
    );
  }

  showTimeWidget(String hh, String mm, String ss) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            hh,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
          child: Text(
            ":",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            mm,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
          child: Text(
            ":",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.timeBorderColor.name))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
          child: Text(
            ss,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26)),
          ),
        ),
      ],
    );
  }

  miningDataBroad(String titleText, String value,
      {bool showTips = false, String? imagePath, String? tipsText}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
        padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), ScreenUtil().setWidth(30),
            ScreenUtil().setWidth(0), ScreenUtil().setWidth(0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      maxLines: 2,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                  ),
                  if (showTips)
                    CustomPopupMenuWrap(
                        key: ValueKey(titleText),
                        verticalMargin: ScreenUtil().setWidth(24),
                        defView: Padding(
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(12)),
                          child: Image.asset(
                            "assets/mining/tips_icon.png",
                            width: ScreenUtil().setWidth(20),
                            fit: BoxFit.cover,
                          ),
                        ),
                        menuItemView: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(50)),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemBgColor.name),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(28), vertical: ScreenUtil().setWidth(30)),
                          child: Text(
                            tipsText ?? '',
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                        ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(30)),
                ),
                Image.asset(
                  imagePath ?? '',
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setWidth(90),
                  fit: BoxFit.cover,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

}
