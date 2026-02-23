import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/btc_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:flustars_flutter3/flustars_flutter3.dart' as flustars;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:validators/validators.dart';
import 'package:n42appv2/src/wallet/api/gas_tracker_api.dart';
import 'package:n42appv2/src/wallet/models/non_evm_fee_model.dart';
import 'package:n42appv2/src/wallet/pages/gas/non_evm_gas_settings_page.dart';
import 'package:n42appv2/src/wallet/pages/send/send_utils.dart';
import 'package:n42appv2/src/wallet/services/recent_address_service.dart';
import 'package:n42appv2/src/wallet/widgets/non_evm_fee_selector.dart';

class WalletChainSendBtc extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  final String? toAmount;
  final String? toAddress;
  const WalletChainSendBtc(this.coinModel,{this.toAddress,this.toAmount,super.key});

  @override
  ConsumerState<WalletChainSendBtc> createState() => _WalletChainSendBtcState();
}

class _WalletChainSendBtcState extends ConsumerState<WalletChainSendBtc> {
  TransferApi? _transferApi;
  TransferApi get transferApi{
    _transferApi ??= TransferApi();
    return _transferApi!;
  }
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
  final oCcy =  NumberFormat("#,##0.00########", "en_US");
  TextEditingController toTextEditingController=TextEditingController();
  TextEditingController valueTextEditingController=TextEditingController();
  TextEditingController byteFeeTextEditingController=TextEditingController();
  FocusNode toNode=FocusNode();
  FocusNode valueNode=FocusNode();
  FocusNode byteFeeNode=FocusNode();

  String toErrorMessage="";
  String amountErrorMessage="";
  String bytefeeErrorMessage="";
  String errorMessage="";


  Load utxoLoad=Load.finish;//加载utxo
  Load load=Load.loading;
  int price=0;
  List<Map<String,dynamic>> inputUTXO=[];//交易输入utxo列表

  //utxo列表
  int utxoPageSize=50;
  int utxoPageNum=1;
  bool utxoLastPage=false;
  List<dynamic> unspents=[];//可用余额列表

  //当地址被固定时，地址和转账金额输入框不能修改
  bool toTextFieldEnabel=true;

  NonEvmFeeModel? _btcFeeModel;

  Map<String,dynamic> gasFeeLevel={
    "error":false,
    "averageValue":5,//服务器获取的平均价格 gas
    "loading":false,
    "gasFeeRate":5,//用户输入的 gas
    "gasFees":0,//根据用户转账amount 和选择的gasFeeLevel 计算出gasFee
    "signByteSize":0,//签名返回的 数据包大小
    "maxValue":0,//全部转出的金额
  };

