import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactEmpty extends StatelessWidget {
  const ContactEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/chat/no_frame.png",
          width: ScreenUtil().setWidth(120),
          fit: BoxFit.cover,
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Text(
          S.of(context).g_chat_key_60,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(32),
          ),
        ),

      ],
    );
  }
}