import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/miningV2/pages/keyManagement/mining_output_tip.dart';
import 'package:n42appv2/src/miningV2/pages/share_mining.dart';
import 'package:n42appv2/src/miningV2/widgets/group_confrim.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/miningV2/widgets/n_level_widget.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class MiningFullNodeV2 extends StatefulWidget {
  final int nNum;
  const MiningFullNodeV2({required this.nNum,super.key});

  @override
  State<MiningFullNodeV2> createState() => _MiningFullNodeV2State();
}

class _MiningFullNodeV2State extends State<MiningFullNodeV2> {
  final TokenViewApi _tokenViewApi = TokenViewApi();
  StreamSubscription? _eventSubscription;
  int _payType = 0;
  int _payMethod = 0;

  bool isLoadingAstBalance = false;
  bool isLoadingNftBalance = false;

  double? nBalance;
  //nft50num (拥有多少个50面额的NFT)
  BigInt nft50num = BigInt.zero;

  bool savePrivateKey=false;
  Map<String,dynamic>? encrypteData=null;

  @override
  void initState() {
    super.initState();
    _eventSubscription=eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.miningFullNode) {
        if(mounted){
          Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (_) => ShareMining(
                  fromType: _payType == 0 ? 2 : 3,
                  astValue: widget.nNum,
                )),
          );
        }
      }
    });
    initData();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    await checkNBalance();
  }

  Future<void> checkNBalance() async {
    try {
      if(mounted){
        setState(() {
          isLoadingAstBalance = true;
        });
      }
      
      // Use IWalletService instead of WalletActionProvider
      final walletService = ServiceLocatorSetup.walletService;
      if (walletService == null) return;
      
      final miningIndex = walletService.miningWalletIndex;
      final coinInfo = walletService.getCoinInfoForWallet(miningIndex);
      if (coinInfo == null) return;
      
      final mnemonic = await walletService.getMnemonicForWallet(miningIndex);
      final privateKey = await walletService.getPrivateKeyForWallet(miningIndex);
      
      final astMap = coinInfo[CoinType.N.name];
      if (astMap == null) return;
      
      int pathIndex = astMap['pathIndex'] ?? 0;
      final path = getPathWithIndex(astMap["baseInfo"]["path"]["legacy"], pathIndex);
      
      Trustdart trustdart = Trustdart();
      var addressMap = await trustdart.generateAddress(
          CoinType.N.name, path, 'legacy', mnemonic: mnemonic ?? "", pk: privateKey ?? "");
      final astAddress = addressMap['legacy'];
      
      MessageModel mm = await _tokenViewApi.getBalance(
          BlockchainType.Ethereum.name,
          CoinType.N.name,
          astAddress ?? '',
          isTest: true,
          rpc: 'http://5.161.252.59:8545/'
      );
      if (mm.error) {
      } else {
        nBalance = toEther(mm.data.toString(), 18).toDouble();
        debugPrint("ast mining token : $nBalance");
        if (mounted) {
          setState(() {});
        }
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    } finally {
      if(mounted){
        setState(() {
          isLoadingAstBalance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text:
        "${S.current.g_mining_key_37}:${S.of(context).g_mining_key_62}",
      ),
      body: Consumer<MiningV2Provider>(
        builder: (context, mpValue, child) {
          return SafeArea(
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
                                NLevelWidget(
                                  nNum: widget.nNum,
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
                                if(nBalance != null && nBalance! > widget.nNum)
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                                    margin: EdgeInsets.only(top: ScreenUtil().setWidth(30),),
                                    decoration: BoxDecoration(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text(
                                              //Please save the verifier's public and private key pair first.
                                              S.of(context).g_mining_key_78,
                                              style: TextStyle(
                                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                                                fontSize: ScreenUtil().setSp(32),
                                              ),
                                            ),),
                                            Container(
                                              width: ScreenUtil().setWidth(36),
                                              height: ScreenUtil().setWidth(36),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                savePrivateKey ? const Color(0xff32D74B) : Colors.transparent,
                                                border: Border.all(
                                                  color: savePrivateKey
                                                      ? Colors.transparent
                                                      : AppThemeUtils.getColorByKey(
                                                      context, AppThemeKeys.mainWhiteColor.name),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: savePrivateKey
                                                  ? Icon(
                                                Icons.check,
                                                size: ScreenUtil().setWidth(24),
                                                color: Colors.white,
                                              )
                                                  : null,
                                            ),
                                          ],
                                        ),

                                        Container(
                                          height: ScreenUtil().setWidth(80),
                                          width: double.infinity,
                                          margin: EdgeInsets.only(top: ScreenUtil().setWidth(30),left: ScreenUtil().setWidth(30),right: ScreenUtil().setWidth(30)),
                                          child: ButtonStyle2(context, () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => MiningOutputTip()),
                                            );
                                            // 接收返回的 copyEncrypte 值并更新状态
                                            if (result !=null && mounted) {
                                              setState(() {
                                                savePrivateKey = true;
                                                encrypteData=result;
                                              });
                                            }
                                          },
                                              //"导出"
                                              S.of(context).g_mining_key_79
                                          ),
                                        )
                                      ],
                                    ),
                                  )
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
                        child: ButtonStyle6(context, () async {
                          if(mpValue.depositLoad==Load.loading)return;
                          if (_payType == 0) {
                            if (_payMethod == 0) {
                              if (nBalance == null || nBalance! < widget.nNum) {
                                //如果获取余额失败 再次尝试获取
                                await checkNBalance();
                              }

                              if (nBalance! < widget.nNum) {
                                return;
                              }
                                showGroupConfirmDialog(
                                    context, widget.nNum, '640s', () async {
                                  await handlerData();
                              });
                            }
                          }
                        },
                          S.of(context).g_key_78,
                          AppThemeUtils.getColorByKey(context, mpValue.depositLoad==Load.loading?AppThemeKeys.mainButtonBgColor3.name:AppThemeKeys.mainButtonBgColor.name,),
                          AppThemeUtils.getColorByKey(context, mpValue.depositLoad==Load.loading?AppThemeKeys.mainButtonTextColor3.name:AppThemeKeys.mainButtonTextColor.name),
                          mpValue.depositLoad==Load.loading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayMethods() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPayMethodv2("assets/mining/pay_wallet.png",
            "${S.current.g_mining_key_42}: ${nBalance ?? 0} ${CoinType.N.name}",
            // errTips: "You do not have enough AST for this transaction",
            errTips: S.current.g_mining_key_43,
            isSelected: _payMethod == 0, onTap: () {
              setState(() {
                _payMethod = 0;
              });
            }, isEnough: nBalance != null && nBalance! > widget.nNum),
      ],
    );
  }

  Widget _buildPayMethod(String icon, String payType,
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

  Widget _buildPayMethodv2(String icon, String payType,
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
  Future<void> handlerData() async {
    if(encrypteData==null){
      ToastUtils.show(S.of(context).g_mining_key_78);
      return;
    }
    try {
      MiningV2Provider mp=Provider.of<MiningV2Provider>(AppGlobals.appContext,listen: false);
      mp.createDepositUnsignedTx(widget.nNum, encrypteData!);
    } catch (err) {
      //RPCError: got code 3 with msg "execution reverted: 10 AST Deposit Limit has been reached".
      debugPrint("质押失败：${err.toString()}");
      if (err.toString().contains(S.of(context).g_mining_key_80)) {
        ToastUtils.show(S.of(context).g_mining_key_80);
      }
    }
  }
}
