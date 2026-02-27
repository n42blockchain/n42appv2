import 'dart:async';

import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_sync.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_xrp_actions.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_address.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_token_address.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_7.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletChainInfoXRP extends ConsumerStatefulWidget {
  final CoinModel coinModel;

  const WalletChainInfoXRP(this.coinModel, {super.key});

  @override
  ConsumerState<WalletChainInfoXRP> createState() =>
      _WalletChainInfoXRPState();
}

class _WalletChainInfoXRPState extends ConsumerState<WalletChainInfoXRP>
    with
        WalletChainInfoSyncMixin<WalletChainInfoXRP>,
        WalletChainInfoXrpActionsMixin<WalletChainInfoXRP> {
  // ── DB accessor ───────────────────────────────────────────────────────────

  AppDatabase? _dbInstance;

  @override
  AppDatabase get db {
    _dbInstance ??= AppDatabase();
    return _dbInstance!;
  }

  // ── Display state ─────────────────────────────────────────────────────────

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
  dynamic getCoinModel() => widget.coinModel;

  // ── Wallet provider ───────────────────────────────────────────────────────

  WalletActionProvider get _walletProvider => ref.read(wapBridgeProvider);

  // ── Backup guard ──────────────────────────────────────────────────────────

  @override
  Future<bool> ensureWalletBackedUp() async {
    if (_walletProvider.walletInfo.password != '') return true;
    final flag = await tipsDialog7(context);
    if (!mounted) return false;
    if (flag == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'BackupOne'),
          builder: (context) => BackupOne(
              _walletProvider.walletInfo, _walletProvider.walletIndex),
        ),
      );
    }
    return false;
  }

  // ── Actions (mixin contract implementation) ───────────────────────────────

  @override
  Future<void> handleSend({bool closeSheet = false}) async {
    if (!await ensureWalletBackedUp()) {
      if (!mounted) return;
      if (closeSheet) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    await navigateToXrpSend();
    await getTransactionData(Load.refresh);
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  @override
  Future<void> handleReceive({bool closeSheet = false}) async {
    if (!await ensureWalletBackedUp()) {
      if (!mounted) return;
      if (closeSheet) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    await navigateToReceive();
    if (!mounted) return;
    if (closeSheet) Navigator.pop(context);
  }

  @override
  Future<void> changeNet(bool isTest, Load loadType) async {
    try {
      final wap = ref.read(wapBridgeProvider);
      wap.walletMap[widget.coinModel.coin['coinType']]['isTest'] = isTest;
      widget.coinModel.isTest = isTest;
      await wap.saveWalletInfo(wap.walletInfo, wap.walletIndex);
      await widget.coinModel.getBalance();
      widget.coinModel.address = null;
      await widget.coinModel.buildWallet();
      await widget.coinModel.getBalance();
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
      if (event is EventPublic &&
          event.type == EventPublicType.transferOk) {
        getTransactionData(Load.refresh);
        getTransactionDataNetwork(Load.refresh);
        await widget.coinModel.getBalance();
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
    if (widget.coinModel.coin['isContract'] == true) {
      final cIndex = ref.read(wapBridgeProvider).coinModels.indexWhere(
            (e) => e.coin['coinType'] == widget.coinModel.coin['coinType'],
          );
      chainCoinModel = ref.read(wapBridgeProvider).coinModels[cIndex];
      _chainName = chainCoinModel?.coin['name'];
      _chainSymbol = chainCoinModel?.coin['miniName'];
      _tokenName = widget.coinModel.coin['name'];
      _tokenSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowserTokenAddress(
        widget.coinModel.coin['coinType'],
        widget.coinModel.address,
        widget.coinModel.coin['contract'],
        isTest: widget.coinModel.isTest,
      );
    } else {
      _chainName = widget.coinModel.coin['name'];
      _chainSymbol = widget.coinModel.coin['miniName'];
      browserUrl = getBrowserAddress(
        widget.coinModel.coin['coinType'],
        widget.coinModel.address,
        isTest: widget.coinModel.isTest,
      );
      _getServiceState();
    }
    marketInfo = ref
        .read(wapBridgeProvider)
        .getCoinPriceWithUnitAll(widget.coinModel.coin['unit']);
    getTransactionData(Load.refresh);
    getTransactionDataNetwork(Load.refresh);
  }

  /// Fetches XRP server state to obtain reserve base and per-object reserve.
  Future<void> _getServiceState() async {
    final MessageModel mm = await XrpApi()
        .getServerStateXrp(isTest: widget.coinModel.isTest);
    if (!mounted) return;
    if (mm.error == false) {
      widget.coinModel.other?.setServiceState(mm.data);
    }
    setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32.0),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_tokenSymbol != null)
              Text(
                '$_tokenSymbol($_tokenName)',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
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
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  getTransactionData(Load.refresh);
                  getTransactionDataNetwork(Load.refresh);
                  await widget.coinModel.getBalance();
                },
                backgroundColor: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainWhiteColor.name),
                displacement: ScreenUtil().setWidth(72.0),
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    WalletChainInfoBoard(
                      address: widget.coinModel.address,
                      coinType: widget.coinModel.coin['coinType'],
                      balanceStr:
                          '${widget.coinModel.balanceStringAll()} ${widget.coinModel.coin['unit'].toString().toUpperCase()}',
                      balanceDollarStr:
                          '\$${widget.coinModel.valueString()}',
                      marketValueStr:
                          '\$${widget.coinModel.coinPriceString()}',
                      lockAmountStr:
                          '${toEther((widget.coinModel.other?.getLockAmount ?? 0).toString(), widget.coinModel.coin['decimals'])} ${CoinType.XRP.name}',
                      xmlLockInfoTap: showXMLLockAmountWidget,
                      sendTap: () async => handleSend(),
                      receiveTap: () async => handleReceive(),
                      browserTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrowserPage(browserUrl)),
                        );
                      },
                      tokenAddTap: null,
                      swapAddTap: null,
                      sellAddTap: null,
                    ),
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(20.0),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(30.0),
                      ),
                      child: Text(
                        S.of(context).g_coin_key_1,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30.0),
                        ),
                      ),
                    ),
                    _transactionsWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionsWidget() {
    if (transactionList.isEmpty) {
      return const IntrinsicHeight(
        child: Center(child: EmptyView()),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      itemCount: transactionList.length + 1,
      itemBuilder: (context, int index) {
        if (index == transactionList.length) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TransactionHistoryList(widget.coinModel)),
              );
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_mining_key_49,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            ),
          );
        }

        if (widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Bitcoin.name) {
          final BtcTransactionRecodeModel trm = transactionList[index];
          return WalletChainInfoTransactionsItem(
            coinModel: widget.coinModel,
            type: 0,
            transactionModel: trm,
            onBack: () => getTransactionData(Load.refresh),
          );
        } else {
          final TransationRecordModel trm = transactionList[index];
          return WalletChainInfoTransactionsItem(
            type: 1,
            transactionModel: trm,
            coinModel: widget.coinModel,
            onBack: () => getTransactionData(Load.refresh),
          );
        }
      },
    );
  }
}
