import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/src/browser/pages/browser_page.dart';
import 'package:n42_wallet/src/wallet/utils/browser_txhash.dart';

import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/src/wallet/api/token_view_api.dart';
import 'package:n42_wallet/src/wallet/api/transfer_api.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/wallet/utils/coin_gas.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/empty.dart';
import 'package:n42_wallet/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web3dart/web3dart.dart';

/// EVM eth_getTransactionReceipt 返回的 status 字段格式不统一：
/// - 标准节点: "0x1" / "0x0"
/// - 部分节点: "0x01" / "0x00"（带前导零）
/// - 部分节点: 整数 1 / 0
/// - 旧格式:   bool true / false
/// 统一解析，1 == 成功，其他均为失败。
bool _isReceiptSuccess(dynamic status) {
  if (status == null) return false;
  if (status is bool) return status;
  if (status is int) return status == 1;
  final s = status.toString().toLowerCase().trim();
  if (s == '1' || s == 'true') return true;
  final hex = s.startsWith('0x') ? s.substring(2) : s;
  final n = int.tryParse(hex, radix: 16);
  return n != null && n == 1;
}

class TransactionRetry extends ConsumerStatefulWidget {
  final String txHash;
  final CoinModel coinModel;
  const TransactionRetry(this.coinModel,this.txHash,{super.key});

  @override
  ConsumerState<TransactionRetry> createState() => _TransactionRetryState();
}