  @override
  void initState() {
    super.initState();
    valueTextEditingController.text="0";
    //tb1qnfppjfejp5yhmm8rt4sqj7ezmgtlp6v54urxgzkh5lqff388d6nq29qq65

    if(widget.toAddress!=null){
      toTextEditingController.text=widget.toAddress!;
      valueTextEditingController.text=widget.toAmount!;
      toTextFieldEnabel=false;
    }
    initData();
  }
  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    byteFeeTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    byteFeeNode.dispose();
    super.dispose();
  }
  Future<void> initData()async{
    await checkLastTx();
    await getGasFeeBtc();
    await getBalance();
  }

  //验证上一笔交易是否成功
  Future<void> checkLastTx()async{
    MessageModel checkLastModel=await transferApi.checkLastTxBtc(widget.coinModel.coin['coinType'], widget.coinModel.address);
    if(checkLastModel.error){
      errorMessage=checkLastModel.data;
    }
    setState(() {});
  }
  //获取 比特币的gasFee等级
  Future<void> getGasFeeBtc()async{
    if(widget.coinModel.coin['coinType']==CoinType.BTC.name){
      if(gasFeeLevel['loading'])return;
      gasFeeLevel['loading']=true;
      setState(() {});
      MessageModel gasFeeMM=await tokenViewApi.getGasFeeBtc(isTest: widget.coinModel.isTest);
      if(gasFeeMM.error){
        gasFeeLevel['error']=true;
        errorMessage=S.current.g_key_t_44;
      }else{
        gasFeeLevel['error']=false;
        gasFeeLevel['averageValue']=gasFeeMM.data;
        gasFeeLevel['gasFeeRate']=gasFeeMM.data;
      }
      gasFeeLevel['loading']=false;
    }else{
      int averageValue=getCoinGas(widget.coinModel.coin['coinType']);
      gasFeeLevel['averageValue']=averageValue;
      gasFeeLevel['gasFeeRate']=averageValue;
    }
    byteFeeTextEditingController.text=gasFeeLevel['averageValue'].toString();
    _buildBtcFeeModel();
    setState(() {});
  }

  /// 根据服务器费率构建 Slow/Standard/Fast 三档模型（用 250 bytes 估算总费）
  void _buildBtcFeeModel() {
    final avgRate = gasFeeLevel['averageValue'] as int;
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? 'BTC';
    final unit = (widget.coinModel.coin['unit'] ?? coinType).toString().toUpperCase();
    // 典型单输入/双输出 BTC 交易约 250 bytes
    const estBytes = 250;
    _btcFeeModel = NonEvmFeeModel.forBtcLike(
      averageRateSatPerByte: avgRate,
      calcFeeByRate: (rate) => rate * estBytes,
      chainSymbol: coinType,
      unit: unit,
    );
  }

  /// 打开非 EVM Gas 设置页，回来后应用选择结果
  Future<void> _openBtcGasSettings() async {
    if (_btcFeeModel == null) return;
    final result = await Navigator.push<NonEvmGasResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NonEvmGasSettingsPage(feeModel: _btcFeeModel!),
      ),
    );
    if (result != null && mounted) {
      _btcFeeModel = result.feeModel;
      final rate = result.effectiveFeeRate ??
          _btcFeeModel!.currentOption.feeRate ??
          (gasFeeLevel['averageValue'] as int);
      gasFeeLevel['gasFeeRate'] = rate;
      byteFeeTextEditingController.text = rate.toString();
      setState(() {});
      calculateGasFee();
    }
  }

  /// 速度档位标签
  String _btcSpeedLabel(NonEvmFeeSpeed speed) {
    switch (speed) {
      case NonEvmFeeSpeed.slow:     return S.current.g_key_gas_slow;
      case NonEvmFeeSpeed.standard: return S.current.g_key_gas_standard;
      case NonEvmFeeSpeed.fast:     return S.current.g_key_gas_fast;
    }
  }

  //获取余额
  Future<void> getBalance()async{
    try{
      bool isOk=await widget.coinModel.getBalance();
      /*if(widget.coinModel.isImport!=-1){
        isOk=await widget.coinModel.getBalance_import();
      }else{
        isOk=await widget.coinModel.getBalance();
      }*/
      if(isOk==false){
        load=Load.finish;
        errorMessage=S.current.g_key_t_44;
        ToastUtils.show(errorMessage);
        setState(() {});
        return;
      }
    }catch(e){
      errorMessage=e.toString();
      ToastUtils.show(errorMessage);
    }finally{
      load=Load.finish;
      setState(() {});
    }
  }
  //获取 账簿
  Future<void> getUTXO({bool allUTXO=false})async{
    try{
      if(utxoLoad==Load.loading)return;
      if(utxoLastPage)return;
      utxoLoad=Load.loading;
      setState(() {});
      String utxoPath=widget.coinModel.address;
      if(widget.coinModel.coin['coinType']==CoinType.BCH.name){
        utxoPath=widget.coinModel.addressType['legacy'];
      }
      MessageModel mm=await tokenViewApi.getUTXOBtc(widget.coinModel.coin['coinType'], utxoPath,pageSize: utxoPageSize,pageNum: utxoPageNum,isTest: widget.coinModel.isTest);
      if(mm.error){
        errorMessage=mm.data;
        ToastUtils.show(errorMessage);
        utxoLoad=Load.finish;
        setState(() {});
      }else{
        unspents.addAll(mm.data);
        //判断是否时最后一页
        if((unspents.length<(utxoPageSize*utxoPageNum))){
          utxoLastPage=true;
        }else{
          utxoPageNum++;
        }
        utxoLoad=Load.finish;
        setState(() {});
        if(allUTXO){
          getUTXO(allUTXO: allUTXO);
        }else{
          calculateGasFee();//计算gasFee
        }
      }
    }catch(e){
      errorMessage=e.toString();
      ToastUtils.show(errorMessage);
      utxoLoad=Load.finish;
      setState(() {});
    }

  }

  //计算gas费
  Future<void> calculateGasFee()async{
    if(price==0){
      gasFeeLevel['gasFees']=0;
      setState(() {});
      return;
    }
    if(unspents.isEmpty){
      getUTXO();
      return;
    }
    List<Map<String,dynamic>> utxos=[];//输出账单
    int input2Price=0;//实际输入金额
    bool inputValueOK=false;
    for(Map<String,dynamic> unspent in unspents){
      if(widget.coinModel.isTest){
        if(unspent['hex']==null){
          MessageModel utxoTx = await BtcApi(test: true).getUTXOTxid(unspent['txid']);
          if (utxoTx.error == false) {
            unspent['hex'] = utxoTx.data['vout']?[unspent['vout']]?['scriptpubkey'];
          }
        }
        int amount=unspent['value'];
        input2Price+=amount.toInt();
        utxos.add({
          "txid":unspent['txid'],
          "vout":unspent['vout'],
          "value": amount.toString(),
          "script": unspent['hex'],
        });
      }else{
        BigInt amount=ethToWeiString(double.parse(unspent['value']).toString(),8) ;
        input2Price+=amount.toInt();
        utxos.add({
          "txid":unspent['txid'],
          "vout":unspent['output_no'],//
          "value": amount.toString(),//BigInt.from(amount*100000000).toString(),
          "script": unspent['hex'],//unspent['script]
        });
      }

      //int signByteSize=utxos.length*148+84;
      //int gasFee=gasFeeLevel['gasFeeRate'];
      //int byteSizeFees=signByteSize*gasFee;//计算公式  inputNum*148 + outputNum *34 +10 (+/-)40
      //int outputByteSizeFess=34*gasFee;
      //如果 当前gas费——转账金额 小于 账单金额； 需要加入找零字节数
      //gasFeeLevel['gasFees']=byteSizeFees;
      if(price<input2Price){
        //如果 当前input gas费+转账金额+output gas费 == 账单金额; 退出循环，返回 outputByteSizeFess +inputByteSizeFees
        int byteSize=await getSignByteSize(utxos);
        if(byteSize !=0){
          int gasFee=gasFeeLevel['gasFeeRate'];
          int byteSizeFees=byteSize*gasFee;
          gasFeeLevel['gasFees']=byteSizeFees;
          inputValueOK=true;
          break;
        }
      }
    }
    inputUTXO=utxos;
    setState(() {});
    if(inputValueOK==false){
      getUTXO();
    }
  }
  /*calculateGasFee()async{
    if(price==0){
      gasFeeLevel['gasFees']=0;
      setState(() {});
      return;
    }
    List<Map<String,dynamic>> utxos=[];//输出账单
    if(unspents.isEmpty){
      getUTXO();
      return;
    }
    int input2Price=0;//实际输入金额
    bool inputValueOK=false;
    for(Map<String,dynamic> unspent in unspents){
      double amount=double.parse(unspent['value']) ;
      input2Price+=ethToWeiString(amount.toString(),8).toInt();
      utxos.add({
        "txid":unspent['txid'],
        "vout":unspent['output_no'],//
        "value": ethToWeiString(amount.toString(),8).toString(),//BigInt.from(amount*100000000).toString(),
        "script": unspent['hex'],//unspent['script]
      });

      int signByteSize=utxos.length*148+80;
      int gasFee=gasFeeLevel['gasFeeRate'];
      int byteSizeFees=signByteSize*gasFee;//计算公式  inputNum*148 + outputNum *34 +10 (+/-)40
      //int outputByteSizeFess=34*gasFee;
      //如果 当前gas费——转账金额 小于 账单金额； 需要加入找零字节数
      gasFeeLevel['gasFees']=byteSizeFees;
      if(byteSizeFees+price<=input2Price){
        //如果 当前input gas费+转账金额+output gas费 == 账单金额; 退出循环，返回 outputByteSizeFess +inputByteSizeFees
        inputValueOK=true;
        break;
      }
    }
    if(inputValueOK==false){
      await getUTXO();
    }
    inputUTXO=utxos;
    setState(() {});
  }*/
  //检查转账地址是否正确
  Future<void> toAddressCheck(String addr)async{
    if(widget.coinModel.isTest)return;
    if(addr==""){
      toErrorMessage=S.current.g_key_41;
    }else{
      bool check=await Trustdart().validateAddress(widget.coinModel.coin['coinType'], addr);
      if(check){
        if(addr.toUpperCase()==widget.coinModel.address.toUpperCase()){
          toErrorMessage=S.current.g_key_t_50;
        }else{
          toErrorMessage="";
        }
      }else{
        toErrorMessage=S.current.g_key_t_50;
      }
    }
    setState(() {});
  }

  //检查输入金额
  void amountCheck({String value=""}){
    if(gasFeeLevel['maxValue'] !=0)return;
    if(value==""){
      value=valueTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage= S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    bool checkValue=regular.regularDouble(value.toString());
    bool checkValue1=regular.regularNums(value.toString());
    dec.Decimal transactionTotal=dec.Decimal.parse(value)+dec.Decimal.parse(toEther(gasFeeLevel['gasFees'].toString(), 8).toString());
    if(checkValue==false && checkValue1==false){
      amountErrorMessage= S.of(context).g_key_134;
      setState(() {});
      return;
    } else if(double.parse(value)<=0){
      amountErrorMessage= S.of(context).g_key_46(0);
      setState(() {});
      return;
    }else if (transactionTotal.toDouble() > widget.coinModel.balanceDoubleAll()) {
      amountErrorMessage= S.of(context).g_key_47;
      setState(() {});
      return;
    }
    if(widget.coinModel.coin['coinType']==CoinType.BTC.name){
      if(double.parse(value)<0.00001){
        amountErrorMessage= S.of(context).g_key_135(0.00001);
        setState(() {});
        return;
      }
    }
    amountErrorMessage="";
    price=ethToWeiString(value.toString(), 8).toInt();
    gasFeeLevel['maxValue']=0;
    calculateGasFee();
    setState(() {});
  }
  //检查输入的 byteFee
  void byteFeeCheck({String value=""}){
    if(value==""){
      value=byteFeeTextEditingController.text;
    }
    if (value.isEmpty) {
      amountErrorMessage= S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    bool checkValue =isInt(value);
    if(checkValue==false){
      amountErrorMessage= S.of(context).g_key_t_43;
      setState(() {});
      return;
    }
    int valueInt=int.parse(value);
    if(valueInt<=0){
      amountErrorMessage= S.of(context).g_key_t_43;
      setState(() {});
      return;
    }
    gasFeeLevel['gasFeeRate']=valueInt;
    if(gasFeeLevel['max'] !=0 ){
      maxTag();
    }else{
      calculateGasFee();
    }
  }
  //签名
  Future<void> signTx(BtcTransactionRecodeModel trModel)async{
    load=Load.loading;
    setState(() {});
    if(unspents.isEmpty) {
      ToastUtils.show(S.current.g_key_2);
      return;
    }
    trModel=await transatroinBuilder1To1(trModel, unspents);
    if (!mounted) return;
    if(trModel.txHash != ""){
      await AppDatabase().insertBtcTransactionRecord(trModel);
      if (!mounted) return;
      ref.read(tripBridgeProvider).addUndoneTr(trModel,0);
      await RecentAddressService.save(
        widget.coinModel.coin['coinType'] ?? '',
        toTextEditingController.text.trim(),
      );
      ToastUtils.show(S.current.g_key_nft_41);
      if(toTextFieldEnabel==false){
        Navigator.pop(context,trModel.txHash);
      }else{
        Navigator.pop(context);
      }
    }else{
      ToastUtils.show(errorMessage);
      load=Load.finish;
      setState(() {});
    }
  }
  //交易打包
  //unspents 未消费列表
  Future<BtcTransactionRecodeModel> transatroinBuilder1To1(BtcTransactionRecodeModel btcTransactionRecodeModel,List<dynamic> unspents)async{
    try{
      Map<String,dynamic> btcTxMap={
        "utxo":[],
        "toAddress":btcTransactionRecodeModel.to1,
        "amount":btcTransactionRecodeModel.price,
        "byteFee":gasFeeLevel['gasFeeRate'],
        "changeAddress":btcTransactionRecodeModel.address,
        "change":0,
      };
      //List<Map<String,dynamic>> utxos=[];//输出账单
      int input2Price=0;//实际输入金额
      int output2Price=0;//找零金额
      btcTransactionRecodeModel.inputModels=[];
      for(Map<String,dynamic> unspent in inputUTXO){
        input2Price+=int.parse(unspent['value']);
        InputModel im=InputModel(
            txid:unspent['txid'],
            vout: unspent['vout'],
            value:int.parse(unspent['value']),
            script:unspent['script']
        );
        im.address=[widget.coinModel.address.toString()];
        btcTransactionRecodeModel.inputModels!.add(
          im,
        );
      }
      int gasFees=gasFeeLevel['gasFees'] as int;
      int totalPrice=btcTransactionRecodeModel.price+gasFees;
      if(input2Price>totalPrice){
        output2Price=input2Price-totalPrice;
      }
      btcTxMap['change']=output2Price;
      btcTxMap['fees']=gasFees;
      btcTxMap['utxo']=inputUTXO;

      btcTransactionRecodeModel.gas=gasFeeLevel['gasFeeRate'];
      btcTransactionRecodeModel.gasPrice=gasFees;
      btcTransactionRecodeModel.addrType=widget.coinModel.addrType;
      btcTransactionRecodeModel.max=gasFeeLevel['maxValue'] !=0;
      btcTransactionRecodeModel.isTest=widget.coinModel.isTest?1:0;
      MessageModel rmm=await transferApi.transferWallet(
        trModelBtc:btcTransactionRecodeModel,
        pathIndex: widget.coinModel.pathIndex,
        privateKey: widget.coinModel.privateKey,
      );
      if(rmm.error){
        errorMessage=rmm.data;
      }else{
        btcTransactionRecodeModel.txHash=rmm.data;
      }
      /*
      WalletInfo wi=ProviderUtil.walletActionProvider().walletInfoLsit[ProviderUtil.walletActionProvider().walletIndex];
      String signStr=await Trustdart.signTransaction(wi.mnemonic!, _trModel.coin['coinType'], _trModel.coin['path'][_coinModel!.addrType], btcTxMap,"","");
      btcTransactionRecodeModel.signStr=signStr;
       */
      return btcTransactionRecodeModel;
    }catch(e){
      return btcTransactionRecodeModel;
    }
  }

  Future<void> maxTag()async{
    //await toAddressCheck(toTextEditingController.text);
    //if(toErrorMessage != "")return;
    price=widget.coinModel.balance.toInt();
    await getUTXO(allUTXO: true);
    if(errorMessage !="")return;
    List<Map<String,dynamic>> utxos=[];//输出账单
    for(Map<String,dynamic> unspent in unspents){
      BigInt amount=ethToWeiString(double.parse(unspent['value']).toString(),8) ;
      utxos.add({
        "txid":unspent['txid'],
        "vout":unspent['output_no'],//
        "value": amount.toString(),//BigInt.from(amount*100000000).toString(),
        "script": unspent['hex'],//unspent['script]
      });
    }
    inputUTXO=utxos;
    int byteSize=await getSignByteSize(utxos,max: true);
    int gasFee=gasFeeLevel['gasFeeRate'];
    int byteSizeFees=byteSize*gasFee;//计算公式  inputNum*148 + outputNum *34 +10 (+/-)40
    //int outputByteSizeFess=34*gasFee;
    //如果 当前gas费——转账金额 小于 账单金额； 需要加入找零字节数
    gasFeeLevel['gasFees']=byteSizeFees;
    price=widget.coinModel.balance.toInt()-byteSizeFees;
    gasFeeLevel['maxValue']=price;
    valueTextEditingController.text=toEther(price.toString(), 8).toString();
    amountErrorMessage="";
    setState(() {});
  }
  //计算 打包 字段数
  Future<int> getSignByteSize(List<Map<String,dynamic>> utxos,{bool max=false})async{
    //await toAddressCheck(toTextEditingController.text);
    //if(toErrorMessage !="")return;
    Map<String,dynamic> btcTxMap={
      "utxo":utxos,
      "toAddress":"bc1q4q83qn0r4ndkpldfkypttncfrjxu4zdeeuz40s",//toTextEditingController.text,
      "amount":price,
      "byteFee":gasFeeLevel['gasFeeRate'],
      "changeAddress":widget.coinModel.address,
      "max":max,
    };
    String signByteSize=await transferApi.transactionMaxValue(
      widget.coinModel.coin['blockchainType'],
      widget.coinModel.coin['coinType'],
      btcTxMap,
      getPathWithIndex(widget.coinModel.coin['path'][widget.coinModel.addrType], widget.coinModel.pathIndex),
      privateKey: widget.coinModel.privateKey,
    );
    if(signByteSize == ""){
      return 0;
    }else{
      return int.parse(signByteSize);
    }
  }

  void scanQR() async{
    String? scanValue =await Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanPage()));
    if (!mounted) return;
    if(scanValue != null){
      toTextEditingController.text=scanValue;
      toAddressCheck(scanValue);
    }
    Navigator.pop(context);
  }
  //关闭键盘
  void closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:"${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
        /*actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> AddressBookList(coinName: widget.coinModel.coin['coinType'],))).then((value)async{
                if(value !=null){
                  toTextEditingController.text=value;
                }
              },);
            },
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right:ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(20.0),),
              child: Image.asset(
                'assets/wallet/addressBook.png',
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],*/
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: closeKeyboard,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /*
                      WalletChainInfoTitle(
                        title: Text(
                          "${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(32.0),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: null,
                        rightWidget: null,
                        rightImgUrl: "assets/wallet/addressBook.png",
                        rightTao: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> AddressBookList(coinName: widget.coinModel.coin['coinType'],))).then((value)async{
                            if(value !=null){
                              toTextEditingController.text=value;
                            }
                          },);
                        },
                      ),
                      */
                      RecentAddressBar(
        coinType: widget.coinModel.coin['coinType'] ?? '',
        onSelected: (addr) {
          toTextEditingController.text = addr;
          toAddressCheck(addr);
        },
      ),
      toWidget(),
                      amountWidget(),
                      _buildBtcFeeCompact(),
                      totalPriceWidgegt(),
                      errorMessageWidget(),
                      SizedBox(height: ScreenUtil().setWidth(100.0),),
                    ],
                  ),
                ),
              ),
              sendButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
  Widget toWidget(){
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0),),
          textFieldStyle2(
            context,
            controller: toTextEditingController,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: (){
              FocusScope.of(context).requestFocus(valueNode);
              toAddressCheck(toTextEditingController.text.trim());
            },
            enabled: toTextFieldEnabel,
            errorMessage: toErrorMessage,
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: () => performPasteAddress(
              context,
              controller: toTextEditingController,
              onAddress: toAddressCheck,
            ),
            rightWidget2: buildSendIconBtn(context, Icons.menu_book_outlined),
            rightOnTap2: searchToAddressWidget,
            bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }
  Widget amountWidget(){
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                S.of(context).g_key_44,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Expanded(flex: 1,child: amountBalanceWidget(),),
            ],
          ),
          containerStyle1(
            context,
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: valueTextEditingController,
                  focusNode: valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(54.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textFieldHintColor.name),
                  ),
                  enabled: toTextFieldEnabel,
                  maxLines: 1,
                  onChanged: (value){
                    amountCheck(value: value);
                  },
                  onEditingComplete: (){
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow:BoxShadow(
                    color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
                    offset: Offset(0, 0), //阴影位置,从什么位置开始
                    blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
                    spreadRadius: 0, ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                  rightWidget1: toTextFieldEnabel?Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0),)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ):null,
                  rightOnTap1: toTextFieldEnabel?(){
                    maxTag();
                  }:null,
                ),
                buildUsdEquivalent(context, valueTextEditingController.text, widget.coinModel.coinPrice),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                ownerAddress(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget amountBalanceWidget(){
    String unit=widget.coinModel.coin['unit'];
    return Text(
      '${dec.Decimal.parse(widget.coinModel.balanceDoubleAll().toString())} $unit',
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(28.0),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }
  //返回账户地址
  Widget ownerAddress(){
    String addr=widget.coinModel.address.toString();
    addr=dataUtils.addressFarmat(addr);
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(30.0),
        left: ScreenUtil().setWidth(30.0),
      ),
      child: Text(addr,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 紧凑型费用展示（替换旧的 gasFeeWidgetPrice + gasFeeWidgetBtc）
  Widget _buildBtcFeeCompact() {
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? 'BTC';
    final fees = gasFeeLevel['gasFees'] as int;
    final feesBtc = gasFeeLevel['loading'] as bool
        ? '...'
        : '${flustars.NumUtil.divide(fees, 100000000)} $coinType';

    if (_btcFeeModel == null) {
      // 首次加载前降级展示
      return NonEvmFeeCompact(
        feeText: feesBtc,
        hasError: false,
        onTap: null,
      );
    }

    final option = _btcFeeModel!.currentOption;
    final totalSat = fees + price;
    final hasError = totalSat > 0 &&
        widget.coinModel.balanceDoubleAll() < totalSat / 100000000;

    return NonEvmFeeCompact(
      feeText: feesBtc,
      speedLabel: _btcSpeedLabel(_btcFeeModel!.selectedSpeed),
      estimatedTime: GasTrackerApi.formatEstimatedTime(option.estimatedSeconds),
      rateText: option.feeRate != null
          ? '${option.feeRate} ${option.feeRateUnit ?? "sat/byte"}'
          : null,
      hasError: hasError,
      onTap: _openBtcGasSettings,
    );
  }

  Widget gasFeeWidgetPrice(){
    String coinTypeName=widget.coinModel.coin['coinType'];
    if(coinTypeName != CoinType.BTC.name)return Container();
    double gasFees=0;
    if(gasFeeLevel['gasFees'] !=0){
      gasFees=flustars.NumUtil.divide(gasFeeLevel['gasFees'],100000000);
    }
    return containerStyle1(
      context,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),),
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
      ),
      height: ScreenUtil().setWidth(88.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
            child: Text(S.of(context).g_key_t_30,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('$gasFees $coinTypeName',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  //价格合计
  Widget totalPriceWidgegt(){
    int gasFeesInt=gasFeeLevel['gasFees']+price;
    double gasFees=gasFeesInt/100000000;
    Color textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
    if(widget.coinModel.balanceDoubleAll()<gasFees){
      textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    }
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).g_key_nft_141,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(30.0),
            ),
          ),
          Expanded(
              flex: 1,
              child: SizedBox()),
          Text(
            '$gasFees ${widget.coinModel.coin['unit']}',
            style: TextStyle(
              color: textColor,
              fontSize: ScreenUtil().setSp(30.0),
            ),
          ),
          utxoLoad==Load.loading?
          Container(
            height: ScreenUtil().setWidth(36.0),
            width: ScreenUtil().setWidth(36.0),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
            child: CircularProgressIndicator(),):SizedBox(),
        ],
      ),
    );
  }
  Widget gasFeeWidgetBtc(){
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),bottom: ScreenUtil().setWidth(20.0)),
            child: Row(
              children: [
                Text(S.of(context).g_key_t_36,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Visibility(
                    visible: gasFeeLevel['error'],
                    child: Row(
                      children: [
                        SizedBox(width: ScreenUtil().setWidth(10.0),),
                        Icon(Icons.error_outline,size: ScreenUtil().setWidth(36.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),),
                        Expanded(
                          flex: 1,
                          child: Text(S.of(context).g_key_5,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                              fontSize: ScreenUtil().setSp(26.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                gasFeeLevel['loading']?
                Container(
                  height: ScreenUtil().setWidth(36.0),
                  width: ScreenUtil().setWidth(36.0),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                  child: CircularProgressIndicator(),):
                InkWell(
                  onTap: (){
                    getGasFeeBtc();
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(36.0),
                    width: ScreenUtil().setWidth(36.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                    child: Image.asset('assets/img/shuaxin.png',color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
                  ),
                ),
              ],
            ),
          ),
          containerStyle1(
            context,
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
            child: Column(
              children: [
                textFieldStyle2(
                  context,
                  controller: byteFeeTextEditingController,
                  focusNode: byteFeeNode,
                  hintText: S.of(context).g_key_t_43,
                  onChanged: (value){
                    byteFeeCheck(value: value);
                  },
                  onEditingComplete: (){
                    FocusScope.of(context).requestFocus(valueNode);
                    byteFeeCheck();
                  },
                  errorMessage: bytefeeErrorMessage,
                  boxShadow:BoxShadow(
                    color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
                    offset: Offset(0, 0), //阴影位置,从什么位置开始
                    blurRadius: ScreenUtil().setWidth(0),  // 阴影模糊层度
                    spreadRadius: 0, ),
                  messageMargin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0)),
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    maxLines:2,
                    text: TextSpan(
                      text: "${S.of(context).g_key_t_37}: ",
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(26.0),
                      ),
                      children: [
                        TextSpan(
                          text:"${gasFeeLevel['averageValue']}",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                        TextSpan(
                          text:" sal/b",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32.0),vertical: ScreenUtil().setWidth(32.0)),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
        ),
        child: Text(
          errorMessage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ),
        ),
      );
    }

  }

  Widget sendButtonWidget(){
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          Container(
            padding: EdgeInsets.all( ScreenUtil().setWidth(30.0)),
            height: ScreenUtil().setWidth(148.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context, ()async{
              if(load==Load.loading)return;
              closeKeyboard();
              amountCheck();
              if(amountErrorMessage !=""){
                return;
              }
              await toAddressCheck(toTextEditingController.text.trim());
              if(toErrorMessage !="")return;

              //await getSignByteSize(inputUTXO);
              if(widget.coinModel.balance==BigInt.zero){
                return;
              }
              if(errorMessage !=""){
                return;
              }
              if (!mounted) return;
              BtcTransactionRecodeModel trModel=BtcTransactionRecodeModel();//交易数据
              trModel.address=widget.coinModel.address;
              trModel.to1=toTextEditingController.text.trim();
              trModel.coin=widget.coinModel.coin;
              trModel.coinMiniName=widget.coinModel.coin['coinType'];
              trModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
              trModel.price=price;
              trModel.gasPrice=gasFeeLevel['gasFees'];
              bool check=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletBaseSend(null,trModel,widget.coinModel.coin['unit'])));
              if (!mounted) return;
              if(check){
                signTx(trModel);
              }
            },
              load==Load.loading?'${S.of(context).g_key_106}...':S.of(context).g_key_48,
              AppThemeUtils.getColorByKey(
                context, load==Load.loading?
              AppThemeKeys.mainButtonBgColor3.name:
              AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              load==Load.loading,
            ),
          ),
        ],
      ),
    );
  }
  void searchToAddressWidget() {
    showAddressPickerSheet(
      context,
      coinModel: widget.coinModel,
      onAddressSelected: (addr) {
        toTextEditingController.text = addr;
        toAddressCheck(addr);
      },
    );
  }
}
