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
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20),
        bottom: ScreenUtil().setWidth(30),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor5.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_swap_key_4,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemTextColor.name),
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(100),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemTextColor.name),
                      fontSize: ScreenUtil().setWidth(50.0),
                    ),
                    controller: getController,
                    focusNode: getNode,
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_44,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setWidth(50.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.textFieldHintColor.name),
                      ),
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onChanged: onGetChanged,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(payNode);
                      onGetEditingComplete();
                    },
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(200),
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: ScreenUtil().setWidth(52),
                        height: ScreenUtil().setWidth(52),
                        child: Image.asset('assets/img/ast.png'),
                      ),
                      Expanded(
                        child: Text(
                          CoinType.N.name,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemTextColor.name),
                            fontSize: ScreenUtil().setSp(30),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(40),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemBorderColor.name),
                          size: ScreenUtil().setWidth(40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${S.of(context).g_key_29}:${getCoinModel?.balanceDoubleAll()}",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
              if (getLoad == Load.loading)
                SizedBox(
                  width: ScreenUtil().setWidth(26),
                  height: ScreenUtil().setWidth(26),
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
