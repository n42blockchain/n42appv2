import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/sui_api.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/address_book/address_book_list.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_match.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_base_send.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/utils/coin_gas.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:n42appv2/src/widgets/text_field_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletChainSendSui extends StatefulWidget {
  final CoinModel coinModel;
  const WalletChainSendSui(this.coinModel,{super.key});

  @override
  State<WalletChainSendSui> createState() => _WalletChainSendSuiState();
}

class _WalletChainSendSuiState extends State<WalletChainSendSui> {
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
  final oCcy =  NumberFormat("#,##0.00########", "en_US");
  TextEditingController toTextEditingController=TextEditingController();
  TextEditingController valueTextEditingController=TextEditingController();
  TextEditingController noteTextEditingController=TextEditingController();
  FocusNode toNode=FocusNode();
  FocusNode valueNode=FocusNode();
  FocusNode noteNode=FocusNode();

  String toErrorMessage="";
  String noteErrorMessage="";
  String amountErrorMessage="";
  String errorMessage="";

  BigInt totalGasPrice=BigInt.zero;
  BigInt gasPrice=BigInt.zero;
  BigInt gasPrice_eth=BigInt.zero;
  BigInt gas=BigInt.zero;
  BigInt gas_eth=BigInt.zero;
  BigInt transferValue=BigInt.zero;//转账金额
  List<Map<String,dynamic>> utxos=[];


