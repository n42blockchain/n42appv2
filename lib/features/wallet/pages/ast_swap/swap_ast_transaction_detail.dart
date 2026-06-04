import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_order_model.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart' as dformat;
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwapAstTransactionDetail extends StatefulWidget {
  final SwapAstOrderModel orderModel;
  const SwapAstTransactionDetail(this.orderModel, {super.key});

  @override
  State<SwapAstTransactionDetail> createState() =>
      _SwapAstTransactionDetailState();
}

class _SwapAstTransactionDetailState extends State<SwapAstTransactionDetail> {
  String stateStr = "";
  Color? stateColor;
  IconData? iconData;
  late String createStr;
  late SwapAstOrderModel _orderModel;

  @override
  void initState() {
    super.initState();
    _orderModel = widget.orderModel;
    final int tsMs = (_orderModel.created ?? 0) * 1000;
    createStr = dformat.formatDate(DateTime.fromMillisecondsSinceEpoch(tsMs), [
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
    ]);
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      final MessageModel rData = await SwapAstApi().getNftOrAstDetail(
        _orderModel.id ?? 0,
      );
      if (!mounted) return;
      if (!rData.error) {
        setState(() => _orderModel = SwapAstOrderModel.fromJson(rData.data));
      }
    } catch (e) {
      AppLogger.w('SwapAstTxDetail', '_loadOrderDetail error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_tran_4),
      body: _buildBody(),
    );
  }

  void _resolveStateDisplay() {
    final s = S.of(context);
    switch (_orderModel.orderState) {
      case 1:
        iconData = Icons.error;
        stateStr = s.g_swap_key_22;
        stateColor = _themeColor(AppThemeKeys.errorTextColor);
      case 2:
        iconData = Icons.error;
        stateStr = s.g_key_79;
        stateColor = _themeColor(AppThemeKeys.errorTextColor);
      case 0:
        final hasTx = (_orderModel.payTx?.contains("0x") ?? false);
        stateStr = hasTx ? s.g_swap_key_24 : s.g_swap_key_23;
        iconData = Icons.info_rounded;
        stateColor = _themeColor(AppThemeKeys.textColorOrange);
      case 5:
        iconData = Icons.check_circle;
        stateStr = s.g_swap_key_18;
        stateColor = _themeColor(AppThemeKeys.rightTextColor);
      default:
        iconData = Icons.info_rounded;
        stateStr = s.g_swap_key_25;
        stateColor = _themeColor(AppThemeKeys.textColorOrange);
    }
  }

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  Widget _buildBody() {
    _resolveStateDisplay();
    return switch (_orderModel.orderState) {
      0 || null => processingWidget(),
      5 || 1 || 2 => successWidget(),
      _ => processingWidget(),
    };
  }

  Widget processingWidget() {
    final su = ScreenUtil();
    final Color mainText = _themeColor(AppThemeKeys.mainTextColor);
    final Color subtitle = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final Color divider = _themeColor(AppThemeKeys.dividerColor);
    final int state = _orderModel.orderState ?? 0;
    final String pair =
        "${_orderModel.payCoin ?? 'USDT'}/${_orderModel.type == 1 ? "NFT" : CoinType.N.name}";

    return Padding(
      padding: EdgeInsets.all(AppSpacing.space8),
      child: Column(
        children: [
          Container(
            height: su.setWidth(80),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: AppSpacing.space12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      pair,
                      style: AppTypography.body.copyWith(color: mainText),
                    ),
                    Expanded(
                      child: Text(
                        "+${_orderModel.orderNum}",
                        style: AppTypography.body.copyWith(
                          color: mainText,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      createStr,
                      style: AppTypography.caption.copyWith(color: subtitle),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: su.setWidth(4)),
                            child: Icon(
                              iconData,
                              color: stateColor,
                              size: su.setWidth(30),
                              fill: 0,
                            ),
                          ),
                          Text(
                            stateStr,
                            style: AppTypography.caption.copyWith(
                              color: stateColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: su.setWidth(300),
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(
                  width: su.setWidth(40),
                  child: Column(
                    children: [
                      _stepIcon(state >= 3, su, divider),
                      _stepDivider(su, divider),
                      _stepIcon(state == 3 || state == 4, su, divider),
                      _stepDivider(su, divider),
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.space4),
                        child: _stepIconRaw(state == 5, su, divider),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pRowWidget(_orderModel.payCoin ?? 'USDT'),
                      SizedBox(height: AppSpacing.space16),
                      pRowWidget("Swap"),
                      SizedBox(height: AppSpacing.space16),
                      pRowWidget(S.of(context).g_key_191),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIcon(bool completed, ScreenUtil su, Color dividerColor) {
    return SizedBox(
      height: su.setWidth(40),
      width: su.setWidth(40),
      child: _stepIconRaw(completed, su, dividerColor),
    );
  }

  Widget _stepIconRaw(bool completed, ScreenUtil su, Color dividerColor) {
    return Icon(
      completed ? Icons.check_circle : Icons.radio_button_unchecked,
      color: completed
          ? _themeColor(AppThemeKeys.rightTextColor)
          : dividerColor,
      size: su.setWidth(40),
    );
  }

  Expanded _stepDivider(ScreenUtil su, Color color) {
    return Expanded(
      child: VerticalDivider(
        width: su.setWidth(40),
        indent: 0,
        endIndent: 0,
        color: color,
      ),
    );
  }

  Widget pRowWidget(String title) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTypography.body.copyWith(
            color: _themeColor(AppThemeKeys.mainTextColor),
          ),
        ),
      ),
    );
  }

  Widget successWidget() {
    final su = ScreenUtil();
    final Color mainText = _themeColor(AppThemeKeys.mainTextColor);
    final s = S.of(context);

    return Column(
      children: [
        Container(
          height: su.setWidth(300),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
                child: RichText(
                  text: TextSpan(
                    text: '${_orderModel.orderPrice}',
                    style: AppTypography.titleLg.copyWith(color: mainText),
                    children: [
                      TextSpan(
                        text: CoinType.N.name,
                        style: AppTypography.caption.copyWith(
                          color: mainText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.space2),
                      child: Icon(
                        iconData,
                        color: stateColor,
                        size: su.setWidth(40),
                      ),
                    ),
                    Text(
                      stateStr,
                      style: AppTypography.body.copyWith(
                        color: stateColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.space2,
                  horizontal: su.setWidth(200),
                ),
                child: Text(
                  s.g_key_tran_6,
                  style: AppTypography.caption.copyWith(color: mainText),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: AppSpacing.space16,
          color: _themeColor(AppThemeKeys.dividerColor),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
          child: Column(
            children: [
              _rowWidget(
                s.g_key_tran_7,
                "${_orderModel.payNum} ${_orderModel.payCoin ?? 'USDT'}",
              ),
              _rowWidget(
                s.g_key_tran_8,
                "${_orderModel.orderNum} ${CoinType.N.name}",
              ),
              _rowWidget(s.g_key_wallet_k25, createStr),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _rowWidget(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                color: _themeColor(AppThemeKeys.mainTextColor),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
