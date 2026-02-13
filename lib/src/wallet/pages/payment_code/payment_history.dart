import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/utils/browser_txhash.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  List<Map<String,dynamic>> dataList=[
    {
      "fromUuid":"123456",
      "fromName":"豆豆",
      "toUuid":"75ae0f5b-e3a4-4b46-bbdf-4cd8f88a72ff",
      "toName":"豇豆",
      "amount":"9.9",
      "tokenAmount":"10.1",
      "chainSymbol":"ETH",
      "token":"USDT",
      "tokenPrice":"0.92",
      "txHash":"0x12345678901234567890",
    },
    {
      "fromUuid":"75ae0f5b-e3a4-4b46-bbdf-4cd8f88a72ff",
      "fromName":"豆豆",
      "toUuid":"654321",
      "toName":"豇豆",
      "amount":"7.9",
      "tokenAmount":"8.1",
      "chainSymbol":"ETH",
      "token":"USDT",
      "tokenPrice":"0.92",
      "txHash":"0x12345678901234567890",
    },
    {
      "fromUuid":"123456",
      "fromName":"豆豆",
      "toUuid":"75ae0f5b-e3a4-4b46-bbdf-4cd8f88a72ff",
      "toName":"豇豆",
      "amount":"8.8",
      "tokenAmount":"9",
      "chainSymbol":"ETH",
      "token":"USDT",
      "tokenPrice":"0.92",
      "txHash":"0x12345678901234567890",
    },
    {
      "fromUuid":"75ae0f5b-e3a4-4b46-bbdf-4cd8f88a72ff",
      "fromName":"豆豆",
      "toUuid":"654321",
      "toName":"豇豆",
      "amount":"1.1",
      "tokenAmount":"1.2",
      "chainSymbol":"ETH",
      "token":"USDT",
      "tokenPrice":"0.92",
      "txHash":"0x12345678901234567890",
    },
    {
      "fromUuid":"123456",
      "fromName":"豆豆",
      "toUuid":"75ae0f5b-e3a4-4b46-bbdf-4cd8f88a72ff",
      "toName":"豇豆",
      "amount":"6.6",
      "tokenAmount":"7",
      "chainSymbol":"ETH",
      "token":"USDT",
      "tokenPrice":"0.92",
      "txHash":"0x12345678901234567890",
    },
  ];
  String uuid="";
  @override
  void initState() {
    uuid=AppGlobals.userInfo?.uuid??"";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: "支付历史",
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setWidth(15)),
        itemCount: dataList.length,
        itemBuilder: (context,index){
          Map<String,dynamic> data=dataList[index];
          Widget icon;
          Widget sz;
          if(data["toUuid"]==uuid){
            icon=Icon(
              Icons.input_outlined,
              size: ScreenUtil().setWidth(40),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
            );
            sz=Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
              child: Text(
                "收入",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            );
          }else{
            icon=Icon(
              Icons.output_outlined,
              size: ScreenUtil().setWidth(40),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
            );
            sz=Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
              child: Text(
                "支出",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            );
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
            padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    icon,
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: (){
                          String openUrl=getBrowserTxHash(data['chainSymbol'], data['txHash']);
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(openUrl)));
                        },
                        child: Text(
                          data['txHash'],
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(28),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: ScreenUtil().setWidth(16),
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "\$ ${data['amount']}",
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                    fontSize: ScreenUtil().setSp(40),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "约 ${data['tokenAmount']}${data['token']}",
                                  style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                    fontSize: ScreenUtil().setSp(40),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                        )
                    ),
                    sz,
                  ],
                ),
                Divider(
                  height: ScreenUtil().setWidth(16),
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  children: [
                    Text(
                      "${data['token']}(${data['chainSymbol']})",
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "\$ ${data['tokenPrice']}",
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(28),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
