import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef ShareType = void Function(int shareType);
class ShareList extends StatelessWidget {
  final ShareType callBack;
  const ShareList({ required this.callBack,super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_share_method,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    size: ScreenUtil().setWidth(44),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ))
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(40),
          ),
          //Partager le code QR
          _buildItem(context, S.of(context).g_key_share_code, () {
            callBack(0);
            Navigator.of(context).pop();
          }),
          _buildItem(context, S.of(context).g_key_share_link, () {
            callBack(1);
            Navigator.of(context).pop();
          }),
        ],
    );
  }

  Widget _buildItem(BuildContext context, String payTypeName, GestureTapCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(28)),
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            // color: Colors.transparent,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            border: Border.fromBorderSide(BorderSide(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemLineColor.name),
                width: 1))),
        child: Row(
          children: [
            Text(
              payTypeName,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
            )
          ],
        ),
      ),
    );
  }
}

