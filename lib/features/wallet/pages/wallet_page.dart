import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/token_discovery/discovered_token.dart';
import 'package:n42_wallet/core/token_discovery/token_discovery_service.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_home_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_home_page.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_page.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/set_amount.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_header.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_section.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_top_bar.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_sheets.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/widgets/feature_entry_cards.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/wallet_connect_uri.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  late ScrollController _scrollController;
  bool _showAddTokenButton = false;

  /// 小额资产过滤阈值：0=关闭，1/5/10/50 表示过滤低于该 USD 价值的代币
  double _smallAssetsThreshold = 0.0;

  // ── Token auto-discovery ──────────────────────────────────────────────────
  List<DiscoveredToken> _discoveredTokens = [];

  /// 防止每次 rebuild 重复扫描；钱包切换时重置。
  bool _discoveryScanned = false;

  /// 价格自动刷新定时器（每 60 秒）
  Timer? _priceRefreshTimer;

  // ENS 状态
  String? _ensName;
  String? _lastCheckedAddress;

  // ── 生命周期 ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
    _scrollController = ScrollController()..addListener(_onScroll);
    SPUtil().getSmallAssetsThreshold().then((v) {
      if (mounted) setState(() => _smallAssetsThreshold = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPriceTimer());
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final pixel = _scrollController.position.pixels;
    final shouldShow = maxScroll - pixel < 50;
    if (_showAddTokenButton != shouldShow) {
      setState(() => _showAddTokenButton = shouldShow);
    }
  }

  // ── Price timer ───────────────────────────────────────────────────────────

  void _startPriceTimer() {
    _priceRefreshTimer?.cancel();
    _priceRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      ref.read(wapBridgeProvider).refreshWalletCoinInfo(refresh: false);
    });
  }

  // ── Token discovery ───────────────────────────────────────────────────────

  Future<void> _runTokenDiscovery(WalletActionProvider wap) async {
    if (_discoveryScanned) return;
    _discoveryScanned = true;

    try {
      final knownContracts = wap.walletMap.values
          .expand(
            (chainData) =>
                (chainData['mainnets'] as Map<dynamic, dynamic>? ?? {}).values,
          )
          .whereType<Map>()
          .map((t) => (t['contract'] as String?)?.trim() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet();

      final ignoredContracts = await SPUtil().getIgnoredTokenContracts();

      final addressByChain = <String, String?>{};
      for (final cm in wap.coinModels) {
        final coinType = cm.coin['coinType'] as String? ?? '';
        final address = cm.address?.toString() ?? '';
        if (coinType.isNotEmpty && address.isNotEmpty) {
          addressByChain.putIfAbsent(coinType, () => address);
        }
      }

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
      debugPrint('[WalletPage] Token discovery error: $e');
    }
  }

  // ── ENS ───────────────────────────────────────────────────────────────────

  Future<void> _loadEnsInfo(String ethAddress) async {
    if (ethAddress.isEmpty || ethAddress == _lastCheckedAddress) return;
    _lastCheckedAddress = ethAddress;
    try {
      final ensName = await EnsService().resolveAddress(ethAddress);
      if (mounted && ensName != null && ensName.isNotEmpty) {
        setState(() => _ensName = ensName);
      }
    } catch (e) {
      debugPrint('ENS reverse resolve error: $e');
    }
  }

  // ── WalletConnect ─────────────────────────────────────────────────────────

  Future<void> _walletConnect() async {
    final wcp = ref.read(wcpBridgeProvider);
    await wcp.connectInit();

    if (wcp.getActiveSessions().isNotEmpty) {
      await _pushAndRefreshWc(WcSessionListPage(), wcp);
      return;
    }

    final state = wcp.walletConnectState;
    final shouldScan =
        state == WalletConnectState.disconnect ||
        state == WalletConnectState.loading ||
        state == WalletConnectState.connectOK;

    if (!shouldScan) {
      await _pushAndRefreshWc(WalletConnectPage(""), wcp);
      return;
    }

    final scanStr = await _scan();
    if (!mounted || scanStr.isEmpty) return;

    if (isWalletConnectUriString(scanStr)) {
      await _pushAndRefreshWc(WalletConnectPage(scanStr), wcp);
      return;
    }

    final idx = scanStr.indexOf(AppConfig.apiUrl['walletamazeBrowser']);
    if (idx == -1) return;
    final params = Uri.parse(scanStr).queryParameters;
    if (params['type'] != 'payment') return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          params["amount"],
          params["user"],
          params["coinType"],
          params["address"],
        ),
      ),
    );
  }

  Future<void> _pushAndRefreshWc(Widget page, dynamic wcp) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    wcp.refresh();
  }

  Future<String> _scan() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanPage()),
    );
    return result ?? "";
  }

  // ── WalletBoard callbacks ─────────────────────────────────────────────────

  /// Returns true if the action can proceed. Blocks watchOnly wallets
  /// (unless [blockWatchOnly] is false) and prompts backup for unprotected wallets.
  Future<bool> _guardAction(
    WalletActionProvider waValue, {
    bool blockWatchOnly = true,
  }) async {
    if (blockWatchOnly && waValue.walletInfo.watchOnly) {
      ToastUtils.show(S.of(context).g_key_watch_only_cant_send);
      return false;
    }
    if (waValue.walletInfo.password == "") {
      await _promptBackup(waValue);
      return false;
    }
    return true;
  }

  Future<void> _onSendTap(WalletActionProvider waValue) async {
    if (await _guardAction(waValue) && mounted) showSearchCoinSheet(context, 0);
  }

  Future<void> _onReceiveTap(WalletActionProvider waValue) async {
    if (await _guardAction(waValue, blockWatchOnly: false) && mounted) {
      showSearchCoinSheet(context, 1);
    }
  }

  Future<void> _onSwapTap(WalletActionProvider waValue) async {
    if (await _guardAction(waValue) && mounted) showSwapModeSheet(context);
  }

  Future<void> _promptBackup(WalletActionProvider waValue) async {
    if (!walletHasBackupableMnemonic(waValue.walletInfo)) {
      ToastUtils.show(walletBackupPhraseUnavailableMessage);
      return;
    }
    final flag = await tipsDialog7(context);
    if (!mounted || flag != true) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'BackupOne'),
        builder: (_) => BackupOne(waValue.walletInfo, waValue.walletIndex),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: Builder(
            builder: (context) {
              final waValue = ref.watch(wapBridgeProvider);

              if (waValue.walletIndex == -1 || waValue.buildwallet) {
                return Loading();
              }

              if (!_discoveryScanned) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _runTokenDiscovery(waValue),
                );
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        WalletTopBar(
                          walletName: waValue.walletName,
                          isWatchOnly: waValue.walletInfo.watchOnly,
                          onTitleTap: () => showAddressSheet(
                            context,
                            ref,
                            ref.read(wapBridgeProvider),
                          ),
                          onMenuTap: () =>
                              Scaffold.of(this.context).openDrawer(),
                          onWalletConnectTap: _walletConnect,
                          onScanTap: _walletConnect,
                          onReceiveTap: () => showSearchCoinSheet(context, 1),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (waValue.load == Load.refresh ||
                                  waValue.load == Load.loading) {
                                return;
                              }
                              await waValue.refreshWalletCoinInfo();
                            },
                            backgroundColor: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainButtonBgColor.name,
                            ),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainButtonTextColor.name,
                            ),
                            displacement: 72,
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: false,
                              primary: false,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: WalletBoard(
                                    accountPrice: waValue.balanceTotal,
                                    usdToCnyRate: waValue.usdToCnyRate,
                                    priceLastUpdated: waValue.priceLastUpdated,
                                    walletName: waValue.walletName,
                                    sendTap: () => _onSendTap(waValue),
                                    receiveTap: () => _onReceiveTap(waValue),
                                    swapTap: () => _onSwapTap(waValue),
                                    paymentCodeTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SetAmount(),
                                      ),
                                    ),
                                    buyTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Moonpay(type: 0),
                                      ),
                                    ),
                                    sellTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Moonpay(type: 1),
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Builder(
                                    builder: (context) {
                                      final ethAddress =
                                          waValue.getAddress(
                                            CoinType.ETH.name,
                                          ) ??
                                          '';
                                      if (ethAddress.isNotEmpty) {
                                        _loadEnsInfo(ethAddress);
                                      }
                                      final hasAA =
                                          waValue.walletInfo.hasAAAccounts;
                                      final primaryAccount = waValue.walletInfo
                                          .getPrimarySmartAccount(1);
                                      final isDeployed =
                                          primaryAccount?.isDeployed ?? false;

                                      return FeatureEntryHorizontal(
                                        ensName: _ensName,
                                        hasSmartAccount: hasAA,
                                        isSmartAccountDeployed: isDeployed,
                                        onEnsTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EnsHomePage(
                                              walletAddress: ethAddress,
                                            ),
                                          ),
                                        ),
                                        onSmartAccountTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AAHomePage(
                                              walletAddress: ethAddress,
                                              accountInfo: waValue
                                                  .walletInfo
                                                  .aaAccountInfo,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                WalletCoinListHeader(
                                  waValue: waValue,
                                  smallAssetsThreshold: _smallAssetsThreshold,
                                  onAddToken: () =>
                                      showAddTokenSheet(context, ref),
                                  onChangeNetwork: () =>
                                      showNetworkSheet(context, waValue),
                                  onThresholdChanged: (next) {
                                    setState(
                                      () => _smallAssetsThreshold = next,
                                    );
                                    SPUtil().setSmallAssetsThreshold(next);
                                  },
                                ),
                                WalletCoinListSliver(
                                  waValue: waValue,
                                  smallAssetsThreshold: _smallAssetsThreshold,
                                  discoveredTokens: _discoveredTokens,
                                  onDiscoveryDismiss: () =>
                                      setState(() => _discoveredTokens = []),
                                  onDiscoveryAdded: () =>
                                      setState(() => _discoveredTokens = []),
                                  onShowAllTap: () {
                                    setState(() => _smallAssetsThreshold = 0.0);
                                    SPUtil().setSmallAssetsThreshold(0.0);
                                  },
                                  coinItemBuilder: (coin, key, group) =>
                                      WalletCoinItem(
                                        coinInfo: coin,
                                        itemKey: key,
                                        group: group,
                                      ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: ScreenUtil().setWidth(300.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 悬浮添加代币按钮（滚动到底部时显示）
                  Positioned(
                    bottom: ScreenUtil().setWidth(180.0),
                    left: 0,
                    right: 0,
                    height: ScreenUtil().setWidth(70.0),
                    child: Visibility(
                      visible: _showAddTokenButton,
                      child: Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => showAddTokenSheet(context, ref),
                          child: const AddTokenFloatingIcon(),
                        ),
                      ),
                    ),
                  ),
                  // 未备份提示条
                  Positioned(
                    bottom: ScreenUtil().setWidth(120.0),
                    left: ScreenUtil().setWidth(30.0),
                    right: ScreenUtil().setWidth(30.0),
                    child: Visibility(
                      visible: waValue.walletInfo.password == "",
                      child: BackupReminderBanner(waValue: waValue),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
