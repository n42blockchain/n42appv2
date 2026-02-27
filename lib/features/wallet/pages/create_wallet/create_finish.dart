import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_gen_success.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'create_finish_content.dart';

class CreateFinish extends ConsumerStatefulWidget {
  final WalletInfo? wInfo;
  final String createMetod;//Create,Import,PrivateKey
  const CreateFinish({this.wInfo,this.createMetod="Create",super.key});

  @override
  ConsumerState<CreateFinish> createState() => _CreateFinishState();
}

class _CreateFinishState extends ConsumerState<CreateFinish> with _CreateFinishContentMixin {
  @override
  Load load=Load.loading;
  @override
  bool exportKeystore=false;
  //bool isSelectedUserProtocol = false;
  @override
  String pageName="/CreateOne";
  WalletInfo? _wInfo;

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
  Future<void> createWallet()async{
    _wInfo=widget.wInfo;
    final walletActionProvider =ref.read(wapBridgeProvider);
    if(_wInfo==null){
      _wInfo=WalletInfo(
        walletName: "",
        password: "",
        walletUuid: walletActionProvider.userUUID,
      );
      _wInfo!.mnemonic= await Trustdart().generateMnemonic();
    }
    //String walletName="Account${walletActionProvider.walletMap.length}";
    if(_wInfo!.walletName==""){
      _wInfo!.walletName="Account${walletActionProvider.walletInfoLsit.length+1}";
    }
    if(_wInfo!.coinInfo==null){
      _wInfo!.coinInfo = chainUrlMap;
    }
    //根据导入时间设置时间戳 标记钱包的唯一标识
    _wInfo!.timestamp = "${DateTime.now().millisecondsSinceEpoch}";

    ///生成钱包
    int code = -1;
    try {
      setState(() {
        load=Load.loading;
      });
      //await Future.delayed(const Duration(microseconds: 600), () {});
      if(widget.createMetod=="Import"){
        code = await walletActionProvider.checkWalletMnemonic(_wInfo!);
      }else{
        code=0;
      }

      if (code == 0) {
        //本地安全存储助记词
        //await info.saveMnemonicToStorage();

        ///更新一下provider中的数据
        await walletActionProvider.addWalletInfo(_wInfo!);
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
    super.initState();
    _wInfo = _wInfo;
    if(widget.createMetod=="Import"){
      pageName="/ImportOne";
    }else if(widget.createMetod=="PrivateKey"){
      pageName="/ImportPrivatekey";
    }
    createWallet();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        actions: [
          SizedBox(width: ScreenUtil().setWidth(130.0),),
        ],
        leadingWidth: ScreenUtil().setWidth(130.0),
        leading: SizedBox(),
        title: _buildProgressIndicator(),
      ),
      body: SafeArea(
        child: exportKeystore?
        _buildExportKeystoreContent():
        _buildMainContent(),
      ),
    ));
  }
}
