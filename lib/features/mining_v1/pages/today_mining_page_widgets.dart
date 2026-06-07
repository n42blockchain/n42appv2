part of 'today_mining_page.dart';

/// UI widget builder methods for [_TodayMiningPageState].
///
/// Depends on [_LogicMixin] for all shared state and business methods.
/// Contains status cards, time displays, data boards, and tier widgets.
mixin _WidgetsMixin on _LogicMixin {
  Widget miningStatusWidget(MiningProvider mpValue) {
    final isActive = mpValue.miningType != null && mpValue.miningStatus == true;
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(18)),
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
                color: AppColorTokens.of(context).bgSurface,
                borderRadius: AppRadius.brMd,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).g_mining_key_5,
                          maxLines: 2,
                          style: TextStyle(
                            color: AppColorTokens.of(context).textSubtitle,
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setWidth(32),
                        width: ScreenUtil().setWidth(32),
                        margin: EdgeInsets.only(
                          left: ScreenUtil().setWidth(10),
                        ),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color.fromRGBO(50, 215, 75, 0.2)
                              : const Color.fromRGBO(235, 88, 81, 0.2),
                          borderRadius: AppRadius.brMd,
                        ),
                        child: Container(
                          height: ScreenUtil().setWidth(16),
                          width: ScreenUtil().setWidth(16),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xff32D74B)
                                : const Color(0xffEB5851),
                            borderRadius: AppRadius.brMd,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          isActive
                              ? S.current.g_key_193
                              : S.current.g_mining_key_47,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColorTokens.of(context).textItem,
                            fontSize: ScreenUtil().setSp(32),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (miningStartLoad == Load.loading) return;
                          if (mpValue.miningType == null) return;
                          setState(() => miningStartLoad = Load.loading);
                          if (isActive) {
                            SPUtil().setMiningOpen(false);
                            globalMiningV1.setMiningStatus(false);
                            await MiningUtils.stopMining();
                          } else {
                            SPUtil().setMiningOpen(true);
                            globalMiningV1.setMiningStatus(true);
                            await MiningUtils.startMining();
                          }
                          if (!mounted) return;
                          setState(() => miningStartLoad = Load.finish);
                        },
                        child: SizedBox(
                          height: ScreenUtil().setWidth(40),
                          width: ScreenUtil().setWidth(40),
                          child: miningStartLoad == Load.finish
                              ? Image.asset(
                                  "assets/mining/${isActive ? 'stop' : 'play'}.png",
                                  color: AppThemeUtils.getColorByKey(
                                    context,
                                    isActive
                                        ? AppThemeKeys.mainBlueColor.name
                                        : AppThemeKeys
                                              .iconTextDisableColor
                                              .name,
                                  ),
                                  height: ScreenUtil().setWidth(40),
                                  width: ScreenUtil().setWidth(40),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(22)),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(26),
              ),
              decoration: BoxDecoration(
                color: AppColorTokens.of(context).bgSurface,
                borderRadius: AppRadius.brMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).g_mining_key38,
                    style: TextStyle(
                      color: AppColorTokens.of(context).textSubtitle,
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(30)),
                  Text(
                    mpValue.miningType == null
                        ? "0 ${CoinType.N.name}"
                        : '$currDepositsOfValue ${CoinType.N.name}',
                    style: TextStyle(
                      color: AppColorTokens.of(context).textItem,
                      fontSize: ScreenUtil().setSp(32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dayMiningTimeWidget(MiningProvider mpValue) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(18),
        horizontal: ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
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
                S.of(context).g_mining_key_8,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppColorTokens.of(context).textItem,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          showTimeWidget(
            currentMiningTimes[0],
            currentMiningTimes[1],
            currentMiningTimes[2],
          ),
        ],
      ),
    );
  }

  Widget showTimeWidget(String hh, String mm, String ss) {
    final blueColor = AppColorTokens.of(context).brand;
    final borderColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.timeBorderColor.name,
    );
    final textStyle = TextStyle(
      color: blueColor,
      fontSize: ScreenUtil().setSp(26),
    );

    Widget timeBox(String value) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        child: Text(value, style: textStyle),
      );
    }

    Widget separator() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12)),
        child: Text(":", style: textStyle),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        timeBox(hh),
        separator(),
        timeBox(mm),
        separator(),
        timeBox(ss),
      ],
    );
  }

  Widget miningDataBroad(
    String titleText,
    String value, {
    bool showTips = false,
    String? imagePath,
    String? tipsText,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
        ),
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(0),
          ScreenUtil().setWidth(0),
        ),
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
                          context,
                          AppThemeKeys.ff888888.name,
                        ),
                        fontSize: ScreenUtil().setSp(22),
                      ),
                    ),
                  ),
                  if (showTips)
                    CustomPopupMenuWrap(
                      key: ValueKey(titleText),
                      verticalMargin: ScreenUtil().setWidth(24),
                      defView: Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(12),
                        ),
                        child: Image.asset(
                          "assets/mining/tips_icon.png",
                          width: ScreenUtil().setWidth(20),
                          fit: BoxFit.cover,
                        ),
                      ),
                      menuItemView: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setWidth(50),
                          ),
                          color: AppColorTokens.of(context).bgSurface,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(100),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(28),
                          vertical: ScreenUtil().setWidth(30),
                        ),
                        child: Text(
                          tipsText ?? '',
                          style: TextStyle(
                            color: AppColorTokens.of(context).textPrimary,
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
                Image.asset(
                  imagePath ?? '',
                  width: ScreenUtil().setWidth(90),
                  height: ScreenUtil().setWidth(90),
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
