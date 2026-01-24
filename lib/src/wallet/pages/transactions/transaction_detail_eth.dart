import 'dart:convert';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class TransactionDetailEth extends StatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionDetailEth(this.coinModel,this.txHash,{super.key});

  @override
  State<TransactionDetailEth> createState() => _TransactionDetailEthState();
}

class _TransactionDetailEthState extends State<TransactionDetailEth> {
  EthAPI? _ethAPI;
  EthAPI get ethAPI{
    _ethAPI ??= EthAPI();
    return _ethAPI!;
  }
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  TextEditingController searchEditingController=TextEditingController();
  Load load=Load.finish;
  String errorMessage="";
  TransationRecordModel trm=TransationRecordModel();
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  late String _txHash;
  @override
  void initState() {
    // TODO: implement initState
    _txHash = _txHash;
    searchEditingController.text=_txHash;
    init();
    super.initState();
  }
  init()async{
    errorMessage="";
    if(_txHash==""){
      _txHash=searchEditingController.text;
    }
    if(_txHash==""){
      owner=false;
      return;
    }
    setState(() {
      load=Load.loading;
    });
    List<TransationRecordModel> trModelList=await db.selectTransationRecordTxHash(_txHash,widget.coinModel.address);
    if(trModelList.isNotEmpty){
      trm=trModelList[0];
    }
    bool r=await getTransactionByHash();
    if(r){
      await getTransactionReceipt();
      setState(() {
        load=Load.finish;
      });
    }else{
      setState(() {
        load=Load.error;
      });
    }
  }
  Map<String,dynamic>? transactionInfo;
  Map<String,dynamic>? transactionInfoReceipt;
  String resultStr="Pending";
  String value='';
  String gasPrice='';
  String gasLimit='';
  String nonce="";
  bool owner=true;//是否时自己的交易信息
  getTransactionByHash()async{
    MessageModel rData=await ethAPI.getTransactionByHash(
        _txHash,
        coinType: widget.coinModel.coin['coinType'],);
    if(rData.error==false){
      if(rData.data==null){
        errorMessage="Not found";
        owner=false;
        return false;
      }
      transactionInfo=rData.data;
      trm.gas=hexToInt(transactionInfo!['gas']??"0x0").toInt();
      trm.gasPriceValue=hexToInt(transactionInfo!['gasPrice']??"0x0");
      //trm.price=hexToInt(transactionInfo!['value']??"0x0");
      resultStr="Pending";
      gasPrice='${toGWei(trm.gasPriceValue.toString())} GWei';
      gasLimit='${trm.gas}';
      nonce='${hexToInt(transactionInfo!['nonce']??"0x0").toInt()}';

      if(trm.contract ==""){
        try{
          trm.message=utf8.decode(hexToBytes(transactionInfo!['input']));
        }
        catch(e){
          trm.message="";
        }
        trm.to1=transactionInfo!['to'];
        trm.price=hexToInt(transactionInfo!['value']??"0x0");
        value='${toEther(trm.price.toString(), widget.coinModel.coin['decimals'])} ${widget.coinModel.coin['unit']}';
      }else{
        try{
          trm.message="";
          String input=transactionInfo!['input'];
          String to=input.substring(10,74).substring(24);
          trm.to1="0x$to";
          //String match=input.substring(0,10);
          String valueStr=input.substring(74,138);
          trm.price=hexToInt(valueStr);
          value='${toEther(trm.price.toString(), widget.coinModel.coin['decimals'])} ${widget.coinModel.coin['unit']}';
        } catch (_) {
          // 错误安全忽略
        }
      }
      if(trm.from1.toLowerCase() != (transactionInfo?['from']??"").toString().toLowerCase()){
        owner=false;
      }else{
        owner=true;
      }
      return true;
    }else{
      errorMessage=rData.data.toString();
      owner=false;
      return false;
    }
  }
  getTransactionReceipt()async{
    MessageModel rData=await ethAPI.getTransactionReceipt(
        _txHash,
        coinType: widget.coinModel.coin['coinType'],);
    if(rData.error==false){
      transactionInfoReceipt=rData.data;
      if(transactionInfoReceipt !=null){
        if(transactionInfoReceipt!['status']=="0x0"){
          resultStr="Pending";
        }
        else if(transactionInfoReceipt!['status']=="0x1"){
          resultStr="Success";
          return;
        }else{
          resultStr="Error";
        }
      }
      errorMessage="";
    }else{
      errorMessage=rData.data.toString();
    }
  }
  //关闭键盘
  closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_3,
      ),
      body: bodyWidget(),
    );
  }
  bodyWidget(){
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                searchWidget(),
                Expanded(
                  flex: 1,
                  child: load==Load.error?errorWidget():
                  txDataWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  errorWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: (){
            init();
          },
          child: Container(
            height: ScreenUtil().setWidth(80),
            width: ScreenUtil().setWidth(80),
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            child: Icon(Icons.refresh,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
          ),
        ),
        errorMessageWidget(),
      ],
    );
  }
  txDataWidget(){
    if(transactionInfo==null){
      return const IntrinsicHeight(
        child: Center(
          child: EmptyView(),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          itemWidget(S.of(context).g_key_wallet_k37,transactionInfo?['hash']??"",copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_wallet_k33,resultStr),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_wallet_k54,transactionInfo?['blockHash']??"",copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_75,transactionInfo?['from']??"",copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_38,trm.to1,copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_wallet_k55,value),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_t_15,gasPrice),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_101,gasLimit),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_wallet_k56,nonce),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          itemWidget(S.of(context).g_key_wallet_k58,trm.message??""),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          errorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140),),
        ],
      ),
    );
  }
  searchWidget(){
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(72.0),
        minHeight: ScreenUtil().setWidth(72.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                hintText: S.of(context).search,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              maxLines: 1,
              onEditingComplete: (){
                closeKeyboard();
                init();
              },
            ),
          ),
          InkWell(
            onTap: (){
              closeKeyboard();
              init();
            },
            child: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              alignment: Alignment.center,
              child: Icon(
                Icons.search,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
  errorMessageWidget(){
    if(errorMessage==""){
      return SizedBox();
    }else{
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),left: ScreenUtil().setWidth(30),right: ScreenUtil().setWidth(30)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
        ),
        child: Text(
          errorMessage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

  }
  itemWidget(String title,String value,{bool copy=false}){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20),),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ),
              if(copy)
                InkWell(
                  onTap: (){
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                    child: Icon(Icons.copy,color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
