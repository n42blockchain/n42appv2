import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_code.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

class SetAmount extends ConsumerStatefulWidget {
  /// 0: default, navigate and replace PaymentCode; 1: pop with result.
  final int type;
  final Map<String, String>? amount;

  const SetAmount({this.type = 0, this.amount, super.key});

  @override
  ConsumerState<SetAmount> createState() => _SetAmountState();
}

class _SetAmountState extends ConsumerState<SetAmount> {
  late final Regular regular = Regular();
  final _oCcy = NumberFormat("#,##0.0#", "en_US");
  final TextEditingController amountController = TextEditingController();
  List<CoinModel> coinList = [];
  int coinListIndex = -1;
  String amountErrorMessage = "";

  String _validateAmount(String value) {
    if (regular.regularDouble(value) || regular.regularNums(value)) return "";
    return S.of(context).g_key_payment_amount_invalid;
  }

  @override
  void initState() {
    super.initState();
    _initCoin();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _initCoin() {
    final WalletActionProvider wap = ref.read(wapBridgeProvider);
    for (final CoinModel cm in wap.coinList) {
      if (cm.coin['miniName'].toString().toLowerCase() == "usdt") {
        coinList.add(cm);
      }
    }

    if (coinList.isEmpty) return;

    coinListIndex = 0;
    if (widget.amount != null) {
      final index = coinList.indexWhere(
        (e) =>
            widget.amount!['coinType'] == e.coin['coinType'] &&
            widget.amount!['address'] == e.address,
      );
      if (index != -1) {
        coinListIndex = index;
        amountController.text = widget.amount!["amount"].toString();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.backGroundColor.name,
      ),
      appBar: AppBarWidget(text: S.of(context).g_key_payment_set_amount_title),
      body: SafeArea(
        child: Column(
          children: [
            _buildAmountInput(),
            Expanded(child: _buildCoinList()),
            Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      child: textFieldStyle2(
        context,
        controller: amountController,
        height: ScreenUtil().setWidth(150.0),
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainTextColor.name,
          ),
          fontSize: ScreenUtil().setWidth(50.0),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        maxLines: 1,
        errorMessage: amountErrorMessage,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            amountErrorMessage = _validateAmount(amountController.text);
          });
        },
        onChanged: (String value) {
          setState(() {
            amountErrorMessage = _validateAmount(value);
          });
        },
        leftWidget: Padding(
          padding: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
          child: Text(
            "\$",
            style: TextStyle(
              fontSize: ScreenUtil().setWidth(50.0),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinList() {
    if (coinList.isEmpty) {
      return Container(
        height: ScreenUtil().setWidth(300.0),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.backGroundColor.name,
        ),
        child: const EmptyView(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: coinList.length,
      itemBuilder: (_, index) => _buildCoinItem(coinList[index], index),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      height: ScreenUtil().setWidth(148),
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: buttonStyle6(
        context,
        _onConfirm,
        S.of(context).g_key_payment_confirm,
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainButtonBgColor.name,
        ),
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainButtonTextColor.name,
        ),
        false,
      ),
    );
  }

  void _onConfirm() {
    if (coinList.isEmpty ||
        coinListIndex < 0 ||
        coinListIndex >= coinList.length) {
      ToastUtils.show(S.of(context).g_key_payment_usdt_not_found);
      return;
    }
    final amountStr = amountController.text;
    amountErrorMessage = _validateAmount(amountStr);
    if (amountErrorMessage.isNotEmpty) {
      setState(() {});
      return;
    }
    final selectedCoin = coinList[coinListIndex];
    final rmap = {
      "amount": amountStr,
      "coinType": selectedCoin.coin['coinType'] as String,
      "address": selectedCoin.address.toString(),
    };
    if (widget.type == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentCode(amount: rmap)),
      );
    } else {
      Navigator.pop(context, rmap);
    }
  }

  String _formatBalance(double value, {String? fallback}) {
    if (value >= 1000000000) return regular.getMoneyAbbreviation(value);
    if (value > 0 && value < 0.0000000009) {
      return regular.getMoneyAbbreviationDecimal(value);
    }
    return fallback ?? _oCcy.format(value);
  }

  Widget _buildCoinIcon(CoinModel coinInfo) {
    final iconUrl = coinInfo.coin['icon'] ?? "";
    final Widget image = (iconUrl == "")
        ? Image.asset("assets/img/list_default.png")
        : ImageNetWork(
            imageUrl: iconUrl,
            placeholder: "assets/img/list_default.png",
          );

    return Container(
      width: ScreenUtil().setWidth(52.0),
      height: ScreenUtil().setWidth(72.0),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
      child: Stack(
        children: [
          Positioned(
            top: ScreenUtil().setWidth(10.0),
            bottom: ScreenUtil().setWidth(10.0),
            left: 0,
            right: 0,
            child: image,
          ),
          if (coinInfo.coin['isContract'] == true)
            Positioned(
              top: 0,
              left: 0,
              height: ScreenUtil().setWidth(22.0),
              width: ScreenUtil().setWidth(22.0),
              child: ImageNetWork(
                imageUrl: coinInfo.mainCoinIcon ?? "",
                placeholder: "assets/img/list_default.png",
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoinItem(CoinModel coinInfo, int index) {
    final isSelected = coinListIndex == index;
    final balanceStr = _formatBalance(coinInfo.value);
    final valueBalanceStr = _formatBalance(
      coinInfo.balanceDoubleAll(),
      fallback: coinInfo.balanceString(),
    );
    final mainTextColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final subtitleColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );

    return InkWell(
      onTap: () => setState(() => coinListIndex = index),
      child: Container(
        height: ScreenUtil().setWidth(140.0),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(
                  width: ScreenUtil().setWidth(1),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              )
            : null,
        padding: isSelected
            ? EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16))
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCoinIcon(coinInfo),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${coinInfo.coin['miniName']}(${coinInfo.coin['coinType']})",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: mainTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          valueBalanceStr,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: mainTextColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${coinInfo.coinPriceString()}",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: subtitleColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "\$$balanceStr",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: subtitleColor,
                        ),
                      ),
                    ],
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
