import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

Widget successView(String title) => _statusView(title, error: false);

Widget createWalletErrView(String title) => _statusView(title, error: true);

Widget _statusView(String title, {required bool error}) => Builder(
  builder: (context) {
    final colors = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space6,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brLg,
        color: colors.bgSurface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            error ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: error ? colors.danger : colors.success,
            size: 36,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  },
);
