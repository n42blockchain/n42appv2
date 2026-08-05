import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/shared/utils/in_app_browser.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 显示当前兑换汇率（1 payCoin = ? N）。
class SwapAstPriceWidget extends StatelessWidget {
  final SwapAstModel? youPay;
  final CoinModel? getCoinModel;
  final Regular regular;

  const SwapAstPriceWidget({
    super.key,
    required this.youPay,
    required this.getCoinModel,
    required this.regular,
  });

  @override
  Widget build(BuildContext context) {
    final double gCoinPrice = getCoinModel?.coinPrice ?? 0;
    final double yPrice = youPay?.price ?? 0;
    final String text;
    if (gCoinPrice != 0 && yPrice != 0) {
      final double pc = yPrice / gCoinPrice;
      text =
          "1${youPay?.payCoin ?? ""} = ${regular.formartNumDouble(dec.Decimal.parse(pc.toString()).toDouble(), 8, isCrop: true, isFill0: false)}${CoinType.N.name}";
    } else {
      text = "??${youPay?.payCoin ?? ""} = ??${CoinType.N.name}";
    }

    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      margin: AppSpacing.pageHorizontal,
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textPrimary,
        ),
      ),
    );
  }
}

/// 显示 25% / 50% / 75% / 100% 快速填充按钮。
class SwapAstPercentWidget extends StatelessWidget {
  final void Function(int percent) onPercentTap;

  const SwapAstPercentWidget({super.key, required this.onPercentTap});

  @override
  Widget build(BuildContext context) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - ScreenUtil().setWidth(60)) / 4;
    return Container(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      margin: AppSpacing.pageHorizontal,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, int index) {
          final int percent = 25 * (4 - index);
          // Material 包裹使按压 splash 在透明背景上可见；高 88.w(=44dp) 满足触控红线。
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onPercentTap(percent),
              borderRadius: AppRadius.brSm,
              child: Container(
                height: ScreenUtil().setWidth(88),
                width: itemWidth,
                alignment: Alignment.center,
                child: Text(
                  "$percent%",
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).brand,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 服务条款复选框 + 链接。
class SwapAstCheckWidget extends StatelessWidget {
  final bool readStatement;
  final void Function() onToggle;

  const SwapAstCheckWidget({
    super.key,
    required this.readStatement,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Material + 圆形 splash 让按压可见；触控区抬到 88.w(=44dp) 满足红线。
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: SizedBox(
                height: ScreenUtil().setWidth(88),
                width: ScreenUtil().setWidth(88),
                child: Icon(
                  readStatement
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    readStatement
                        ? AppThemeKeys.mainBlueColor.name
                        : AppThemeKeys.dividerColor.name,
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(500)),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: S.of(context).g_swap_key_16,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () {
                        InAppBrowser.open(context, "${AppConfig.apiUrl['n42Browser']!}/static/terms_of_use.html");
                      },
                      // 行内链接：补按压反馈 + 垂直外扩命中区（§5 红线）
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.space2,
                        ),
                        child: Text(
                          S.of(context).g_swap_key_17,
                          style: AppTypography.caption.copyWith(
                            decoration: TextDecoration.underline,
                            color: AppColorTokens.of(context).brand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部"预览兑换"按钮或"重试"按钮。
class SwapAstPreviewButton extends StatelessWidget {
  final Load load;
  final void Function() onPreview;
  final void Function() onRetry;

  const SwapAstPreviewButton({
    super.key,
    required this.load,
    required this.onPreview,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = load == Load.loading;

    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: Container(
        padding: AppSpacing.pageHorizontal,
        height: ScreenUtil().setWidth(88.0),
        child: load == Load.error
            ? AppButton(label: S.of(context).g_swap_key_6, onPressed: onRetry)
            : AppButton(
                label: S.of(context).g_swap_key_5,
                onPressed: onPreview,
                loading: isLoading,
              ),
      ),
    );
  }
}