class _TransactionRetryState extends ConsumerState<TransactionRetry> {
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
  TokenViewApi? _tokenViewApiInstance;
  TokenViewApi get tokenViewApi {
    _tokenViewApiInstance ??= TokenViewApi();
    return _tokenViewApiInstance!;
  }
  late String _txHash;
  late String _explorerUrl;
  @override
  void initState() {
    _txHash = widget.txHash;
    searchEditingController.text=_txHash;
    _explorerUrl = getBrowserTxHash(
      widget.coinModel.coin['coinType'],
      _txHash,
      isTest: widget.coinModel.isTest,
    );
    init();
    super.initState();
  }
  @override
  void dispose() {
    if(timer !=null){
      timer!.cancel();
      timer=null;
    }
    super.dispose();
  }
  Future<void> init()async{
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
      trModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
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
  BigInt _originalGasPriceValue = BigInt.zero;
  Timer? timer;
  Future<bool> getTransactionByHash()async{
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
      _originalGasPriceValue = trm.gasPriceValue; // 缓存原始值，防止重复乘法
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
  Future<void> getTransactionReceipt()async{
    MessageModel rData=await ethAPI.getTransactionReceipt(
        _txHash,
        coinType: widget.coinModel.coin['coinType'],);
    if(rData.error==false){
      transactionInfoReceipt=rData.data;
      if(transactionInfoReceipt !=null){
        // receipt 非 null 表示交易已上链确认，停止轮询
        if(_isReceiptSuccess(transactionInfoReceipt!['status'])){
          resultStr="Success";
        }else{
          // 0x0 = 链上 revert，或其他异常状态
          resultStr="Failed";
        }
        return;
      }
      // receipt 为 null 表示仍在 mempool，继续轮询
      errorMessage="";
    }else{
      errorMessage=rData.data.toString();
    }
    timerInit();
  }
  void timerInit(){
    timer=Timer(Duration(seconds: 3), () {
      getTransactionReceipt();
    });
  }
  Future<void> send(String toAddress, BigInt transferValue, {bool isCancel = false}) async {
    if (load == Load.loading) return;
    if (errorMessage != "") return;
    if (!mounted) return;
    setState(() { load = Load.loading; });
    try {
      // Step 1: 计算替换 gasPrice（修复 Bug 2 双重乘法 / Bug 7 testnet RPC）
      final bool isEip1559 = transactionInfo!['gasPrice'] == "0x0"
          || _originalGasPriceValue == BigInt.zero;
      final String? customRpc = widget.coinModel.coin['custom'] == true
          ? (widget.coinModel.isTest
              ? widget.coinModel.coin['service_test']
              : widget.coinModel.coin['service'])
          : null;

      BigInt newGasPriceValue;
      if (isEip1559) {
        // EIP-1559：从 API 获取当前市场价格 ×1.5（修复 Bug 2 错误乘法）
        final mm = await tokenViewApi.getGasPrice(
          BlockchainType.Ethereum.name,
          trm.coinMiniName,
          rpc: customRpc,
        ) ?? MessageModel.error();
        if (!mounted) return;
        if (mm.error) {
          setState(() { load = Load.finish; }); // 修复 Bug 3 loading 卡死
          ToastUtils.show(mm.data);
          return;
        }
        newGasPriceValue = (mm.data as BigInt) * BigInt.from(3) ~/ BigInt.from(2);
      } else {
        // Legacy：从原始缓存值 ×1.5（修复 Bug 5 就地翻倍 / Bug 2 错误系数）
        newGasPriceValue = _originalGasPriceValue * BigInt.from(3) ~/ BigInt.from(2);
      }

      if (isCancel) {
        // Step 2a: 取消路径 —— 构造最小 cancel tx（修复 Bug 4 gas 浪费 / Bug 6 合约污染）
        final cancelTrm = _buildCancelTrm(newGasPriceValue);
        final bool check = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => WalletBaseSend(cancelTrm, null, cancelTrm.coin['unit'])));
        if (!mounted) return;
        if (!check) { setState(() { load = Load.finish; }); return; }
        final mm = await TransferApi().transferWallet(
          trModel: cancelTrm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, cancelTrm);
      } else {
        // Step 2b: 加速路径 —— 相同 nonce/目标/金额，更高 gasPrice
        trm.gasPriceValue = newGasPriceValue;
        trm.price = transferValue;
        trm.to1 = toAddress;
        trm.nonce = transactionInfo!['nonce'];
        trm.gas = hexToInt(transactionInfo!['gas']).toInt();

        final BigInt gaslimit = BigInt.from(getCoinGas(
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.coin['isContract'],
        ));
        final MessageModel gasEst = await tokenViewApi.getGasEstimateEthV2(
          widget.coinModel.address,
          trm.to1,
          trm.gasPriceValue,
          trm.price,
          gaslimit,
          widget.coinModel.coin['coinType'],
          contract: widget.coinModel.isTest
              ? widget.coinModel.coin['contract_test']
              : widget.coinModel.coin['contract'],
          isTest: widget.coinModel.isTest,
        );
        if (!mounted) return;
        if (gasEst.error == false) {
          trm.gas = (gasEst.data as BigInt).toInt();
        } else {
          setState(() { load = Load.finish; }); // 修复 Bug 3 loading 卡死
          ToastUtils.show(gasEst.data);
          return;
        }
        trm.gasPrice = trm.gasPriceValue * BigInt.from(trm.gas);

        final bool check = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => WalletBaseSend(trm, null, trm.coin['unit'])));
        if (!mounted) return;
        if (!check) { setState(() { load = Load.finish; }); return; }
        final mm = await TransferApi().transferWallet(
          trModel: trm,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex,
        );
        if (!mounted) return;
        await _handleTransferResult(mm, trm);
      }
    } catch (e) {
      if (mounted) { setState(() { load = Load.finish; }); ToastUtils.show(e.toString()); }
    }
  }

  /// 构造取消交易的独立 model（不污染 trm，修复 Bug 6 合约污染 / Bug 4 gas 浪费）
  TransationRecordModel _buildCancelTrm(BigInt gasPriceValue) {
    return TransationRecordModel()
      ..address       = trm.address
      ..from1         = trm.from1
      ..to1           = widget.coinModel.address  // 发给自己
      ..price         = BigInt.zero               // 0 ETH
      ..gas           = 21000                     // 普通转账最小 gas，不需要估算
      ..gasPriceValue = gasPriceValue
      ..gasPrice      = gasPriceValue * BigInt.from(21000)
      ..nonce         = transactionInfo!['nonce'] // 必须与原交易相同，RBF 核心
      ..contract      = ""                        // 无合约，修复 Bug 6
      ..coin          = trm.coin
      ..coinMiniName  = trm.coinMiniName
      ..coinId        = trm.coinId
      ..isTest        = trm.isTest
      ..addrType      = trm.addrType
      ..walletIndex   = trm.walletIndex;
  }

  /// 统一广播后处理（消除重复代码，修复 Bug 3 error 路径 loading 卡死）
  Future<void> _handleTransferResult(MessageModel mm, TransationRecordModel model) async {
    if (mm.error) {
      setState(() { load = Load.finish; });
      ToastUtils.show(mm.data);
    } else {
      model.txHash = mm.data;
      if (model.trId == 0) {
        model.trId = await db.insertTransationRecord(model);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(model, 1);
      } else {
        await db.updateTransationRecord(model);
        if (!mounted) return;
        ref.read(tripBridgeProvider).selectUndoneTr();
      }
      ToastUtils.show(S.current.g_key_nft_41);
      setState(() { load = Load.finish; });
      Navigator.pop(context, true);
    }
  }
  //关闭键盘
  void closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_3,
        actions: _explorerUrl.isNotEmpty ? [
          IconButton(
            icon: const Icon(Icons.open_in_browser_outlined),
            tooltip: S.of(context).g_key_196,
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BrowserPage(_explorerUrl))),
          ),
        ] : null,
      ),
      body: bodyWidget(),
    );
  }
  Widget bodyWidget(){
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
  Widget errorWidget(){
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
  Widget txDataWidget(){
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
  Widget searchWidget(){
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
  Widget errorMessageWidget(){
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
  Widget itemWidget(String title,String value,{bool copy=false}){
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
  Widget bottomButton(){
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
                send(widget.coinModel.address, BigInt.zero, isCancel: true);
              }),
            ),
            SizedBox(width: ScreenUtil().setWidth(30.0),),
            Expanded(
              flex: 1,
              child: buttonWidget(S.of(context).g_key_wallet_k57,(){
                send(trm.to1, trm.price);
              }),
            ),
          ],
        ),
      ):
      SizedBox(),
    );
  }
  Widget loadingButton(){
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
  Widget buttonWidget(String title,dynamic onTap,){
    return buttonStyle2(context, ()async{
      onTap();
    }, title);
  }
}
