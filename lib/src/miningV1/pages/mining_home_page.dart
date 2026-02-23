import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/miningV1/api/mining_api.dart';
import 'package:n42_wallet/src/miningV1/pages/mining_index.dart';
import 'package:n42_wallet/src/miningV1/provider/mining_provider.dart';
import 'package:n42_wallet/src/miningV1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/src/miningV1/utils/mining_utils.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/src/widgets/empty.dart';
import 'package:n42_wallet/src/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiningHomePage extends StatefulWidget {
  const MiningHomePage({super.key});

  @override
  State<MiningHomePage> createState() => _MiningHomePageState();
}

class _MiningHomePageState extends State<MiningHomePage> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    super.initState();
    //每次创建完钱包 发送一个监听
    eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.selectWallet) {
        if(event.stringValue=="mainwallet"){
          return;
        }
        if(globalMiningV1.walletIndex!=-1 && event.stringValue=="wallet"){
          return;
        }
        initData(event.intValue??0);
      }
      if (event is EventPublic && event.type == EventPublicType.selectMiningWallet) {
        initData(event.intValue??0);
      }
    });
  }
  initData(int walletIndex)async{
    /// 绑定用户的地址到服务器
    //ExchangeAccountUtils exchangeAccountUtils=ExchangeAccountUtils();
    //exchangeAccountUtils.init();
    AppConfig.isMainChainMining= await SPUtil().getIsMainChainMining()??true;
    await MiningUtils.stopMining();
    MiningApi.cleanToken();
    MiningProvider mp=globalMiningV1;
    mp.resetData();

    await mp.checkAddressMiningStatus(wIndex: walletIndex);
    ///挖矿逻辑初始化
    await MiningUtils.initEvmSdk();
    // 请注意，在安卓上，这并不能保证连接到互联网。例如，该应用程序可能具有wifi访问权限，但它可能是VPN或无法访问的酒店WiFi。
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // debugPrint("connectivityResult ：$connectivityResult");
    // if (connectivityResult == ConnectivityResult.wifi) {

    //   //evm start
    //   MiningUtils.startMining();
    // }
    //MiningType? type = ProviderUtil.miningProvider().miningType;
    MiningUtils.startMining();
    eventBus.fire(EventPublic(EventPublicType.refreshMiningData));
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: buildContentView(context),
    );
  }

  Widget buildContentView(BuildContext context) {
    return ListenableBuilder(
      listenable: globalMiningV1,
      builder: (context, _) {
        final miningModel = globalMiningV1;
        if (miningModel.depositsEnable == null && !miningModel.isLoadingMiningDeposits)
          return Center(
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
              child: EmptyView(
                canRefresh: true,
                onPressed: () async {
                  await miningModel.checkAddressMiningStatus();
                },
              ),
            ),
          );
        if (miningModel.depositsEnable != null) {
          return const MiningIndex();
        }
        return const Loading();
      },
    );
  }
  @override
  bool get wantKeepAlive => true;
}
