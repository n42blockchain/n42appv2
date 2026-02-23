import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/component/pages/scan_page.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/src/wallet/api/token_view_api.dart';
import 'package:n42_wallet/src/wallet/api/transfer_api.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/src/wallet/pages/address_book/address_book_list.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/wallet/utils/coin_gas.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/container_widget.dart';
import 'package:n42_wallet/src/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:n42_wallet/src/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/src/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/src/wallet/widgets/non_evm_fee_selector.dart';

class WalletChainSendXrp extends ConsumerStatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendXrp(this.coinModel,{super.key});

  @override
  ConsumerState<WalletChainSendXrp> createState() => _WalletChainSendXrpState();
}

class _WalletChainSendXrpState extends ConsumerState<WalletChainSendXrp> {
  CoinModel? chainModel;
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  final oCcy =  NumberFormat("#,##0.00########", "en_US");
  late TextEditingController toTextEditingController=TextEditingController();
  late TextEditingController valueTextEditingController=TextEditingController();
  final TextEditingController destTagCtrl = TextEditingController();
  late FocusNode toNode=FocusNode();
  late FocusNode valueNode=FocusNode();
  final FocusNode destTagNode = FocusNode();

  String toErrorMessage="";
  String amountErrorMessage="";
  String errorMessage="";

  BigInt totalGasPrice=BigInt.zero;
  BigInt gasPrice=BigInt.zero;
  BigInt gas=BigInt.zero;
  BigInt transferValue=BigInt.zero;//转账金额
  dec.Decimal lockValue=dec.Decimal.zero;

