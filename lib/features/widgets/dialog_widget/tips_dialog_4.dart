import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/shared/widgets/tips_dialog_3.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

///密码输入确认
Future<bool?> tipsDialog4(
  BuildContext context,
  String? title, {
  TextEditingController? controller,
  String? hintText,
}) async {
  return await tipsDialog3(
    context,
    Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppColorTokens.of(context).bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    child: Text(
                      title ?? S.of(context).g_key_21,
                      style: TextStyle(
                        color: AppColorTokens.of(context).textPrimary,
                        fontSize: ScreenUtil().setSp(30),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Container(
                    height: ScreenUtil().setWidth(120),
                    decoration: BoxDecoration(
                      color: AppColorTokens.of(context).bgSurface,
                      borderRadius: AppRadius.brMd,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                    ),
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
                ],
              ),
            ),
          ),

          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
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
                          color: AppColorTokens.of(context).textSubtitle,
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(color: AppColorTokens.of(context).border, width: 1),
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
                            color: AppColorTokens.of(context).brand,
                            fontSize: ScreenUtil().setSp(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
