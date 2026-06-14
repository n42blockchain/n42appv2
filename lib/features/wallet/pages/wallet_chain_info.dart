import 'dart:async';

import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/unified_send_page.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_actions.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_sync.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_address.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_token_address.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_coin_market_preview.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletChainInfo extends ConsumerStatefulWidget {
  final CoinModel coinModel;

  const WalletChainInfo(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainInfo> createState() => _WalletChainInfoState();
}

class _WalletChainInfoState extends ConsumerState<WalletChainInfo>
    with
        WalletChainInfoSyncMixin<WalletChainInfo>,
        WalletChainInfoActionsMixin<WalletChainInfo> {
  // ── DB accessor ───────────────────────────────────────────────────────────

  @override
  late final AppDatabase db = AppDatabase();

  // ── Display state ─────────────────────────────────────────────────────────

  String _chainName = '';
  String _chainSymbol = '';
  String? _tokenName;
  String? _tokenSymbol;
  CoinModel? _chainCoinModel;

  @override
  Map<String, dynamic>? marketInfo;

  @override
  String browserUrl = '';

  // ── Pagination & transaction list ─────────────────────────────────────────

  @override
  Load load = Load.finish;

  @override
  int pageSize = 10;

  @override
  int page = 1;

  @override
  bool lastPage = false;

  @override
  final List<dynamic> transactionList = [];

  // ── Scroll & events ───────────────────────────────────────────────────────

  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _eventBusFn;

  // ── Mixin contract ────────────────────────────────────────────────────────

  @override
  CoinModel get coinModel => widget.coinModel;

  @override
  CoinModel getCoinModel() => widget.coinModel;

  // ── Wallet provider ───────────────────────────────────────────────────────

  WalletActionProvider get _walletProvider => ref.read(wapBridgeProvider);

  // ── Backup guard ──────────────────────────────────────────────────────────

  @override
  Future<bool> ensureWalletBackedUp() async {
    final walletInfo = _walletProvider.walletInfo;
    if ((walletInfo.password ?? '').isNotEmpty) return true;
    if (!walletHasBackupableMnemonic(walletInfo)) {
      ToastUtils.show(walletBackupPhraseUnavailableMessage);
      return false;
    }
    final flag = await tipsDialog7(context);
    if (!mounted) return false;
    if (flag == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'BackupOne'),
          builder: (context) =>
              BackupOne(walletInfo, _walletProvider.walletIndex),
        ),
      );
    }
    return false;
  }

  // ── Actions (mixin contract implementation) ───────────────────────────────

  @override
  Future<void> handleSend({bool closeSheet = false}) async {
    if (!await _guardBackup(closeSheet)) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedSendPage(widget.coinModel),
      ),
    );
    if (!mounted) return;
    await getTransactionData(Load.refresh);
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  @override
  Future<void> handleReceive({bool closeSheet = false}) async {
    if (!await _guardBackup(closeSheet)) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletReceiveQr(
          _chainCoinModel ?? widget.coinModel,
          tokenCoinModel: _chainCoinModel == null ? null : widget.coinModel,
        ),
      ),
    );
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  /// Shared guard: ensures wallet is backed up and pops sheet on failure.
  Future<bool> _guardBackup(bool closeSheet) async {
    if (!await ensureWalletBackedUp()) {
      if (!mounted) return false;
      if (closeSheet) Navigator.pop(context);
      return false;
    }
    if (!mounted) return false;
    return true;
  }

  @override
  Future<void> changeNet(bool isTest, Load loadType) async {
    try {
      final wap = ref.read(wapBridgeProvider);
      wap.walletMap[widget.coinModel.config.coinType]['isTest'] = isTest;
      widget.coinModel.isTest = isTest;
      await wap.saveWalletInfo(wap.walletInfo, wap.walletIndex);
      await fetchCoinBalance(widget.coinModel, wap);
      widget.coinModel.address = null;
      await buildCoinWallet(widget.coinModel, wap);
      await fetchCoinBalance(widget.coinModel, wap);
      if (!mounted) return;
      setState(() {});
      _initData();
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initData();
    _scrollController.addListener(_onScroll);
    _eventBusFn = eventBus.on().listen((event) async {
      if (event is EventPublic && event.type == EventPublicType.transferOk) {
        getTransactionData(Load.refresh);
        getTransactionDataNetwork(Load.refresh);
        await fetchCoinBalance(widget.coinModel, _walletProvider);
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _eventBusFn?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final pixel = _scrollController.position.pixels;
    if (pixel > maxScroll - 200) {
      getTransactionData(Load.nextPage);
      getTransactionDataNetwork(Load.nextPage);
    }
  }

  void _initData() {
    final cm = widget.coinModel;
    final coin = cm.coin;
    final config = cm.config;
    final isContract = config.isContract;

    if (isContract) {
      final wap = ref.read(wapBridgeProvider);
      final cIndex = wap.coinModels.indexWhere(
        (e) => e.config.coinType == config.coinType,
      );
      if (cIndex < 0) return;
      _chainCoinModel = wap.coinModels[cIndex];
      _chainName = _chainCoinModel!.config.name;
      _chainSymbol = _chainCoinModel!.config.miniName;
      _tokenName = config.name;
      _tokenSymbol = config.miniName;
      browserUrl = getBrowserTokenAddress(
        config.coinType,
        cm.address,
        config.contract,
        isTest: cm.isTest,
      );
    } else {
      _chainName = config.name;
      _chainSymbol = config.miniName;
      browserUrl = getBrowserAddress(
        config.coinType,
        cm.address,
        isTest: cm.isTest,
      );
    }

    marketInfo = ref
        .read(wapBridgeProvider)
        .getCoinPriceWithUnitAll(coin['unit']);
    getTransactionData(Load.refresh);
    getTransactionDataNetwork(Load.refresh);
  }

  // ── Theme helpers ────────────────────────────────────────────────────────

  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    final textColor = _themeColor(AppThemeKeys.mainTextColor.name);
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);
    final cm = widget.coinModel;

    return Scaffold(
      appBar: AppBarWidget(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$_chainSymbol ($_chainName)',
              style: AppTypography.title.copyWith(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_tokenSymbol != null)
              Text(
                '$_tokenSymbol($_tokenName)',
                style: AppTypography.caption.copyWith(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          InkWell(
            onTap: showActionButtonListWidget,
            child: Container(
              width: su.setWidth(40.0),
              height: su.setWidth(40.0),
              margin: EdgeInsets.only(
                right: AppSpacing.space8,
                left: AppSpacing.space4,
              ),
              child: Image.asset(
                'assets/wallet/w_actions.png',
                color: blueColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await getTransactionData(Load.refresh);
            await getTransactionDataNetwork(Load.refresh);
            await fetchCoinBalance(cm, _walletProvider);
            if (!mounted) return;
            setState(() {});
          },
          backgroundColor: _themeColor(AppThemeKeys.mainButtonBgColor.name),
          color: _themeColor(AppThemeKeys.mainWhiteColor.name),
          displacement: su.setWidth(72.0),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              WalletChainInfoBoard(
                address: cm.address,
                coinType: cm.config.coinType,
                balanceStr:
                    '${cm.balanceStringAll()}${cm.coin['unit'].toString().toUpperCase()}',
                balanceDollarStr: '\$${cm.valueString()}',
                marketValueStr: '\$${cm.coinPriceString()}',
                lockAmountStr: null,
                xmlLockInfoTap: null,
                sendTap: handleSend,
                receiveTap: handleReceive,
                browserTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrowserPage(browserUrl),
                    ),
                  );
                },
              ),
              if ((marketInfo?['coin_gecko_id'] ?? '').toString().isNotEmpty)
                WalletCoinMarketPreview(
                  geckoId: marketInfo!['coin_gecko_id'].toString(),
                  priceChange24h:
                      (marketInfo!['price_change_per_24h'] as num?)
                          ?.toDouble() ??
                      0,
                  marketInfo: marketInfo!,
                ),
              Divider(height: su.setWidth(1)),
              _buildTransactionHeader(),
              _buildTransactionsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    final su = ScreenUtil();
    final cm = widget.coinModel;
    final isEth = cm.config.blockchainType == BlockchainType.Ethereum.name;

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).g_coin_key_1,
              style: AppTypography.body.copyWith(
                color: _themeColor(AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
          if (isEth)
            InkWell(
              onTap: () async {
                final Widget page = TransactionDetailEth(cm, '');
                final r = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
                if (!mounted) return;
                if (r == true) getTransactionData(Load.refresh);
              },
              child: Container(
                height: su.setWidth(50),
                width: su.setWidth(50),
                padding: EdgeInsets.all(su.setWidth(5)),
                child: Icon(
                  Icons.search,
                  color: _themeColor(AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsWidget() {
    if (transactionList.isEmpty) {
      return IntrinsicHeight(child: Center(child: EmptyView()));
    }

    final su = ScreenUtil();
    final cm = widget.coinModel;
    final isBtc = cm.config.blockchainType == BlockchainType.Bitcoin.name;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      itemCount: transactionList.length + 1,
      itemBuilder: (context, int index) {
        if (index == transactionList.length) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionHistoryList(cm),
                ),
              );
            },
            child: Container(
              height: su.setWidth(80.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_mining_key_49,
                style: AppTypography.body.copyWith(
                  color: _themeColor(AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          );
        }

        return WalletChainInfoTransactionsItem(
          coinModel: cm,
          type: isBtc ? 0 : 1,
          transactionModel: transactionList[index],
          onBack: () => getTransactionData(Load.refresh),
        );
      },
    );
  }
}
