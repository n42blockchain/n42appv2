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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

class SetAmount extends ConsumerStatefulWidget {
  final int type;//0默认 跳转并替换PaymentCode页面，1返回上一个页面
  final Map<String,String>? amount;
  const SetAmount({this.type=0,this.amount,super.key});

  @override
  ConsumerState<SetAmount> createState() => _SetAmountState();
}

class _SetAmountState extends ConsumerState<SetAmount> {
  late final Regular regular = Regular();
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  final TextEditingController amountController = TextEditingController();
  List<CoinModel> coinList=[];
  int coinListIndex=-1;
  String amountErrorMessage="";

  /// 校验金额字符串，返回错误信息（合法时返回空字符串）
  String _validateAmount(String value) {
    if (regular.regularDouble(value) || regular.regularNums(value)) return "";
    return S.of(context).g_key_payment_amount_invalid;
  }

  @override
  void initState() {
    initCoin();
    super.initState();
  }
  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
  void initCoin(){
    WalletActionProvider wap=ref.read(wapBridgeProvider);
    for(CoinModel cm in wap.coinList){
      if(cm.coin['miniName'].toString().toLowerCase()=="usdt"){
        coinList.add(cm);
      }
    }
    if(coinList.isNotEmpty){
      coinListIndex=0;
      if(widget.amount !=null){
        int index=coinList.indexWhere((e) =>
          widget.amount!['coinType']==e.coin['coinType'] && widget.amount!['address']==e.address
        );
        if(index !=-1){
          coinListIndex=index;
          amountController.text=widget.amount!["amount"].toString();
        }
      }
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: S.of(context).g_key_payment_set_amount_title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
              child: textFieldStyle2(
                context,
                controller: amountController,
                height: ScreenUtil().setWidth(150.0),
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setWidth(50.0),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                maxLines: 1,
                errorMessage: amountErrorMessage,
                onEditingComplete: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                  amountErrorMessage = _validateAmount(amountController.text);
                  setState(() {});
                },
                onChanged: (String value){
                  amountErrorMessage = _validateAmount(value);
                  setState(() {});
                },
                leftWidget: Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                  child: Text(
                    "\$",
                    style: TextStyle(
                      fontSize: ScreenUtil().setWidth(50.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ),
              ),
            ),
            if (coinList.isEmpty)
              Expanded(
                child: Container(
                  height: ScreenUtil().setWidth(300.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.backGroundColor.name),
                  child: const EmptyView(),
                ),
              ),
            if(coinList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  itemCount: coinList.length,
                  itemBuilder: (context,index){
                    return _mainCoin(coinList[index],index);
                  },
                ),
              ),
            Divider(
              height: ScreenUtil().setWidth(1),
              indent: 0,
              endIndent: 0,
            ),
            Container(
              height: ScreenUtil().setWidth(148),
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              child: buttonStyle6(
                context, (){
                  String amountStr=amountController.text;
                  amountErrorMessage = _validateAmount(amountStr);
                  if (amountErrorMessage.isNotEmpty) {
                    setState(() {});
                    return;
                  }
                  Map<String,String> rmap={
                    "amount":amountController.text,
                    "coinType":coinList[coinListIndex].coin['coinType'],
                    "address":coinList[coinListIndex].address.toString(),
                  };
                  if(widget.type==0){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PaymentCode(amount: rmap,)));
                  }else{
                    Navigator.pop(context,rmap);
                  }
              },
                S.of(context).g_key_payment_confirm,
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                false,
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// 格式化金额数值：大额缩写 / 极小值缩写 / 常规格式
  String _formatBalance(double value, {String? fallback}) {
    if (value >= 1000000000) return regular.getMoneyAbbreviation(value);
    if (value > 0 && value < 0.0000000009) return regular.getMoneyAbbreviationDecimal(value);
    return fallback ?? oCcy.format(value);
  }

  Widget _mainCoin(CoinModel coinInfo,int index) {
    final balanceStr = _formatBalance(coinInfo.value);
    final valueBalanceStr = _formatBalance(
      coinInfo.balanceDoubleAll(),
      fallback: coinInfo.balanceString(),
    );
    Widget? mainImage;
    Widget image;
    if (coinInfo.coin['icon'] == "") {
      image = Image.asset("assets/img/list_default.png");
    } else {
      image = ImageNetWork(imageUrl:
      coinInfo.coin['icon'] ?? "",
        placeholder: "assets/img/list_default.png",
      );
    }
    if (coinInfo.coin['isContract']) {
      mainImage = ImageNetWork(imageUrl:
      coinInfo.mainCoinIcon ?? "",
        placeholder: "assets/img/list_default.png",
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          coinListIndex=index;
        });
      },
      child:Container(
        height: ScreenUtil().setWidth(140.0),
        decoration: coinListIndex==index?BoxDecoration(
          border: Border.all(
            width: ScreenUtil().setWidth(1),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ):null,
        padding: coinListIndex==index?EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)):null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
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
                  if (mainImage != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      height: ScreenUtil().setWidth(22.0),
                      width: ScreenUtil().setWidth(22.0),
                      child: mainImage,
                    ),
                ],
              ),
            ),
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
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(valueBalanceStr,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "\$${coinInfo.coinPriceString()}",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Expanded(child: SizedBox()),
                      Text("\$$balanceStr",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                          )),
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
