import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

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
    final titleStyle = AppTypography.headline.copyWith(color: color ?? AppColorTokens.of(context).brand);

    if (!must) return Text(title, style: titleStyle);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        Text(
          "*",
          style: AppTypography.captionSm.copyWith(color: AppColorTokens.of(context).danger),
        ),
      ],
    );
  }
}
