import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class WalletChainInfoTitle extends StatelessWidget {

  Widget? title; //主标题
  Widget? subtitle; //副标题
  Widget? rightWidget; //右侧按钮
  String? rightImgUrl;
  Widget? rightTaoChangeNetworkWidget; //切换网络widget

  GestureTapCallback? rightTao; //去行情页点击事件
  WalletChainInfoTitle({
    @required this.title,
    @required this.subtitle,
    @required this.rightWidget,
    @required this.rightImgUrl,
    @required this.rightTao,
    @required this.rightTaoChangeNetworkWidget,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
      alignment: Alignment.topCenter,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: SizedBox(
              width: ScreenUtil().setWidth(50.0),
              height: ScreenUtil().setWidth(50.0),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                size: ScreenUtil().setWidth(40.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (title != null) title!,
                if (subtitle != null) subtitle!,
              ],
            ),
          ),
          rightChangeNetworkButton(context,),
          rightButton(context,),
        ],
      ),
    );
  }

  rightButton(
      context,
      ) {
    if (rightImgUrl != null) {
      return InkWell(
        onTap: rightTao,
        child: Container(
          width: ScreenUtil().setWidth(50.0),
          height: ScreenUtil().setWidth(50.0),
          padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
          child: Image.asset(
            rightImgUrl!,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      );
    } else if (rightWidget != null) {
      return rightWidget;
    } else {
      return SizedBox(
        width: rightTaoChangeNetworkWidget == null ? ScreenUtil().setWidth(50.0) : 0,
      );
    }
  }

  rightChangeNetworkButton(context) {
    if (rightTaoChangeNetworkWidget != null) {
      return rightTaoChangeNetworkWidget;
    } else {
      return SizedBox();
    }
  }
}

