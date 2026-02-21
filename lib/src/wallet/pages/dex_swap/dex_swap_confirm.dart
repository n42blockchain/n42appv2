import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/dex/dex_quote_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class DexSwapConfirm extends StatefulWidget {
  final DexQuoteModel quote;
  const DexSwapConfirm({required this.quote, super.key});

  @override
  State<DexSwapConfirm> createState() => _DexSwapConfirmState();
}

class _DexSwapConfirmState extends State<DexSwapConfirm> {
  // 可选滑点 (bps: 10=0.1%, 50=0.5%, 100=1%)
  static const List<int> _slippageOptions = [10, 50, 100];
  int _slippageBps = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: 'Confirm Swap'),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(30),
          0,
        ),
        child: Column(
          children: [
            _summaryCard(),
            SizedBox(height: ScreenUtil().setWidth(40)),
            _slippageSelector(),
            const Expanded(child: SizedBox()),
            _actionRow(),
            SizedBox(height: ScreenUtil().setWidth(36)),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    final q = widget.quote;
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          _row('You Pay', '${q.amountIn} ${q.tokenInSymbol}'),
          _row('You Receive', '${q.amountOut} ${q.tokenOutSymbol}'),
          _row('Price Impact', q.priceImpact),
          _row('Gas Estimate', q.gasEstimate),
          _row('Best Source', q.source),
          _row('Chain', q.chain),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(14)),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          const Expanded(child: SizedBox()),
          Text(
            value,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slippageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slippage Tolerance',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        Row(
          children: _slippageOptions.map((bps) {
            final selected = _slippageBps == bps;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _slippageBps = bps),
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
                  padding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainButtonBgColor.name)
                        : AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemBgColor.name),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8)),
                    border: Border.all(
                      color: selected
                          ? AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainButtonBgColor.name)
                          : AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.dividerColor.name),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${bps / 100}%',
                    style: TextStyle(
                      color: selected
                          ? AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.mainButtonTextColor.name)
                          : AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _actionRow() {
    return SizedBox(
      height: ScreenUtil().setWidth(88),
      child: Row(
        children: [
          Expanded(
            child: buttonStyle5(
              context,
              () => Navigator.pop(context, null),
              S.of(context).g_key_79,
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainWhiteColor.name),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor3.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(30)),
          Expanded(
            child: buttonStyle2(
              context,
              () async {
                final nav = Navigator.of(context);
                final bool verified = await nav.push(
                  MaterialPageRoute(
                      builder: (_) => WalletSecurityVerification()),
                );
                if (verified) {
                  nav.pop(_slippageBps);
                }
              },
              S.of(context).g_key_78,
            ),
          ),
        ],
      ),
    );
  }
}
