import 'dart:convert';

import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_display.dart';
import 'package:web3dart/web3dart.dart';

class OneCoinWalletManage extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final CoinModel model;
  final int walletIndex;
  const OneCoinWalletManage({required this.walletInfo, required this.model,required this.walletIndex,super.key});

  @override
  ConsumerState<OneCoinWalletManage> createState() => _OneCoinWalletManageState();
}

class _OneCoinWalletManageState extends ConsumerState<OneCoinWalletManage> {
  String? mnemonic;
  String? coinPath;
  String? addrType;
  String? pk;
  int pathIndex=0;
  List<dynamic> pathList=[0];
  Load load=Load.finish;
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    mnemonic = widget.walletInfo.mnemonic;
    addrType=widget.walletInfo.coinInfo![widget.model.coin['coinType']]['addrType'];
    coinPath = widget.walletInfo.coinInfo![widget.model.coin['coinType']]['baseInfo']['path'][addrType];
    pathList=widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathList']?? [0];
    pathIndex=widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathIndex']?? 0;
    pk=widget.walletInfo.privateKey;
    setState(() {});
  }

  //添加 path index
  void addPath(){
    if(pathList.length>=10){
      return;
    }
    pathList.add(pathList[pathList.length-1]+1);
    setState(() {});
  }
  void removePath(int index){
    pathList.removeAt(index);
    setState(() {});
  }
  void chagePath(int index){
    pathIndex=pathList[index];
    setState(() {});
  }
  Future<void> saveCoin()async{
    widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathList']=pathList;
    widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathIndex']=pathIndex;
    widget.walletInfo.coinInfo![widget.model.coin['coinType']]['addrType']=addrType;
    await ref.read(wapBridgeProvider).saveWalletInfo(widget.walletInfo,widget.walletIndex);
    if (!mounted) return;
    if(ref.read(wapBridgeProvider).walletIndex == widget.walletIndex){
      ref.read(wapBridgeProvider).reBuildCoin(widget.walletInfo,widget.model.coin['coinType']);
    }
    Navigator.pop(context,true);
  }
  Future<void> jumpExportKeystoreDescPage({String? password})async{
    setState(() {
      load=Load.loading;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    password ??= widget.walletInfo.password ?? "";
    final keystoreJson= await Trustdart().getKeyStore(
      widget.model.coin['coinType']!,
      getPathWithIndex(coinPath!, widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathIndex']??0),
      widget.walletInfo.coinInfo![widget.model.coin['coinType']]['addrType'],
      password,
      mnemonic: mnemonic??"",
      pk:pk??"",
    );
    if (!mounted) return;
    //test 反推一下
    //success：目前支持的有： eth ast matic ETC avax  ht  xDAI FTM celo clo poa
    //反推之后的address大小写有些不一致：0x7Ac869Ff8b6232f7cfC4370A2df4a81641Cba3d9 返推的 0x7ac869ff8b6232f7cfc4370a2df4a81641cba3d9

    //keystore json 说明页面explain
    Navigator.push(context,
      MaterialPageRoute(
          builder: (_) => ExportKeystoreDesc(
            keystoreJson: keystoreJson,
          )),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_110,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWalletInfo(),
                    if(widget.walletInfo.privateKey ==null)
                    _buildExport(),
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
                    height: ScreenUtil().setWidth(148),
                    width: double.infinity,
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle2(
                      context,
                      (){
                        saveCoin();
                      },
                      S.of(context).g_key_115,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfo() {
    int pathCount=1;
    if(widget.model.coin['blockchainType']==BlockchainType.Bitcoin.name){
      pathCount=(widget.model.coin['path'] as Map<String,dynamic>).length;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0))),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0), horizontal: ScreenUtil().setWidth(30.0)),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.model.coin['name'] ?? '',
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(36.0)),
              ),
              Text(
                " (${widget.model.coin['miniName'] ?? ''})",
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0)),
              ),
            ],
          ),
          Divider(
            height: ScreenUtil().setWidth(48.0),
            indent: 0,
            endIndent: 0,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "${S.of(context).g_key_address}: ",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32.0)),
                ),
              ),
              pathCount==1?
              SizedBox():
              InkWell(
                onTap: (){
                  showChangeAddress();
                },
                child:Container(
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
                  child: Row(
                    children: [
                      Text(
                        widget.model.addrType,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_outlined,size: ScreenUtil().setWidth(40.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(20.0),
          ),
          EnsAddressDisplay(
            address: widget.model.address ?? "",
            coinType: widget.model.coin['coinType'] ?? 'ETH',
            style: EnsDisplayStyle.compact,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28.0),
          ),
          if(widget.walletInfo.privateKey ==null)
          Divider(
            height: ScreenUtil().setWidth(48.0),
            indent: 0,
            endIndent: 0,
          ),
          if(widget.walletInfo.privateKey ==null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${S.of(context).g_key_wallet_k53}:",
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(32.0)),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "(${coinPath==null?"": getPathWithIndex(coinPath!, widget.walletInfo.coinInfo![widget.model.coin['coinType']]['pathIndex']??0)})",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0)),
                ),
              ),
              InkWell(
                onTap: (){
                  addPath();
                },
                child: Container(
                  height:ScreenUtil().setWidth(50.0),
                  width:ScreenUtil().setWidth(50.0),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    size: ScreenUtil().setWidth(40.0),
                  ),
                ),
              ),
            ],
          ),
          if(widget.walletInfo.privateKey ==null)
          SizedBox(
            height: ScreenUtil().setWidth(101.0*(pathList.length>4?4:pathList.length)),
            child: ListView.separated(
              itemCount: pathList.length,
              itemBuilder: (context,int index){
                int pIndex=pathList[index];
                String path=getPathWithIndex(widget.model.coin['path'][widget.model.addrType], pIndex);
                return Container(
                  alignment: Alignment.centerLeft,
                  height: ScreenUtil().setWidth(100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if(pIndex != pathIndex)
                        InkWell(
                          onTap: (){
                            chagePath(index);
                          },
                          child:Container(
                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                            height:ScreenUtil().setWidth(50.0),
                            width:ScreenUtil().setWidth(50.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),width: ScreenUtil().setWidth(1.0)),
                            ),
                          ),
                        ),
                      if(pIndex == pathIndex)
                        Container(
                          margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                          height:ScreenUtil().setWidth(50.0),
                          width:ScreenUtil().setWidth(50.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),width: ScreenUtil().setWidth(1.0)),
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            size: ScreenUtil().setWidth(40.0),
                          ),
                        ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          path,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(28.0),
                          ),
                        ),
                      ),
                      if(pIndex !=0 && pIndex != pathIndex)
                        InkWell(
                          onTap: (){
                            removePath(index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.remove,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              size: ScreenUtil().setWidth(40.0),
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
              separatorBuilder: (context,int index){
                return Divider(
                  height: ScreenUtil().setWidth(1.0),
                  endIndent: 0,
                  indent: 0,
                );
              }, ),
          ),
        ],
      ),
    );
  }

  Widget _buildExport() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0))),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0), horizontal: ScreenUtil().setWidth(30.0)),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_181,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0)),
          ),
          Divider(
            height: ScreenUtil().setWidth(48.0),
            indent: 0,
            endIndent: 0,
          ),
          InkWell(
            onTap: () async {
              try {
                if(load==Load.loading)return;
                //导出keystore json
                if(widget.walletInfo.password==""){
                  final TextEditingController controller = TextEditingController();
                  final TextEditingController controller2 = TextEditingController();
                  final flag = await tipsDialog3(context, Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemBgColor.name)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text(
                            S.of(context).g_key_21,
                            style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30.0)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(80.0),
                          width: double.infinity,
                          padding:EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                          decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemBgColor.name),
                            //borderRadius: BorderRadius.circular(12)
                          ),
                          child: CommInput(
                            type: InputFieldType.password,
                            hintText:S.of(context).rest_Choose_password,
                            controller: controller,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(80.0),
                          width: double.infinity,
                          padding:EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                          decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemBgColor.name),
                            //borderRadius: BorderRadius.circular(12)
                          ),
                          //padding: EdgeInsets.symmetric(horizontal: scr.setWidth(30.0)),
                          margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0),bottom: ScreenUtil().setWidth(30.0),),
                          child: CommInput(
                            type: InputFieldType.password,
                            hintText:S.of(context).repeatPassword,
                            controller: controller2,
                            maxLines: 1,
                          ),
                        ),
                        Divider(
                          endIndent: 0,
                          indent: 0,
                          height: ScreenUtil().setWidth(1),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      S.of(context).g_key_79,
                                      style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(
                                              context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(30)),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.dividerColor.name),
                                width: ScreenUtil().setWidth(1),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    child: Text(
                                      S.of(context).g_key_78,
                                      style: TextStyle(
                                        // color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor),
                                          color: AppThemeUtils.getColorByKey(
                                              context, AppThemeKeys.mainBlueColor.name),
                                          fontSize: ScreenUtil().setSp(30)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
                  if (!mounted) return;
                  if (flag != null && flag) {
                    final password = controller.text.trim();
                    final password2= controller2.text.trim();
                    if (password.isEmpty) {
                      ToastUtils.show(S.of(context).g_key_21);
                      return;
                    }
                    //if (password.length < AppConfig.walletPasswordLength) {
                    if (!Regular().isPassword(password)) {
                      ToastUtils.show(S.of(context).rest_Choose_password);
                      return;
                    }
                    if (password2.isEmpty) {
                      ToastUtils.show(S.of(context).g_key_21);
                      return;
                    }
                    if (password != password2) {
                      ToastUtils.show(S.of(context).g_key_25);
                      return;
                    }
                    jumpExportKeystoreDescPage(password:password);
                  }
                }
                else{
                  //密码验证：标题更明确，告知用户这是导出操作
                  final controller = TextEditingController();
                  final flag = await tipsDialog4(
                      context,
                      S.of(context).g_key_ex_keystore_pwd_title,
                      controller: controller);
                  if (!mounted) return;
                  if (flag != null && flag) {
                    final password = controller.text.trim();
                    // SECURITY: Never log passwords
                    if (password != widget.walletInfo.password) {
                      ToastUtils.show(S.of(context).g_key_146);
                      return;
                    }
                    jumpExportKeystoreDescPage();
                  }
                  controller.dispose();
                }
              } finally {
                setState(() {
                  load=Load.finish;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(load==Load.loading)
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                    width: ScreenUtil().setWidth(40),
                    child: CircularProgressIndicator(),
                  ),
                  Text(
                    S.of(context).g_key_ex_keystore,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28.0)),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: ScreenUtil().setWidth(40.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(48.0),
            indent: 0,
            endIndent: 0,
          ),
          if(widget.walletInfo.password != "")
            InkWell(
              onTap: ()async{
                // 私钥导出前必须进行密码二次验证，防止他人借用已解锁设备直接复制
                final controller = TextEditingController();
                try {
                  final flag = await tipsDialog4(
                    context,
                    S.of(context).g_key_ex_pk_pwd_title,
                    controller: controller,
                  );
                  if (!mounted) return;
                  if (flag != true) return;
                  final entered = controller.text.trim();
                  if (entered != widget.walletInfo.password) {
                    ToastUtils.show(S.of(context).g_key_146);
                    return;
                  }
                } finally {
                  controller.dispose();
                }
                String pk=await Trustdart().getPrivateKey(mnemonic??"", widget.model.coin['coinType'], coinPath??"");
                if (!mounted) return;
                String pkHex=bytesToHex(base64Decode(pk));
                Clipboard.setData(ClipboardData(text: pkHex));
                ToastUtils.show(S.of(context).copy);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0),),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).g_key_ex_keystore_19,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(28.0)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  //显示切换地址类型
  void showChangeAddress(){
    List<Widget> childs=[];
    Map<String,dynamic> paths=widget.model.coin['path'];
    List<String> keyList=paths.keys.toList();
    for(int i=0;i<keyList.length;i++){
      Color textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
      if(widget.model.addrType==keyList[i]){
        textColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name);
      }
      childs.add(
          InkWell(
            onTap: ()async{
              if(widget.model.addrType==keyList[i]){

              }else{
                widget.model.addrType=keyList[i];
                addrType=keyList[i];
                widget.model.address=null;
                await widget.model.buildWallet();
                if (!mounted) return;
                coinPath=widget.model.coin['path'][widget.model.addrType];
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
              alignment: Alignment.center,
              child: Text(
                keyList[i],
                style: TextStyle(
                  color: textColor,
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              ),
            ),
          )
      );
    }
    sheetBottom(context, "", Column(
      children: childs,
    ));
  }
}
