import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_get_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_miner_fee_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_pay_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_summary.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_transactions.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/widgets/arlert_widget.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:decimal/decimal.dart' as dec;
import 'package:date_format/date_format.dart' as dformat;

part 'swap_ast_home_build.dart';
part 'swap_ast_home_tx.dart';

class SwapAstHome extends ConsumerStatefulWidget {
  final double? getAstNum;
  const SwapAstHome({this.getAstNum, super.key});

  @override
  ConsumerState<SwapAstHome> createState() => _SwapAstHomeState();
}

class _SwapAstHomeState extends ConsumerState<SwapAstHome> {
  late final Regular _regular = Regular();

  Load load = Load.loading;
  String errorMessage = "";

  final TextEditingController payTextEditingController =
      TextEditingController();
  final TextEditingController getTextEditingController =
      TextEditingController();
  final FocusNode payNode = FocusNode();
  final FocusNode getNode = FocusNode();

  SwapAstModel? youPay;
  CoinModel? payCoinModel;
  CoinModel? getCoinModel;

  Load getLoad = Load.finish;
  Load payLoad = Load.finish;

  List<SwapAstModel> swapAstList = [];
  List<dynamic> coinMarketInfo = [];

  bool readStatement = false;
  Map<String, dynamic>? token;
  int? orderId;

  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gas = BigInt.zero;

