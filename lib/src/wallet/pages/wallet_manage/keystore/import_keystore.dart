import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/all_chain.dart';
import 'package:n42appv2/src/wallet/widgets/choose_import_coin.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:n42appv2/src/widgets/container_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ImportKeystore extends StatefulWidget {
  const ImportKeystore({super.key});

  @override
  State<ImportKeystore> createState() => _ImportKeystoreState();
}

class _ImportKeystoreState extends State<ImportKeystore> {
  final _keystoreController = TextEditingController();
  final _passwordController = TextEditingController();
  Load load=Load.finish;
  Map<String,dynamic> selectChain=allChainUrlMap[CoinType.N.name];
  @override
  void initState() {
    //_keystoreController.text='{"address":"05f1f4958fa2f6756a2bafa6b9b13410dfa2af64","crypto":{"cipher":"aes-128-ctr","ciphertext":"e833d020795104945eb3f863b59f99817c51b6eeb5ac000dc94be5d460966ded","cipherparams":{"iv":"850425007de4c071e3c429849a4cc425"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"96c24775c553d01e814487b1f64625ad82dcb85e14943bdcc51c44e12bd78136"},"mac":"4c97c8d827de2fd3e8d1c773755a13658160d82ec37dfa584b7acadec6a39403"},"id":"4a8b82c3-f0b0-41e9-9d65-3bc5632d8132","version":3}';
    //_passwordController.text='Devkinglory1';
    super.initState();
  }
  @override
  void dispose() {
    _keystoreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_m22,
        //"Import ${widget.model.coin['miniName']} Wallet",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).g_key_keystore_22,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(32)),
                      ),
                    ),
                    InkWell(
                      onTap: ()async{
                        ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data != null) {
                          if (data.text != null && data.text != "null") {
                            _keystoreController.text = data.text!;
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                        //margin: EdgeInsets.only(left: 10,),
                        height: ScreenUtil().setWidth(60.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0)))
                        ),
                        child: Text(
                          S.of(context).g_key_166,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ),
                    ),
                    /*
                    SizedBox(
                      width: ScreenUtil().setWidth(12),
                    ),
                    /// 对keystore json的说明 什么是keystore？
                    GestureDetector(
                      child: Icon(
                        Icons.device_unknown,
                        size: ScreenUtil().setWidth(32),
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(
                          builder: (_) => BrowserPage(
                              '${AppConfig.apiUrl['walletamazeBrowser']!}/share/help/keystore.html'
                          ),
                        ));
                      },
                    ),*/
                  ]),
                  containerStyle1(
                    context,
                    height: ScreenUtil().setWidth(440),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                    margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(20)),
                    child: CommInput(
                      type: InputFieldType.account,
                      //"Keystore json文件内容"
                      hintText: S.of(context).g_key_ex_keystore_17,
                      controller: _keystoreController,
                      maxLines: 30,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(26),
                      ),
                    ),
                  ),
                  Text(
                    S.of(context).login_password,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  containerStyle1(
                      context,
                    height: ScreenUtil().setWidth(120),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                    margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(20)),
                    child: CommInput(
                      type: InputFieldType.password,
                      hintText: S.of(context).g_key_21,
                      controller: _passwordController,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(26),
                      ),
                    ),
                  ),
                  Text(
                    S.of(context).g_key_17,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  containerStyle1(
                      context,
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                      margin: EdgeInsets.symmetric( vertical: ScreenUtil().setWidth(20)),
                      child: Row(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(60),
                            height: ScreenUtil().setWidth(60),
                            margin: EdgeInsets.only(right:ScreenUtil().setWidth(20)),
                            child: ImageNetWork(imageUrl: selectChain['baseInfo']['icon']),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectChain['baseInfo']['name'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                  ),
                                ),
                                Text(
                                  selectChain['baseInfo']['miniName'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(30),
                            height: ScreenUtil().setWidth(30),
                            margin: EdgeInsets.only(left:ScreenUtil().setWidth(20)),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                              size: ScreenUtil().setWidth(30),
                            ),
                          ),
                        ],
                      ),
                      onTap: ()async{
                        Map<String,dynamic>? rData=await Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseImportCoin(selectChain: selectChain,)));
                        if (!mounted) return;
                        if(rData !=null){
                          setState(() {
                            selectChain=rData;
                          });
                        }
                      }
                  ),
                  SizedBox(height: ScreenUtil().setWidth(148),)
                ],
              ),
            ),),
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
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    height: ScreenUtil().setWidth(148),
                    width: double.infinity,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonStyle6(
                        context,
                            () async {
                          if(load==Load.loading)return;
                          FocusScope.of(context).requestFocus(FocusNode());
                          // 模拟数据
                          //mnemonic : bomb business wage crowd also real pencil excess soldier hurdle media frost
                          //path : m/44'/60'/0'/0/0
                          // String? json = await KeystoreUtils.keystoreJson(
                          //     mnemonic:
                          //         "bomb business wage crowd also real pencil excess soldier hurdle media frost",
                          //     path: "m/44'/60'/0'/0/0",
                          //     password: '123456');
                          //{"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"071d2330c8977fc3dfffcebaa9620e17"},"ciphertext":"f69b9ee76f3dc6f015f12df13325eafbe45bbc0ff76e2b684e9f8627e9cd0444","kdf":"scrypt","kdfparams":{"dklen":32,"n":8192,"r":8,"p":1,"salt":"0a9642f884dddd30dfcafaf0c5043d0e0e103a9fecb2fe19cceca905a74dcab4"},"mac":"8ff47a2bacd7e2b10e5458dbf7589d5b4a10280365e5063a9148b59da4f392a1"},"id":"72676887-78cf-453c-aac9-c46478d5e3c4","version":3}
                          // debugPrint("keystore json $json");
                          // final keystoreJson = json!;
                          // final password = '123456';

                          /// 导入keystore json时 必须已经创建了钱包才可以使用
                          /// 导入keystore json方式创建的钱包，在备份时 只能时 keystore 或者 私钥
                          /// 自己创建的钱包 可以备份助记词

                          // 导入逻辑处理
                          final keystoreJson = _keystoreController.text.trim();
                          //final password = _passwordController.text.trim();

                          if (keystoreJson.isEmpty) {
                            //请输入keystore文件内容
                            ToastUtils.show(S.of(context).g_key_ex_keystore_18);
                            return;
                          }
                          //Map<String,dynamic> ksMap=json.decode(keystoreJson);
                          //String? name=ksMap['name'];
                          createWallet(selectChain, _keystoreController.text, _passwordController.text);
                          //showChooseCoin(name);

                        },
                        S.of(context).g_key_78,
                        AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name),
                        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        load==Load.loading),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  int selectIndex=-1;
  void showChooseCoin(String? chainName){
    Map<String,dynamic> mMap={};
    if(chainName !=null){
      allChainUrlMap.forEach((key,value){
        if(value['baseInfo']['blockchainType'].toString().toUpperCase()==chainName){
          mMap[key]=value;
        }
      });
    }else{
      mMap=allChainUrlMap;
    }
    List<String> keyList=mMap.keys.toList();
    Widget child=ListView.separated(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: mMap.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String,dynamic> cInfo =mMap[keyList[index]];
        return GestureDetector(
          onTap: ()async{
            selectIndex = index;
            createWallet(cInfo, _keystoreController.text, _passwordController.text);
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(56),
                      height: ScreenUtil().setWidth(56),
                      child: ImageNetWork(imageUrl:
                      cInfo['baseInfo']['icon'] ?? "",
                        placeholder: "assets/img/list_default.png",
                      ),
                    ),
                    // NftImageNetWork(imageUrl: path,width: 28,height: 28,),
                    SizedBox(
                      width: ScreenUtil().setWidth(30),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cInfo['baseInfo']['name'] ?? "",
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(32)),
                        ),
                        Text(
                          cInfo['baseInfo']['miniName'] ?? "",
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(32)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    index == selectIndex
                        ? Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(48),
                      color: Color(0xFF448BDF),
                    )
                        : SizedBox(
                      width: ScreenUtil().setWidth(28),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
        );
      },
    );
    sheetBottom(
        context,
        S.of(context).g_key_17,
        SizedBox(
          width: double.infinity,
          height: ScreenUtil().setWidth(1000),
          child: child,
        ));
  }
  Future<void> createWallet(Map<String,dynamic> cInfo,String keystoreJson,String password)async{
    try {
      setState(() {
        load=Load.loading;
      });

      //if(selectIndex ==-1)return;
      Map<dynamic,dynamic> walletInfo=await Trustdart().getWalletInfoWithKeyStore(keystoreJson, cInfo['baseInfo']['coinType']!, password);
      if (!mounted) return;
      if(walletInfo['privateKey']!=""){
        //这里能生成Wallet对象说明是导入成功的success
        //生成本地walletInfo对象 在列表中展示
        Map<String,dynamic> addressMap={};
        if(walletInfo['address']['legacy'] != null){
          addressMap['legacy']=walletInfo['address']['legacy'];
        }
        if(walletInfo['address']['segwit'] != null){
          addressMap['segwit']=walletInfo['address']['segwit'];
        }
        final address = walletInfo['address'][walletInfo['addressType']];
        debugPrint("import wallet address $address");

        String privateKey = walletInfo['privateKey'];
        // SECURITY: Never log private keys
        privateKey=privateKey.replaceAll('\n','');
        //导入类型默认是钱包名字
        final name = cInfo['baseInfo']['coinType'];
        WalletInfo info = WalletInfo(
          walletName: name,
          password: password,
          walletUuid: Provider.of<WalletActionProvider>(context,listen: false).userUUID,
          privateKey: privateKey,
          coinInfo: {selectChain['baseInfo']['mKey']:selectChain},
        );
        // 添加到集合中
        final res = await Provider.of<WalletActionProvider>(context,listen: false)
            .addImportWalletInfo(info);
        if (!mounted) return;
        if (res) {
          //关闭页面
          Navigator.of(context).pop(true);
        } else {
          //failure
          // 已经存在当前货币钱包
          ToastUtils.show(S.of(context).g_key_keystore_19);
        }
      } else {
        //keystore json 格式错误/或者密码错误 解析失败
        ToastUtils.show(S.of(context).g_key_keystore_21);
      }
    } catch (err) {
      // keystore json 格式错误/或者密码错误 解析失败
      debugPrint("import keystore json err: ${err.toString()}");
      ToastUtils.show(err.toString());
    } finally {
      setState(() {
        load=Load.finish;
      });
    }
  }
}
