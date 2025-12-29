import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletBaseSend extends StatefulWidget {
  TransationRecordModel? transationRecordModel;
  BtcTransactionRecodeModel? btcTransactionRecodeModel;
  String mainCoinUnit;
  bool isNft;
  WalletBaseSend(
      this.transationRecordModel,
      this.btcTransactionRecodeModel,
      this.mainCoinUnit,
      {this.isNft=false,super.key});

  @override
  State<WalletBaseSend> createState() => _WalletBaseSendState();
}

class _WalletBaseSendState extends State<WalletBaseSend> {
  Map<String,dynamic> coinInfo={};
  String gasPrice="";

  //账号安全
  Map<String,dynamic> securityMap={
    "email":false,
    //"google":false,
    "face":false,
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.btcTransactionRecodeModel!=null){
      coinInfo=widget.btcTransactionRecodeModel!.coin;
    }
    if(widget.transationRecordModel!=null){
      coinInfo=widget.transationRecordModel!.coin;
    }
    init();
    init_security();
  }
  init(){
    //计算gasPrice
    BlockchainType bt=BlockchainType.values.firstWhere((element) => element.name==coinInfo['blockchainType']?true:false);
    switch(bt){
      case BlockchainType.Bitcoin:
        gasPrice='${toEther(widget.btcTransactionRecodeModel!.gasPrice.toString(), 8)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Ethereum:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Solana:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 9)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Tron:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Ripple:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Algorand:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Tezos:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Cosmos:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 6)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Filecoin:
        gasPrice='${toEther(widget.transationRecordModel!.gasPrice.toString(), 18)} ${widget.mainCoinUnit}';
        break;
      case BlockchainType.Polkadot:
        // TODO: Handle this case.
        gasPrice="0";
      case BlockchainType.Aptos:
        // TODO: Handle this case.
        gasPrice="0";
      case BlockchainType.Sui:
        // TODO: Handle this case.
        gasPrice="0";
      case BlockchainType.TheOpenNetwork:
        // TODO: Handle this case.
        gasPrice="0";
    }

  }
  init_security()async{
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[AppGlobals.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          securityMap=userSecurityMap;
        });
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  //关闭键盘
  closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }
  Future<bool> _pageBack(){
    if(Navigator.canPop(context)){
      Navigator.pop(context,false);
    }else{
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    String from="";
    String to="";
    String price="";
    if(widget.btcTransactionRecodeModel!=null){
      from=widget.btcTransactionRecodeModel!.address;
      to=widget.btcTransactionRecodeModel!.to1;
      price='${widget.btcTransactionRecodeModel!.price_double()} ${coinInfo['unit']}';
    }
    if(widget.transationRecordModel!=null){
      from=widget.transationRecordModel!.from1;
      to=widget.transationRecordModel!.to1;
      if(widget.isNft){
        price='${int.parse(widget.transationRecordModel!.price_double().toString())}';
      }else{
        price='${widget.transationRecordModel!.price_double()} ${coinInfo['unit']}';
      }
    }
    // TODO: implement build
    return WillPopScope(
      onWillPop: _pageBack,
      child:Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).s_key_3,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: (){
              closeKeyboard();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: ScreenUtil().setWidth(30.0),
                          ),
                          child: Text(
                            S.of(context).g_key_202,
                            style: TextStyle(
                              fontSize: ScreenUtil().setWidth(28.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16.0),horizontal: ScreenUtil().setWidth(30.0)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              tapLabelWidget(S.of(context).g_key_75,from,copy: true,),
                              tapLabelWidget(S.of(context).g_key_38,to,copy: true,),
                              tapLabelWidget(S.of(context).g_key_44,price,),
                              tapLabelWidget(S.of(context).g_key_t_16,gasPrice,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Divider(
                        height: ScreenUtil().setWidth(1),
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        padding: EdgeInsets.all( ScreenUtil().setWidth(30.0)),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                        height: ScreenUtil().setWidth(148),
                        child: Row(
                          children: [
                            Expanded(child: Container(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: ButtonStyle5(context, (){
                                Navigator.pop(context,false);
                              },
                                S.of(context).g_key_79,
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                borderColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                              ),
                            ),),
                            SizedBox(width: ScreenUtil().setWidth(30.0),),
                            Expanded(child: Container(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: ButtonStyle2(context, ()async{
                                bool r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletSecurityVerification()));
                                if(r){
                                  Navigator.pop(context,true);
                                }
                              }, S.of(context).g_key_t_31,),
                            ),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //带标签的label 控件
  Widget tapLabelWidget(String title,String value,{bool copy=false}){
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(16.0),
        top: ScreenUtil().setWidth(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
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
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    child: Icon(
                      Icons.copy,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Divider(
            height: ScreenUtil().setWidth(1.0),
            indent: 0,
            endIndent: 0,
          ),
        ],
      ),
    );
  }
}