  Load load=Load.loading;
  Load gasLimitLoad=Load.finish;
  TokenViewApi? _tokenViewApi;
  TokenViewApi get tokenViewApi{
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }
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
    noteTextEditingController.dispose();
    toNode.dispose();
    valueNode.dispose();
    noteNode.dispose();
    super.dispose();
  }

  initData()async{
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
      if (!mounted) return;
      setState(() {});
    }
    gas=BigInt.from(GetCoinGas(widget.coinModel.coin['coinType'],contract:widget.coinModel.coin['isContract']));
    await getBalance();
    await getGasPrice();
    await getOwnerObjects();
  }
  //获取余额
  getBalance()async{
    setState(() {
      load=Load.loading;
    });
    bool isOk=await widget.coinModel.getBalance(getToken: false);
    if (!mounted) return;
    if(isOk==false){
      load=Load.finish;
      errorMessage=S.current.g_key_t_44;
      ToastUtils.show(S.current.g_key_t_44);
      setState((){});
      return;
    }
  }
  //获取旷工费
  getGasPrice()async{
    setState(() {
      load=Load.loading;
    });
    String? rpc=widget.coinModel.coin['custom']==true?widget.coinModel.coin['service']:null;

    MessageModel mm=await tokenViewApi.getGasPrice(
      widget.coinModel.coin['blockchainType'],
      widget.coinModel.coin['coinType'],
      isTest:widget.coinModel.isTest,
      rpc: rpc,
    );
    if (!mounted) return;
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
  //获取持有的所有可用资产
  /*"data": {
          "objectId": "0xabc...",
          "version": "1",
          "digest": "xxx",
          "type": "0x2::coin::Coin<0x2::sui::SUI>",
          "content": {
            "fields": {
              "balance": "100000000"
            },
            "type": "0x2::coin::Coin<0x2::sui::SUI>"
          },
          "owner": {
            "AddressOwner": "0x1f4..."
          }
        }*/
  getOwnerObjects()async{
    List<dynamic> v= await SuiApi(isTest: widget.coinModel.isTest).getOwnedObjects(widget.coinModel.address);
    if (!mounted) return;
    utxos=[];
    for(Map utxo in v){
      Map<String,dynamic> u={
        "objectId":utxo['data']['objectId'],
        "objectDigest":utxo['data']['digest'],
        "version":utxo['data']['version'],
        "balance":utxo['data']['content']['fields']['balance'],
      };
      utxos.add(u);
    }
  }
  //eth 模拟交易
  estimateGas_eth_local({bool checkAddress=true})async{
    closeKeyboard();
    if(gasLimitLoad==Load.loading)return;
    setState(() {
      gasLimitLoad=Load.loading;
    });
    try{
      String? toAddr;
      if(checkAddress){
        if(amountErrorMessage !="")return;
        toAddr=await toAddress_check(toTextEditingController.text.trim());
        if (!mounted) return false;
        if(toAddr==null){
          return;
        }
      }else{
        toAddr=toTextEditingController.text.trim();
      }
      if(toErrorMessage !="")return;
      String price=valueTextEditingController.text;
      if(price==""){
        return;
      }
      //await getGasPrice();
      MessageModel suiMessage=MessageModel();
      Map<String,dynamic> signData={
        "referenceGasPrice":totalGasPrice,
        "gasBudget":totalGasPrice.toInt()*1.2,
        "toAddress":toTextEditingController.text,
        "amount":BigInt.parse(valueTextEditingController.text),
        "utxo":utxos
      };
      SuiApi suiApi=SuiApi(isTest: widget.coinModel.isTest);
      String path=getPathWithIndex(widget.coinModel.coin['path'][widget.coinModel.addrType], widget.coinModel.pathIndex);
      final mnemonic = Provider.of<WalletActionProvider>(context,listen: false).walletInfo.mnemonic??"";
      String signStr=await Trustdart().signTransaction(CoinType.SUI.name, path, signData,
        mnemonic: mnemonic,
        pk: widget.coinModel.privateKey??"",
      );
      if (!mounted) return false;
      suiMessage=await suiApi.dryRunTransactionBlock(signStr);
      if (!mounted) return false;

      if(suiMessage.error==false){
        gasPrice=suiMessage.data;
        totalGasPrice=gasPrice;
        errorMessage="";
        return true;
      }else{
        errorMessage=suiMessage.data;
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
  //检查 amount 输入是否正确
  amount_check({String value=""}){
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
      checkValue1=_regular.regular_nums(value.toString());
      if(checkValue1==false){
        amountErrorMessage= S.of(context).g_key_134;
        setState(() {});
        return;
      }
    }else{
      checkValue1=_regular.regular_nums(value.toString());
    }
    bool checkValue=_regular.regular_double(value.toString());
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
    BigInt value_bi=ethToWeiString(value, widget.coinModel.coin['decimals']);
    if(widget.coinModel.coin['isContract']==false){
      if (value_bi+totalGasPrice > widget.coinModel.balance) {
        amountErrorMessage= S.of(context).g_key_47;
        setState(() {});
        return;
      }
    }
    transferValue=value_bi;
    amountErrorMessage="";
    setState(() {});
  }
  //检查转账地址是否正确
  toAddress_check(String addr)async{
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
  sendTransaction()async{
    if(load==Load.loading){
      ToastUtils.show("loading");
      return;
    }
    if(amountErrorMessage !="")return;
    closeKeyboard();
    amount_check();
    if(amountErrorMessage !=""){
      return;
    }
    setState(() {
      load=Load.loading;
    });
    String? toAddr=await toAddress_check(toTextEditingController.text.trim());
    if(toAddr == null) {
      setState(() {
        load=Load.finish;
      });
      return;
    }
    await estimateGas_eth_local(checkAddress: false);
    if (!mounted) return;
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
    if (!mounted) return;
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
    trModel.gasPriceValue=gasPrice;
    trModel.price=transferValue;
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      trModel.message=noteTextEditingController.text.trim();
    }
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
  signTx(TransationRecordModel trModel)async{
    if(signTx_check()==false)return;
    try{
      TransferApi transferApi=TransferApi();
      MessageModel mm=await transferApi.transfer_wallet(
        trModel: trModel,
        privateKey: widget.coinModel.privateKey,
        pathIndex: widget.coinModel.pathIndex,
      );
      if (!mounted) return;
      if(mm.error){
        errorMessage=mm.data;
      }else{
        trModel.txHash=mm.data;
        AppDatabase appDatabase =AppDatabase();
        trModel.trId=await appDatabase.insertTransationRecord(trModel);
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
  signTx_check(){
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
      toAddress_check(scanValue);
    }
    Navigator.pop(context);
  }
  maxTag()async{
    if(gasLimitLoad==Load.loading)return;
    if(widget.coinModel.coin['isContract']){
      valueTextEditingController.text=widget.coinModel.balance_string_all();
      transferValue=widget.coinModel.balance;
      estimateGas_eth_local();
    }else{
      transferValue=widget.coinModel.balance-totalGasPrice;
      valueTextEditingController.text=toEther(transferValue.toString(),widget.coinModel.coin['decimals']).toString();
    }
    amountErrorMessage="";
    setState(() {});
  }
  //关闭键盘
  closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:"${S.of(context).g_key_37} ${widget.coinModel.coin['miniName']}",
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
  coinTypeWidget(){
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
      noteWidget(),
      minerFeeWidget(),
      errorMessageWidget(),
      SizedBox(height: 100,),
    ];
    return Column(
      children: cChildren,
    );
  }
  toWidget(){
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
          TextFieldStyle2(
            context,
            controller: toTextEditingController,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: (){
              FocusScope.of(context).requestFocus(valueNode);
              toAddress_check(toTextEditingController.text.trim());
            },
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: toErrorMessage,
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
            /*
            rightWidget3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.face_outlined,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ):null,
            rightOnTap3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?faceMatchTypeWidget:null,
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Image.asset(
                "assets/wallet/scan.png",
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                width: ScreenUtil().setWidth(50.0),
                height: ScreenUtil().setWidth(50.0),
              ),
            ),
            rightWidget2: Container(
              //margin: EdgeInsets.only(left: scr.setWidth(10.0)),
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
            rightOnTap1: scanQR,
            rightOnTap2: ()async{
              ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
              if(cd !=null){
                if(cd.text !=null && cd.text != "null"){
                  toTextEditingController.text=cd.text??"";
                  setState(() {
                  });
                  toAddress_check(cd.text??"");
                }
              }
            },
            */
          ),
        ],
      ),
    );
  }
  noteWidget(){
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name && widget.coinModel.coin['isContract']==false) {
      return Container(
        margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_wallet_k58,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20.0),),
            TextFieldStyle2(
              context,
              controller: noteTextEditingController,
              focusNode: noteNode,
              hintText: S.of(context).nicknameMessage(100),
              errorMessage: noteErrorMessage,
              suffix: Text(
                "${noteTextEditingController.text.length}/100",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(toNode);
              },
              onChanged: (String value){
                if(value.length>100){
                  noteErrorMessage=S.of(context).nicknameMessage(100);
                }else{
                  noteErrorMessage="";
                }
                setState(() {});
              },
              maxLines: 2,
              height: ScreenUtil().setWidth(108.0),
              bgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
  amountWidget(){
    return ContainerStyle1(
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
                TextFieldStyle2(
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
                    amount_check(value: value);
                  },
                  onEditingComplete: (){
                    amount_check();
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
                  indent: ScreenUtil().setWidth(30.0),
                  endIndent: ScreenUtil().setWidth(30.0),
                ),
                ownerAddress(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  amountBalanceWidget(){
    String unit=widget.coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${widget.coinModel.balance_string_all()} $unit',
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
  ownerAddress(){
    String addr="";
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      addr=widget.coinModel.address.toString();
    }else if(widget.coinModel.coin['blockchainType']==BlockchainType.Solana.name){
      addr=widget.coinModel.address.toString();
    }else{
      addr=widget.coinModel.address.toString();
    }
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
  //旷工费
  minerFeeWidget(){
    String title=widget.coinModel.coin['coinType'];
    String totalGasPriceStr="";
    String gasPriceStr="";
    Color totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    Widget gasLimitWidget=Container();
    int decimals=widget.coinModel.coin['decimals'];
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      String unit=widget.coinModel.coin['unit'].toString().toUpperCase();
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
        unit=(chainModel?.coin['unit']??"").toString().toUpperCase();
        BigInt chainBalance=chainModel?.balance?? BigInt.zero;
        if(totalGasPrice > chainBalance){
          totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
        }
      }
      totalGasPriceStr='${Decimal.parse(toEther(totalGasPrice.toString(),decimals).toString())}$unit';
      gasPriceStr='${Decimal.parse(toGWei(gasPrice.toString()).toString()) }Gwei';
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
    }
    else if(widget.coinModel.coin['blockchainType']==BlockchainType.Tron.name){
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
        if(toEther(totalGasPrice.toString(),decimals).toDouble() > (chainModel?.balance_double_all()??0)){
          totalGasPriceColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
        }
      }
      totalGasPriceStr='${toEther(totalGasPrice.toString(),decimals)} $title';
      gasPriceStr='${toEther(gasPrice.toString(),decimals) } $title';
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
            Expanded(flex: 1,child: Container()),
            Text(
              "$gas",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ],
        ),
      );
    }
    else{
      if(widget.coinModel.coin['isContract']){
        decimals=chainModel?.coin['decimals']??0;
      }
      totalGasPriceStr='${toEther(totalGasPrice.toString(),decimals)} $title';
      gasPriceStr='${toEther(gasPrice.toString(),decimals) } $title';
    }

    return ContainerStyle1(
      context,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          if(widget.coinModel.coin['isContract'])
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
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
                  SizedBox(width: ScreenUtil().setWidth(10),),
                  Expanded(flex: 1,child: Text(
                    '${chainModel?.balance_double_all()??0} ${(chainModel?.coin['unit']??"").toString().toUpperCase()}',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    textAlign: TextAlign.right,
                  ),),

                ],
              ),
            ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_t_17,
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
  errorMessageWidget(){
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
  sendButtonWidget(){
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
            child: ButtonStyle6(
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
  faceMatchTypeWidget(){
    Widget child=Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(1)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddress_check(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).photograph,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(2)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddress_check(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88.0),
            width: double.infinity,
            child: Text(
              S.of(context).g_key_nft_16,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(32.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    SheetBottom(context, S.of(context).g_face_match_key1, child);
  }
  searchToAddressWidget(){
    List<Widget> childs=[
      InkWell(
        onTap: ()async{
          final value =await Navigator.push(context, MaterialPageRoute(
              builder: (context)=> AddressBookList(coinName: widget.coinModel.coin['coinType'],)));
          if (!mounted) return;
          if(value !=null){
            toTextEditingController.text=value;
          }
          Navigator.pop(context);
        },
        child: SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                child: Image.asset(
                  "assets/wallet/addressBook.png",
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  height: ScreenUtil().setWidth(48),
                  width: ScreenUtil().setWidth(48),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  S.of(context).g_key_108,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ),
      InkWell(
        onTap: scanQR,
        child: SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                child: Image.asset(
                  "assets/wallet/scan.png",
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  height: ScreenUtil().setWidth(48),
                  width: ScreenUtil().setWidth(48),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  S.of(context).g_key_4,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ),
      InkWell(
        onTap: ()async{
          ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
          if (!mounted) return;
          if(cd !=null){
            if(cd.text !=null && cd.text != "null"){
              toTextEditingController.text=cd.text??"";
              setState(() {
              });
              toAddress_check(cd.text??"");
            }
          }
          Navigator.pop(context);
        },
        child: SizedBox(
          height: ScreenUtil().setWidth(88),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                height: ScreenUtil().setWidth(48),
                width: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                child: Icon(
                  Icons.paste_outlined,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  size: ScreenUtil().setWidth(48),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  S.of(context).g_key_166,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      ),
    ];
    if(widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name){
      childs.addAll([
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(1)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddress_check(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88),
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: ScreenUtil().setWidth(48),
                  width: ScreenUtil().setWidth(48),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                  child: Icon(
                    Icons.photo_album_outlined,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    size: ScreenUtil().setWidth(48),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${S.of(context).g_face_match_key1}(${S.of(context).photograph})',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: ScreenUtil().setWidth(1),
          indent: 0,
          endIndent: 0,
        ),
        InkWell(
          onTap: ()async{
            String? address=await Navigator.push(context,
                MaterialPageRoute(builder: (_) => FaceMatch(2)));
            if (!mounted) return;
            if(address !=null){
              toTextEditingController.text=address;
              toAddress_check(address);
            }
            Navigator.pop(context);
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(88),
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: ScreenUtil().setWidth(48),
                  width: ScreenUtil().setWidth(48),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20),),
                  child: Icon(
                    Icons.face_outlined,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    size: ScreenUtil().setWidth(48),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${S.of(context).g_face_match_key1}(${S.of(context).g_key_nft_16})',
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
    }
    SheetBottom(context, S.of(context).g_face_match_key1, Column(
      children: childs,
    ));
  }
}
