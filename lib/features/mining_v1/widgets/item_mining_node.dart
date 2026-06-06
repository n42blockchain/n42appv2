import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemMiningNode extends StatelessWidget {
  final String icon;
  final String countryName;
  final String nodeAddress;
  final String socketUrl;
  final GestureTapCallback? onTap;
  final bool isSelected;
  const ItemMiningNode({
    required this.icon,
    required this.countryName,
    required this.nodeAddress,
    this.onTap,
    required this.isSelected,
    required this.socketUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(24),
          vertical: ScreenUtil().setWidth(24),
        ),
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          color: Colors.transparent,
          border: Border.fromBorderSide(
            BorderSide(color: AppColorTokens.of(context).border, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countryName,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(12)),
                Text(
                  nodeAddress,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainGreyColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(12)),
                Text(
                  socketUrl,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainGreyColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ],
            ),
            isSelected
                ? Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(48),
                    color: AppColorTokens.of(context).brand,
                  )
                : SizedBox(width: ScreenUtil().setWidth(48)),
          ],
        ),
      ),
    );
  }
}
