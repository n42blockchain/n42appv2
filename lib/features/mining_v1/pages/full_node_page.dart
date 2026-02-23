import 'dart:convert';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/pages/share_mining.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/ast_level.dart';
import 'package:n42_wallet/features/mining_v1/widgets/group_confrim.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
//import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
// import removed: use web3dart/web3dart.dart instead
import 'package:web3dart/web3dart.dart';

class FullNodePage extends StatefulWidget {
  final int astNum;
  const FullNodePage({required this.astNum,super.key});

  @override
  State<FullNodePage> createState() => _FullNodePageState();
}

class _FullNodePageState extends State<FullNodePage> {
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils= DataUtils();
    }
    return _dataUtils!;
  }
  Load load=Load.finish;
  int _payType = 0;
  int _payMethod = 0;

  bool isLoadingAstBalance = false;
  bool isLoadingNftBalance = false;

  double? astBalance;
  String? astAddress;

  //nft50num (拥有多少个50面额的NFT)
  BigInt nft50num = BigInt.zero;
  BigInt nft100num = BigInt.zero;
  BigInt nft500num = BigInt.zero;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initData() async {
    checkAstBalance();
  }

  checkAstBalance() async {
    try {
      setState(() {
        isLoadingAstBalance = true;
      });
      WalletActionProvider wap=globalWapAdapter;
      MiningProvider mp=globalMiningV1;
      //获取ast的 private key
      WalletInfo walletInfo=wap.walletInfoLsit[mp.walletIndex];
      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path =
      getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      Trustdart trustdart=Trustdart();
      var addressMap=await trustdart.generateAddress(
        CoinType.N.name, path, 'legacy',mnemonic: walletInfo.mnemonic??"",pk: walletInfo.privateKey??"");
      final astAddress = addressMap['legacy'];
      final isMainChainMining = await MiningUtils.isMainChainMining();
      TokenViewApi tokenViewApi=TokenViewApi();
      MessageModel? mm = await tokenViewApi.getBalance(
        BlockchainType.Ethereum.name,
        CoinType.N.name,
        astAddress ?? '',
        isTest: !isMainChainMining,
      );
      if (mm == null || mm.error) {
      } else {
        astBalance = toEther(mm.data.toString(), 18).toDouble();
        debugPrint("ast mining token : $astBalance");
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    } finally {
      setState(() {
        isLoadingAstBalance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:
        "${S.current.g_mining_key_37}:${widget.astNum == 50 ?
        S.of(context).g_mining_key_62 :
        widget.astNum == 100 ?
        S.of(context).g_mining_key_61 :
        S.of(context).g_mining_key_63}",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                child: Column(
                  children: [
                    Expanded(
                        child: ListView(
                          children: [
                            AstLevel(
                              astNum: widget.astNum,
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(90),
                            ),
                            Row(
                              children: [
                                Text(
                                  // "Select the payment method",
                                  S.current.g_mining_key_38,
                                  style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.mainTextColor.name),
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(30),
                            ),
                            _buildPayMethod("assets/mining/pay_ast.png", S.of(context).g_mining_key_40,
                                isSelected: _payType == 0, onTap: () {
                                  setState(() {
                                    _payType = 0;
                                  });
                                }),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Divider(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Text(
                              S.of(context).g_mining_key46,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                  fontSize: ScreenUtil().setSp(26)),
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(90),
                            ),
                            Row(
                              children: [
                                Text(
                                  // "Payment Methods",
                                  S.current.g_mining_key_39,
                                  style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.mainTextColor.name),
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            _buildPayMethods(),
                          ],
                        )),
                    SizedBox(height: ScreenUtil().setWidth(148),),
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
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all( ScreenUtil().setWidth(30)),
                    child: buttonStyle6(context, () async {
                      if(load==Load.loading)return;
                      if (_payType == 0) {
                        if (_payMethod == 0) {
                          if (astBalance == null || astBalance! < 50) {
                            //如果获取余额失败 再次尝试获取
                            await checkAstBalance();
                          }
                          if (astBalance == null || astBalance! < 50) {
                            //如果获取余额失败 再次尝试获取
                            return;
                          }

                          if (astBalance! < widget.astNum) {
                            return;
                          }

                          //计算解锁时间
                          int currTime = DateTime.now().millisecondsSinceEpoch;
                          int yearTime = 365 * 24 * 60 * 60 * 1000;
                          int totalTime = currTime + yearTime;
                          String lockTime = dataUtils.getTimeByTimeStamp(
                              "$totalTime",
                              format: "dd/MM/yyyy");
                          showGroupConfirmDialog(
                              this.context, widget.astNum, lockTime, () async {
                            handlerData();
                          });
                        }
                        else if (_payMethod == 1) {
                          // buy ast
                        }
                        else if (_payMethod == 2) {
                          // usdt to ast
                          WalletActionProvider wap=globalWapAdapter;
                          MiningProvider mp=globalMiningV1;
                          //获取ast的 private key
                          WalletInfo walletInfo=wap.walletInfoLsit[mp.walletIndex];
                          if(walletInfo.password==""){
                            final flag= await tipsDialog7(context);
                            if (flag != null && flag) {
                              await Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(
                                    name: 'BackupOne',
                                  ),
                                  builder: (context)=>BackupOne(walletInfo,mp.walletIndex)));
                            }
                          }
                          else{
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SwapAstHome(
                                  getAstNum: widget.astNum.toDouble(),
                                )));
                          }
                        }
                      } else {

                      }
                    },
                        S.of(context).g_key_78,
                      AppThemeUtils.getColorByKey(context, load==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name,),
                      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      load==Load.loading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildPayMethods() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPayMethodv2("assets/mining/pay_wallet.png",
            "${S.current.g_mining_key_42}: ${astBalance ?? 0} ${CoinType.N.name}",
            // errTips: "You do not have enough AST for this transaction",
            errTips: S.current.g_mining_key_43,
            isSelected: _payMethod == 0, onTap: () {
              setState(() {
                _payMethod = 0;
              });
            }, isEnough: astBalance != null && astBalance! > widget.astNum),

        /*if(Platform.isAndroid)
          _buildPayMethodv2(
            "assets/mining/swap_ast.png",
            // "Deposit USDT to convert to AST",
            S.current.g_mining_key_44,
            isSelected: _payMethod == 2,
            onTap: () {
              setState(() {
                _payMethod = 2;
              });
            },
          ),*/
      ],
    );
  }

  _buildPayMethod(String icon, String payType,
      {bool isSelected = false, GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(24)),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: ScreenUtil().setWidth(68),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: ScreenUtil().setWidth(26),
            ),
            Expanded(
              child: Text(
                payType,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30)),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                isSelected ? const Color(0xff32D74B) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  width: 1.0,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: ScreenUtil().setWidth(24),
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  _buildPayMethodv2(String icon, String payType,
      {bool isSelected = false,
        GestureTapCallback? onTap,
        String? errTips,
        bool isEnough = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(24)),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: ScreenUtil().setWidth(44),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: ScreenUtil().setWidth(26),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      payType,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30)),
                    ),
                    if (!isEnough)
                      Text(
                        errTips ?? '',
                        style:
                        TextStyle(color: Color(0xffEB5851), fontSize: ScreenUtil().setSp(20)),
                      ),
                  ],
                )),
            Container(
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                isSelected ? const Color(0xff32D74B) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  width: 1.0,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: ScreenUtil().setWidth(24),
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  //开始质押
  handlerData() async {
    try {
      ///设置质押数量
      WalletActionProvider wap=globalWapAdapter;
      MiningProvider mp=globalMiningV1;
      //获取ast的 private key
      WalletInfo walletInfo=wap.walletInfoLsit[mp.walletIndex];
      final Map<String, dynamic>? map = walletInfo.coinInfo;
      final astMap = map?[CoinType.N.name];
      if (astMap != null) {
        int pathIndex = astMap['pathIndex'] ?? 0;
        final path =
        getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
        String? privateKey=walletInfo.privateKey;
        if(walletInfo.privateKey ==null){
          privateKey=await Trustdart().getPrivateKey(walletInfo.mnemonic!, CoinType.N.name, path);
        }
        final pk = base64Decode(privateKey!);

        //1、调用evmSdk sign
        BigInt an = ethToWeiString('${widget.astNum}', 18);
        final res = await MiningPluginUtils.blsSign(bytesToHex(pk,padToEvenLength: true),dataUtils.bigIntToHex(an,need0x: false,padToEvenLength: true));
            //_hexUtils.uint8ToHex(pk), _hexUtils.bigIntToHex(an));

        if (res == null || res["data"] == null) {
          return;
        }

        //2、调用质押合约
        //2.1 bls 公钥
        final blsMap =
        await MiningPluginUtils.getPubKey(
          bytesToHex(pk,padToEvenLength: true)
            //_hexUtils.uint8ToHex(pk)
        );
        //2.2 质押rpc
        try {
          setState(() {
            load=Load.loading;
          });
          final data = await MiningApi.deposit(
              blsMap?["data"], res["data"], BigInt.from(widget.astNum));
          if (data != null) {
            // 返回交易hash：tx:0x80e92d4a89dba6af4774408c73437ac6bce4d6c578f348017553462e11f0f958
            // success
            SPUtil().setMiningOpen(true);

            //埋点：用户成功加入或创建组节点，或确认全节点权益并开始挖掘。
            //AmplitudeUtils.miningSetupSucceeded(getMiningLevelType());

            /// 根据交易hash 获取是否上链
            await waitChainData(data);
          }
        } catch (err) {
          //RPCError: got code 3 with msg "execution reverted: 10 AST Deposit Limit has been reached".
          debugPrint("质押失败：${err.toString()}");
          if (err.toString().contains('insufficient funds for transfer')) {
            ToastUtils.show("insufficient funds for transfer");
          }
        } finally {
          setState(() {
            load=Load.finish;
          });
        }
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future checkChainData(String txHash) async {
    final chainData = await MiningApi.getTransactionReceipt(txHash);
    if (chainData != null) {
      return true;
    }
    return false;
  }

  Future waitChainData(String txHash) async {
    try {
      await Future.delayed(const Duration(seconds: 2), () async {
        final chainData = await MiningApi.getTransactionReceipt(txHash);
        if (chainData != null) {
          globalMiningV1.setDepositsEnable(true);
          //开启挖矿
          debugPrint("----->>>>>>  EVM插件 开启挖矿 <<<<<<-----");
          MiningPluginUtils.start();
          // ignore: use_build_context_synchronously
          // Navigator.of(context).pop();
          Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => ShareMining(
                  fromType: _payType == 0 ? 2 : 3,
                  astValue: widget.astNum,
                )),
          );
          return;
        } else {
          await waitChainData(txHash);
        }
      });
    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }
}
