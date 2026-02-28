import 'package:n42_wallet/features/home/setting/security/security_google_backup_key.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityGoogleInstructions extends StatelessWidget {
  const SecurityGoogleInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonBgColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
    final buttonTextColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name);
    final mainTextColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final scr = ScreenUtil();
    final stepSize = scr.setWidth(40.0);
    final stepFontSize = scr.setSp(26.0);
    final stepMarginRight = scr.setWidth(30.0);
    final separatorWidth = scr.setWidth(2.0);

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).google_verification_message12,
      ),
      body: Container(
        padding: EdgeInsets.all(scr.setWidth(30.0)),
        child: Column(
          children: [
            // Step 1
            _buildStepRow(
              stepWidget: _buildStepCircle(
                number: "1",
                size: stepSize,
                fontSize: stepFontSize,
                bgColor: buttonBgColor,
                textColor: buttonTextColor,
              ),
              marginRight: stepMarginRight,
              child: Text(
                S.of(context).google_verification_message13,
                style: TextStyle(color: mainTextColor, fontSize: stepFontSize),
              ),
            ),
            // Separator between step 1 and 2
            Row(
              children: [
                Container(
                  height: stepSize,
                  margin: EdgeInsets.only(left: scr.setWidth(18.0)),
                  child: MySeparator(separatorWidth, mainTextColor),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            // Step 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: scr.setWidth(360.0),
                  margin: EdgeInsets.only(right: stepMarginRight),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepCircle(
                        number: "2",
                        size: stepSize,
                        fontSize: stepFontSize,
                        bgColor: buttonBgColor,
                        textColor: buttonTextColor,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          width: stepSize,
                          child: MySeparator(separatorWidth, mainTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: scr.setWidth(4.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).google_verification_message14,
                          style: TextStyle(color: mainTextColor, fontSize: stepFontSize),
                        ),
                        Container(
                          height: scr.setWidth(210),
                          width: scr.setWidth(316),
                          margin: EdgeInsets.symmetric(vertical: scr.setWidth(30.0)),
                          child: Image.asset('assets/home/setting/scurity/example.png'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Step 3
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: scr.setWidth(100.0),
                  margin: EdgeInsets.only(right: stepMarginRight),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepCircle(
                        number: "3",
                        size: stepSize,
                        fontSize: stepFontSize,
                        borderColor: buttonBgColor,
                        textColor: buttonBgColor,
                        borderWidth: scr.setWidth(2.0),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          width: stepSize,
                          child: MySeparator(separatorWidth, mainTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: scr.setWidth(4.0)),
                    child: Text(
                      S.of(context).google_verification_message15,
                      style: TextStyle(color: mainTextColor, fontSize: stepFontSize),
                    ),
                  ),
                ),
              ],
            ),
            // Final step icon
            _buildStepRow(
              stepWidget: Container(
                alignment: Alignment.center,
                width: stepSize,
                height: stepSize,
                child: Image.asset('assets/home/setting/scurity/open.png'),
              ),
              marginRight: stepMarginRight,
              height: scr.setWidth(100.0),
              crossAxisAlignment: CrossAxisAlignment.start,
              child: Text(
                S.of(context).google_verification_message16,
                style: TextStyle(color: mainTextColor, fontSize: stepFontSize),
              ),
            ),
            const Spacer(),
            Container(
              height: scr.setWidth(88.0),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: scr.setWidth(6.0)),
              child: buttonStyle2(context, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SecurityGoogleBackupKey()));
              }, S.of(context).next),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a filled step circle with background color.
  Widget _buildStepCircle({
    required String number,
    required double size,
    required double fontSize,
    Color? bgColor,
    Color? borderColor,
    double? borderWidth,
    required Color textColor,
  }) {
    return Container(
      alignment: Alignment.center,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size)),
        color: bgColor,
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
            : null,
      ),
      child: Text(
        number,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );
  }

  /// Builds a simple step row with an icon/circle on the left and content on the right.
  Widget _buildStepRow({
    required Widget stepWidget,
    required double marginRight,
    required Widget child,
    double? height,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          height: height,
          margin: EdgeInsets.only(right: marginRight),
          alignment: Alignment.center,
          child: stepWidget,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class MySeparator extends StatelessWidget {
  final double width;
  final Color color;
  const MySeparator(this.width, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        const dashHeight = 2.0;
        final dashWidth = width;
        final int dashCount = (boxHeight / (2 * dashHeight).floor()).toInt();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
