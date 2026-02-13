import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/payment_history.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/set_amount.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentCode extends StatefulWidget {
  final Map<String,String>? amount;
  const PaymentCode({this.amount,super.key});

  @override
  State<PaymentCode> createState() => _PaymentCodeState();
}

class _PaymentCodeState extends State<PaymentCode> {
  Map<String,String>? amount;
  @override
  void initState() {
    amount=widget.amount;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
      appBar: AppBarWidget(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
        text: "收款码",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: ScreenUtil().setSp(32.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentHistory()));
            },
            child: Text(
              "历史",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                ),
                child: Column(
                  children: [
                    if((AppGlobals.userInfo?.name??"") !="")
                    Container(
                      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
                      alignment: Alignment.center,
                      child: Text(
                        AppGlobals.userInfo?.name??"未设置",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlockColor.name),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if(amount !=null)
                      Container(
                        padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30)),
                        alignment: Alignment.center,
                        child: Text(
                          "\$ ${amount?["amount"]??""}",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(50),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlockColor.name),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40.0)),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: QrImageView(
                        padding: EdgeInsets.all(20.0),
                        backgroundColor: const Color(0xffffffff),
                        data: "${AppConfig.apiUrl['walletamazeBrowser']}?type=payment&amount=${amount?['amount']??""}&coinType=${amount?['coinType']??""}&address=${amount?['address']??""}&user=${AppGlobals.userInfo?.uuid??""}",
                        version: QrVersions.min + 7,
                        embeddedImage:Image.network("${AppConfig.apiUrl['walletamazeBrowser']}/static/ast.png").image,
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(ScreenUtil().setWidth(80.0), ScreenUtil().setWidth(80.0)),
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setWidth(60),
                      indent: 0,
                      endIndent: 0,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
                    ),
                    TextButton(
                      onPressed: ()async{
                        Map<String,String>? rAmount=await Navigator.push(context, MaterialPageRoute(builder: (context)=>SetAmount(type: 1,amount: amount,)));
                        if(rAmount !=null){
                          setState(() {
                            amount=rAmount;
                          });
                        }
                      },
                      child: Text(
                        "设置收款金额",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        ),
                      ),
                    ),
                  ],
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
