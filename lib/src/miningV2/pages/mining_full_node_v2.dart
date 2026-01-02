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
                                // 支付方式标题
                                _buildSectionTitle(context, S.current.g_mining_key_38),
                                SizedBox(height: ScreenUtil().setWidth(20)),
                                // 支付方式选择
                                _buildPayMethod("assets/mining/pay_ast.png", S.of(context).g_mining_key_40,
                                    isSelected: _payType == 0, onTap: () {
                                      setState(() {
                                        _payType = 0;
                                      });
                                    }),
                                SizedBox(height: ScreenUtil().setWidth(20)),
                                // 提示文字
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(20),
                                    vertical: ScreenUtil().setWidth(16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                                    border: Border.all(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: ScreenUtil().setWidth(32),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      ),
                                      SizedBox(width: ScreenUtil().setWidth(12)),
                                      Expanded(
                                        child: Text(
                                          S.of(context).g_mining_key46,
                                          style: TextStyle(
                                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                            fontSize: ScreenUtil().setSp(24),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: ScreenUtil().setWidth(50)),
                                // 支付方式标题
                                _buildSectionTitle(context, S.current.g_mining_key_39),
                                SizedBox(height: ScreenUtil().setWidth(20)),
                                _buildPayMethods(),
                                if(nBalance != null && nBalance! > widget.nNum)
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: ScreenUtil().setWidth(44),
                                                height: ScreenUtil().setWidth(44),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                                                ),
                                                child: Icon(
                                                  Icons.vpn_key_outlined,
                                                  color: Colors.white,
                                                  size: ScreenUtil().setWidth(24),
                                                ),
                                              ),
                                              SizedBox(width: ScreenUtil().setWidth(16)),
                                              Expanded(
                                                child: Text(
                                                  S.of(context).g_mining_key_78,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ScreenUtil().setSp(28),
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: ScreenUtil().setWidth(12)),
                                              Container(
                                                width: ScreenUtil().setWidth(36),
                                                height: ScreenUtil().setWidth(36),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: savePrivateKey ? Colors.white : Colors.transparent,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: savePrivateKey
                                                    ? Icon(
                                                        Icons.check,
                                                        size: ScreenUtil().setWidth(22),
                                                        color: const Color(0xFFFF6B35),
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.fromLTRB(
                                            ScreenUtil().setWidth(24),
                                            0,
                                            ScreenUtil().setWidth(24),
                                            ScreenUtil().setWidth(24),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => MiningOutputTip()),
                                              );
                                              if (result != null && mounted) {
                                                setState(() {
                                                  savePrivateKey = true;
                                                  encrypteData = result;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFFFF6B35),
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                                              ),
                                            ),
                                            child: Text(
                                              S.of(context).g_mining_key_79,
                                              style: TextStyle(
                                                fontSize: ScreenUtil().setSp(28),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(6),
          height: ScreenUtil().setWidth(28),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3)),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Text(
          title,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPayMethods() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnough = nBalance != null && nBalance! > widget.nNum;
    
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.06) 
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPayMethodv2(
            "assets/mining/pay_wallet.png",
            "${S.current.g_mining_key_42}: ${nBalance ?? 0} ${CoinType.N.name}",
            errTips: S.current.g_mining_key_43,
            isSelected: _payMethod == 0,
            onTap: () {
              setState(() {
                _payMethod = 0;
              });
            },
            isEnough: isEnough,
          ),
        ],
      ),
    );
  }

  Widget _buildPayMethod(String icon, String payType,
      {bool isSelected = false, GestureTapCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected 
                ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(60),
              height: ScreenUtil().setWidth(60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9A9E).withOpacity(0.3),
                    const Color(0xFFFECFEF).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: ScreenUtil().setWidth(36),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            Expanded(
              child: Text(
                payType,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xff32D74B) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(22),
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
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: ScreenUtil().setWidth(28),
                  fit: BoxFit.contain,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    payType,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isEnough)
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setWidth(6)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: ScreenUtil().setWidth(20),
                            color: const Color(0xFFEB5851),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(6)),
                          Flexible(
                            child: Text(
                              errTips ?? '',
                              style: TextStyle(
                                color: const Color(0xFFEB5851),
                                fontSize: ScreenUtil().setSp(22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xff32D74B) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(22),
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
      //RPCError: got code 3 with msg "execution reverted: 10 N Deposit Limit has been reached".
      debugPrint("质押失败：${err.toString()}");
      if (err.toString().contains(S.of(context).g_mining_key_80)) {
        ToastUtils.show(S.of(context).g_mining_key_80);
      }
    }
  }
}
