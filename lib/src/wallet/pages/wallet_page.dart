import 'dart:async';
import 'dart:math';

import 'package:n42appv2/core/token_discovery/discovered_token.dart';
import 'package:n42appv2/core/token_discovery/token_discovery_service.dart';
import 'package:n42appv2/src/wallet/pages/token_discovery/token_discovery_page.dart';
import 'package:n42appv2/core/utils/responsive_utils.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/pay/moonpay/moonpay.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_chain_add.dart';
import 'package:n42appv2/src/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42appv2/src/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42appv2/src/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/payment_page.dart';
import 'package:n42appv2/src/wallet/pages/payment_code/set_amount.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_chain_info.dart';
import 'package:n42appv2/src/wallet/pages/wallet_chain_info_xrp.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42appv2/src/wallet/pages/manage_chains_page.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/widgets/create_wallet_button.dart';
import 'package:n42appv2/src/wallet/widgets/feature_entry_cards.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_board.dart';
import 'package:n42appv2/src/wallet/widgets/wallet_search_coin.dart';
import 'package:n42appv2/src/wallet/pages/ens/ens_home_page.dart';
import 'package:n42appv2/src/wallet/pages/portfolio/portfolio_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_home_page.dart';
import 'package:n42appv2/src/wallet/services/ens_service.dart';
import 'package:n42appv2/src/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42appv2/src/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  Regular? _regular;
  Regular get regular{
    _regular ??= Regular();
    return _regular!;
  }
  final oCcy = NumberFormat("#,##0.0#", "en_US");
  late ScrollController _scrollController;
  bool showAddTokenButton = false; //显示底部添加代币按钮
  /// 小额资产过滤阈值：0=关闭，1/5/10/50 表示过滤低于该 USD 价值的代币
  double _smallAssetsThreshold = 0.0;
  static const List<double> _thresholdCycle = [0.0, 1.0, 5.0, 10.0, 50.0];

  // ── Token auto-discovery ──────────────────────────────────────────────────
  /// Tokens found on-chain but not yet in the wallet.
  List<DiscoveredToken> _discoveredTokens = [];
  /// Prevents re-scanning on every rebuild; reset when wallet changes.
  bool _discoveryScanned = false;

  /// 价格自动刷新定时器（每 60 秒）
  Timer? _priceRefreshTimer;

  // ENS 状态
  String? _ensName;
  String? _lastCheckedAddress;

  void setShowAddTokenButton(bool value) {
    if (showAddTokenButton == value) return;
    setState(() {
      showAddTokenButton = value;
    });
  }

  /// 加载 ENS 反向解析信息
  Future<void> _loadEnsInfo(String ethAddress) async {
    if (ethAddress.isEmpty || ethAddress == _lastCheckedAddress) return;
    _lastCheckedAddress = ethAddress;

    try {
      final ensService = EnsService();
      final ensName = await ensService.resolveAddress(ethAddress);
      if (mounted && ensName != null && ensName.isNotEmpty) {
        setState(() {
          _ensName = ensName;
        });
      }
    } catch (e) {
      debugPrint('ENS reverse resolve error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
    _scrollController = ScrollController()
      ..addListener(() {
        var maxScroll = _scrollController.position.maxScrollExtent;
        var pixel = _scrollController.position.pixels;
        if (maxScroll - pixel < 50) {
          setShowAddTokenButton(true);
        } else {
          setShowAddTokenButton(false);
        }
      });
    // 恢复小额资产过滤阈值偏好（兼容旧版 bool 格式）
    SPUtil().getSmallAssetsThreshold().then((v) {
      if (mounted) setState(() => _smallAssetsThreshold = v);
    });
    // 首次 build 完成后启动价格自动刷新 Timer（60s 间隔）
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPriceTimer());
  }

  // ── Token discovery ────────────────────────────────────────────────────────

  /// Called from build() the first time the wallet is fully loaded.
  /// Runs entirely in the background; never blocks the UI.
  Future<void> _runTokenDiscovery(WalletActionProvider wap) async {
    if (_discoveryScanned) return;
    _discoveryScanned = true;

    try {
      // 1. Collect already-known contracts (lower-cased).
      final knownContracts = <String>{};
      for (final chainType in wap.walletMap.keys) {
        final chainData = wap.walletMap[chainType];
        final mainnets = chainData['mainnets'] as Map<dynamic, dynamic>? ?? {};
        for (final tokenData in mainnets.values) {
          if (tokenData is Map) {
            final contract =
                (tokenData['contract'] as String?)?.toLowerCase() ?? '';
            if (contract.isNotEmpty) knownContracts.add(contract);
          }
        }
      }

      // 2. Load ignored contracts from persistent storage.
      final ignoredContracts = await SPUtil().getIgnoredTokenContracts();

      // 3. Build address map: coinType → wallet address (main chains only).
      final addressByChain = <String, String?>{};
      for (final cm in wap.coinModels) {
        final coinType = cm.coin['coinType'] as String? ?? '';
        final address = cm.address?.toString() ?? '';
        if (coinType.isNotEmpty && address.isNotEmpty) {
          addressByChain.putIfAbsent(coinType, () => address);
        }
      }

      // 4. Scan.
      final discovered = await TokenDiscoveryService.scanAll(
        addressByChain: addressByChain,
        knownContracts: knownContracts,
        ignoredContracts: ignoredContracts,
      );

      if (!mounted) return;
      if (discovered.isNotEmpty) {
        setState(() => _discoveredTokens = discovered);
      }
    } catch (e) {
      // Discovery is best-effort; never surface errors to the user.
      debugPrint('[WalletPage] Token discovery error: $e');
    }
  }

  void _startPriceTimer() {
    _priceRefreshTimer?.cancel();
    _priceRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      // refresh: false → 保留 loading 状态，静默后台更新
      ref.read(wapBridgeProvider).refreshWalletCoinInfo(refresh: false);
    });
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> walletConnect() async {
    WalletConnectProvider walletConnectProvider=ref.read(wcpBridgeProvider);
    // Ensure SDK is initialized before checking sessions
    await walletConnectProvider.connectInit();

    // If there are active sessions, show the session list page
    final activeSessions = walletConnectProvider.getActiveSessions();
    if (activeSessions.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WcSessionListPage()),
      );
      if (!mounted) return;
      walletConnectProvider.refresh();
      return;
    }

    // No active sessions — scan for a new connection
    if (walletConnectProvider.walletConnectState ==
        WalletConnectState.disconnect ||
        walletConnectProvider.walletConnectState ==
            WalletConnectState.loading ||
        walletConnectProvider.walletConnectState ==
            WalletConnectState.connectOK) {
      String scanStr = await scan();
      if (!mounted) return;
      if (scanStr.contains('relay-protocol') && scanStr.contains('symKey')) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletConnectPage(scanStr)));
        if (!mounted) return;
        walletConnectProvider.refresh();
      } else {
        if (scanStr != ""){
          int index=scanStr.indexOf(AppConfig.apiUrl['walletamazeBrowser']);
          if(index !=-1){
            Uri uri=Uri.parse(scanStr);
            final Map<String, dynamic> params = uri.queryParameters;
            if (params['type'] !=null) {
              if(params["type"]=="payment"){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentPage(params["amount"],params["user"],params["coinType"],params["address"])));
              }
              return;
            }
          }
        }
      }
    } else {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => WalletConnectPage("")));
      if (!mounted) return;
      walletConnectProvider.refresh();
    }
  }
  //扫码
  Future<String> scan() async {
    String? scanValue = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScanPage()));
    if (scanValue != null) {
      return scanValue;
    } else {
      return "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: Builder(builder: (context) {
            final waValue = ref.watch(wapBridgeProvider);
              if(waValue.walletIndex==-1) {
                return Loading();
              }
              if(waValue.buildwallet) {
                return Loading();
              }
              // Trigger token discovery once after the wallet is ready.
              if (!_discoveryScanned) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _runTokenDiscovery(waValue),
                );
              }
              return Stack(
              children: [
                /*Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: ScreenUtil().setWidth(630.0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.backGroundColor2.name),
                    height: double.infinity,
                    child: Image.asset(
                      'assets/wallet/wallet_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),*/
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        AppHomeTopBar(
                          //title: S.of(context).g_key_6,
                          titleChild: InkWell(
                            onTap: (){
                              showChangeAddress();
                            },
                            child: SizedBox(
                              height: ScreenUtil().setWidth(60),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    waValue.walletName,
                                    style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      fontSize: ScreenUtil().setSp(30),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(40),
                                    width: ScreenUtil().setWidth(40),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      size: ScreenUtil().setWidth(40),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onLeftImageClick: () {
                            Scaffold.of(this.context).openDrawer();
                          },
                          onLeftImageUri: "assets/img/menu.png",
                          actions: [
                            // QR Code 图标 - 扫描和显示二维码
                            PopupMenuButton<int>(
                              icon: Icon(
                                Icons.qr_code_rounded,
                                size: ScreenUtil().setWidth(52.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.mainBlueColor.name),
                              ),
                              offset: Offset(0, ScreenUtil().setWidth(80)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                              ),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                              onSelected: (value) async {
                                if (value == 0) {
                                  // 扫描二维码
                                  walletConnect();
                                } else if (value == 1) {
                                  // 显示我的二维码（接收）
                                  showSearchCoin(1);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        size: ScreenUtil().setWidth(40),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      ),
                                      SizedBox(width: ScreenUtil().setWidth(20)),
                                      Text(
                                        S.of(context).g_key_4,  // Scan QR code
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code,
                                        size: ScreenUtil().setWidth(40),
                                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                      ),
                                      SizedBox(width: ScreenUtil().setWidth(20)),
                                      Text(
                                        S.of(context).g_key_33,  // Receive
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                          fontSize: ScreenUtil().setSp(28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Builder(builder: (context) {
                              final wc = ref.watch(wcpBridgeProvider);
                              final sessionCount = wc.getActiveSessions().length;
                              return InkWell(
                                onTap: () {
                                  walletConnect();
                                },
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(60.0),
                                  height: ScreenUtil().setWidth(60.0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: (wc.walletConnectState !=
                                                WalletConnectState.disconnect &&
                                            wc.dAppTopic != null &&
                                            wc.metadata != null)
                                            ? ImageNetWork(
                                                imageUrl: (wc.metadata?.icons.isEmpty ?? true)
                                                    ? ""
                                                    : wc.metadata!.icons[0],
                                                placeholder: "assets/img/list_default.png",
                                              )
                                            : Image.asset(
                                                "assets/wallet/WalletConnect.png",
                                                color: AppThemeUtils.getColorByKey(
                                                    context,
                                                    AppThemeKeys.mainBlueColor.name),
                                              ),
                                      ),
                                      if (sessionCount > 0)
                                        Positioned(
                                          right: -ScreenUtil().setWidth(8),
                                          top: -ScreenUtil().setWidth(8),
                                          child: Container(
                                            padding: EdgeInsets.all(ScreenUtil().setWidth(6)),
                                            decoration: BoxDecoration(
                                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: ScreenUtil().setWidth(28),
                                              minHeight: ScreenUtil().setWidth(28),
                                            ),
                                            child: Text(
                                              '$sessionCount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScreenUtil().setSp(18),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => FaceUserNotice()));
                              },
                              child: Container(
                                width: ScreenUtil().setWidth(40.0),
                                height: ScreenUtil().setWidth(40.0),
                                margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
                                //padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
                                child: Image.asset(
                                  "assets/face/portrait.png",
                                  color: AppThemeUtils.getColorByKey(
                                      context,
                                      AppThemeKeys.mainBlueColor.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ///下拉刷新操作
                              if (waValue.load == Load.refresh ||
                                  waValue.load == Load.loading) {
                                return;
                              }
                              await waValue.refreshWalletCoinInfo();
                            },
                            backgroundColor: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainButtonBgColor.name),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainButtonTextColor.name),
                            displacement: 72,
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: false,
                              primary: false,
                              slivers: <Widget>[
                                //钱包看板
                                SliverToBoxAdapter(
                                  // margin: const EdgeInsets.symmetric(
                                  //   horizontal: 30,
                                  //   vertical: 30,
                                  // ),
                                  child: WalletBoard(
                                      accountPrice: waValue.balanceTotal,
                                      usdToCnyRate: waValue.usdToCnyRate,
                                      priceLastUpdated: waValue.priceLastUpdated,
                                      walletName: waValue.walletName,
                                      sendTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await tipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          showSearchCoin(0);
                                        }
                                      },
                                      receiveTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await tipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          showSearchCoin(1);
                                        }
                                      },
                                      swapTap: () async{
                                        if(waValue.walletInfo.password==""){
                                          final flag= await tipsDialog7(this.context);
                                          if (!mounted) return;
                                          if (flag != null && flag) {
                                            Navigator.push(this.context, MaterialPageRoute(
                                                settings: RouteSettings(
                                                  name: 'BackupOne',
                                                ),
                                                builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                                          }
                                        }
                                        else{
                                          sheetBottom(
                                            context,
                                            'Select Swap Mode',
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.currency_exchange),
                                                  title: const Text('Buy N'),
                                                  subtitle: const Text('Purchase N via AST protocol'),
                                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) => SwapAstHome()));
                                                  },
                                                ),
                                                const Divider(height: 1),
                                                ListTile(
                                                  leading: const Icon(Icons.swap_horiz),
                                                  title: const Text('DEX Swap'),
                                                  subtitle: const Text('Swap any token via Uniswap / 1inch / Jupiter'),
                                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DexSwapHome()));
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      paymentCodeTap: () async{
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SetAmount()));
                                      },
                                      buyTap:()async{
                                        Navigator.push(context, MaterialPageRoute(builder: (content)=>Moonpay(type:0)));
                                      },
                                      sellTap:()async{
                                        Navigator.push(context, MaterialPageRoute(builder: (content)=>Moonpay(type:1)));
                                      },
                                    ),
                                ),
                                // Feature Entry Section (ENS & AA)
                                SliverToBoxAdapter(
                                  child: Builder(
                                    builder: (context) {
                                      // 获取 ETH 地址并加载 ENS 信息
                                      final ethAddress = waValue.getAddress(CoinType.ETH.name) ?? '';
                                      if (ethAddress.isNotEmpty) {
                                        _loadEnsInfo(ethAddress);
                                      }

                                      // 获取 AA 账户状态
                                      final hasAA = waValue.walletInfo.hasAAAccounts;
                                      final primaryAccount = waValue.walletInfo.getPrimarySmartAccount(1); // Ethereum mainnet
                                      final isDeployed = primaryAccount?.isDeployed ?? false;

                                      return FeatureEntryHorizontal(
                                        ensName: _ensName,
                                        hasSmartAccount: hasAA,
                                        isSmartAccountDeployed: isDeployed,
                                        onEnsTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => EnsHomePage(walletAddress: ethAddress),
                                          ));
                                        },
                                        onSmartAccountTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => AAHomePage(
                                              walletAddress: ethAddress,
                                              accountInfo: waValue.walletInfo.aaAccountInfo,
                                            ),
                                          ));
                                        },
                                      );
                                    },
                                  ),
                                ),
                                coinListHeaderWidget(waValue),
                                coinListWidget(waValue),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: ScreenUtil().setWidth(300.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
                Positioned(
                  bottom: ScreenUtil().setWidth(180.0),
                  left: 0,
                  right: 0,
                  height: ScreenUtil().setWidth(70.0),
                  child: Visibility(
                    visible: showAddTokenButton,
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          showAddToken();
                        },
                        child: addIcon(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: ScreenUtil().setWidth(120.0),
                  left: ScreenUtil().setWidth(30.0),
                  right: ScreenUtil().setWidth(30.0),
                  child: Visibility(
                    visible: waValue.walletInfo.password=="",
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20.0),
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.of(context).g_key_wallet_c35,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                                fontSize: ScreenUtil().setSp(28),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(
                                    name: 'BackupOne',
                                  ),
                                  builder: (context)=>BackupOne(waValue.walletInfo,waValue.walletIndex)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical:  ScreenUtil().setWidth(20)),
                              child: Text(
                                S.of(context).g_key_wallet_c36,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
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
                ),


              ],
            );
            }),
        ),
      ),
    );
  }

  Widget addIcon() {
    return Container(
        //margin: const EdgeInsets.only(left: 5),
        width: ScreenUtil().setWidth(50.0),
        height: ScreenUtil().setWidth(50.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(50.0))),
            border: Border.all(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name))),
        alignment: Alignment.center,
        child: Center(
          child: Icon(
            Icons.add,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            size: ScreenUtil().setWidth(38.0),
          ),
        ));
  }

  Widget coinListHeaderWidget(WalletActionProvider waValue) {
    String networkStr = S.of(context).g_token_m_key_4;
    if (waValue.walletInfo.networkIndex != -1) {
      networkStr = waValue.coinModels[waValue.walletInfo.networkIndex].coin['name'] ?? "";
    }
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: ScreenUtil().setWidth(165.0),
        maxHeight: ScreenUtil().setWidth(165.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(24),
            vertical: ScreenUtil().setWidth(18),
          ),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(ScreenUtil().setWidth(28)),
              topLeft: Radius.circular(ScreenUtil().setWidth(28)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.03),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 顶部行：Tokens标题 + 添加按钮 + 网络选择
              Row(
                children: [
                  Text(
                    S.of(context).g_token_m_key_11,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  // 添加代币按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showAddToken(),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                      child: Container(
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setWidth(36),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(22),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 投资组合分析入口
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PortfolioPage())),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10),
                          vertical: ScreenUtil().setWidth(6),
                        ),
                        child: Icon(
                          Icons.donut_large_rounded,
                          size: ScreenUtil().setWidth(36),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(4)),
                  // 网络选择器
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showChangeNetwork(waValue),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(14),
                          vertical: ScreenUtil().setWidth(8),
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              networkStr,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                fontWeight: FontWeight.w500,
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                              size: ScreenUtil().setWidth(22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 底部行：排序选项 + 小额隐藏开关
              Row(
                children: [
                  // 按名称排序
                  _buildSortButton(
                    S.of(context).g_browser_key6,
                    "name",
                    waValue.walletInfo.coinSort['name'] ?? -1,
                    () => waValue.setCoinSortAssets("name"),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  // 按资产排序
                  _buildSortButton(
                    S.of(context).g_key_198,
                    "assets",
                    waValue.walletInfo.coinSort['assets'] ?? -1,
                    () => waValue.setCoinSortAssets("assets"),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  // 按 24h 涨跌幅排序
                  _buildSortButton(
                    '24h%',
                    "change",
                    waValue.walletInfo.coinSort['change'] ?? -1,
                    () => waValue.setCoinSortAssets("change"),
                  ),
                  const Spacer(),
                  // 小额资产过滤：点击循环切换阈值 off→$1→$5→$10→$50→off
                  _buildThresholdButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 小额资产阈值切换按钮
  /// 点击循环：off → $1 → $5 → $10 → $50 → off
  Widget _buildThresholdButton() {
    final active = _smallAssetsThreshold > 0;
    final label = active
        ? '< \$${_smallAssetsThreshold.toInt()}'
        : '< \$';
    final blueColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final subColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    return GestureDetector(
      onTap: () {
        final idx = _thresholdCycle.indexOf(_smallAssetsThreshold);
        final next = _thresholdCycle[(idx + 1) % _thresholdCycle.length];
        setState(() => _smallAssetsThreshold = next);
        SPUtil().setSmallAssetsThreshold(next);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(14),
          vertical: ScreenUtil().setWidth(6),
        ),
        decoration: BoxDecoration(
          color: active ? blueColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: active
              ? Border.all(color: blueColor.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: ScreenUtil().setWidth(26),
              color: active ? blueColor : subColor,
            ),
            SizedBox(width: ScreenUtil().setWidth(5)),
            Text(
              label,
              style: TextStyle(
                color: active ? blueColor : subColor,
                fontSize: ScreenUtil().setSp(22),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 排序按钮组件
  Widget _buildSortButton(String label, String key, int sortValue, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(8),
            vertical: ScreenUtil().setWidth(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(4)),
              SizedBox(
                width: ScreenUtil().setWidth(16),
                height: ScreenUtil().setWidth(16),
                child: Image.asset(
                  "assets/wallet/assets$sortValue.png",
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget coinListWidget(WalletActionProvider waValue) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return coinListWidget1(waValue);
          },
          childCount: 1,
        ));
  }

  Widget coinListWidget1(WalletActionProvider waValue) {
    // 小额资产过滤：阈值 > 0 时过滤掉价值低于阈值的代币
    final displayList = _smallAssetsThreshold > 0
        ? waValue.coinList.where((c) => c.value >= _smallAssetsThreshold).toList()
        : waValue.coinList;

    // 初始加载（coinList 为空且钱包正在构建）→ 显示 skeleton 占位
    final showSkeleton = waValue.coinList.isEmpty && waValue.buildwallet;

    // 使用 shrinkWrap 和自适应高度，避免固定高度导致溢出
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          border: Border.all(
              width: 2,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name))),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      // 添加底部安全边距，避免被底部导航栏遮挡
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_discoveredTokens.isNotEmpty) _buildDiscoveryBanner(),
          // 余额逐条加载中的进度提示条
          if (waValue.loadBalance == Load.loading)
            Container(
              width: double.infinity,
              height: ScreenUtil().setWidth(60.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.textColorOrange.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                S.of(context).g_key_208,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainWhiteColor.name),
                ),
              ),
            ),
          // Skeleton 占位：初始加载时显示
          if (showSkeleton) const _CoinListSkeleton(),
          // 列表为空（非加载中）
          if (!showSkeleton && displayList.isEmpty)
            Container(
              height: ScreenUtil().setWidth(300.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name),
              child: _smallAssetsThreshold > 0 && waValue.coinList.isNotEmpty
                  ? _buildAllHiddenHint()
                  : const EmptyView(),
            ),
          if (!showSkeleton && displayList.isNotEmpty)
            _buildCoinListView(displayList),
        ],
      ),
    );
  }

  // ── Token discovery banner ────────────────────────────────────────────────

  Widget _buildDiscoveryBanner() {
    final count = _discoveredTokens.length;
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TokenDiscoveryPage(tokens: _discoveredTokens),
          ),
        );
        if (!mounted) return;
        if (added == true) {
          setState(() => _discoveredTokens = []);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(24),
          vertical: ScreenUtil().setWidth(14),
        ),
        decoration: BoxDecoration(
          color: blueColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: blueColor.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.manage_search_rounded,
                color: blueColor, size: ScreenUtil().setWidth(36)),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Text(
                S.of(context).g_key_token_discovery_banner(count),
                style: TextStyle(
                  color: blueColor,
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Dismiss — clears banner without adding to ignore list.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _discoveredTokens = []),
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                child: Icon(Icons.close_rounded,
                    color: blueColor.withValues(alpha: 0.70),
                    size: ScreenUtil().setWidth(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 代币列表 ListView，有置顶时在置顶与普通代币之间插入分隔行。
  Widget _buildCoinListView(List<dynamic> list) {
    // 统计从头部连续的置顶代币数量（coinList 已排序，置顶必在前）
    int pinnedCount = 0;
    for (final c in list) {
      if (c is CoinModel && c.isPinned) {
        pinnedCount++;
      } else {
        break;
      }
    }

    // 是否需要插入分隔行（有置顶且列表中还有非置顶代币）
    final needsDivider = pinnedCount > 0 && pinnedCount < list.length;
    // 分隔行占一个 index slot
    final itemCount = list.length + (needsDivider ? 1 : 0);

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (needsDivider && index == pinnedCount) {
          // 置顶区与普通区之间的分隔行
          return Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(4)),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    height: 1,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.dividerColor.name),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(12)),
                  child: Text(
                    S.of(context).g_key_coin_list_separator,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    height: 1,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.dividerColor.name),
                  ),
                ),
              ],
            ),
          );
        }
        // 真实代币 index（分隔行之后需要偏移 -1）
        final coinIndex = (needsDivider && index > pinnedCount) ? index - 1 : index;
        return _mainCoin(list[coinIndex], "c$coinIndex", "coin_list");
      },
    );
  }

  /// 所有资产因小额过滤全部隐藏时的提示
  Widget _buildAllHiddenHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: ScreenUtil().setWidth(60),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_coin_list_all_hidden,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          GestureDetector(
            onTap: () {
              setState(() => _smallAssetsThreshold = 0.0);
              SPUtil().setSmallAssetsThreshold(0.0);
            },
            child: Text(
              S.of(context).g_key_coin_list_show_all,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainCoin(CoinModel coinInfo, String key, String group,) {
    String balanceStr = "";
    double balance = coinInfo.value;
    if (balance >= 1000000000) {
      balanceStr = regular.getMoneyAbbreviation(balance);
    }else if(balance>0 && balance <0.0000000009){
      balanceStr=regular.getMoneyAbbreviationDecimal(balance);
    } else {
      balanceStr = oCcy.format(balance);
    }
    String valueBalanceStr="";
    double valueBalance=coinInfo.balanceDoubleAll();
    if(valueBalance>1000000000){
      valueBalanceStr=regular.getMoneyAbbreviation(valueBalance);
    }else if(valueBalance>0 && valueBalance <0.0000000009){
      valueBalanceStr=regular.getMoneyAbbreviationDecimal(valueBalance);
    }else{
      valueBalanceStr=coinInfo.balanceString();
    }
    Widget? mainImage;
    Widget image;
    final coinIcon = coinInfo.coin['icon'] ?? '';
    if (coinIcon == "") {
      image = Image.asset("assets/img/list_default.png");
    } else {
      image = ImageNetWork(imageUrl: coinIcon,
        placeholder: "assets/img/list_default.png",
      );
    }
    if (coinInfo.coin['isContract'] == true) {
      mainImage = ImageNetWork(imageUrl:
        coinInfo.mainCoinIcon ?? "",
        placeholder: "assets/img/list_default.png",
      );
    }
    Color deleteColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    if(coinInfo.coin['canEdit']==false){
      // 使用更暗的灰色，在暗色主题下也能看清
      deleteColor = const Color(0xFF6B6B6B);
    }
    Widget refreshWidget = const SizedBox();
    /*if (coinInfo.isRefresh) {
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(6.0),
        ),
        child: const CircularProgressIndicator(),
      );
    }
    else */
    if (coinInfo.loadError) {
      refreshWidget = Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(6.0),
        ),
        child: Image.asset("assets/img/error.png",color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),),
      );
    }
    return InkWell(
      onTap: () {
        // 聚合代币暂不支持详情页面
        if(coinInfo.coin['isAggregated'] == true) {
          ToastUtils.show(S.of(context).g_key_aa_coming_soon);
          return;
        }
        if(coinInfo.coin['coinType']==CoinType.BTC.name){
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfo(coinInfo)));
        }else if(coinInfo.coin['coinType']==CoinType.XRP.name){
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfoXRP(coinInfo)));
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => WalletChainInfo(coinInfo)));
        }
      },
      child:Slidable(
        key: ValueKey(key),
        groupTag: group,
        closeOnScroll: true,
        enabled: true,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) async {
                if(coinInfo.coin['canEdit']==true){
                  if(coinInfo.coin['isContract']){
                    ref.read(wapBridgeProvider).removeWalletChainToken(coinInfo.coin,symbol:coinInfo.coin["coinType"],miniName:coinInfo.coin['miniName']);
                  }else{
                    ref.read(wapBridgeProvider).removeWalletChain(coinInfo.coin['mKey'],coinInfo.coin['unit']);
                  }
                }
              },
              backgroundColor:
              deleteColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              //label: S.of(context).g_key_113,
              autoClose: true,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 错误/加载指示器
              refreshWidget,
              // 币种图标
              Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(48),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(14)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
                      child: image,
                    ),
                    if (mainImage != null)
                      Positioned(
                        top: -2,
                        left: -2,
                        height: ScreenUtil().setWidth(20),
                        width: ScreenUtil().setWidth(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                            border: Border.all(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                            child: mainImage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 币种信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 第一行：币种名称 + 余额数量
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 置顶时在名称左侧显示蓝色图钉角标
                        if (coinInfo.isPinned)
                          Padding(
                            padding: EdgeInsets.only(right: ScreenUtil().setWidth(6)),
                            child: Icon(
                              Icons.push_pin,
                              size: ScreenUtil().setWidth(22),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            coinInfo.coin['miniName'] ?? '',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Text(
                          valueBalanceStr,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    // 第二行：单价+涨跌幅 + 总价值
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "\$${coinInfo.coinPriceString()}",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            percentageWidget(context, coinInfo.percentage),
                          ],
                        ),
                        Text(
                          "\$$balanceStr",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── 图钉按钮（独立触控区，不触发 onTap 跳转）
              if (coinInfo.coin['isAggregated'] != true)
                _PinIconButton(
                  isPinned: coinInfo.isPinned,
                  onTap: () => ref.read(wapBridgeProvider).togglePinCoin(coinInfo),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 涨跌幅百分比
  Widget percentageWidget(BuildContext context, var percentage) {
    final isPositive = percentage >= 0;
    final color = isPositive
        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name)
        : AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        "${isPositive ? '+' : ''}${percentage.toStringAsFixed(2)}%",
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 保留旧的百分比组件（向后兼容）
  // ignore: unused_element
  Widget _oldPercentageWidget(BuildContext context, var percentage) {
    if (percentage >= 0) {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.rightTextColor.name),
            height: 1.5,
          ));
    } else {
      return Text("${percentage.toStringAsFixed(2)}%",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
            height: 1.5,
          ));
    }
  }
  //切换网络
  void showChangeNetwork(WalletActionProvider walletValue) {
    List<Widget> childs = [];
    // 顶部标题行 + 管理链按钮
    childs.add(Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Row(
        children: [
          Text(
            S.of(context).g_token_m_key_4,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(40),
            ),
            tooltip: S.of(context).g_key_manage_chains,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageChainsPage()),
              );
            },
          ),
        ],
      ),
    ));
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(600.0),
      ),
      child: ListView.separated(
        itemCount: walletValue.coinModels.length + 1,
        itemBuilder: (context, int index) {
          bool selected = false;
          if (walletValue.walletInfo.networkIndex == index - 1) {
            selected = true;
          }
          if (index == 0) {
            return InkWell(
              onTap: () {
                walletValue.setNetworkIndex(-1);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(30.0),
                  horizontal: ScreenUtil().setWidth(20.0),
                ),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        width: ScreenUtil().setWidth(1.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemLineColor.name),
                      )),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).g_token_m_key_4,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, "mainTextColor"),
                          fontWeight: FontWeight.bold),
                    ),
                    if (selected)
                      Icon(
                        Icons.check,
                        size: ScreenUtil().setWidth(40.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                      ),
                  ],
                ),
              ),
            );
          }
          CoinModel coinInfo = walletValue.coinModels[index - 1];
          Widget image;
          if (coinInfo.coin['miniName'] == CoinType.N.name) {
            image = Image.asset('assets/img/ast.png');
          } else {
            image = ImageNetWork(imageUrl:
              coinInfo.coin['icon'],
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              walletValue.setNetworkIndex(index - 1);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(20.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      width: ScreenUtil().setWidth(1.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name),
                    )),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(52.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: image,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(coinInfo.coin['name'],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemSubtitleTextColor.name),
                            )),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: ScreenUtil().setWidth(1.0),
          );
        },
      ),
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
  //显示钱包列表
  void showChangeAddress() {
    //WalletInfo nowWalletInfo=walletValue.walletInfoLsit[walletValue.walletIndex];
    WalletActionProvider walletValue = ref.read(wapBridgeProvider);
    List<Widget> childs = [];
    childs.add(
      Container(
        height: ScreenUtil().setWidth(80),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              S.of(context).g_key_13,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>WalletList()));
              },
              child: Icon(
                Icons.settings,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        ),
      ),
    );
    childs.add(
      Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
      ),
    );
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(500.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: ListView.separated(
        itemCount: walletValue.walletInfoLsit.length,
        itemBuilder: (context, int index) {
          WalletInfo wInfo = walletValue.walletInfoLsit[index];
          Color walletColor = AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name);
          if (index == walletValue.walletIndex) {
            walletColor = AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name);
          }
          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              if (index == walletValue.walletIndex) {
              } else {
                await walletValue.setWalletIndex(index);
              }
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    wInfo.mainWallet?S.of(context).g_key_14:S.of(context).g_key_6,
                    style: TextStyle(
                      color: walletColor,
                      fontSize: ScreenUtil().setSp(36.0),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(20.0),
                  ),
                  Text(
                    wInfo.walletName!,
                    style: TextStyle(
                      color: walletColor,
                      fontSize: ScreenUtil().setSp(36.0),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Spacer(),
                  if(wInfo.mainWallet==true || ref.read(wapBridgeProvider).walletIndex == index)
                    Icon(Icons.lock,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainGreyColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: ScreenUtil().setWidth(1.0),
          );
        },
      ),
    ));
    childs.add(CreateWalletButton());
    /*childs.add(
      Container(
        height: ScreenUtil().setWidth(88.0),
        width: double.infinity,
        child: buttonStyle2(context, () async {
          Navigator.pop(context);
          //添加钱包
          await Navigator.pushNamed(
              context,"/CreateWallet");
        }, S.of(context).g_key_159),
      )
    );*/

    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }


  //显示选择币列表
  void showSearchCoin(int type) {
    sheetBottom(
      context,
      S.of(context).g_token_m_key_12,
      WalletSearchCoin(type),
    );
  }
  //显示添加代币和链
  Future<void> showAddToken()async{
    WalletInfo wi=ref.read(wapBridgeProvider).walletInfo;
    if(wi.privateKey !=null){
      String? cType=wi.coinInfo?.keys.toList()[0];
      bool? r = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WalletCoinAddAll("",coinType: cType,)
          ));
      if (!mounted) return;
      if (r==true) {
        ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
      }
      return;
    }
    Widget child=Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: ()async{
              String? cType;
              WalletInfo wi=ref.read(wapBridgeProvider).walletInfo;
              if(wi.privateKey !=null){
                cType=wi.coinInfo?.keys.toList()[0];
              }
              bool? r = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletCoinAddAll("",coinType: cType,)
                  ));
              if (!mounted) return;
              if (r==true) {
                ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
              }
              Navigator.pop(context);
            },
            child: Container(
              height: ScreenUtil().setWidth(88),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_token_m_key_20,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
          ),
          Divider(
            height: ScreenUtil().setWidth(1),
            endIndent: 0,
            indent: 0,
          ),
          InkWell(
            onTap: ()async{
              bool? r = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletChainAdd()
                  ));
              if (!mounted) return;
              if (r==true) {
                ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
              }
              Navigator.pop(context);
            },
            child: Container(
              height: ScreenUtil().setWidth(88),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_token_m_key_19,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    sheetBottom(
      context,
      "",
      child,
    );
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

/// 代币列表项中的图钉按钮。
///
/// 独立 [StatelessWidget] 以缩小 rebuild 范围：仅当 [isPinned] 变化时
/// Flutter diff 算法才会重建此节点，不受父节点其他字段更新的影响。
class _PinIconButton extends StatelessWidget {
  const _PinIconButton({
    required this.isPinned,
    required this.onTap,
  });

  final bool isPinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(12),
          ScreenUtil().setWidth(16),
          0,
          ScreenUtil().setWidth(16),
        ),
        child: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          size: ScreenUtil().setWidth(30),
          color: isPinned
              ? AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

// ── Skeleton 加载占位组件 ────────────────────────────────────────────────────

/// 资产列表骨架屏：初始加载时显示 5 个脉冲占位行，无需外部依赖。
class _CoinListSkeleton extends StatefulWidget {
  const _CoinListSkeleton();

  @override
  State<_CoinListSkeleton> createState() => _CoinListSkeletonState();
}

class _CoinListSkeletonState extends State<_CoinListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        // 在背景色和稍亮色之间脉冲
        final base = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name);
        final shimmer = Color.lerp(
              base,
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.dividerColor.name),
              _anim.value,
            ) ??
            base;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => _SkeletonCoinRow(shimmerColor: shimmer),
          ),
        );
      },
    );
  }
}

class _SkeletonCoinRow extends StatelessWidget {
  const _SkeletonCoinRow({required this.shimmerColor});
  final Color shimmerColor;

  @override
  Widget build(BuildContext context) {
    final radius = ScreenUtil().setWidth(8);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 圆形头像占位
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(14)),
            decoration: BoxDecoration(
              color: shimmerColor,
              shape: BoxShape.circle,
            ),
          ),
          // 文字占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：符号 + 数量
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setWidth(22),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(60),
                      height: ScreenUtil().setWidth(22),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(10)),
                // 第二行：价格 + 总价值
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setWidth(18),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(18),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
