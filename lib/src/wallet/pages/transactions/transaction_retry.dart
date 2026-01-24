import 'dart:async';
import 'dart:convert';

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';

class TransactionRetry extends StatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionRetry(this.coinModel,this.txHash,{super.key});

  @override
  State<TransactionRetry> createState() => _TransactionRetryState();
}

class _TransactionRetryState extends State<TransactionRetry> {
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
  late TokenViewApi tokenViewApi;
  late String _txHash;
  @override
  void initState() {
    // TODO: implement initState
    _txHash = _txHash;
    searchEditingController.text=_txHash;
    init();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(timer !=null){
      timer!.cancel();
      timer=null;
    }
    super.dispose();
  }
  init()async{
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
    if (!mounted) return;
    if(trModelList.isNotEmpty){
      trm=trModelList[0];
    }
    else{
      TransationRecordModel trModel=TransationRecordModel();
      trModel.address=widget.coinModel.address.toString();
      trModel.from1=widget.coinModel.address.toString();
      //trModel.to1=toAddr??"";//toTextEditingController.text;
      trModel.addrType=widget.coinModel.addrType;
      trModel.coin=widget.coinModel.coin;
      trModel.coinMiniName=widget.coinModel.coin['coinType'];
      trModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
      trModel.contract=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
      trModel.isTest=widget.coinModel.isTest?1:0;
      trModel.gasPrice=BigInt.zero;//totalGasPrice;
      //trModel.gas=gas.toInt();
      trModel.gasPriceValue=BigInt.zero;//gasPrice;
      //trModel.price=transferValue;
      trModel.coinId=widget.coinModel.isTest?widget.coinModel.coin['chainId_test']:widget.coinModel.coin['chainId'];
      trm=trModel;
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
  Timer? timer;
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
          resultStr="Error";
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
    timer_init();
  }
  timer_init(){
    timer=Timer(Duration(seconds: 3), () {
      getTransactionReceipt();
    });
  }
  send(String toAddress,BigInt value,double gasPricePercent)async{
    try{
      if(load==Load.loading)return;
      if(errorMessage !="")return;
      setState(() {
        load=Load.loading;
      });
      if(transactionInfo!['gasPrice']=="0x0"){
        MessageModel rGasPrice=await tokenViewApi.getGasPrice(
            BlockchainType.Ethereum.name,
            trm.coinMiniName,
          rpc: widget.coinModel.coin['custom']==true?widget.coinModel.coin['service']:null,
        );
        if(rGasPrice.error==false){
          trm.gasPriceValue=rGasPrice.data*BigInt.from(gasPricePercent);
        }else{
          ToastUtils.show(rGasPrice.data);
          return;
        }
      }
      trm.price=value;
      trm.gas=hexToInt(transactionInfo!['gas']).toInt();
      trm.gasPriceValue=trm.gasPriceValue*BigInt.from(gasPricePercent);
      trm.gasPrice=trm.gasPriceValue*BigInt.from(trm.gas);
      trm.to1=toAddress;
      trm.nonce=transactionInfo!['nonce'];

      BigInt gaslimit=BigInt.from(GetCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
      MessageModel ethMessage=await tokenViewApi.getGasEstimateEthV2(//EthAPI.getGasLimit(
        widget.coinModel.address,
        trm.to1,
        trm.gasPriceValue,
        trm.price,
        gaslimit,
        widget.coinModel.coin['coinType'],
        contract: widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'],
        isTest: widget.coinModel.isTest,
      );
      if (!mounted) return;
      if(ethMessage.error==false){
        trm.gas=(ethMessage.data as BigInt).toInt();
        trm.gasPrice=trm.gasPriceValue*BigInt.from(trm.gas);
      }else{
        ToastUtils.show(ethMessage.data);
        return;
      }

      bool check=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletBaseSend(trm,null,trm.coin['unit'])));
      if (!mounted) return;
      if(check==false){
        setState(() {
          load=Load.finish;
        });
        return;
      }
      TransferApi transferApi=TransferApi();
      MessageModel mm=await transferApi.transferWallet(
          trModel: trm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex);
      if (!mounted) return;
      if(mm.error){
        ToastUtils.show(ethMessage.data);
      }else{
        trm.txHash=mm.data;
        if(trm.trId==0){
          trm.trId=await db.insertTransationRecord(trm);
          if (!mounted) return;
          Provider.of<TransactionRecordItemProvider>(context,listen: false).addUndoneTr(trm,1);
        }else{
          await db.updateTransationRecord(trm);
          if (!mounted) return;
          Provider.of<TransactionRecordItemProvider>(context,listen: false).selectUndoneTr();
        }
        ToastUtils.show(S.current.g_key_nft_41);
        setState(() {
          load=Load.finish;
        });
        Navigator.pop(context,true);
      }
    }catch(e){
      ToastUtils.show(e.toString());
      load=Load.finish;
      setState(() {});
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
          if(transactionInfoReceipt ==null)
            bottomButton(),
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
                    ToastUtils.showFtToast(child:SuccessViewV1(S.of(context).copy),duration: 3);
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
  bottomButton(){
    if(load==Load.loading){
      return loadingButton();
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: owner?Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_key_79,(){
                send(trm.from1,BigInt.zero,2);
              }),
            ),
            SizedBox(width: ScreenUtil().setWidth(30.0),),
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_key_wallet_k57,(){
                send(trm.to1,trm.price,2);
              }),
            ),
          ],
        ),
      ):
      SizedBox(),
    );
  }
  loadingButton(){
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
          height: ScreenUtil().setWidth(88.0),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(40),
                width: ScreenUtil().setWidth(40),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                child: CircularProgressIndicator(),
              ),
              Text(
                S.of(context).g_key_106,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name)
                ),
              ),
            ],
          )
      ),
    );
  }
  buttonWidget(String title,dynamic onTap,){
    return ButtonStyle2(context, ()async{
      onTap();
    }, title);
  }
}
