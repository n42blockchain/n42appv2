import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_gen_success.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class CreateFinish extends StatefulWidget {
  WalletInfo? wInfo;
  String createMetod;//Create,Import,PrivateKey
  CreateFinish({this.wInfo,this.createMetod="Create",super.key});

  @override
  State<CreateFinish> createState() => _CreateFinishState();
}

class _CreateFinishState extends State<CreateFinish> {
  Load load=Load.loading;
  bool exportKeystore=false;
  //bool isSelectedUserProtocol = false;
  String pageName="/CreateOne";

  Future<bool> _pageBack(){
    if(Navigator.canPop(context)){
      if(load==Load.finish){
        //eventBus.fire(EventPublic(EventPublicType.finishPage));
        Navigator.popUntil(context,ModalRoute.withName(pageName));
      }
      return Future.value(false);
    }else{
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
  createWallet()async{
    final walletActionProvider =Provider.of<WalletActionProvider>(context,listen: false);
    if(widget.wInfo==null){
      widget.wInfo=WalletInfo(
        walletName: "",
        password: "",
        UUID: walletActionProvider.UserUUID,
      );
      widget.wInfo!.mnemonic= await Trustdart().generateMnemonic();
    }
    //String walletName="Account${walletActionProvider.walletMap.length}";
    if(widget.wInfo!.walletName==""){
      widget.wInfo!.walletName="Account${walletActionProvider.walletInfoLsit.length+1}";
    }
    if(widget.wInfo!.coinInfo==null){
      widget.wInfo!.coinInfo = chainUrlMap;
    }
    //根据导入时间设置时间戳 标记钱包的唯一标识
    widget.wInfo!.timestamp = "${DateTime.now().millisecondsSinceEpoch}";

    ///生成钱包
    int code = -1;
    try {
      setState(() {
        load=Load.loading;
      });
      //await Future.delayed(const Duration(microseconds: 600), () {});
      if(widget.createMetod=="Import"){
        code = await walletActionProvider.checkWalletMnemonic(widget.wInfo!);
      }else{
        code=0;
      }

      if (code == 0) {
        //本地安全存储助记词
        //await info.saveMnemonicToStorage();

        ///更新一下provider中的数据
        await walletActionProvider.addWalletInfo(widget.wInfo!);
        //walletActionProvider.addDefaultToken();
        //刷新一下首页的nft 和wallet 数据
        //walletActionProvider.notifyWalletState(true);
        ///创建成功
        //ToastUtils.showFtToast(child: successView('Success'));
        //eventBus.fire(EventPublic(EventPublicType.finishPage));

        //埋点用户导入钱包
        //AmplitudeUtils.walletActive(WalletStatus.imported);
      } else {
        //Provider.of<WalletActionProvider>(context, listen: false).deleteWalletInfo();
        //失败
        //AmplitudeUtils.walletActive(WalletStatus.missing);
        debugPrint("create wallet err: ");
        ToastUtils.showFtToast(
            child: createWalletErrView('error'));
      }
    } catch (err) {
      ToastUtils.show(err.toString());
      debugPrint("create wallet err: ${err.toString()}");
    } finally {
      setState(() {
        load=Load.finish;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.createMetod=="Import"){
      pageName="/ImportOne";
    }else if(widget.createMetod=="PrivateKey"){
      pageName="/ImportPrivatekey";
    }
    createWallet();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        actions: [
          SizedBox(width: ScreenUtil().setWidth(130.0),),
        ],
        leadingWidth: ScreenUtil().setWidth(130.0),
        leading: SizedBox(),
        title: load==Load.finish?SizedBox():(widget.createMetod=="Import" || widget.createMetod=="PrivateKey")?Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(144.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(144.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ],
          ),
        ):
        Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0),),
              Container(
                height: ScreenUtil().setWidth(10.0),
                width: ScreenUtil().setWidth(88.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: exportKeystore?
        exportKeystoreWidget():
        Stack(
          children: [
            Positioned.fill(
              child: Visibility(
                visible: load==Load.loading,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(30.0),bottom: ScreenUtil().setWidth(30.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
                      alignment: Alignment.center,
                      child: Text(
                        (widget.createMetod=="Import" || widget.createMetod=="PrivateKey")?S.of(context).g_key_wallet_c13:S.of(context).g_key_wallet_c14,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: ScreenUtil().setWidth(160.0),
                            width: ScreenUtil().setWidth(160.0),
                            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                            decoration: BoxDecoration(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    height: ScreenUtil().setWidth(100.0),
                                    width: ScreenUtil().setWidth(100.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    height: ScreenUtil().setWidth(100.0),
                                    width: ScreenUtil().setWidth(100.0),
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: ScreenUtil().setWidth(48.0),
                                      width: ScreenUtil().setWidth(48.0),
                                      decoration: BoxDecoration(
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24.0)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset("assets/home/money.png",width: ScreenUtil().setWidth(28.0),height: ScreenUtil().setWidth(28.0),),
                                    ),
                                  ),
                                ),
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
            if(widget.createMetod=="Import" || widget.createMetod=="PrivateKey")
              Positioned.fill(
                child: Visibility(
                  visible:load==Load.finish,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(560.0),
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                "assets/wallet/create_finish.gif",
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: ScreenUtil().setWidth(50.0),
                              child: Container(
                                height: ScreenUtil().setWidth(200.0),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/home/ast_big.png",
                                  height: ScreenUtil().setWidth(200.0),
                                  width: ScreenUtil().setWidth(200.0),
                                  //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        ),

                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                        child: Text(
                          S.of(context).g_key_wallet_c15,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(56.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Text(
                          S.of(context).g_key_wallet_c16,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            if(widget.createMetod=="Create")
              Positioned.fill(
                child: Visibility(
                  visible: load==Load.finish,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(320.0),
                        width: ScreenUtil().setWidth(320.0),
                        margin:EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                        child: Image.asset(
                          "assets/home/create_successful.png",
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                        child: Text(
                          widget.createMetod=="Create"?
                          S.of(context).g_key_wallet_c22:
                          S.of(context).g_key_wallet_c15,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(56.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                        child: Text(
                          widget.createMetod=="Create"?
                          S.of(context).g_key_wallet_c23:
                          S.of(context).g_key_wallet_c16,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32.0),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(248),)
                      //Spacer(),
                      /*UserProtocol(
                      onChanged: (value) {
                        isSelectedUserProtocol = value;
                        setState(() {});
                      },
                    ),*/
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: load==Load.finish,
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    Container(
                      height: ScreenUtil().setWidth(148.0),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                      width: double.infinity,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                      child: ButtonStyle2(context,
                            (){
                          //eventBus.fire(EventPublic(EventPublicType.finishPage));
                              Navigator.popUntil(context,ModalRoute.withName(pageName));
                        },
                        S.of(context).g_key_wallet_c17,
                      ),
                    ),
                    if(widget.createMetod=="Create")
                      InkWell(
                        onTap: (){
                          setState(() {
                            exportKeystore=true;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60.0)),
                          child: Text(
                            S.of(context).g_key_wallet_c24,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(28.0),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              decoration: TextDecoration.underline,
                              decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ), onWillPop: _pageBack);
  }
  exportKeystoreWidget(){
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: ScreenUtil().setWidth(320.0),
                width: ScreenUtil().setWidth(320.0),
                margin:EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
                child: Image.asset(
                  "assets/wallet/illustration.png",
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(30.0)),
                child: Text(
                  S.of(context).g_key_wallet_c25,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(56.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                child: Text(
                  S.of(context).g_key_wallet_c26,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor6.name),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(20.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).g_key_wallet_c27,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        S.of(context).g_key_wallet_c28,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        S.of(context).g_key_wallet_c29,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor7.name),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
              ),
              SizedBox(height: ScreenUtil().setWidth(248),)
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: load==Load.finish,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                Container(
                  height: ScreenUtil().setWidth(148.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  width: double.infinity,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                  child: ButtonStyle2(context,
                        ()async{
                      await Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletList()));
                      //eventBus.fire(EventPublic(EventPublicType.finishPage));
                      Navigator.popUntil(context,ModalRoute.withName(pageName));
                    },
                    S.of(context).g_key_wallet_c30,
                  ),
                ),
                InkWell(
                  onTap: (){
                    //eventBus.fire(EventPublic(EventPublicType.finishPage));
                    Navigator.popUntil(context,ModalRoute.withName(pageName));
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60.0)),
                    child: Text(
                      S.of(context).g_key_wallet_c31,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        decoration: TextDecoration.underline,
                        decorationColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
