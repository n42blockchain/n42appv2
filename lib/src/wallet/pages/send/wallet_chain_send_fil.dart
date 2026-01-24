import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/fil_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/address_book/address_book_list.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;

class WalletChainSendFil extends StatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendFil(this.coinModel,{super.key});

  @override
  State<WalletChainSendFil> createState() => _WalletChainSendFilState();
}

class _WalletChainSendFilState extends State<WalletChainSendFil> {
  CoinModel? chainModel;
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  final oCcy =  NumberFormat("#,##0.00########", "en_US");
  late TextEditingController toTextEditingController=TextEditingController();
  late TextEditingController valueTextEditingController=TextEditingController();
  late FocusNode toNode=FocusNode();
  late FocusNode valueNode=FocusNode();

  String toErrorMessage="";
  String amountErrorMessage="";
  String errorMessage="";

  BigInt totalGasPrice=BigInt.zero;
  BigInt gasPrice=BigInt.zero;
  BigInt gas=BigInt.zero;
  String gasFeeCap="0";
  String gasPremium="0";
  BigInt transferValue=BigInt.zero;//转账金额


  Load load=Load.loading;
  Load gasLimitLoad=Load.finish;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valueTextEditingController.text="0";
    initData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    toTextEditingController.dispose();
    valueTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    super.dispose();
  }

  Future<void> initData()async{
    //判断是否是代币
    if(widget.coinModel.coin['isContract']){
      WalletActionProvider wap=Provider.of<WalletActionProvider>(context,listen: false);
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
      setState(() {});
    }
    gas=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
    await getBalance();
    //await getGasPrice();
  }

  //获取余额
  Future<void> getBalance()async{
    setState(() {
      load=Load.loading;
    });
    bool isOk=await widget.coinModel.getBalance(getToken: false);
    if(isOk==false){
      load=Load.finish;
      errorMessage=S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState((){});
      return;
    }else{
      setState(() {
        load=Load.finish;
      });
    }
  }


  //检查 amount 输入是否正确
  void amountCheck({String value=""}){
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
    //print(toEther(totalGasPrice.toString()));
    if(checkValue==false && checkValue1==false){
      amountErrorMessage= S.of(context).g_key_134;
      setState(() {});
      return;
    } else if(double.parse(value)<=0){
      amountErrorMessage= S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ripple.name){
      BigInt valueBi=ethToWeiString(value, widget.coinModel.coin['decimals']);
      if (valueBi + totalGasPrice> widget.coinModel.balance-ethToWeiString("10", widget.coinModel.coin['decimals'])) {
        amountErrorMessage= S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    else{
      BigInt valueBi=ethToWeiString(value, widget.coinModel.coin['decimals']);
      if(widget.coinModel.coin['isContract']==false){
        if (valueBi+totalGasPrice > widget.coinModel.balance) {
          amountErrorMessage= S.of(context).g_key_47;
          setState(() {});
          return;
        }
      }
      transferValue=valueBi;
    }
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
    closeKeyboard();
    amountCheck();
    if(amountErrorMessage !=""){
      return;
    }
    setState(() {
      load=Load.loading;
    });
    String? toAddr=await toAddressCheck(toTextEditingController.text);
    if(toAddr == null) {
      setState(() {
        load=Load.finish;
      });
      return;
    }
    await estimateGasEthLocal();
    if(errorMessage != ""){
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
    FilApi filApi=FilApi();
    MessageModel rDataNonce=await filApi.getNonce(widget.coinModel.address.toString(),isTest:widget.coinModel.isTest);
    if (!mounted) return;
    if(rDataNonce.error){
      setState(() {
        errorMessage=rDataNonce.data;
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
    trModel.walletIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
    trModel.contract=widget.coinModel.isTest?widget.coinModel.coin['contract_test']:widget.coinModel.coin['contract'];
    trModel.isTest=widget.coinModel.isTest?1:0;
    trModel.gasPrice=totalGasPrice;
    trModel.gas=gas.toInt();
    trModel.gasPriceValue=BigInt.zero;//gasPrice;
    trModel.price=transferValue;
    trModel.other=FilTrModel(gasFeeCap, gasPremium);
    trModel.nonce=rDataNonce.data.toString();
    //trModel.coinId=widget.coinModel.isTest?widget.coinModel.coin['chainId_test']:widget.coinModel.coin['chainId'];

    bool check=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletBaseSend(trModel,null,widget.coinModel.coin['unit'])));
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
    if(signTxCheck()==false)return;
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
        trModel.txHash=mm.data['/'];
        trModel.trId=await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        Provider.of<TransactionRecordItemProvider>(context,listen: false).addUndoneTr(trModel,1);
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    }catch(e){
      errorMessage=e.toString();
      ToastUtils.show(e.toString());
    }finally{
      load=Load.finish;
      setState(() {});
    }
  }
  bool signTxCheck(){
    return true;
  }
  Future<bool?> estimateGasEthLocal()async{
    closeKeyboard();
    if(gasLimitLoad==Load.loading)return;
    setState(() {
      gasLimitLoad=Load.loading;
    });
    try{
      if(amountErrorMessage !="")return;
      String? toAddr=await toAddressCheck(toTextEditingController.text);
      if(toAddr==null){
        return;
      }
      if(toErrorMessage !="")return;
      String price=valueTextEditingController.text;
      if(price==""){
        return;
      }
      BigInt gaslimit=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],));
      FilApi filApi=FilApi();
      MessageModel ethMessage=await filApi.getGasLimit(
        widget.coinModel.address,
        toAddr,
        gaslimit,
        value:ethToWeiString(price,widget.coinModel.coin['decimals']).toString(),
        isTest: widget.coinModel.isTest,
      );

      if(ethMessage.error==false){
        gas=BigInt.parse(ethMessage.data['GasLimit'].toString());
        gasFeeCap=ethMessage.data['GasFeeCap'];
        gasPremium=ethMessage.data['GasPremium'];
        gasPrice=BigInt.parse(gasFeeCap);
        totalGasPrice=gasPrice*gas;
        errorMessage="";
        return true;
      }else{
        errorMessage=ethMessage.data;
        return false;
      }
    }catch(e){
      errorMessage=e.toString();
      return false;
    }finally{
      setState(() {
        gasLimitLoad=Load.finish;
      });
    }
  }
  void scanQR() async{
    String? scanValue =await Navigator.push(context, MaterialPageRoute(builder: (context)=>ScanPage()));
    if (!mounted) return;
    if(scanValue !=null){
      toTextEditingController.text=scanValue;
      toAddressCheck(scanValue);
    }
  }
  Future<void> maxTag()async{
    if(gasLimitLoad==Load.loading)return;
    valueTextEditingController.text=widget.coinModel.balanceStringAll();
    bool? rOK=await estimateGasEthLocal();
    if(rOK != null && rOK){
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
        actions: [
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
        ],
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
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    controller: toTextEditingController,
                    focusNode: toNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_155,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onEditingComplete: (){
                      FocusScope.of(context).requestFocus(valueNode);
                      toAddressCheck(toTextEditingController.text);
                    },
                  ),
                ),
                InkWell(
                  onTap: scanQR,
                  child: Container(
                    width: ScreenUtil().setWidth(60.0),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8.0)),
                    child: Image.asset(
                      "assets/wallet/scan.png",
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: ()async{
                    ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
                    if(cd !=null){
                      if(cd.text !=null && cd.text != "null"){
                        toTextEditingController.text=cd.text??"";
                        setState(() {
                        });
                        toAddressCheck(cd.text??"");
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0),)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_166,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(toErrorMessage !="")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                toErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
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
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),bottom:ScreenUtil().setWidth(20.0) ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setWidth(70.0),
                        ),
                        controller: valueTextEditingController,
                        focusNode: valueNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: S.of(context).g_key_44,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setWidth(70.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textFieldHintColor.name),
                          ),
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        maxLines: 1,
                        onChanged: (value){
                          amountCheck(value: value);
                        },
                        onEditingComplete: (){
                          amountCheck();
                          FocusScope.of(context).requestFocus(toNode);
                        },
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        maxTag();
                      },
                      child: Container(
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
                    ),
                  ],
                ),
                if(amountErrorMessage!="")
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amountErrorMessage,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                        fontSize: ScreenUtil().setSp(24.0),
                      ),
                    ),
                  ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: 0,
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
  //返回账户地址
  Widget ownerAddress(){
    String addr="";
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      addr=widget.coinModel.address.toString();
    }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Solana.name){
      addr=widget.coinModel.address.toString();
    }else{
      addr=widget.coinModel.address.toString();
    }
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(20.0),
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
  Widget minerFeeWidget(){
    String totalGasPriceStr="";
    String gasPriceStr="";
    Color totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    Widget gasLimitWidget=Container();
    int decimals=widget.coinModel.coin['decimals'];
    String unit=widget.coinModel.coin['unit'];
    totalGasPriceStr='${dec.Decimal.parse(toEther(totalGasPrice.toString(),decimals).toString())}$unit';
    //gasPriceStr='${dec.Decimal.parse(toEther(gasPrice.toString(),decimals).toString()) }${unit}';
    gasLimitWidget=Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).g_key_101,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10),),
          Expanded(flex: 1,child: Text(
            "$gas",
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
            textAlign: TextAlign.right,
          ),),
        ],
      ),
    );

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_15,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10),),
                Expanded(
                  flex: 1,
                  child: Text(
                    gasPriceStr,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    textAlign: TextAlign.right,
                  ),),
              ],
            ),
          ),
          gasLimitWidget,
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_16,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10),),
                Expanded(flex: 1,child: Text(
                  totalGasPriceStr,
                  style: TextStyle(
                    color: totalGasPriceColor,
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                  textAlign: TextAlign.right,
                ),),
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
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),left: ScreenUtil().setWidth(30),right: ScreenUtil().setWidth(30)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
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
}
