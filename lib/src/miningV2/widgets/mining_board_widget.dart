
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题区域
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(24),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(20)),
                topRight: Radius.circular(ScreenUtil().setWidth(20)),
              ),
            ),
            child: Text(
              S.of(context).g_mining_key_62, // "Entry"
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // 主内容区域
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            child: Column(
              children: [
                _buildBoard(context),
                SizedBox(height: ScreenUtil().setWidth(40)),
                _buildItems(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    const String bigImage = "assets/mining/ast_50.png";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧图片 - 添加渐变背景
        Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setWidth(180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4FACFE).withOpacity(0.15),
                const Color(0xFF00F2FE).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          ),
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child: Image.asset(
            bigImage,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(30)),
        // 右侧内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 数量显示
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$nNum",
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(80),
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  Text(
                    CoinType.N.name,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil().setSp(28),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(24)),
              // 解锁信息
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(10),
                ),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(28),
                      height: ScreenUtil().setWidth(28),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unlock Period:",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                              fontSize: ScreenUtil().setSp(20),
                            ),
                          ),
                          Text(
                            "Unlockable at any time",
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(22),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItems(BuildContext context) {
    final String rewardPerVerification =
        "${toEther('$cReward', 9)} ${CoinType.N.name}";
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            context, 
            "assets/mining/medal-star.png",
            S.current.g_mining_key_33,
            rewardPerVerification,
            const Color(0xFF5C6BC0), // 紫蓝色
          ),
          _buildDivider(context),
          _buildItem(
            context, 
            "assets/mining/flash.png",
            S.current.g_mining_key_36,
            S.of(context).g_mining_key_72,
            const Color(0xFF26A69A), // 青色
          ),
          _buildDivider(context),
          _buildItem(
            context, 
            "assets/mining/grid-lock.png",
            S.current.g_mining_key_34,
            S.current.g_mining_key_74,
            const Color(0xFFFF7043), // 橙色
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name).withOpacity(0.5),
      height: 1,
      indent: ScreenUtil().setWidth(70),
      endIndent: ScreenUtil().setWidth(16),
    );
  }

  Widget _buildItem(
      BuildContext context, String iconPath, String action, String desc, Color iconBgColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(24),
        horizontal: ScreenUtil().setWidth(16),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: ScreenUtil().setWidth(24),
                height: ScreenUtil().setWidth(24),
                fit: BoxFit.contain,
                color: iconBgColor,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // 标题
          Expanded(
            flex: 2,
            child: Text(
              action,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24),
              ),
            ),
          ),
          // 值
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    desc,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Container(
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(16),
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}