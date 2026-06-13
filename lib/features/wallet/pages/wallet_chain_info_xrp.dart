import 'dart:async';

import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_sync.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_xrp_actions.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_address.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_token_address.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletChainInfoXRP extends ConsumerStatefulWidget {
  final CoinModel coinModel;

  const WalletChainInfoXRP(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainInfoXRP> createState() => _WalletChainInfoXRPState();
}

class _WalletChainInfoXRPState extends ConsumerState<WalletChainInfoXRP>
    with
        WalletChainInfoSyncMixin<WalletChainInfoXRP>,
        WalletChainInfoXrpActionsMixin<WalletChainInfoXRP> {
  AppDatabase? _dbInstance;

  @override
  AppDatabase get db {
    _dbInstance ??= AppDatabase();
    return _dbInstance!;
  }

  String _chainName = '';
  String _chainSymbol = '';
  String? _tokenName;
  String? _tokenSymbol;

  @override
  CoinModel? chainCoinModel;

  @override
  Map<String, dynamic>? marketInfo;

  @override
  String browserUrl = '';

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

  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _eventBusFn;

  @override
  CoinModel get coinModel => widget.coinModel;

  @override
  dynamic getCoinModel() => widget.coinModel;

  WalletActionProvider get _walletProvider => ref.read(wapBridgeProvider);

  /// Shorthand for theme color lookup.
  Color _tc(String key) => AppThemeUtils.getColorByKey(context, key);

  @override
  Future<bool> ensureWalletBackedUp() async {
    if (_walletProvider.walletInfo.password != '') return true;
    if (!walletHasBackupableMnemonic(_walletProvider.walletInfo)) {
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
          builder: (context) => BackupOne(
            _walletProvider.walletInfo,
            _walletProvider.walletIndex,
          ),
        ),
      );
    }
    return false;
  }

  /// Runs [action] after ensuring wallet backup, then optionally closes sheet.
  Future<void> _guardedAction(
    Future<void> Function() action, {
    bool closeSheet = false,
  }) async {
    if (!await ensureWalletBackedUp()) {
      if (mounted && closeSheet) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    await action();
    if (mounted && closeSheet) Navigator.pop(context);
  }

  @override
  Future<void> handleSend({bool closeSheet = false}) =>
      _guardedAction(() async {
        await navigateToXrpSend();
        await getTransactionData(Load.refresh);
      }, closeSheet: closeSheet);

  @override
  Future<void> handleReceive({bool closeSheet = false}) =>
      _guardedAction(() => navigateToReceive(), closeSheet: closeSheet);

  @override
  Future<void> changeNet(bool isTest, Load loadType) async {
    try {
      final wap = _walletProvider;
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

  @override
  void initState() {
    super.initState();
    _initData();
    _scrollController.addListener(_onScroll);
    _eventBusFn = eventBus.on().listen((event) async {
      if (event is EventPublic && event.type == EventPublicType.transferOk) {
        _refreshTransactions(Load.refresh);
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

  void _refreshTransactions(Load loadType) {
    getTransactionData(loadType);
    getTransactionDataNetwork(loadType);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final pixel = _scrollController.position.pixels;
    if (pixel > maxScroll - 200) {
      _refreshTransactions(Load.nextPage);
    }
  }

  void _initData() {
    final wap = _walletProvider;
    final coin = widget.coinModel.coin;

    if (coin['isContract'] == true) {
      final cIndex = wap.coinModels.indexWhere(
        (e) => e.config.coinType == coin['coinType'],
      );
      chainCoinModel = wap.coinModels[cIndex];
      _chainName = chainCoinModel!.config.name;
      _chainSymbol = chainCoinModel!.config.miniName;
      _tokenName = coin['name'];
      _tokenSymbol = coin['miniName'];
      browserUrl = getBrowserTokenAddress(
        coin['coinType'],
        widget.coinModel.address,
        coin['contract'],
        isTest: widget.coinModel.isTest,
      );
    } else {
      _chainName = coin['name'];
      _chainSymbol = coin['miniName'];
      browserUrl = getBrowserAddress(
        coin['coinType'],
        widget.coinModel.address,
        isTest: widget.coinModel.isTest,
      );
      _getServiceState();
    }
    marketInfo = wap.getCoinPriceWithUnitAll(coin['unit']);
    _refreshTransactions(Load.refresh);
  }

  Future<void> _getServiceState() async {
    final MessageModel mm = await XrpApi().getServerStateXrp(
      isTest: widget.coinModel.isTest,
    );
    if (!mounted) return;
    if (mm.error == false) {
      widget.coinModel.other?.setServiceState(mm.data);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$_chainSymbol ($_chainName)',
              style: AppTypography.headline.copyWith(
                color: _tc(AppThemeKeys.mainTextColor.name),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_tokenSymbol != null)
              Text(
                '$_tokenSymbol($_tokenName)',
                style: AppTypography.caption.copyWith(
                  color: _tc(AppThemeKeys.mainTextColor.name),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          InkWell(
            onTap: showActionButtonListWidget,
            child: Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(40.0),
                left: ScreenUtil().setWidth(20.0),
              ),
              child: Image.asset(
                'assets/wallet/w_actions.png',
                color: _tc(AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshTransactions(Load.refresh);
            await fetchCoinBalance(widget.coinModel, _walletProvider);
          },
          backgroundColor: _tc(AppThemeKeys.mainButtonBgColor.name),
          color: _tc(AppThemeKeys.mainWhiteColor.name),
          displacement: ScreenUtil().setWidth(72.0),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              WalletChainInfoBoard(
                address: widget.coinModel.address,
                coinType: widget.coinModel.config.coinType,
                balanceStr:
                    '${widget.coinModel.balanceStringAll()} ${widget.coinModel.coin['unit'].toString().toUpperCase()}',
                balanceDollarStr: '\$${widget.coinModel.valueString()}',
                marketValueStr: '\$${widget.coinModel.coinPriceString()}',
                lockAmountStr:
                    '${toEther((widget.coinModel.other?.getLockAmount ?? 0).toString(), widget.coinModel.coin['decimals'])} ${CoinType.XRP.name}',
                xmlLockInfoTap: showXMLLockAmountWidget,
                sendTap: () async => handleSend(),
                receiveTap: () async => handleReceive(),
                browserTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrowserPage(browserUrl),
                    ),
                  );
                },
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                endIndent: 0,
                indent: 0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                child: Text(
                  S.of(context).g_coin_key_1,
                  style: AppTypography.body.copyWith(
                    color: _tc(AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ),
              _transactionsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionsWidget() {
    if (transactionList.isEmpty) {
      return const IntrinsicHeight(child: Center(child: EmptyView()));
    }

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
                  builder: (context) =>
                      TransactionHistoryList(widget.coinModel),
                ),
              );
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_mining_key_49,
                style: AppTypography.body.copyWith(
                  color: _tc(AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          );
        }

        return WalletChainInfoTransactionsItem(
          coinModel: widget.coinModel,
          type: 1,
          transactionModel: transactionList[index],
          onBack: () => getTransactionData(Load.refresh),
        );
      },
    );
  }
}
