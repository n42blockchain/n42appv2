import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
/// 常用风格的提示框 只有（标题 取消 和 确定）
Future<bool?> tipsDialog2(
    BuildContext context, String title,{
      String? cancelText,
      String? sureText
    }) async {
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
              padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(20),
                  bottom: ScreenUtil().setWidth(50),
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30)),
              child: Text(
                title,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemTextColor.name),
                    fontSize: ScreenUtil().setSp(28)),
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
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          cancelText ?? S.of(context).g_key_79,
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
                        alignment: Alignment.center,
                        child: Text(
                          sureText ?? S.of(context).g_key_78,
                          style: TextStyle(
                            // color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                              fontSize: ScreenUtil().setSp(30)),
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