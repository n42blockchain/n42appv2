import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_detail_page.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_detail_trx.dart';
import 'package:n42appv2/src/wallet/pages/transactions/transaction_retry.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletChainInfoTransactionsItem extends StatelessWidget {
  final int? type;//0 BTC类型的 1 除了btc其它类型的
  final dynamic transactionModel;
  final CoinModel? coinModel;
  final dynamic onBack;
  const WalletChainInfoTransactionsItem({required this.type,
    required this.transactionModel,
    required this.coinModel,
    required this.onBack,super.key});

  @override
  Widget build(BuildContext context) {
    if(type==0){
      bool isOut=true;
      int index=transactionModel.InputsAddress.indexWhere((e) {
        if(coinModel!.address.toString().toUpperCase()==e.toString().toUpperCase()){
          return true;
        }
        return false;
      });
      if(index==-1){
        isOut=false;
      }
      // TODO: implement build
      return InkWell(
        onTap: ()async{
          if(type==0){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionDetailPage(
                      from: transactionModel.address,
                      to: transactionModel.to1,
                      txHash: transactionModel.txHash,
                      value: transactionModel.price_double().toString(),
                      coinType: transactionModel.coin['coinType'],
                      //gas: transactionModel.gas_double.toString(),
                      time: transactionModel.getTxTimeStr(),
                    )));
          }
          else{
            if(coinModel!.coin['coinType']==CoinType.N.name){
              bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionRetry(coinModel!,transactionModel.txHash,)));
              if(r==true){
                onBack();
              }
            }
            else{
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        from: "",//transactionModel.from1,
                        to: transactionModel.to1,
                        txHash: transactionModel.txHash,
                        value: transactionModel.price_double().toString(),
                        coinType: transactionModel.coin['coinType'],
                        //gas: transactionModel.gas.toString(),
                        //gasPrice: transactionModel.gasPrice_double().toString(),
                        time: DateTime.fromMillisecondsSinceEpoch(int.parse(transactionModel.txTime)).toString(),
                      )));
            }
          }
        },
        child: Card(
          margin: EdgeInsets.only(
            bottom: ScreenUtil().setWidth(30.0),
          ),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          elevation: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(30.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      transactionModel.getTxTimeStr(),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: ScreenUtil().setWidth(30.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                  ],
                ),
                const Divider(
                  height: 10.0,
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(80.0),
                      height: ScreenUtil().setWidth(80.0),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
                      ),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                      child: Icon(
                        isOut?Icons.arrow_upward:Icons.arrow_downward,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOut?S.of(context).g_key_t_4:S.of(context).g_key_t_5,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                isOut?
                                AppThemeKeys.errorTextColor.name:
                                AppThemeKeys.rightTextColor.name,
                              ),
                              fontSize: ScreenUtil().setSp(30.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          EnsAddressText(
                            address: isOut ? transactionModel.OutputAddressStr : transactionModel.InputAddressStr,
                            coinType: coinModel?.coin['coinType'] ?? 'ETH',
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                              fontSize: ScreenUtil().setSp(26.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(20.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${transactionModel.price_double()} ${transactionModel.coin['unit'].toUpperCase()}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(26.0),
                        ),
                      ),
                    ),
                    Text(
                      getBuyStateText(transactionModel.state),
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: transactionModel.state == 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: ScreenUtil().setWidth(20.0),
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(20.0))),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.errorBgColor.name),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/img/remind.png",
                              width: ScreenUtil().setWidth(30.0),
                              height: ScreenUtil().setWidth(32.0),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(10.0),
                            ),
                            Text(
                              transactionModel.errorMessage,
                              maxLines: null,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.errorTextColor.name),
                                fontSize: ScreenUtil().setSp(24.0),
                              ),
                            ),
                          ],
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
    else{
      bool isOut=false;
      if(transactionModel.from1.toString().toLowerCase()==coinModel!.address.toString().toLowerCase()){
        isOut=true;
      }
      // TODO: implement build
      return InkWell(
        onTap: ()async{
          if(type==0){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionDetailPage(
                      from: transactionModel.address,
                      to: transactionModel.to1,
                      txHash: transactionModel.txHash,
                      value: transactionModel.price_double().toString(),
                      coinType: transactionModel.coin['coinType'],
                      //gas: transactionModel.gas_double.toString(),
                      time: DateTime.fromMillisecondsSinceEpoch(int.parse(transactionModel.txTime)*1000).toString(),
                    )));
          }
          else{
            if(coinModel!.coin['blockchainType']==BlockchainType.Ethereum.name){
              if(coinModel!.coin['coinType']==CoinType.N.name){
                bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionRetry(coinModel!,transactionModel.txHash,)));
                if(r==true){
                  onBack();
                }
              }
              else{
                bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetailEth(coinModel!,transactionModel.txHash,)));
                if(r==true){
                  onBack();
                }
              }
            }
            else if(coinModel!.coin['blockchainType']==BlockchainType.Tron.name){
              bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetailTrx(coinModel!,transactionModel.txHash,)));
              if(r==true){
                onBack();
              }
            }
            else{
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(
                        from: transactionModel.from1,
                        to: transactionModel.to1,
                        txHash: transactionModel.txHash,
                        value: transactionModel.price_double().toString(),
                        coinType: transactionModel.coin['coinType'],
                        //gas: transactionModel.gas.toString(),
                        //gasPrice: transactionModel.gasPrice_double().toString(),
                        time: transactionModel.getTxTimeStr(),
                      )));
            }
          }
        },
        child: Card(
          margin: EdgeInsets.only(
            bottom: ScreenUtil().setWidth(30.0),
          ),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          elevation: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(30.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      transactionModel.getTxTimeStr(),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: ScreenUtil().setWidth(30.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                  ],
                ),
                const Divider(
                  height: 10.0,
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(80.0),
                      height: ScreenUtil().setWidth(80.0),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
                      ),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                      child: Icon(
                        isOut?Icons.arrow_upward:Icons.arrow_downward,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOut?S.of(context).g_key_t_4:S.of(context).g_key_t_5,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                isOut?
                                AppThemeKeys.errorTextColor.name:
                                AppThemeKeys.rightTextColor.name,
                              ),
                              fontSize: ScreenUtil().setSp(30.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isOut?transactionModel.to1:transactionModel.from1,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name,),
                              fontSize: ScreenUtil().setSp(26.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setWidth(20.0),
                ),
                if((transactionModel.message??"") !="")
                  Text(
                    '${transactionModel.message}',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                if((transactionModel.message??"") !="")
                  SizedBox(
                    height: ScreenUtil().setWidth(20.0),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${transactionModel.price_double()} ${transactionModel.coin['unit'].toUpperCase()}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(26.0),
                        ),
                      ),
                    ),
                    Text(
                      getBuyStateText(transactionModel.state),
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: transactionModel.state == 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: ScreenUtil().setWidth(20.0),
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(20.0))),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.errorBgColor.name),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/img/error.png",
                              width: ScreenUtil().setWidth(30.0),
                              height: ScreenUtil().setWidth(32.0),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(10.0),
                            ),
                            Text(
                              transactionModel.errorMessage,
                              maxLines: null,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.errorTextColor.name),
                                fontSize: ScreenUtil().setSp(24.0),
                              ),
                            ),
                          ],
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
  //获取购买状态文本
  String getBuyStateText(int state){
    if(state==0){
      return S.current.g_key_t_2;
    }else if(state==1){
      return S.current.g_key_t_1;
    }else if(state==2){
      return S.current.g_key_t_3;
    }else{
      return "";
    }
  }
}
