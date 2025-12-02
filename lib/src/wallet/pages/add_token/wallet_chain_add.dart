import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/widgets/login_title.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/all_chain.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletChainAdd extends StatefulWidget {
  const WalletChainAdd({super.key});

  @override
  State<WalletChainAdd> createState() => _WalletChainAddState();
}

class _WalletChainAddState extends State<WalletChainAdd> {
  late TextEditingController nameController;
  late TextEditingController symbolController;
  late TextEditingController decimalController;
  late TextEditingController chainIdController;
  late TextEditingController rpcController;
  //late TextEditingController apiController;
  late FocusNode nameNode;
  late FocusNode symbolNode;
  late FocusNode decimalNode;
  late FocusNode chainIdNode;
  late FocusNode rpcNode;
  //late FocusNode apiNode;
  String nameErrorMessage="";
  String symbolErrorMessage="";
  String decimalErrorMessage="";
  String chainIdErrorMessage="";
  String rpcErrorMessage="";
  //String apiErrorMessage="";
  String errorMessage="";
  Load load=Load.finish;
  Map<String,dynamic> ethMap={
    "showList":true,//主链币是否显示在主页列表中
    //"sort":2,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":true,//是否可以使用测试网络
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "mKey": "ETH",
      "blockchainType": BlockchainType.Ethereum.name,//链类型 字符串类型 Ethereum、Bitcoin、Solana、Tron等
      "coinType": CoinType.ETH.name,//是那种币，ETH、BNB、等
      "icon": "",//图标地址
      "name": "Ethereum",//链全名
      "miniName": "ETH",//链 的symbol，
      "unit":"ETH",
      "decimals": 18,//小数位数
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",//链path，
      },
      "service": "",//主网rpc地址
      "service_test": "",//测试网rpc地址，如果没有传""
      "chainId": 1,//主网链id
      "chainId_test": 3,//测试网链id
      "contract": "",
      "contract_test": "",
      "canEdit": true,//是否可以修改
      "rules": "ERC20",//代币的类型 eth 是ERC20，BNB是BEP20，TRX 是TRC20
    },
    "mainnetChainID":1,
    "testnetChainID":3,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":3,
        "testnetContract":{
        }
      },
    ],
    "mainnets":{
    },
  };
  @override
  void initState() {
    // TODO: implement initState
    nameController=TextEditingController();
    symbolController=TextEditingController();
    decimalController=TextEditingController();
    chainIdController=TextEditingController();
    rpcController=TextEditingController();
    //apiController=TextEditingController();
    nameNode=FocusNode();
    symbolNode=FocusNode();
    decimalNode=FocusNode();
    chainIdNode=FocusNode();
    rpcNode=FocusNode();
    //apiNode=FocusNode();
    /*nameController.text="N42";
    symbolController.text="N";
    decimalController.text="18";
    chainIdController.text="94";
    apiController.text="";
    rpcController.text="https://rpc.n42.world";*/
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    symbolController.dispose();
    decimalController.dispose();
    chainIdController.dispose();
    rpcController.dispose();
    //apiController.dispose();
    nameNode.dispose();
    symbolNode.dispose();
    decimalNode.dispose();
    chainIdNode.dispose();
    rpcNode.dispose();
    //apiNode.dispose();
    super.dispose();
  }
  addChain()async{
    //if(load==Load.loading)return;
    String mKey=symbolController.text.toUpperCase();
    String chainIdStr=chainIdController.text;
    String name=nameController.text.toUpperCase();
    String decimalStr=decimalController.text;
    String rpcStr=rpcController.text;
    //String apiStr=apiController.text;
    Regular reg=Regular();
    if(name.length==0){
      setState(() {
        nameErrorMessage=S.of(context).g_token_m_key_1(30);
      });
      return;
    }
    if(name.length>30){
      setState(() {
        nameErrorMessage=S.of(context).g_token_m_key_1(30);
      });
      return;
    }
    if(mKey.length==0){
      setState(() {
        symbolErrorMessage=S.of(context).g_token_m_key_1(10);
      });
      return;
    }
    if(mKey.length>10){
      setState(() {
        symbolErrorMessage=S.of(context).g_token_m_key_1(10);
      });
      return;
    }
    int chainId=int.parse(chainIdStr);
    if(!reg.regular_nums(chainIdStr)){
      setState(() {
        chainIdErrorMessage=S.of(context).g_token_m_key_21;
      });
      return;
    }
    if(chainId<=0){
      setState(() {
        chainIdErrorMessage=S.of(context).g_token_m_key_21;
      });
      return;
    }
    if(chainIdStr.length>10){
      setState(() {
        chainIdErrorMessage=S.of(context).g_token_m_key_21;
      });
      return;
    }
    if(!reg.regular_nums(decimalStr)){
      setState(() {
        decimalErrorMessage=S.of(context).g_token_m_key_21;
      });
      return;
    }
    int decimal=int.parse(decimalStr);
    if((decimal<=18 && decimal>=0)==false){
      setState(() {
        decimalErrorMessage=S.of(context).g_token_m_key_2;
      });
      return;
    }
    if(!isURL(rpcStr)){
      setState(() {
        rpcErrorMessage=S.of(context).g_token_m_key_21;
      });
      return;
    }
    /*if(apiStr!=""){
      if(!isURL(apiStr)){
        setState(() {
          apiErrorMessage=S.of(context).g_token_m_key_21;
        });
        return;
      }
    }*/
    bool exist=await checkChain(mKey,chainId);
    if(exist){
      errorMessage=S.of(context).g_token_m_key_22(name);
      bool? r=await TipsDialog2(context, S.of(context).g_token_m_key_23(name),);
      if(r==true){
        await addDefaultChain(mKey);
        Navigator.pop(context,true);
      }
      return;
    }else{
      errorMessage="";
    }
    setState(() {
      load=Load.loading;
    });
    MessageModel rmm=await EthAPI.init(null, rpcController.text, null).getGasPrice();
    if(rmm.error==false){
      errorMessage="";
    }else{
      setState(() {
        errorMessage=S.of(context).g_token_m_key_24(S.of(context).g_token_m_key_17);
        load=Load.finish;
      });
      ToastUtils.show(errorMessage);
      return;
    }
    ethMap['baseInfo']['mKey']=mKey;
    ethMap['baseInfo']['custom']=true;
    ethMap['baseInfo']['coinType']=mKey;
    ethMap['baseInfo']['miniName']=mKey;
    ethMap['baseInfo']['unit']=mKey;
    ethMap['baseInfo']['name']=name;
    ethMap['baseInfo']['decimals']=decimal;
    ethMap['baseInfo']['chainId']=chainId;
    ethMap['baseInfo']['service']=rpcStr;
    //ethMap['baseInfo']['api']=apiStr;
    await Provider.of<WalletActionProvider>(context,listen: false).addWalletChain(ethMap);
    setState(() {
      load=Load.finish;
    });
    Navigator.pop(context,true);
  }
  checkChain(String symbol,int chainId)async{
    Map<String,dynamic>? chainMap= allChainUrlMap[symbol];
    if(chainMap==null){
      return false;
    }else{
      return true;
    }
  }
  addDefaultChain(String symbol)async{
    await Provider.of<WalletActionProvider>(context,listen: false).addWalletChain(allChainUrlMap[symbol]);
    Navigator.pop(context,true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: S.of(context).g_token_m_key_19,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoginTitle(title: S.of(context).g_token_m_key_13,must: true,),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle3(
                      context,
                      controller: nameController,
                      focusNode: nameNode,
                      hintText: S.of(context).g_token_m_key_1(30),
                      maxLines: 1,
                      maxLengths: 30,
                      height: ScreenUtil().setWidth(120.0),
                      errorMessage: nameErrorMessage,
                      onEditingComplete: (){
                        FocusScope.of(context).requestFocus(symbolNode);
                      },
                      onChanged: (value){

                      }
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    LoginTitle(title: S.of(context).g_token_m_key_14,must: true,),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle3(
                        context,
                        controller: symbolController,
                        focusNode: symbolNode,
                        hintText: S.of(context).g_token_m_key_1(10),
                        maxLines: 1,
                        maxLengths: 10,
                        height: ScreenUtil().setWidth(120.0),
                        errorMessage: symbolErrorMessage,
                        onEditingComplete: (){
                          FocusScope.of(context).requestFocus(chainIdNode);
                        },
                        onChanged: (value){

                        }
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    LoginTitle(title: S.of(context).g_token_m_key_15,must: true,),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle3(
                        context,
                        controller: chainIdController,
                        focusNode: chainIdNode,
                        hintText: S.of(context).g_token_m_key_15,
                        maxLines: 1,
                        maxLengths: 10,
                        height: ScreenUtil().setWidth(120.0),
                        errorMessage: chainIdErrorMessage,
                        onEditingComplete: (){
                          FocusScope.of(context).requestFocus(decimalNode);
                        },
                        onChanged: (value){

                        }
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    LoginTitle(title: S.of(context).g_token_m_key_16,must: true,),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle2(
                        context,
                        controller: decimalController,
                        focusNode: decimalNode,
                        hintText: S.of(context).g_token_m_key_2,
                        maxLines: 1,
                        height: ScreenUtil().setWidth(88.0),
                        errorMessage: decimalErrorMessage,
                        onEditingComplete: (){
                          FocusScope.of(context).requestFocus(rpcNode);
                        },
                        onChanged: (value){

                        }
                    ),
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    LoginTitle(title: S.of(context).g_token_m_key_17,must: true,),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle2(
                        context,
                        controller: rpcController,
                        focusNode: rpcNode,
                        hintText: S.of(context).g_token_m_key_17,
                        maxLines: 1,
                        height: ScreenUtil().setWidth(88.0),
                        errorMessage: rpcErrorMessage,
                        onEditingComplete: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onChanged: (value){

                        }
                    ),
                    /*
                    SizedBox(height: ScreenUtil().setWidth(20),),
                    LoginTitle(title: S.of(context).g_token_m_key_18),
                    SizedBox(height: ScreenUtil().setWidth(10),),
                    TextFieldStyle2(
                        context,
                        controller: apiController,
                        focusNode: apiNode,
                        hintText: S.of(context).g_token_m_key_18,
                        maxLines: 1,
                        height: ScreenUtil().setWidth(88.0),
                        errorMessage: apiErrorMessage,
                        onEditingComplete: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onChanged: (value){

                        }
                    ),
                    */
                    SizedBox(height: ScreenUtil().setWidth(30),),
                    if(errorMessage !="")
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      alignment: Alignment.center,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(148),),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                child: Column(
                  children: [
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      height: ScreenUtil().setWidth(88),
                      child: ButtonStyle6(
                        context,
                        (){
                          addChain();
                        },
                        S.of(context).g_key_159,
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
