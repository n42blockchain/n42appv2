import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/payment_code.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SetAmount extends StatefulWidget {
  int type;//0默认 跳转并替换PaymentCode页面，1返回上一个页面
  Map<String,String>? amount;
  SetAmount({this.type=0,this.amount,super.key});

  @override
  State<SetAmount> createState() => _SetAmountState();
}

class _SetAmountState extends State<SetAmount> {
  Regular? _regular;
  Regular get regular{
    if(_regular==null){
      _regular=Regular();
    }
    return _regular!;
  }
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  final TextEditingController amountController = TextEditingController();
  List<CoinModel> coinList=[];
  int coinListIndex=-1;
  String amountErrorMessage="";
  @override
  void initState() {
    // TODO: implement initState
    initCoin();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    amountController.dispose();
    super.dispose();
  }
  initCoin(){
    WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
    for(CoinModel cm in wap.coinList){
      if(cm.coin['miniName'].toString().toLowerCase()=="usdt"){
        coinList.add(cm);
      }
    }
    if(coinList.length !=0){
      if(widget.amount !=null){
        int index=coinList.indexWhere((e){
          if(widget.amount!['coinType']==e.coin['coinType'] && widget.amount!['address']==e.address){
            return true;
          }
          return false;
        });
        if(index !=-1){
          coinListIndex=index;
          amountController.text=widget.amount!["amount"].toString();
        }else{
          coinListIndex=0;
        }
      }else{
        coinListIndex=0;
      }
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: "设置收款金额",
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
              child: TextFieldStyle2(
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
                  String amountStr=amountController.text;
                  if(regular.regular_double(amountStr)==false){
                    if(regular.regular_nums(amountStr)==false){
                      amountErrorMessage="收款金额格式错误";
                    }else{
                      amountErrorMessage="";
                    }
                  }else{
                    amountErrorMessage="";
                  }
                  setState(() {});
                },
                onChanged: (String value){
                  if(regular.regular_double(value)==false){
                    if(regular.regular_nums(value)==false){
                      amountErrorMessage="收款金额格式错误";
                    }else{
                      amountErrorMessage="";
                    }
                  }else{
                    amountErrorMessage="";
                  }
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
                flex: 1,
                child: Container(
                  height: ScreenUtil().setWidth(300.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.backGroundColor.name),
                  child: const EmptyView(),
                ),
              ),
            if(coinList.isNotEmpty)
              Expanded(
                flex: 1,
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
              child: ButtonStyle6(
                context, (){
                  String amountStr=amountController.text;
                  if(regular.regular_double(amountStr)==false){
                    if(regular.regular_nums(amountStr)==false){
                      setState(() {
                        amountErrorMessage="收款金额格式错误";
                      });
                      return;
                    }else{
                      amountErrorMessage="";
                    }
                  }else{
                    amountErrorMessage="";
                  }
                  setState(() {});
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
                "确定",
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
  Widget _mainCoin(CoinModel coinInfo,int index) {
    String balanceStr = "";
    double balance = coinInfo.value;
    if (balance >= 1000000000) {
      balanceStr = regular.getMoneyAbbreviation(balance);
    }else if(balance>0 && balance <0.0000000009){
      balanceStr=regular.getMoneyAbbreviation_decimal(balance);
    } else {
      balanceStr = oCcy.format(balance);
    }
    String valueBalanceStr="";
    double valueBalance=coinInfo.balance_double_all();
    if(valueBalance>1000000000){
      valueBalanceStr=regular.getMoneyAbbreviation(valueBalance);
    }else if(valueBalance>0 && valueBalance <0.0000000009){
      valueBalanceStr=regular.getMoneyAbbreviation_decimal(valueBalance);
    }else{
      valueBalanceStr=coinInfo.balance_string();
    }
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
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
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
                        flex: 1,
                        child: Text("${valueBalanceStr}",
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
                        "\$${coinInfo.coinPrice_string()}",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      //percentageWidget(context, coinInfo.percentage),
                      const Expanded(flex: 1, child: SizedBox()),
                      Text("\$${balanceStr}",
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
