import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemWallet extends StatelessWidget {
  final String iconPath;
  final String fullName;
  final String coinType;
  final String coinAddress;
  final GestureTapCallback? onTap;
  const ItemWallet({required this.iconPath,
    required this.coinType,
    required this.coinAddress,
    this.fullName="",
    this.onTap,super.key});

  Widget _buildImage() {
    if (coinType == CoinType.N.name) {
      return Image.asset(
        'assets/img/ast.png',
        width: ScreenUtil().setWidth(52.0),
        height: ScreenUtil().setWidth(52.0),
        fit: BoxFit.cover,
      );
    }
    return ImageNetWork(imageUrl:
      iconPath,
      width: ScreenUtil().setWidth(52.0),
      height: ScreenUtil().setWidth(52.0),
      placeholder: "assets/img/list_default.png",
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0))),
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(10.0)),
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20.0),
            horizontal: ScreenUtil().setWidth(30.0)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(),
                SizedBox(
                  width: ScreenUtil().setWidth(20.0),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coinType,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(28.0),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(6.0),
                      ),
                      Text(
                        coinAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(28.0)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(20.0),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: ScreenUtil().setWidth(30.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
