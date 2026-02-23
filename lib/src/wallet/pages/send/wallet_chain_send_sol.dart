import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/utils/data_utils.dart';
import 'package:n42_wallet/src/utils/regular.dart';
import 'package:n42_wallet/src/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/src/wallet/api/transfer_api.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/src/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/src/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/src/wallet/widgets/non_evm_fee_selector.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/text_field_widget.dart';

class WalletChainSendSol extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendSol(this.coinModel,{super.key});

  @override
  ConsumerState<WalletChainSendSol> createState() => _WalletChainSendSolState();
}

class _WalletChainSendSolState extends ConsumerState<WalletChainSendSol> {
  CoinModel? chainModel;
  Regular? regular;
  Regular get _regular{
    regular ??= Regular();
    return regular!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }
  TextEditingController toTextEditingController=TextEditingController();
  TextEditingController valueTextEditingController=TextEditingController();
  FocusNode toNode=FocusNode();
  FocusNode valueNode=FocusNode();

  String toErrorMessage="";
  String amountErrorMessage="";
  String errorMessage="";

  BigInt totalGasPrice=BigInt.zero;
  BigInt gasPrice=BigInt.zero;
  BigInt gas=BigInt.zero;
  BigInt transferValue=BigInt.zero;//转账金额


  Load load=Load.loading;
  @override
  void initState() {
    super.initState();
    valueTextEditingController.text="0";
    initData();
  }
  @override
  void dispose() {
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    super.dispose();
  }

  Future<void> initData()async{
    //判断是否是代币
    if(widget.coinModel.coin['isContract']){
      WalletActionProvider wap=ref.read(wapBridgeProvider);
      int cIndex=wap.coinModels.indexWhere((element){
        if(element.coin['coinType']==widget.coinModel.coin['coinType']){
          if(widget.coinModel.privateKey !=null){
            if(element.privateKey==widget.coinModel.privateKey){
              return true;
            }else{
              return false;
            }
          }else{
            return true;
          }
        }
        return false;
      });
      chainModel=wap.coinModels[cIndex];
      await chainModel?.getBalance();
      if (!mounted) return;
      setState(() {});
    }
    gas=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
    await getBalance();
    await getGasPrice();
  }
  //获取余额
  Future<void> getBalance()async{
    setState(() {
      load=Load.loading;
    });
    bool isOk=await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if(isOk==false){
      errorMessage=S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
    }
    setState(() {
      load=Load.finish;
    });
  }
  //获取旷工费
  Future<void> getGasPrice()async{
    if (widget.coinModel.coin['isContract']==false){
      totalGasPrice=BigInt.from(5000)*gas;
    }else{
      totalGasPrice=BigInt.from(35000)*gas;
    }
    /*setState(() {
      load=Load.loading;
    });
    MessageModel bhmm=await SolApi().getLatestBlockhash(isTest: widget.coinModel.isTest);
    if(bhmm.error){
      errorMessage=bhmm.data;
      ToastUtils.show(bhmm.data);
    }else{
      Map<String, dynamic> txData = {};
      if (widget.coinModel.coin['isContract']==false) {
        txData = {
          "type": "SOL",
          "recentBlockhash": bhmm.data,
          "transferTransaction": {
            "recipient": "Cw3DBifacWj6vRHyvjcynWrtzSw3szr7V2FyPPaY5Huv",
            "value": "1000000",
          },
          "encodeType": "base641",
        };
      } else {
        String contractAddress=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
        String recipientTokenAddress=await Trustdart().getPubKeySOL("Cw3DBifacWj6vRHyvjcynWrtzSw3szr7V2FyPPaY5Huv",contractAddress);
        if(recipientTokenAddress==""){
          errorMessage="Error";
          ToastUtils.show("Error");
          setState(() {load=Load.finish;});
          return;
        }
        txData={
          "type":"tokenCreate",
          "recentBlockhash": bhmm.data,
          "tokenTransferTransaction": {
            "tokenMintAddress": contractAddress,
            "senderTokenAddress": widget.coinModel.address,
            "recipientTokenAddress": recipientTokenAddress,
            "recipientMainAddress":"Cw3DBifacWj6vRHyvjcynWrtzSw3szr7V2FyPPaY5Huv",
            "amount": "1000000",
            "decimals": widget.coinModel.coin['decimals'].toString(),
          },
          "encodeType": "base64",
        };
      }
      String path=getPathWithIndex(widget.coinModel.coin['path'][widget.coinModel.addrType], widget.coinModel.pathIndex);
      String signStr=await Trustdart().signTransaction(widget.coinModel.coin['coinType'], path, txData,mnemonic: ref.read(wapBridgeProvider).walletInfo.mnemonic??"",pk: ref.read(wapBridgeProvider).walletInfo.privateKey??"");
      if(signStr ==""){
        errorMessage="Error";
        ToastUtils.show("Error");
        setState(() {load=Load.finish;});
        return;
      }
      //MessageModel ffmmm=await SolApi().getFeeForMessage(signStr,isTest: widget.coinModel.isTest);
      MessageModel ffmmm=await SolApi().sendTransaction(signStr,isTest: widget.coinModel.isTest);
      if(ffmmm.error){

      }
      /*MessageModel mm=await tokenViewApi.getGasPrice(
        widget.coinModel.coin['blockchainType'],
        widget.coinModel.coin['coinType'],
        isTest:widget.coinModel.isTest,
        rpc: widget.coinModel.custom?widget.coinModel.coin['service']:null,
      );
      if(mm.error==false){
        gasPrice=mm.data;
        if(get1559WithChainSymbol(widget.coinModel.coin['coinType'])){
          gasPrice=gasPrice*BigInt.from(2);
        }
      }else{
        errorMessage=mm.data.toString();
        ToastUtils.show(errorMessage);
      }
      totalGasPrice=gasPrice*gas;
      */
    }