  Load load=Load.loading;
  Load gasLimitLoad=Load.finish;


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
    destTagCtrl.dispose();
    toNode.dispose();
    valueNode.dispose();
    destTagNode.dispose();
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
      setState(() {});
    }
    gas=BigInt.from(getCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
    await getBalance();
    await getGasPrice();
    await getServiceState();
    lockValue=toEther((widget.coinModel.other?.getLockAmount??0).toString(), widget.coinModel.coin['decimals']);
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
    }
  }
  //获取xrp服务器信息，主要获取 基础说定额度和每个对象的锁定额度
  Future<void> getServiceState()async{
    MessageModel mm=await XrpApi().getServerStateXrp(isTest: widget.coinModel.isTest);
    if(mm.error==false){
      widget.coinModel.other?.setServiceState(mm.data);
    }else{

    }
    setState(() {});
  }
  //获取旷工费
  Future<void> getGasPrice()async{
    setState(() {
      load=Load.loading;
    });
    TokenViewApi tokenViewApi=TokenViewApi();
    MessageModel mm=await tokenViewApi.getGasPrice(
        widget.coinModel.coin['blockchainType'],
        widget.coinModel.coin['coinType'],
        isTest:widget.coinModel.isTest,
    ) ?? MessageModel.error();
    if(mm.error==false){
      gasPrice=mm.data;
    }else{
      errorMessage=mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    totalGasPrice=gasPrice*gas;
    load=Load.finish;
    setState(() {});
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
    if(checkValue==false && checkValue1==false){
      amountErrorMessage= S.of(context).g_key_134;
      setState(() {});
      return;
    } else if(double.parse(value)<=0){
      amountErrorMessage= S.of(context).g_key_46(0);
      setState(() {});
      return;
    }
    BigInt valueBi=ethToWeiString(value, widget.coinModel.coin['decimals']);

    BigInt vb1=widget.coinModel.balance-BigInt.from(widget.coinModel.other?.getLockAmount??0);
    if (valueBi + totalGasPrice>= vb1) {
      amountErrorMessage= S.of(context).g_key_47;
      setState(() {});
      return;
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
          await checkAccountXRP(addr);
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

  //检查瑞波币，是否创建了账号
  Map<String,dynamic> accountXrp={
    "address":"",
    "error":"",
    "account":"",
    "load":Load.finish,
    "isCreate":false
  };
  //瑞波币接收方是否创建了账号
  Future<void> checkAccountXRP(String addr)async{
    if(accountXrp['load']==Load.loading)return;
    accountXrp['load']=Load.loading;
    setState(() {});
    XrpApi xrpApi=XrpApi();
    MessageModel mm=await xrpApi.getAccountInfoXrp(addr, widget.coinModel.isTest);
    if(mm.error){
      accountXrp['error']=S.current.g_key_t_45(addr);
      accountXrp['load']=Load.finish;
      setState(() {});
    }else{
      accountXrp['address']=addr;
      if(mm.data['account']==false){
        accountXrp['account']=S.current.g_key_t_49;
        accountXrp['isCreate']=false;
      }else{
        accountXrp['account']=S.current.g_key_t_51;
        accountXrp['isCreate']=true;
      }
      accountXrp['error']="";
      accountXrp['load']=Load.finish;
    }
    setState(() {});
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

    amountCheck();
    if (!mounted) return;
    if(widget.coinModel.balance==BigInt.zero){
      setState(() {
        load=Load.finish;
      });
      return;
    }
    if(accountXrp['isCreate']==false){
      if(transferValue<BigInt.from(widget.coinModel.other.reserveBase)){
        errorMessage=S.of(context).g_key_t_52(widget.coinModel.other.reserveBase);
        setState(() {
          load=Load.finish;
        });
        return;
      }else{
        errorMessage="";
      }
    }else{
      errorMessage="";
    }
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
    trModel.other=RippleTrModel(
      "XRP",
      widget.coinModel.other.sequence,
      destinationTag: destTagCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(destTagCtrl.text.trim()),
    );
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
      if(mm.error){
        errorMessage=mm.data;
      }else{
        trModel.txHash=mm.data;
        trModel.trId=await AppDatabase().insertTransationRecord(trModel);
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
  bool signTxCheck(){
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      if(widget.coinModel.coin['isContract']){
        BigInt chainBalance=chainModel?.balance??BigInt.zero;
        if(chainBalance==BigInt.zero){
          ToastUtils.show(S.current.g_key_t_29(chainModel?.coin['coinType']??""));
          return false;
        }else if(totalGasPrice > chainBalance){
          ToastUtils.show(S.current.g_key_t_29(chainModel?.coin['coinType']??""));
          return false;
        }
      }
    }
    return true;
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
    transferValue=widget.coinModel.balance-BigInt.from(widget.coinModel.other.reserveBase)-totalGasPrice;
    if(transferValue<BigInt.zero){
      transferValue=BigInt.zero;
    }
    valueTextEditingController.text=toEther(transferValue.toString(),widget.coinModel.coin['decimals']).toString();
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
      /*WalletChainInfoTitle(
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
      ),*/
      RecentAddressBar(
        coinType: widget.coinModel.coin['coinType'] ?? '',
        onSelected: (addr) {
          toTextEditingController.text = addr;
          toAddressCheck(addr);
        },
      ),
      toWidget(),
      destinationTagWidget(),
      amountWidget(),
      minerFeeWidgetRippleXRP(),
      toAddressAccount(),
      errorMessageWidget(),
      SizedBox(height: 100,),
    ];
    return Column(
      children: cChildren,
    );
  }
  Widget destinationTagWidget() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Destination Tag',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                '（可选）',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12.0)),
          TextField(
            controller: destTagCtrl,
            focusNode: destTagNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
            decoration: InputDecoration(
              hintText: '转账到交易所时通常必填',
              hintStyle: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24.0),
              ),
              filled: true,
              fillColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20.0),
                vertical: ScreenUtil().setWidth(16.0),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
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
            errorMessage: toErrorMessage,
            height: ScreenUtil().setWidth(170.0),
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.add,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            rightOnTap1: searchToAddressWidget,
            bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }
  Widget amountWidget(){
    return containerStyle1(
      context,
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left:ScreenUtil().setWidth(30.0),
              right:ScreenUtil().setWidth(30.0),
              top: ScreenUtil().setWidth(30.0),
            ),
            child: Row(
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
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius:BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff101828).withAlpha((0 * 255).round()),  //底色,阴影颜色
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget amountBalanceWidget(){
    String unit=widget.coinModel.coin['unit'];
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ripple.name){
      double tBalance=widget.coinModel.balanceDoubleAll();
      dec.Decimal uBalance=dec.Decimal.zero;//可用余额
      if(tBalance>lockValue.toDouble()){
        uBalance=dec.Decimal.parse(tBalance.toString())-lockValue;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${S.of(context).g_key_29}:${dec.Decimal.parse(tBalance.toString())} $unit',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${S.of(context).g_key_xml_0}:$lockValue $unit',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${S.of(context).g_key_43}:${dec.Decimal.parse(uBalance.toString())} $unit',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      );
    }
    else{
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
  Widget minerFeeWidgetRippleXRP() {
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
  Widget toAddressAccount(){
    if(accountXrp['address'] !=""){
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top:ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0) ),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    S.of(context).g_key_t_46,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    if(accountXrp['load']==Load.loading)return;
                    checkAccountXRP(toTextEditingController.text);
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          accountXrp['load']==Load.loading?
                          SizedBox(
                            height: ScreenUtil().setWidth(30.0),
                            width: ScreenUtil().setWidth(30.0),
                            child: CircularProgressIndicator(color:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),),
                          ): SizedBox(),
                          Text(
                            S.of(context).g_key_t_47,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                              fontSize: ScreenUtil().setSp(24.0),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ],
            ),
            Text(
              S.of(context).g_key_t_46,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
              child: Text(
                accountXrp['account'],
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
            Text(
              accountXrp['error'],
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                fontSize: ScreenUtil().setSp(22.0),
              ),
            ),
          ],
        ),
      );
    }else{
      return SizedBox();
    }
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
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
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
