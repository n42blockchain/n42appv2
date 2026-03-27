import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 兑换页"您获得"区域，包含输入框和 N 代币余额显示。
class SwapAstGetWidget extends StatelessWidget {
  final TextEditingController getController;
  final FocusNode getNode;
  final FocusNode payNode;
  final CoinModel? getCoinModel;
  final Load getLoad;
  final void Function(String value) onGetChanged;
  final void Function() onGetEditingComplete;

  const SwapAstGetWidget({
    super.key,
    required this.getController,
    required this.getNode,
    required this.payNode,
    required this.getCoinModel,
    required this.getLoad,
    required this.onGetChanged,
    required this.onGetEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final textColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemTextColor.name);

    return Container(
      margin: EdgeInsets.only(
        top: su.setWidth(20),
        bottom: su.setWidth(30),
        left: su.setWidth(30),
        right: su.setWidth(30),
      ),
      padding: EdgeInsets.all(su.setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor5.name),
        borderRadius: BorderRadius.circular(su.setWidth(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_swap_key_4,
            style: TextStyle(color: textColor, fontSize: su.setSp(30)),
          ),
          SizedBox(
            height: su.setWidth(100),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: textColor,
                      fontSize: su.setWidth(50.0),
                    ),
                    controller: getController,
                    focusNode: getNode,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_44,
                      hintStyle: TextStyle(
                        fontSize: su.setWidth(50.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.textFieldHintColor.name),
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: su.setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onChanged: onGetChanged,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(payNode);
                      onGetEditingComplete();
                    },
                  ),
                ),
                _buildTokenBadge(context, su, textColor),
              ],
            ),
          ),
          _buildBalanceRow(context, su, textColor),
        ],
      ),
    );
  }

  Widget _buildTokenBadge(
      BuildContext context, ScreenUtil su, Color textColor) {
    final iconSize = su.setWidth(52);
    return Container(
      width: su.setWidth(200),
      margin: EdgeInsets.only(left: su.setWidth(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image.asset('assets/img/ast.png'),
          ),
          Expanded(
            child: Text(
              CoinType.N.name,
              style: TextStyle(color: textColor, fontSize: su.setSp(30)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: su.setWidth(40),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBorderColor.name),
              size: su.setWidth(40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
      BuildContext context, ScreenUtil su, Color textColor) {
    return Row(
      children: [
        Flexible(
          child: Text(
            "${S.of(context).g_key_29}:${getCoinModel?.balanceDoubleAll()}",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontSize: su.setSp(26)),
          ),
        ),
        if (getLoad == Load.loading)
          SizedBox(
            width: su.setWidth(26),
            height: su.setWidth(26),
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }
}
