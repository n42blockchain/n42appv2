import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
//提示没有备份钱包
Future<bool?> tipsDialog7(BuildContext context,)async{
  return await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(30),
              horizontal: ScreenUtil().setWidth(30),
            ),
            child: Text(
              S.of(context).g_face_3,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: ScreenUtil().setWidth(20),
              bottom: ScreenUtil().setWidth(50),
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
            ),
            child: Text(
              S.of(context).g_key_wallet_c49,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
              ),
            ),
          ),
          Divider(height: ScreenUtil().setWidth(1),
            endIndent: 0,
            indent: 0,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    Navigator.pop(context,false);
                  },
                  child: Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(80),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_79,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: ScreenUtil().setWidth(80), // 容器的高度，可以根据需要调整
                width: 1, // 竖线的宽度
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name), // 竖线的颜色
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    Navigator.pop(context,true);
                  },
                  child: Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(80),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_wallet_c36,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}