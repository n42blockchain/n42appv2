
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ASTMiningBoard extends StatelessWidget {
  final int astNum;

  const ASTMiningBoard({
    super.key,
    required this.astNum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(44),
          ),
          _buildBoard(context),
          SizedBox(
            height: ScreenUtil().setWidth(72),
          ),
          _buildItems(context),
          SizedBox(
            height: ScreenUtil().setWidth(20),
          ),
        ],
      ),
    );
  }

  String _getLevelText(BuildContext context) => switch (astNum) {
    50 => S.of(context).g_mining_key_62,
    100 => S.of(context).g_mining_key_61,
    _ => S.of(context).g_mining_key_63,
  };

  String _getTimes() => astNum == 50 ? "70" : "15";

  Widget _buildBoard(BuildContext context) {
    final bigImage = "assets/mining/ast_$astNum.png";
    final levelText = _getLevelText(context);
    final times = _getTimes();
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              bigImage,
              width: ScreenUtil().setWidth(216),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: ScreenUtil().setWidth(34),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelText,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$astNum",
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontSize:ScreenUtil().setSp(104),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CoinType.N.name,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                            fontSize:ScreenUtil().setSp(32)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(20),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(12),
                      ),
                      Expanded(
                        child: Text(
                          S.current.g_mining_key_32,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize:ScreenUtil().setSp(24)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: ScreenUtil().setWidth(36),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTag(context, "assets/mining/icon_full_node.png", S.of(context).g_mining_key_64),
            SizedBox(width: ScreenUtil().setWidth(32)),
            _buildTag(context, "assets/mining/lock_time.png", "$times ${S.of(context).g_mining_key_65}"),
          ],
        ),
      ],
    );
  }

  Widget _buildItems(BuildContext context) {
    final (maxReward, dailyLimit, rewardDistribution) = switch (astNum) {
      50 => ("4.5", S.of(context).g_mining_key_69, S.of(context).g_mining_key_71("0.5", "20,000")),
      100 => ("12", S.of(context).g_mining_key_70, S.of(context).g_mining_key_71("0.5", "1,500")),
      _ => ("75", S.of(context).g_mining_key_70, S.of(context).g_mining_key_71("0.625", "300")),
    };

    final divider = Divider(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
      indent: 1,
      endIndent: 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(context, "assets/mining/medal-star.png",
            S.current.g_mining_key_33, "$maxReward ${CoinType.N.name}"),
        divider,
        _buildItem(context, "assets/mining/flash.png",
            S.current.g_mining_key_36, S.of(context).g_mining_key_72),
        divider,
        _buildItem(context, "assets/mining/star.png",
            S.current.g_mining_key_35, dailyLimit),
        divider,
        _buildItem(context, "assets/mining/grid-lock.png",
            S.current.g_mining_key_34, rewardDistribution),
      ],
    );
  }

  Widget _buildItem(
      BuildContext context, String iconPath, String action, String desc) {
    final textStyle = TextStyle(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      fontSize: ScreenUtil().setSp(24),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(28)),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
            ),
            width: ScreenUtil().setWidth(44),
            height: ScreenUtil().setWidth(44),
            child: Center(
              child: Image.asset(
                iconPath,
                width: ScreenUtil().setWidth(24),
                height: ScreenUtil().setWidth(24),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(child: Text(action, style: textStyle)),
          Expanded(child: Text(desc, style: textStyle, maxLines: 2)),
          Image.asset(
            "assets/mining/duihao.png",
            width: ScreenUtil().setWidth(20),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String iconPath, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff373739) : const Color(0xffEDEFF2),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: ScreenUtil().setWidth(24),
            fit: BoxFit.cover,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Text(
            text,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(24),
            ),
          ),
        ],
      ),
    );
  }
}