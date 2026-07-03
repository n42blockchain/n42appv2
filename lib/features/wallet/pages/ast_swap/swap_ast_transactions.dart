import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_order_model.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_transaction_detail.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:date_format/date_format.dart' as dformat;

class SwapAstTransactions extends StatefulWidget {
  const SwapAstTransactions({super.key});

  @override
  State<SwapAstTransactions> createState() => _SwapAstTransactionsState();
}

class _SwapAstTransactionsState extends State<SwapAstTransactions> {
  late final SwapAstApi _swapAstApi = SwapAstApi();

  static const _dateFormat = [
    dformat.yyyy,
    '/',
    dformat.mm,
    '/',
    dformat.dd,
    ' ',
    dformat.am,
    ' ',
    dformat.hh,
    ':',
    dformat.nn,
  ];

  ({IconData icon, String label, Color color}) _orderStateInfo(
    BuildContext context,
    SwapAstOrderModel order,
  ) {
    final s = S.of(context);
    return switch (order.orderState) {
      1 => (
        icon: Icons.error,
        label: s.g_swap_key_22,
        color: AppColorTokens.of(context).danger,
      ),
      2 => (
        icon: Icons.error,
        label: s.g_key_79,
        color: AppColorTokens.of(context).danger,
      ),
      0 => (
        icon: Icons.info_rounded,
        label: (order.payTx?.contains("0x") ?? false)
            ? s.g_swap_key_24
            : s.g_swap_key_23,
        color: AppColorTokens.of(context).warning,
      ),
      5 => (
        icon: Icons.check_circle,
        label: s.g_swap_key_18,
        color: AppColorTokens.of(context).success,
      ),
      _ => (
        icon: Icons.info_rounded,
        label: s.g_swap_key_25,
        color: AppColorTokens.of(context).warning,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final mainTextColor = AppColorTokens.of(context).textPrimary;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_tran_1),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: BaseList(
          firstRefresh: true,
          pageIndex: 1,
          pageSize: 15,
          getData: (int page, int pageSize) async {
            final rData = await _swapAstApi.getNftOrAstOrderList(
              2,
              AppGlobals.userInfo?.uuid ?? '',
              page: page,
              pageSize: pageSize,
            );
            if (rData.error) return [];
            final data = rData.data;
            if (data is! List) return [];
            return data
                .whereType<Map>()
                .map(
                  (e) => SwapAstOrderModel.fromJson(
                    e.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList();
          },
          buildItem: (BuildContext context, List<dynamic> results, int index) {
            final order = results[index] as SwapAstOrderModel;
            final state = _orderStateInfo(context, order);
            final timeStr = dformat.formatDate(
              DateTime.fromMillisecondsSinceEpoch(order.created ?? 0),
              _dateFormat,
            );
            final textStyle = AppTypography.body.copyWith(color: mainTextColor);
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SwapAstTransactionDetail(order),
                ),
              ),
              child: Container(
                // >=96.w（48dp 列表项最小可点高，§2.2）
                height: ScreenUtil().setWidth(96),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppSpacing.space12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${order.payCoin ?? 'USDT'}/${CoinType.N.name}",
                          style: textStyle,
                        ),
                        Expanded(
                          child: Text(
                            "+${order.orderNum}",
                            style: textStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: AppTypography.caption.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                state.icon,
                                color: state.color,
                                size: ScreenUtil().setWidth(30),
                                fill: 0,
                              ),
                              SizedBox(width: AppSpacing.space2),
                              Text(
                                state.label,
                                style: AppTypography.caption.copyWith(
                                  color: state.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
