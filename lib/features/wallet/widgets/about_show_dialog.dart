import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_html_css/simple_html_css.dart';

void aboutShowDialog(BuildContext context, String aboutStr, String title) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
        topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.space8),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 1.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(50.0),
                    height: ScreenUtil().setWidth(50.0),
                    padding: EdgeInsets.all(AppSpacing.space2),
                    child: Icon(Icons.close),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space8),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: RichText(
                  text: HTML.toTextSpan(
                    context,
                    aboutStr,
                    defaultTextStyle: AppTypography.bodySm.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      // etc etc
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
