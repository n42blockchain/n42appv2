import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
// 修改备注
// 备注过长最好不要超过15个字符
Future<bool?> tipsDialog5(BuildContext context,
    {TextEditingController? controller, String? title}) async {
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
              title ?? '',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: ScreenUtil().setWidth(60),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
            child: Text(
              S.of(context).g_key_8,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name)
              ),
            ),
          ),
          Container(
            height: ScreenUtil().setWidth(170),
            width: double.infinity,
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
              bottom: ScreenUtil().setWidth(50),
            ),
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
            child: textFieldStyle3(
              context,
              controller: controller,
              hintText: S.of(context).g_key_8,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(FocusNode());
              },
              textInputAction: TextInputAction.done,
              maxLines: 3,
              maxLengths:100,
              height: ScreenUtil().setWidth(170.0),
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
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_key_78,
                        style: TextStyle(
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
