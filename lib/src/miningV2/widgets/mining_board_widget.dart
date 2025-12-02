
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';

class MiningBoardWidget extends StatelessWidget {
  final int nNum;
  final int cReward;//单次验证收益

  const MiningBoardWidget({
    Key? key,
    required this.nNum,
    required this.cReward,
  }) : super(key: key);

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

  _buildBoard(BuildContext context) {
    String bigImage = "assets/mining/ast_50.png";
    String levelText = S.of(context).g_mining_key_62;

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
              flex: 1,
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
                        "$nNum",
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
                        flex: 1,
                        child: Text(
                          // "Unlock Period: Unlockable at any time",
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
      ],
    );
  }

  _buildItems(BuildContext context) {
    /*String maxReward = nNum == 50
        ? "4.5"
        : nNum == 100
        ? "12"
        : "75";
    String dailyLimit = nNum == 50
        ? S.of(context).g_mining_key_69
        : nNum == 100
        ? S.of(context).g_mining_key_70
        : S.of(context).g_mining_key_70;
    String rewardDistribution = nNum == 50
        ? S.of(context).g_mining_key_71("0.5","20,000")
        : nNum == 100
        ? S.of(context).g_mining_key_71("0.5","1,500")
        : S.of(context).g_mining_key_71("0.625","300");*/

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(context, "assets/mining/medal-star.png",
            // "Max Reward Annually",
            //S.current.g_mining_key_33,
            "Revenue per verification",
            "${toEther('${cReward}', 9)} ${CoinType.N.name}"),
        Divider(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          indent: 1,
          endIndent: 1,
        ),
        _buildItem(
            context, "assets/mining/flash.png",
            // "Speed",
            S.current.g_mining_key_36,
            S.of(context).g_mining_key_72),
        /*Divider(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          indent: 1,
          endIndent: 1,
        ),
        _buildItem(
            context, "assets/mining/star.png",
            // "Daily Limit",
            S.current.g_mining_key_35,
            dailyLimit),*/
        Divider(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          indent: 1,
          endIndent: 1,
        ),
        _buildItem(context, "assets/mining/grid-lock.png",
            // "Reward Distribution",
            S.current.g_mining_key_34,
            "128 seconds per reward"),
        //every 20,000 blocks mined

      ],
    );
  }

  _buildItem(
      BuildContext context, String iconPath, String action, String desc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(28)),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
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
          SizedBox(
            width: ScreenUtil().setWidth(12),
          ),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24)),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24)),
              maxLines: 2,
            ),
          ),
          Image.asset(
            "assets/mining/duihao.png",
            width: ScreenUtil().setWidth(20),
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}