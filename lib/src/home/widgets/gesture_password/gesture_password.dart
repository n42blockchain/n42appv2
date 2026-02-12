import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';

class GesturePassword extends StatelessWidget{
  final Function completeEvent;
  final double identifySize;
  final List<int>? answer;
  const GesturePassword(this.completeEvent,this.identifySize,{this.answer,super.key});
  @override
  Widget build(BuildContext context) {
    double bigWidth=identifySize/2;
    double miniWidth=identifySize/4;
    return GesturePasswordWidget(
      size: identifySize*3,
      lineColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      errorLineColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
      singleLineCount: 3,
      identifySize: identifySize,
      minLength: 4,
      hitShowMilliseconds: 40,
      errorItem: Container(
        width: bigWidth,
        height: bigWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(bigWidth,)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name).withAlpha((0.5 * 255).round()),
        ),
        alignment: Alignment.center,
        child: Container(
          width: miniWidth,
          height: miniWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(miniWidth,)),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ),
        ),
      ),
      normalItem: Container(
        height: miniWidth,
        width: miniWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(miniWidth,)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
      selectedItem:Container(
        width: bigWidth,
        height: bigWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(bigWidth,)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha((0.5 * 255).round()),
        ),
        alignment: Alignment.center,
        child: Container(
          width: miniWidth,
          height: miniWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(miniWidth,)),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ),
      hitItem: Container(
        width: bigWidth,
        height: bigWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(bigWidth,)),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha((0.5 * 255).round()),
        ),
      ),
      answer: answer,
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      onComplete: (data) {
        completeEvent(data.join(','));
      },
    );
  }

}