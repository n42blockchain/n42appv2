import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemMiningNode extends StatefulWidget {
  final String icon;
  final String countryName;
  final String nodeAddress;
  final String socketUrl;
  final GestureTapCallback? onTap;
  final bool isSelected;
  const ItemMiningNode({required this.icon,
    required this.countryName,
    required this.nodeAddress,
    this.onTap,
    required this.isSelected,
    required this.socketUrl,
    super.key});

  @override
  State<ItemMiningNode> createState() => _ItemMiningNodeState();
}

class _ItemMiningNodeState extends State<ItemMiningNode> {
  @override
  Widget build(BuildContext context) {
    return _buildItem(context, widget.icon, widget.countryName,
        widget.nodeAddress, widget.socketUrl,widget.onTap);
  }

  Widget _buildItem(context, icon, countryName, ip,socketUrl, GestureTapCallback? onTap) {
    //final innerIcon = "${AppConfig.userInfoHost}$icon";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(24)),
        margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            color: Colors.transparent,
            border: Border.fromBorderSide(BorderSide(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemLineColor.name),
                width: 1))),
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
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(12),
                ),
                Text(
                  ip,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainGreyColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(12),
                ),
                Text(
                  socketUrl,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainGreyColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ],
            ),
            widget.isSelected
                ? Icon(
              Icons.check,
              size: ScreenUtil().setWidth(48),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            )
                : SizedBox(
              width: ScreenUtil().setWidth(48),
            ),
          ],
        ),
      ),
    );
  }
}
