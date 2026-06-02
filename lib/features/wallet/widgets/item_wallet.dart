import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  const ItemWallet({
    required this.iconPath,
    required this.coinType,
    required this.coinAddress,
    this.fullName = "",
    this.onTap,
    super.key,
  });

  Widget _buildImage() {
    if (coinType == CoinType.N.name) {
      return Image.asset(
        'assets/img/ast.png',
        width: ScreenUtil().setWidth(52.0),
        height: ScreenUtil().setWidth(52.0),
        fit: BoxFit.cover,
      );
    }
    return ImageNetWork(
      imageUrl: iconPath,
      width: ScreenUtil().setWidth(52.0),
      height: ScreenUtil().setWidth(52.0),
      placeholder: "assets/img/list_default.png",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brSm,
          child: Ink(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
              borderRadius: AppRadius.brSm,
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.space6,
              horizontal: AppSpacing.space8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(),
                SizedBox(width: AppSpacing.space6),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coinType,
                        style: AppTypography.body.copyWith(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.space2),
                      Text(
                        coinAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.space6),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: ScreenUtil().setWidth(30.0),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
