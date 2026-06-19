import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstSummary extends StatefulWidget {
  final String send;
  final String receive;
  final String balance;
  final String date;
  final String payCoin;
  const SwapAstSummary(
    this.send,
    this.receive,
    this.balance,
    this.date, {
    required this.payCoin,
    super.key,
  });

  @override
  State<SwapAstSummary> createState() => _SwapAstSummaryState();
}

class _SwapAstSummaryState extends State<SwapAstSummary> {
  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  Widget _summaryRow(String label, String value, {bool bottomPadding = true}) {
    return Padding(
      padding: bottomPadding
          ? EdgeInsets.only(bottom: AppSpacing.space16)
          : EdgeInsets.zero,
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: _color(AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                color: _color(AppThemeKeys.itemTextColor),
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final sw = ScreenUtil().setWidth;
    final noteStyle = AppTypography.bodySm.copyWith(
      color: _color(AppThemeKeys.mainTextColor3),
    );

    return Scaffold(
      appBar: AppBarWidget(text: s.g_swap_key_28),
      body: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space8,
          AppSpacing.space8,
          AppSpacing.space8,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
                vertical: AppSpacing.space6,
              ),
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.itemBgColor),
                borderRadius: AppRadius.brSm,
              ),
              child: Column(
                children: [
                  _summaryRow(s.g_key_48, '${widget.send} ${widget.payCoin}'),
                  _summaryRow(
                    s.g_key_33,
                    '${widget.receive} ${CoinType.N.name}',
                  ),
                  _summaryRow(
                    s.g_swap_key_29,
                    '${widget.balance} ${CoinType.N.name}',
                  ),
                  _summaryRow(
                    s.g_swap_key_30,
                    widget.date,
                    bottomPadding: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(102)),
            Text(s.g_swap_key_31(CoinType.N.name), style: noteStyle),
            SizedBox(height: AppSpacing.space4),
            Text(s.g_swap_key_32, style: noteStyle),
            const Spacer(),
            Container(
              height: sw(88),
              margin: EdgeInsets.only(bottom: AppSpacing.space12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: s.g_key_79,
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: AppButton(
                      label: s.g_key_78,
                      onPressed: () async {
                        final r = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletSecurityVerification(),
                          ),
                        );
                        if (!context.mounted) return;
                        if (r == true) Navigator.pop(context, true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
