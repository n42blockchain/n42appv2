import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class NavShowDataItem extends StatelessWidget {
  final String desc;
  final String value;

  const NavShowDataItem(this.desc, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              desc,
              style: AppTypography.body.copyWith(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.ff888888.name,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
