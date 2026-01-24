import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

///密码输入确认
Future<bool?> tipsDialog4(
    BuildContext context, String? title,{TextEditingController? controller,String? hintText}) async {
  return await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(
              ScreenUtil().setWidth(30),
            ),
            child: Text(
              title ?? S.of(context).g_key_21,
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.bold
              ),
            ),
          ),

          Container(
            height: ScreenUtil().setWidth(120),
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              top: ScreenUtil().setWidth(20),
              bottom: ScreenUtil().setWidth(50),
            ),
            child: CommInput(
              type: InputFieldType.password,
              hintText: hintText ?? S.of(context).g_key_21,
              controller: controller,
              maxLines: 1,
            ),
          ),

          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          SizedBox(
            height: ScreenUtil().setWidth(80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Center(
                      child: Text(
                        S.of(context).g_key_79,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(30)),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.dividerColor.name),
                  width: 1,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          S.of(context).g_key_78,
                          style: TextStyle(
                            // color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                              fontSize: ScreenUtil().setSp(30)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
