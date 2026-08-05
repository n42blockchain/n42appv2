import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/token_discovery/discovered_token.dart';
import 'package:n42_wallet/features/wallet/token_discovery/token_discovery_service.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/ai_assistant/presentation/wallet_ai_snapshot_builder.dart';
import 'package:n42_wallet/features/ai_assistant/presentation/wallet_assistant_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_home_page.dart';
import 'package:n42_wallet/features/wallet/pages/iap/iap_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_home_page.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_header.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_section.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_top_bar.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_sheets.dart';
import 'package:n42_wallet/features/wallet/pages/send/scan_to_pay_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';
import 'package:n42_wallet/features/wallet/widgets/feature_entry_cards.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
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
  final TextEditingController _tokenSearchController = TextEditingController();
  final FocusNode _tokenSearchFocusNode = FocusNode();
  final ValueNotifier<String> _tokenSearchQuery = ValueNotifier<String>('');
  bool _isTokenSearchVisible = false;

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
    _scrollController = ScrollController()..addListener(_onScroll);
    SPUtil().getSmallAssetsThreshold().then((v) {
      if (mounted) setState(() => _smallAssetsThreshold = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // initWallet 必须推迟到首帧之后：它虽是 async，但在第一个 await 之前就
      // 同步清空列表并 refresh()（notifyListeners）。直接在 initState 里调，
      // 通知会发生在 ConsumerStatefulElement 还在 mount 的过程中，触发
      // Riverpod 的「Tried to modify a provider while the widget tree was
      // building」断言——T26 真机探针抓到的就是这条。
      ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
      _startPriceTimer();
    });
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    _scrollController.dispose();
    _tokenSearchController.dispose();
    _tokenSearchFocusNode.dispose();
    _tokenSearchQuery.dispose();
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
        final coinType = cm.config.coinType;
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
      AppLogger.w('WalletPage', 'token discovery error: $e');
    }
  }

  // ── ENS ───────────────────────────────────────────────────────────────────

  Future<void> _loadEnsInfo(String ethAddress) async {
    final normalizedAddress = FeatureAddressUtils.normalize(ethAddress);
    if (!FeatureAddressUtils.isValidEvmAddress(normalizedAddress)) {
      _lastCheckedAddress = normalizedAddress;
      if (_ensName != null && mounted) {
        setState(() => _ensName = null);
      }
      return;
    }
    if (normalizedAddress == _lastCheckedAddress) return;
    _lastCheckedAddress = normalizedAddress;
    if (_ensName != null && mounted) {
      setState(() => _ensName = null);
    }
    try {
      final ensName = await EnsService().resolveAddress(normalizedAddress);
      if (!mounted || _lastCheckedAddress != normalizedAddress) return;
      setState(() => _ensName = ensName?.isNotEmpty == true ? ensName : null);
    } catch (e) {
      AppLogger.w('WalletPage', 'ENS reverse resolve error: $e');
      if (mounted && _lastCheckedAddress == normalizedAddress) {
        setState(() => _ensName = null);
      }
    }
  }

  void _showEvmFeatureUnavailableToast() {
    ToastUtils.showWarning(S.of(context).g_key_bridge_chain_not_supported);
  }

  // ── WalletConnect ─────────────────────────────────────────────────────────

  Future<void> _walletConnect() async {
    final wcp = ref.read(wcpBridgeProvider);
    await wcp.connectInit();

    if (wcp.getActiveSessions().isNotEmpty) {
      await _pushAndRefreshWc(WcSessionListPage(), wcp);
      return;
    }

    await _pushAndRefreshWc(WalletConnectPage(""), wcp);
  }

  Future<void> _pushAndRefreshWc(Widget page, dynamic wcp) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    wcp.refresh();
  }

  void _openWalletAssistant(WalletActionProvider waValue) {
    final snapshot = buildWalletAiSnapshot(
      totalUsd: waValue.balanceTotal,
      coins: waValue.coinList.whereType<CoinModel>(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletAssistantPage(snapshot: snapshot),
      ),
    );
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

  void _setTokenSearchVisible(bool visible) {
    setState(() {
      _isTokenSearchVisible = visible;
      if (!visible) {
        _tokenSearchController.clear();
        _tokenSearchQuery.value = '';
      }
    });
    if (visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tokenSearchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _refreshWallet(WalletActionProvider waValue) async {
    if (waValue.load == Load.refresh) return;
    await waValue.refreshWalletCoinInfo();
  }

  /// 钱包首页二维码菜单的扫码入口。EIP-681 请求直接进入对应资产的付款页；
  /// 普通地址则先选择要发送的资产，避免将地址误当作 WalletConnect URI。
  Future<void> _scanToPay(WalletActionProvider waValue) async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );
    if (!mounted || scanned == null || scanned.trim().isEmpty) return;

    // WalletConnect 配对码要走 WC 会话流程，不能被当作收款地址塞进发送页。
    final wcUri = normalizeWalletConnectUriString(scanned);
    if (wcUri != null) {
      final wcp = ref.read(wcpBridgeProvider);
      await wcp.connectInit();
      if (!mounted) return;
      await _pushAndRefreshWc(WalletConnectPage(wcUri), wcp);
      return;
    }

    final request = Eip681.parse(scanned);
    if (request == null) {
      showSearchCoinSheet(
        context,
        0,
        toAddress: Eip681.resolveRecipient(scanned),
      );
      return;
    }

    final resolution = ScanToPayResolver.resolve(
      request: request,
      coinModels: _scanToPayCandidates(waValue),
    );
    if (resolution == null) {
      ToastUtils.show(S.of(context).g_key_scan_pay_unsupported);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletChainSend(
          resolution.coinModel,
          initialToAddress: resolution.recipient,
          initialAmount: resolution.amount,
        ),
      ),
    );
  }

  /// 扫码支付的资产候选须覆盖全部链与代币；coinList 受所选网络筛选影响，
  /// 选中单一网络时会把其他链的合法付款码误判为「钱包不支持」。
  Iterable<CoinModel> _scanToPayCandidates(WalletActionProvider waValue) sync* {
    for (final mm in waValue.coinModels) {
      yield mm;
      for (final token in mm.tokens.values) {
        yield waValue.buildTokenCoinModel(mm, token);
      }
    }
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

              if (!waValue.isWalletReady) {
                return Loading();
              }

              if (!_discoveryScanned) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  // 闸门要在回调里**重新判**，不能只靠 build 时的快照：
                  // initWallet 也挂在 post-frame 队列上（且注册更早），它在第一个
                  // await 之前会同步清空钱包/币列表。若沿用 build 时捕获的
                  // waValue 直接跑，discovery 会撞上 walletIndex 仍为 0 而钱包
                  // 列表已空的瞬时态，walletInfo 抛
                  // 「Invalid walletIndex (0) for list of 0 wallets」。
                  // 此处不置 _discoveryScanned，下一帧条件满足时会自然重试。
                  final wap = ref.read(wapBridgeProvider);
                  if (!wap.isWalletReady) return;
                  _runTokenDiscovery(wap);
                });
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
                          onScanTap: () => _scanToPay(waValue),
                          onReceiveTap: () => showSearchCoinSheet(context, 1),
                          onAssistantTap: () => _openWalletAssistant(waValue),
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
                                    buyTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const IapPage(),
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
                                      final canOpenEvmFeatures =
                                          FeatureAddressUtils.isValidEvmAddress(
                                            ethAddress,
                                          );
                                      if (canOpenEvmFeatures) {
                                        _loadEnsInfo(ethAddress);
                                      } else if (_ensName != null) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                setState(() => _ensName = null);
                                              }
                                            });
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
                                        ensEnabled: canOpenEvmFeatures,
                                        smartAccountEnabled: canOpenEvmFeatures,
                                        onEnsTap: () {
                                          if (!canOpenEvmFeatures) {
                                            _showEvmFeatureUnavailableToast();
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EnsHomePage(
                                                walletAddress: ethAddress,
                                              ),
                                            ),
                                          );
                                        },
                                        onSmartAccountTap: () {
                                          if (!canOpenEvmFeatures) {
                                            _showEvmFeatureUnavailableToast();
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AAHomePage(
                                                walletAddress: ethAddress,
                                                accountInfo: waValue
                                                    .walletInfo
                                                    .aaAccountInfo,
                                                onAccountCreated:
                                                    (account) async {
                                                      waValue.walletInfo
                                                          .addSmartAccount(
                                                            account,
                                                          );
                                                      await waValue
                                                          .saveWalletInfo(
                                                            waValue.walletInfo,
                                                            waValue.walletIndex,
                                                          );
                                                    },
                                              ),
                                            ),
                                          );
                                        },
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
                                  searchController: _tokenSearchController,
                                  searchFocusNode: _tokenSearchFocusNode,
                                  isSearchVisible: _isTokenSearchVisible,
                                  onSearchVisibilityChanged:
                                      _setTokenSearchVisible,
                                  onSearchChanged: (query) =>
                                      _tokenSearchQuery.value = query.trim(),
                                  onRefresh: () => _refreshWallet(waValue),
                                  onMarketTap: () {
                                    final marketTabIndex =
                                        Theme.of(context).platform ==
                                            TargetPlatform.android
                                        ? 3
                                        : 2;
                                    ref
                                            .read(homeTabIndexProvider.notifier)
                                            .state =
                                        marketTabIndex;
                                  },
                                  onPortfolioTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PortfolioPage(),
                                    ),
                                  ),
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
                                  searchQuery: _tokenSearchQuery,
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
                  // 悬浮添加代币按钮（滚动到底部时显示）——
                  // AddTokenFloatingIcon 自带按压态与 ≥88.w 命中区（§5 红线）。
                  Positioned(
                    bottom: ScreenUtil().setWidth(180.0),
                    left: 0,
                    right: 0,
                    height: ScreenUtil().setWidth(88.0),
                    child: Visibility(
                      visible: _showAddTokenButton,
                      child: Container(
                        alignment: Alignment.center,
                        child: AddTokenFloatingIcon(
                          onTap: () => showAddTokenSheet(context, ref),
                        ),
                      ),
                    ),
                  ),
                  // 未备份提示条
                  Positioned(
                    bottom: ScreenUtil().setWidth(120.0),
                    left: AppSpacing.space8,
                    right: AppSpacing.space8,
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
