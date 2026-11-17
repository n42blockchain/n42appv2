import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

Future<void> alertWidget(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_swap_key_20(CoinType.N.name),
                style: AppTypography.titleLg.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space12,
                ),
                child: Image.asset(
                  "assets/home/swap/medal.png",
                  fit: BoxFit.cover,
                  height: ScreenUtil().setWidth(120),
                  color: AppColorTokens.of(context).brand,
                ),
              ),
              Text(
                S.of(context).g_swap_key_19,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.space12),
              // The fill is a Material so the ripple paints above it.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                child: Material(
                  color: AppColorTokens.of(context).brandFill,
                  borderRadius: AppRadius.brSm,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: AppRadius.brSm,
                    child: Container(
                      height: AppTouch.target,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_swap_key_18,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainButtonTextColor.name,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
