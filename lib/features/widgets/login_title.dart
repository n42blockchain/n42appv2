import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final bool must;

  const LoginTitle({
    super.key,
    required this.title,
    this.color,
    this.must = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: color ?? AppColorTokens.of(context).brand,
      fontSize: ScreenUtil().setSp(32.0),
    );

    if (!must) return Text(title, style: titleStyle);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        Text(
          "*",
          style: TextStyle(
            color: AppColorTokens.of(context).danger,
            fontSize: ScreenUtil().setSp(20.0),
          ),
        ),
      ],
    );
  }
}
