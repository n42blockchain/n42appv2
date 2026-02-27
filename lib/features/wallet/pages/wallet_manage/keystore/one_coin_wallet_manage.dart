import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/comm_input.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_3.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:web3dart/web3dart.dart';

part 'one_coin_wallet_manage_widgets.dart';

class OneCoinWalletManage extends ConsumerStatefulWidget {
  final WalletInfo walletInfo;
  final CoinModel model;
  final int walletIndex;
  const OneCoinWalletManage({required this.walletInfo, required this.model,required this.walletIndex,super.key});

  @override
  ConsumerState<OneCoinWalletManage> createState() => _OneCoinWalletManageState();
}

class _OneCoinWalletManageState extends ConsumerState<OneCoinWalletManage> with _OneCoinWalletManageWidgetsMixin {
  @override
  String? mnemonic;
  @override
  String? coinPath;
  @override
  String? addrType;
  @override
  String? pk;
  @override
  int pathIndex=0;
  @override
  List<dynamic> pathList=[0];
  @override
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
  @override
  void addPath(){
    if(pathList.length>=10){
      return;
    }
    pathList.add(pathList[pathList.length-1]+1);
    setState(() {});
  }
  @override
  void removePath(int index){
    pathList.removeAt(index);
    setState(() {});
  }
  @override
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
  @override
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
  //显示切换地址类型
  @override
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
}
