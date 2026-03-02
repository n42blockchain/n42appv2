import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstSummary extends StatefulWidget {
  final String send;
  final String receive;
  final String balance;
  final String date;
  final String payCoin;
  const SwapAstSummary(this.send, this.receive, this.balance, this.date,
      {required this.payCoin, super.key});

  @override
  State<SwapAstSummary> createState() => _SwapAstSummaryState();
}

class _SwapAstSummaryState extends State<SwapAstSummary> {
  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  Widget _summaryRow(String label, String value, {bool bottomPadding = true}) {
    return Padding(
      padding: bottomPadding
          ? EdgeInsets.only(bottom: ScreenUtil().setHeight(60))
          : EdgeInsets.zero,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: _color(AppThemeKeys.itemSubtitleTextColor),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: _color(AppThemeKeys.itemTextColor),
                fontSize: ScreenUtil().setSp(30),
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
    final noteStyle = TextStyle(
      color: _color(AppThemeKeys.mainTextColor3),
      fontSize: ScreenUtil().setSp(26),
    );

    return Scaffold(
      appBar: AppBarWidget(text: s.g_swap_key_28),
      body: Container(
        padding: EdgeInsets.fromLTRB(sw(30), sw(30), sw(30), 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw(30),
                vertical: ScreenUtil().setHeight(26),
              ),
              decoration: BoxDecoration(
                color: _color(AppThemeKeys.itemBgColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _summaryRow(s.g_key_48, '${widget.send} ${widget.payCoin}'),
                  _summaryRow(
                      s.g_key_33, '${widget.receive} ${CoinType.N.name}'),
                  _summaryRow(
                      s.g_swap_key_29, '${widget.balance} ${CoinType.N.name}'),
                  _summaryRow(s.g_swap_key_30, widget.date,
                      bottomPadding: false),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(102)),
            Text(s.g_swap_key_31(CoinType.N.name), style: noteStyle),
            SizedBox(height: ScreenUtil().setHeight(20)),
            Text(s.g_swap_key_32, style: noteStyle),
            const Spacer(),
            Container(
              height: sw(88),
              margin: EdgeInsets.only(bottom: sw(36)),
              child: Row(
                children: [
                  Expanded(
                    child: buttonStyle5(
                      context,
                      () => Navigator.pop(context),
                      s.g_key_79,
                      _color(AppThemeKeys.mainWhiteColor),
                      _color(AppThemeKeys.mainButtonTextColor3),
                    ),
                  ),
                  SizedBox(width: sw(30)),
                  Expanded(
                    child: buttonStyle2(
                      context,
                      () async {
                        final r = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletSecurityVerification(),
                          ),
                        );
                        if (!context.mounted) return;
                        if (r == true) Navigator.pop(context, true);
                      },
                      s.g_key_78,
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