  late final SwapAstApi _swapAstApi = SwapAstApi();
  late final TokenViewApi _tokenViewApi = TokenViewApi();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    payTextEditingController.text = "0";
    getTextEditingController.text = "${widget.getAstNum ?? 0}";
    init();
  }

  @override
  void dispose() {
    payTextEditingController.dispose();
    getTextEditingController.dispose();
    payNode.dispose();
    getNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildPage(context);

  // Non-protected wrapper so part-file extensions can trigger rebuilds.
  // ignore: invalid_use_of_protected_member
  void rebuild([VoidCallback? fn]) => setState(fn ?? () {});

  void _toggleReadStatement() {
    setState(() => readStatement = !readStatement);
  }

  Future<void> _onChainSelected(SwapAstModel rModel) async {
    youPay = rModel;
    payCoinModel = getChainCoinModel((youPay?.payChain ?? "").toUpperCase());
    if (payCoinModel != null) {
      getUsdtMap(
        payCoinModel!.coin['coinType'] as String,
        youPay?.payCoinContract ?? "",
      );
    }
    setState(() {});
    getBalanceChainPay();
    getBalancePay();
    final bool rCoinPrice = await getCoinPrice();
    if (!mounted) return;
    if (rCoinPrice) {
      final bool rGasPrice = await getGasPrice();
      if (!mounted) return;
      if (rGasPrice) {
        await estimateGasEth();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    getAstChainModel();
    bool ok = await getAstList();
    if (!ok) {
      load = Load.error;
      setState(() {});
      return;
    }
    ok = await getCoinPrice();
    if (!ok) {
      load = Load.error;
      setState(() {});
      return;
    }
    ok = await getGasPrice();
    if (ok) {
      estimateGasEth();
      load = Load.finish;
    } else {
      load = Load.error;
    }
    setState(() {});
  }

  Future<void> getAstChainModel() async {
    final WalletActionProvider wa = ref.read(wapBridgeProvider);
    final Map<String, dynamic> astModel =
        wa.walletMap[CoinType.N.name] as Map<String, dynamic>;
    final CoinModel cm =
        CoinModel.fromMap(astModel['baseInfo'] as Map<String, dynamic>);
    cm.showList = astModel['showList'];
    cm.isTest = false;
    cm.addrType = astModel['addrType'];
    cm.pathIndex = astModel['pathIndex'] ?? 0;
    getCoinModel = cm;
    await getCoinModel!.buildWallet();
    getCoinModel!.getBalanceDefault();
    setState(() {});
    getBalanceGet();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<bool> getAstList() async {
    final MessageModel rData = await _swapAstApi.getNftOrAstList(2);
    if (rData.error) {
      setState(() {
        load = Load.error;
        errorMessage = rData.data as String;
      });
      return false;
    }

    swapAstList
      ..clear()
      ..addAll((rData.data as List)
          .map((e) => SwapAstModel.fromJson(e as Map<String, dynamic>)));

    if (swapAstList.isEmpty) {
      if (!mounted) return false;
      errorMessage = S.of(context).g_key_132;
      return false;
    }

    if (youPay != null) {
      final int ypIndex =
          swapAstList.indexWhere((e) => e.payChain == youPay!.payChain);
      youPay = ypIndex != -1 ? swapAstList[ypIndex] : swapAstList[0];
    } else {
      youPay = swapAstList[0];
    }

    payCoinModel =
        getChainCoinModel((youPay?.payChain ?? "").toUpperCase());
    if (payCoinModel != null) {
      getUsdtMap(
          payCoinModel!.coin['coinType'] as String,
          youPay?.payCoinContract ?? "");
    }
    errorMessage = "";
    setState(() {});
    getBalanceChainPay();
    getBalancePay();
    return true;
  }

  CoinModel? getChainCoinModel(String symbol) {
    if (symbol == "BSC") symbol = CoinType.BNB.name;
    final List<CoinModel> rList =
        ref.read(wapBridgeProvider).getCoinModelWithSymbols(symbols: symbol);
    return rList.isNotEmpty ? rList[0] : null;
  }

  void getUsdtMap(String chainSymbol, String contractAddress) {
    token = null;
    if (contractAddress.isNotEmpty) {
      final Map<String, dynamic>? txChainMap = ref
          .read(wapBridgeProvider)
          .walletMap[chainSymbol.toUpperCase()] as Map<String, dynamic>?;
      if (txChainMap != null &&
          (txChainMap['mainnets'] as Map).isNotEmpty) {
        token = txChainMap['mainnets'][contractAddress.toUpperCase()]
            as Map<String, dynamic>?;
      }
    }
    setState(() {});
  }

  Future<void> getBalanceChainPay() async {
    if (payCoinModel == null) return;
    if (payLoad == Load.loading) return;
    setState(() => payLoad = Load.loading);

    final MessageModel rData = await _tokenViewApi.getBalance(
          payCoinModel!.coin['blockchainType'] as String,
          payCoinModel!.coin['coinType'] as String,
          payCoinModel!.address.toString()) ??
        MessageModel.error();
    payCoinModel!.balance =
        rData.error ? BigInt.zero : rData.data as BigInt;
    setState(() => payLoad = Load.finish);
  }

  Future<void> getBalancePay() async {
    if (youPay == null || payCoinModel == null) return;
    setState(() => youPay!.load = Load.loading);

    final MessageModel rData = await _tokenViewApi.getBalance(
          payCoinModel!.coin['blockchainType'] as String,
          (payCoinModel!.coin['coinType'] as String? ?? "").toUpperCase(),
          payCoinModel?.address ?? "",
          contract: youPay?.payCoinContract ?? "") ??
        MessageModel.error();

    if (rData.error) {
      youPay!.balance = 0;
    } else {
      youPay!.balance =
          toEther(rData.data.toString(), youPay?.payCoinDecimal ?? 6)
              .toDouble();
    }
    setState(() => youPay!.load = Load.finish);
  }

  Future<void> getBalanceGet() async {
    if (getCoinModel == null) return;
    if (getLoad == Load.loading) return;
    setState(() => getLoad = Load.loading);

    final MessageModel rData = await _tokenViewApi.getBalance(
          BlockchainType.Ethereum.name,
          CoinType.N.name,
          getCoinModel!.address.toString()) ??
        MessageModel.error();
    getCoinModel!.balance =
        rData.error ? BigInt.zero : rData.data as BigInt;
    setState(() => getLoad = Load.finish);
  }

  // ---------------------------------------------------------------------------
  // Price calculation
  // ---------------------------------------------------------------------------

  Future<bool> getCoinPrice() async {
    final String keys = 'n,${youPay!.payCoin?.toLowerCase() ?? ""}';
    final Map<String, dynamic> list =
        await MarketApi().getWalletCoinsInfo(keys);
    if (!mounted) return false;
    if (list['error'] as bool) {
      errorMessage = S.of(context).g_swap_key_15;
      return false;
    }
    coinMarketInfo = list['data']['data'] as List<dynamic>;
    errorMessage = "";
    setCoinModelPrice();
    return true;
  }

  void setCoinModelPrice() {
    final int index =
        coinMarketInfo.indexWhere((e) => (e as Map)['coin'] == "n");
    final Map<String, dynamic> astCoinInfo =
        coinMarketInfo[index] as Map<String, dynamic>;
    getCoinModel!.coinPrice = (astCoinInfo['price'] as num).toDouble();

    final int indexPay = coinMarketInfo.indexWhere(
        (e) => (e as Map)['coin'] == (youPay?.payCoin ?? "").toLowerCase());
    final Map<String, dynamic> payCoinInfo =
        coinMarketInfo[indexPay] as Map<String, dynamic>;
    youPay!.price = (payCoinInfo['price'] as num).toDouble();
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Input handling
  // ---------------------------------------------------------------------------

  void payInput({String? value}) {
    value ??= payTextEditingController.text;
    if (!_regular.regularNums(value) && !_regular.regularDouble(value)) return;
    if (value == "0") return;
    final double getValue = dec.Decimal.parse(value).toDouble() *
        ((youPay?.price ?? 0) / (getCoinModel?.coinPrice ?? 0));
    getTextEditingController.text =
        '${_regular.formartNumDouble(dec.Decimal.parse(getValue.toString()).toDouble(), 8, isCrop: true, isFill0: false)}';
    setState(() {});
  }

  void getInput({String? value}) {
    value ??= getTextEditingController.text;
    if (!_regular.regularNums(value) && !_regular.regularDouble(value)) return;
    if (value == "0") return;
    final double p = (getCoinModel?.coinPrice ?? 0) / (youPay?.price ?? 0);
    final double payValue = double.parse(value) * p;
    payTextEditingController.text =
        '${_regular.formartNumDouble(dec.Decimal.parse(payValue.toString()).toDouble(), 8, isCrop: true, isFill0: false)}';
    setState(() {});
  }

  bool checkPayInput() {
    final String value = payTextEditingController.text;
    if (!_regular.regularNums(value) && !_regular.regularDouble(value)) {
      return false;
    }
    final double pay = double.parse(value);
    if (pay == 0) return false;
    if ((youPay?.balance ?? 0) < pay) return false;
    return true;
  }

  void percentTap(int percent) {
    if (load != Load.finish) return;
    final double ypBalance = youPay?.balance ?? 0;
    if (ypBalance <= 0) return;
    payTextEditingController.text = '${_regular.formartNumDouble(
      ypBalance * (percent / 100), 8, isCrop: true, isFill0: false)}';
    payInput(value: (ypBalance * (percent / 100)).toString());
  }
}