    load=Load.finish;
    setState(() {});*/
  }
  //模拟交易
  Future<bool> simulateTransaction()async{
    MessageModel bhmm=await SolApi().getLatestBlockhash(isTest: widget.coinModel.isTest);
    if (!mounted) return false;
    if(bhmm.error){
      errorMessage=bhmm.data;
      ToastUtils.show(bhmm.data);
      return false;
    }else{
      String toAddr=toTextEditingController.text.trim();
      Map<String, dynamic> txData = {};
      if (widget.coinModel.coin['isContract']==false) {
        txData = {
          "type": "SOL",
          "recentBlockhash": bhmm.data,
          "transferTransaction": {
            "recipient": toAddr,
            "value": "1000000",
          },
          "encodeType": "base58",
        };
      } else {
        String contractAddress=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
        String recipientTokenAddress=await Trustdart().getPubKeySOL(toAddr,contractAddress);
        if (!mounted) return false;
        if(recipientTokenAddress==""){
          errorMessage="Error";
          ToastUtils.show("Error");
          setState(() {load=Load.finish;});
          return false;
        }
        txData={
          "type":"tokenCreate",
          "recentBlockhash": bhmm.data,
          "tokenTransferTransaction": {
            "tokenMintAddress": contractAddress,
            "senderTokenAddress": widget.coinModel.address,
            "recipientTokenAddress": recipientTokenAddress,
            "recipientMainAddress":toAddr,
            "amount": "1000000",
            "decimals": widget.coinModel.coin['decimals'].toString(),
          },
          "encodeType": "base58",
        };
      }
      String path=getPathWithIndex(widget.coinModel.coin['path'][widget.coinModel.addrType], widget.coinModel.pathIndex);
      final walletInfo = ref.read(wapBridgeProvider).walletInfo;
      String signStr=await Trustdart().signTransaction(widget.coinModel.coin['coinType'], path, txData,mnemonic: walletInfo.mnemonic??"",pk: walletInfo.privateKey??"");
      if (!mounted) return false;
      if(signStr ==""){
        errorMessage="Error";
        ToastUtils.show("Error");
        setState(() {load=Load.finish;});
        return false;
      }
      //MessageModel ffmmm=await SolApi().getFeeForMessage(signStr,isTest: widget.coinModel.isTest);
      MessageModel ffmmm=await SolApi().simulateTransaction(signStr,isTest: widget.coinModel.isTest);
      if(ffmmm.error){
        return false;
      }
      return true;
    }
  }
  //检查 amount 输入是否正确
  void amountCheck({String value=""}){
    if(value==""){
      value=valueTextEditingController.text;
    }
    int minValue=0;
    if(widget.coinModel.coin['decimals']==0){
      minValue=1;
    }
    if (value.isEmpty) {
      amountErrorMessage= S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    bool checkValue1=false;
    if(widget.coinModel.coin['decimals']==0){
      checkValue1=_regular.regularNums(value.toString());
      if(checkValue1==false){
        amountErrorMessage= S.of(context).g_key_134;
        setState(() {});
        return;
      }
    }else{
      checkValue1=_regular.regularNums(value.toString());
    }
    bool checkValue=_regular.regularDouble(value.toString());
    double dValue=double.parse(value);
    if(checkValue==false && checkValue1==false){
      amountErrorMessage= S.of(context).g_key_134;
      setState(() {});
      return;
    } else if(dValue<minValue){
      amountErrorMessage= S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }else if(dValue==0){
      amountErrorMessage= S.of(context).g_key_46(minValue);
      setState(() {});
      return;
    }
    BigInt valueBi=ethToWeiString(value, widget.coinModel.coin['decimals']);
    if(widget.coinModel.coin['isContract']==false){
      if (valueBi+totalGasPrice > widget.coinModel.balance) {
        amountErrorMessage= S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    transferValue=valueBi;
    amountErrorMessage="";
    setState(() {});
  }
  //检查转账地址是否正确
  Future<String?> toAddressCheck(String addr)async{
    if(addr==""){
      toErrorMessage=S.current.g_key_41;
      setState(() {});
      return null;
    }else{
      List<String> addrList=addr.split(":");
      if(addrList.length==2){
        addr=addrList[1];
      }
      bool check=await Trustdart().validateAddress(widget.coinModel.coin['coinType'], addr);
      if(check){
        if(addr.toUpperCase()==widget.coinModel.address.toString().toUpperCase()){
          toErrorMessage=S.current.g_key_t_50;
          setState(() {});
          return null;
        }else{
          toErrorMessage="";
          setState(() {});
          return addr;
        }
      }else{
        toErrorMessage=S.current.g_key_t_50;
        setState(() {});
        return null;
      }
    }
  }
  Future<void> sendTransaction()async{
    if(load==Load.loading){
      ToastUtils.show("loading");
      return;
    }
    if(amountErrorMessage !="")return;
    closeKeyboard();
    amountCheck();
    if(amountErrorMessage !=""){
      return;
    }
    setState(() {
      load=Load.loading;
    });
    String? toAddr=await toAddressCheck(toTextEditingController.text.trim());
    if(toAddr == null) {
      setState(() {
        load=Load.finish;
      });
      return;
    }

    BigInt uBalance=widget.coinModel.balance;
    if(widget.coinModel.coin['isContract']){
      uBalance=chainModel?.balance??BigInt.zero;
    }
    if(totalGasPrice > uBalance){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    if(widget.coinModel.balance==BigInt.zero){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    await simulateTransaction();
    if (!mounted) return;
    if(errorMessage != ""){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    TransationRecordModel trModel=TransationRecordModel();
    trModel.address=widget.coinModel.address.toString();
    trModel.from1=widget.coinModel.address.toString();
    trModel.to1=toAddr;//toTextEditingController.text;
    trModel.addrType=widget.coinModel.addrType;
    trModel.coin=widget.coinModel.coin;
    trModel.coinMiniName=widget.coinModel.coin['coinType'];
    trModel.walletIndex=ref.read(wapBridgeProvider).walletIndex;
    trModel.contract=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
    trModel.isTest=widget.coinModel.isTest?1:0;
    trModel.gasPrice=totalGasPrice;
    trModel.gas=gas.toInt();
    trModel.gasPriceValue=gasPrice;
    trModel.price=transferValue;
    bool check=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletBaseSend(trModel,null,chainModel==null?widget.coinModel.coin['unit'].toString().toUpperCase():chainModel!.coin['unit'].toString().toUpperCase())));
    if (!mounted) return;
    if(check){
      signTx(trModel);
    }else{
      setState(() {
        load=Load.finish;
      });
    }
  }
  Future<void> signTx(TransationRecordModel trModel)async{
    try{
      TransferApi transferApi=TransferApi();
      MessageModel mm=await transferApi.transferWallet(
          trModel: trModel,
          privateKey: widget.coinModel.privateKey,
          pathIndex: widget.coinModel.pathIndex);
      if (!mounted) return;
      if(mm.error){
        errorMessage=mm.data;
      }else{
        trModel.txHash=mm.data;
        AppDatabase appDatabase =AppDatabase();
        trModel.trId=await appDatabase.insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel,1);
        await RecentAddressService.save(
          widget.coinModel.coin['coinType'] ?? '',
          toTextEditingController.text.trim(),
        );
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    }catch(e){
      errorMessage=e.toString();
      ToastUtils.show(e.toString());
    }finally{
      load=Load.finish;
      if (mounted) setState(() {});
    }
  }
  void scanQR() => performScanQR(context,
      controller: toTextEditingController, onAddress: toAddressCheck);

  void pasteAddress() => performPasteAddress(context,
      controller: toTextEditingController, onAddress: toAddressCheck);
  Future<void> maxTag()async{
    if(widget.coinModel.coin['isContract']){
      valueTextEditingController.text=widget.coinModel.balanceStringAll();
      transferValue=widget.coinModel.balance;
      simulateTransaction();
    }else{
      transferValue=widget.coinModel.balance-totalGasPrice;
      valueTextEditingController.text=toEther(transferValue.toString(),widget.coinModel.coin['decimals']).toString();
    }
    amountErrorMessage="";
    setState(() {});
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
                  child: coinTypeWidget(),
                ),
              ),
              sendButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
  Widget coinTypeWidget(){
    List<Widget> cChildren=[
      RecentAddressBar(
        coinType: widget.coinModel.coin['coinType'] ?? '',
        onSelected: (addr) {
          toTextEditingController.text = addr;
          toAddressCheck(addr);
        },
      ),
      toWidget(),
      amountWidget(),
      minerFeeWidget(),
      errorMessageWidget(),
      SizedBox(height: 100,),
    ];
    return Column(
      children: cChildren,
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
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: toErrorMessage,
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: pasteAddress,
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
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius:BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff101828).withAlpha((0.05 * 255).round()),  //底色,阴影颜色
                  offset: Offset(0, 1), //阴影位置,从什么位置开始
                  blurRadius: ScreenUtil().setWidth(4.0),  // 阴影模糊层度
                  spreadRadius: 0, )
              ],
            ),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  rightWidget1: Container(
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
                  ),
                  rightOnTap1: (){
                    maxTag();
                  },
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                ownerAddress(),
                buildUsdEquivalent(context, valueTextEditingController.text, widget.coinModel.coinPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget amountBalanceWidget(){
    String unit=widget.coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${widget.coinModel.balanceStringAll()} $unit',
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(28.0),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }
  Widget ownerAddress(){
    final addr=dataUtils.addressFarmat(widget.coinModel.address.toString());
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
  //旷工费
  Widget minerFeeWidget() {
    final isContract = widget.coinModel.coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : widget.coinModel.coin['decimals'] as int;
    final title = widget.coinModel.coin['coinType']?.toString() ?? '';
    final feeText = '${toEther(totalGasPrice.toString(), decimals)} $title';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isContract)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
              vertical: ScreenUtil().setWidth(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        NonEvmFeeCompact(
          feeText: feeText,
          onTap: null,
        ),
      ],
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
  //提交按钮
  Widget sendButtonWidget(){
    String title=S.of(context).g_key_48;
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
              sendTransaction();
            },
              load==Load.loading?'${S.of(context).g_key_106}...':title,
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
