import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_dot.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_ton.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42appv2/src/wallet/pages/wallet_receive_qr.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletSearchCoin extends ConsumerStatefulWidget {
  final int type;//0转账，1收币
  const WalletSearchCoin(this.type,{super.key});

  @override
  ConsumerState<WalletSearchCoin> createState() => _WalletSearchCoinState();
}

class _WalletSearchCoinState extends ConsumerState<WalletSearchCoin> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  TextEditingController inputEditingController=TextEditingController();
  List<CoinModel> coinlistSearch=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    inputEditingController.dispose();
    super.dispose();
  }
  //查询方法
  Future<void> seachCoin(WalletActionProvider waValue)async{
    if(inputEditingController.text!=""){
      try{
        coinlistSearch=[];
        String inputStr=inputEditingController.text.toLowerCase();

        for(CoinModel cm in waValue.coinList){
          String symbolStr=cm.coin['miniName'].toString().toLowerCase();
          int fullnameIndex=cm.coin['name'].toString().toLowerCase().indexOf(inputStr);
          int symbolIndex=symbolStr.indexOf(inputStr);
          if(symbolIndex!=-1 || fullnameIndex!=-1){
            coinlistSearch.add(cm);
          }
        }
      }catch(e){
        ToastUtils.show(e.toString());
      }
    }
    setState(() {
    });
  }
  //关闭键盘
  void closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(builder: (context) {
          final waValue = ref.watch(wapBridgeProvider);
          return SizedBox(
            height: ScreenUtil().setWidth(800.0),
            width: double.infinity,
            child: Column(
              children: [

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                  margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
                  /*constraints: BoxConstraints(
                        minHeight: scr.setWidth(100.0),
                      ),*/
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  ),
                  constraints: BoxConstraints(
                    minHeight: ScreenUtil().setWidth(100.0),
                    maxHeight: ScreenUtil().setWidth(100.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex:1,
                        child: TextField(
                          controller: inputEditingController,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setWidth(30.0),
                          ),
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(26.0)),
                            isCollapsed: true,
                            hintText: S.of(context).g_key_163,
                            hintStyle: TextStyle(
                              fontSize: ScreenUtil().setWidth(30.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            ),
                            border: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (String value){
                          },
                          onSubmitted: (value){
                            seachCoin(waValue);
                          },
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          closeKeyboard();
                          seachCoin(waValue);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20.0),
                          ),
                          height: ScreenUtil().setWidth(60.0),
                          decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(context,AppThemeKeys.mainButtonBgColor.name),
                            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0))),
                          ),
                          alignment: Alignment.center,
                          child: Text(S.of(context).search,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: coinListWidget(waValue),
                ),
              ],

            ),
          );
        });
  }
  Widget coinListWidget(WalletActionProvider waValue){
    if(inputEditingController.text==""){
      return ListView.builder(
        itemCount: waValue.coinList.length,
        itemBuilder: (context,int index){
          return _mainCoin(waValue.coinList[index]);
        },
      );
    }else{
      if(coinlistSearch.isEmpty){
        return const EmptyView();
      }else{
        return ListView.builder(
          itemCount: coinlistSearch.length,
          itemBuilder: (context,int index){
            return _mainCoin(coinlistSearch[index]);
          },
        );
      }
    }
  }
  Widget _mainCoin(CoinModel coinInfo) {
    String balanceStr = "";
    double balance = coinInfo.value;
    if (balance >= 1000000000) {
      balanceStr = regular.getMoneyAbbreviation(balance);
    } else {
      balanceStr = oCcy.format(balance);
    }
    Widget? mainImage;
    Widget image;
    if (coinInfo.coin['miniName'] == "") {
      image = Image.asset('assets/images/list_default.png');
    } else {
      image = ImageNetWork(imageUrl:
        coinInfo.coin['icon'],
        placeholder: "assets/img/list_default.png",
      );
    }
    if(coinInfo.coin['isContract']){
      mainImage=ImageNetWork(imageUrl:
        coinInfo.mainCoinIcon??"",
        placeholder: "assets/img/list_default.png",
      );
    }
    Widget refreshWidget = SizedBox();
    /*if (coinInfo.isRefresh) {
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0),),
        child: CircularProgressIndicator(),
      );
    }else*/
    if(coinInfo.loadError){
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0),),
        child: Image.asset("assets/img/error.png",color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),),
      );
    }
    return InkWell(
      onTap: () async{
        if(widget.type==0){
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context){
                if(coinInfo.coin["blockchainType"]==BlockchainType.Bitcoin.name){
                  return WalletChainSendBtc(coinInfo);
                }else if(coinInfo.coin["blockchainType"]==BlockchainType.Solana.name){
                  return WalletChainSendSol(coinInfo);
                }else if(coinInfo.coin["blockchainType"]==BlockchainType.Algorand.name){
                  return WalletChainSendAlgo(coinInfo);
                }else if(coinInfo.coin["blockchainType"]==BlockchainType.Ripple.name){
                  return WalletChainSendXrp(coinInfo);
                }else if(coinInfo.coin["blockchainType"]==BlockchainType.Filecoin.name){
                  return WalletChainSendFil(coinInfo);
                }else if(coinInfo.coin['blockchainType']==BlockchainType.Polkadot.name){
                  return WalletChainSendDot(coinInfo);
                }else if(coinInfo.coin['blockchainType']==BlockchainType.Sui.name) {
                  return WalletChainSendSui(coinInfo);
                }else if(coinInfo.coin['blockchainType']==BlockchainType.TheOpenNetwork.name) {
                  return WalletChainSendTon(coinInfo);
                }else{
                  return WalletChainSend(coinInfo);
                }
              },
            ),
          );
          if (!mounted) return;
        }else{
          if (!mounted) return;
          if(coinInfo.coin['isContract']){
            int cIndex=ref.read(wapBridgeProvider).coinModels.indexWhere((element){
              if(element.coin['coinType']==coinInfo.coin['coinType']){
                return true;
              }
              return false;
            });
            CoinModel chainCoinModel=ref.read(wapBridgeProvider).coinModels[cIndex];
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context)=>WalletReceiveQr(chainCoinModel,tokenCoinModel: coinInfo,),
              ),
            );
            if (!mounted) return;
          }
          else{
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context)=>WalletReceiveQr(coinInfo),
              ),
            );
            if (!mounted) return;
          }
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(30.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                width: ScreenUtil().setWidth(1.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
              )
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            refreshWidget,
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
                  if(mainImage !=null)
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
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("\$$balanceStr",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name),
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(coinInfo.address==null?"":
                      "${coinInfo.address.toString().substring(0,6)}...${coinInfo.address.toString().substring(coinInfo.address.toString().length-5)}",
                          //coinInfo.coin['name'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                          )),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      percentageWidget(context, coinInfo.percentage),
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
  //bi 的涨跌幅百分比
  Widget percentageWidget(BuildContext context, var percentage) {
    if (percentage >= 0) {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
          ));
    } else {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ));
    }
  }
}
