import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flutter/gestures.dart';
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
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(30),
        ),
      ),
    );
  }
}

/// 显示 25% / 50% / 75% / 100% 快速填充按钮。
class SwapAstPercentWidget extends StatelessWidget {
  final void Function(int percent) onPercentTap;

  const SwapAstPercentWidget({
    super.key,
    required this.onPercentTap,
  });

  @override
  Widget build(BuildContext context) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - ScreenUtil().setWidth(60)) / 4;
    return Container(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, int index) {
          final int percent = 25 * (4 - index);
          return InkWell(
            onTap: () => onPercentTap(percent),
            child: Container(
              height: ScreenUtil().setWidth(80),
              width: itemWidth,
              alignment: Alignment.center,
              child: Text(
                "$percent%",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(30),
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
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onToggle,
            child: SizedBox(
              height: ScreenUtil().setWidth(60),
              width: ScreenUtil().setWidth(60),
              child: Icon(
                readStatement ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                color: AppThemeUtils.getColorByKey(
                  context,
                  readStatement ? AppThemeKeys.mainBlueColor.name : AppThemeKeys.dividerColor.name,
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
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(22),
                ),
                children: [
                  TextSpan(
                    text: S.of(context).g_swap_key_17,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(24),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BrowserPage(
                              "${AppConfig.apiUrl['walletamazeBrowser']!}/static/terms_of_use-astranet.html",
                            ),
                          ),
                        );
                      },
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
    final bgColorKey = isLoading
        ? AppThemeKeys.mainButtonBgColor3.name
        : AppThemeKeys.mainButtonBgColor.name;

    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        child: load == Load.error
            ? buttonStyle2(context, onRetry, S.of(context).g_swap_key_6)
            : buttonStyle6(
                context,
                onPreview,
                S.of(context).g_swap_key_5,
                AppThemeUtils.getColorByKey(context, bgColorKey),
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
                isLoading,
              ),
      ),
    );
  }
}
