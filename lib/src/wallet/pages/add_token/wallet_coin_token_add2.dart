import 'dart:convert';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletCoinTokenAdd2 extends StatefulWidget {
  //Map<String,dynamic> coinMap;
  final CoinModel coinModel;
  //int isImport;
  const WalletCoinTokenAdd2(this.coinModel,{super.key});

  @override
  State<WalletCoinTokenAdd2> createState() => _WalletCoinTokenAdd2State();
}

class _WalletCoinTokenAdd2State extends State<WalletCoinTokenAdd2> {
  TextEditingController inputEditingController=TextEditingController();
  List<dynamic> coinlist=[];
  List<dynamic> coinlistSeach=[];
  Load load=Load.finish;
  List<String> symbols=[];
  String addSymbol="";//添加的代币
  bool removeSymbol=false;//是否移除了代币
  @override
  void initState() {
    // TODO: implement initState
    getTokenList();
    init();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    inputEditingController.dispose();
    super.dispose();
  }
  init(){
    if(widget.coinModel.tokens.isNotEmpty) {
      symbols=widget.coinModel.tokens.keys.toList();
    }
  }
  checkSymbol(String symStr){
    var checks=symbols.where((element){
      if(element.toUpperCase()==symStr.toUpperCase()){
        return true;
      }else{
        return false;
      }
    });
    if(checks.isEmpty)return false;
    return true;
  }
  addCoin(Map<String,dynamic> coinMap)async{
    try {
      if(coinMap['edit']==true)return;
      setState(() {
        coinMap['edit']=true;
      });
      WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
      String baseTokenStr=json.encode(widget.coinModel.coin);
      Map<String,dynamic>baseToken=json.decode(baseTokenStr);
      baseToken['isContract']=true;
      baseToken['contract']=coinMap['contract'].toString();
      baseToken['contract_test']="";
      baseToken['balance']="0";
      baseToken['balance_test']="0";
      baseToken['coinPrice']=0.0;
      baseToken['percentage']=0.0;
      baseToken['icon']=coinMap['icon'];
      baseToken['name']=coinMap['fullname'];
      baseToken['miniName']=coinMap['coin_name'].toString();
      baseToken['mKey']=coinMap['contract'].toString().toUpperCase();
      baseToken['unit']=coinMap['coin_name'].toString();
      baseToken['decimals']=coinMap['decimals'];
      baseToken['canEdit']=true;
      addSymbol='$addSymbol,${coinMap['coin_name'].toString()}';
      wap.addWalletChain_token(baseToken);
      setState(() {
        coinMap['isAdd']=true;
        coinMap['edit']=false;
      });
    }catch(e){
      ToastUtils.show(e.toString());
      setState(() {
        coinMap['edit']=false;
      });
    }
  }
  removeCoin(Map<String,dynamic> coinMap)async{
    try{
      if(coinMap['edit']==true)return;
      setState(() {
        coinMap['edit']=true;
      });
      WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
      wap.removeWalletChain_token(coinMap);
      coinMap['isAdd']=false;
      removeSymbol=true;

      setState(() {
        coinMap['edit']=false;
      });
    }catch(e){
      ToastUtils.show(e.toString());
      setState(() {
        coinMap['edit']=false;
      });
    }
  }
  //查询方法
  seachCoin()async{
    if(inputEditingController.text!=""){
      try{
        coinlistSeach=[];
        String inputStr=inputEditingController.text.toLowerCase();
        for(Map<String,dynamic> m in coinlist){
          int fullnameIndex=m['fullname'].toString().indexOf(inputStr);
          String symbolStr=m['coin_name'].toString();
          int symbolIndex=symbolStr.indexOf(inputStr);
          if(symbolIndex!=-1 || fullnameIndex!=-1){
            coinlistSeach.add(m);
          }
        }
      }catch(e){
        ToastUtils.show(e.toString());
      }
    }
    setState(() {
    });
  }
  getTokenList()async{
    setState(() {
      load=Load.loading;
    });
    TokenViewApi tokenViewApi=TokenViewApi();
    String fullname=widget.coinModel.coin['name'];
    if(fullname == "AmazeToken"){
      fullname="Amaze Chain";
    }
    MessageModel coinsData=await tokenViewApi.getTokenListFullname(fullname);
    if(coinsData.error){
      ToastUtils.show(coinsData.data);
    }else{
      coinlist=[];
      List<dynamic> returnData=coinsData.data;
      //Map<String,dynamic>chains= ProviderUtil.walletActionProvider().walletMap;
      for(Map<String,dynamic> r in returnData){
        if(r['contract']==""){
          continue;
        }else{
          r['isAdd']=checkSymbol(r['contract'].toString().toUpperCase());
          r['edit']=false;
          if(r['isAdd']){
            coinlist.insert(0, r);
          }else{
            coinlist.add(r);
          }
        }
      }
      setState(() {
        load=Load.finish;
      });
    }
  }
  //关闭键盘
  closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  Future<bool> _pageBack(){
    if(Navigator.canPop(context)){
      bool rValue=removeSymbol;
      if(addSymbol!=""){
        rValue=true;
      }
      Navigator.pop(context,rValue);
    }else{
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        appBar: AppBar(
          title: Text(
            S.of(context).g_key_9,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
          actions: [
            load==Load.loading?Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
              child: SizedBox(
                height: ScreenUtil().setWidth(40.0),
                width: ScreenUtil().setWidth(40.0),
                child: CircularProgressIndicator(),
              ),
            ):Container()
          ],
        ),
        body: SafeArea(
          child: InkWell(
            onTap: (){
              closeKeyboard();
            },
            child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
                    constraints: BoxConstraints(
                        minHeight: ScreenUtil().setWidth(100.0),
                        maxHeight: ScreenUtil().setWidth(100.0)
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
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
                              seachCoin();
                            },
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            closeKeyboard();
                            seachCoin();
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
                    child: coinListWidget(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  coinListWidget(){
    if(inputEditingController.text==""){
      return RefreshIndicator(
        onRefresh: ()async{
          if(load==Load.finish) {
            await getTokenList();
          }
        },
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
        displacement: ScreenUtil().setWidth(72.0),
        child: ListView.separated(
          itemCount: coinlist.length,
          itemBuilder: (context,int index){
            Map<String,dynamic> rowValue = coinlist[index];
            return coinItem(rowValue);
          },
          separatorBuilder: (context,int index){
            return Divider(
              height: ScreenUtil().setWidth(1.0),
              indent: 0,
              endIndent: 0,
            );
          },
        ),
      );
    }
    else{
      if(coinlistSeach.isEmpty) {
        return const EmptyView();
      }
      return ListView.separated(
        itemCount: coinlistSeach.length,
        itemBuilder: (context,int index){
          Map<String,dynamic> rowValue = coinlistSeach[index];
          return coinItem(rowValue);
        },
        separatorBuilder: (context,int index){
          return Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          );
        },
      );
    }
  }
  coinItem(Map<String,dynamic> rowValue){
    //Widget imgWidget=ImageWidget(rowValue['icon']);
    String icon='https://api-wallet.walletamaze.com/market/v1/r/coinImage/${rowValue['coin_name']}.png';
    String fullname = rowValue['fullname'];
    if(fullname=="LoveCoin"){
      icon=rowValue['icon'];
    }
    Widget imgWidget = ImageNetWork(imageUrl: icon,placeholder: "assets/img/list_default.png",);
    if(rowValue['fullname']=="N42"){
      imgWidget=Image.asset('assets/img/ast.png');
    }

    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),
      //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil().setWidth(50.0),
            height: ScreenUtil().setWidth(50.0),
            margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(30.0)),
            child: imgWidget,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(rowValue['fullname'],
                  style: TextStyle(
                    fontSize: ScreenUtil().setWidth(30.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    height: 1.3,
                  ),
                ),
                Text(
                  '${rowValue['coin_name'].toString()}  ',
                  style: TextStyle(
                    fontSize: ScreenUtil().setWidth(26.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if(rowValue['edit'])
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: CircularProgressIndicator(),
            ),
          if(rowValue['isAdd']==false && rowValue['edit']==false)
            InkWell(
              onTap: (){
                addCoin(rowValue);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
                width: ScreenUtil().setWidth(78.0),
                height: ScreenUtil().setWidth(78.0),
                child: Icon(Icons.add,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
              ),
            ),
          if(rowValue['isAdd'] && rowValue['edit']==false)
            InkWell(
              onTap: (){
                removeCoin(rowValue);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setWidth(80.0),
                child: Icon(Icons.remove,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
              ),
            ),
        ],
      ),
    );
  }
}
