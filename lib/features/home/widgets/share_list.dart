import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_share_method,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
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
          SizedBox(height: AppSpacing.space12),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space6,
              vertical: AppSpacing.space8,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              border: Border.fromBorderSide(BorderSide(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemLineColor.name),
                  width: 1)),
            ),
            child: Row(
              children: [
                Text(
                  payTypeName,
                  style: AppTypography.body.copyWith(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

