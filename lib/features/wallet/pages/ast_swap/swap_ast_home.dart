import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_price_utils.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_get_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_miner_fee_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_pay_widget.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_summary.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_transactions.dart';
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

    if (!await getCoinPrice() || !mounted) return;
    if (!await getGasPrice() || !mounted) return;
    await estimateGasEth();
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    getAstChainModel();
    final bool ok =
        await getAstList() && await getCoinPrice() && await getGasPrice();
    if (ok) {
      estimateGasEth();
    }
    load = ok ? Load.finish : Load.error;
    setState(() {});
  }

  Future<void> getAstChainModel() async {
    final WalletActionProvider wa = ref.read(wapBridgeProvider);
    final Map<String, dynamic> astModel =
        wa.walletMap[CoinType.N.name] as Map<String, dynamic>;
    final CoinModel cm = CoinModel.fromMap(
      astModel['baseInfo'] as Map<String, dynamic>,
    );
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
      ..addAll(
        (rData.data as List).map(
          (e) => SwapAstModel.fromJson(e as Map<String, dynamic>),
        ),
      );

    if (swapAstList.isEmpty) {
      if (!mounted) return false;
      errorMessage = S.of(context).g_key_132;
      return false;
    }

    if (youPay != null) {
      final int ypIndex = swapAstList.indexWhere(
        (e) => e.payChain == youPay!.payChain,
      );
      youPay = ypIndex != -1 ? swapAstList[ypIndex] : swapAstList[0];
    } else {
      youPay = swapAstList[0];
    }

    payCoinModel = getChainCoinModel((youPay?.payChain ?? "").toUpperCase());
    if (payCoinModel != null) {
      getUsdtMap(
        payCoinModel!.coin['coinType'] as String,
        youPay?.payCoinContract ?? "",
      );
    }
    errorMessage = "";
    setState(() {});
    getBalanceChainPay();
    getBalancePay();
    return true;
  }

  CoinModel? getChainCoinModel(String symbol) {
    final String normalized = symbol == "BSC" ? CoinType.BNB.name : symbol;
    final List<CoinModel> rList = ref
        .read(wapBridgeProvider)
        .getCoinModelWithSymbols(symbols: normalized);
    return rList.isNotEmpty ? rList.first : null;
  }

  void getUsdtMap(String chainSymbol, String contractAddress) {
    token = null;
    if (contractAddress.isNotEmpty) {
      final Map<String, dynamic>? txChainMap =
          ref.read(wapBridgeProvider).walletMap[chainSymbol.toUpperCase()]
              as Map<String, dynamic>?;
      if (txChainMap != null && (txChainMap['mainnets'] as Map).isNotEmpty) {
        token =
            txChainMap['mainnets'][contractAddress.toUpperCase()]
                as Map<String, dynamic>?;
      }
    }
    setState(() {});
  }

  Future<void> getBalanceChainPay() async {
    if (payCoinModel == null || payLoad == Load.loading) return;
    setState(() => payLoad = Load.loading);
    payCoinModel!.balance = await _fetchBalance(
      payCoinModel!.coin['blockchainType'] as String,
      payCoinModel!.coin['coinType'] as String,
      payCoinModel!.address.toString(),
    );
    setState(() => payLoad = Load.finish);
  }

  Future<void> getBalancePay() async {
    if (youPay == null || payCoinModel == null) return;
    setState(() => youPay!.load = Load.loading);

    final MessageModel rData =
        await _tokenViewApi.getBalance(
          payCoinModel!.coin['blockchainType'] as String,
          (payCoinModel!.coin['coinType'] as String? ?? "").toUpperCase(),
          payCoinModel?.address ?? "",
          contract: youPay?.payCoinContract ?? "",
        ) ??
        MessageModel.error();

    youPay!.balance = rData.error
        ? 0
        : toEther(
            rData.data.toString(),
            youPay?.payCoinDecimal ?? 6,
          ).toDouble();
    setState(() => youPay!.load = Load.finish);
  }

  Future<void> getBalanceGet() async {
    if (getCoinModel == null || getLoad == Load.loading) return;
    setState(() => getLoad = Load.loading);
    getCoinModel!.balance = await _fetchBalance(
      BlockchainType.Ethereum.name,
      CoinType.N.name,
      getCoinModel!.address.toString(),
    );
    setState(() => getLoad = Load.finish);
  }

  Future<BigInt> _fetchBalance(
    String blockchainType,
    String coinType,
    String address,
  ) async {
    final MessageModel rData =
        await _tokenViewApi.getBalance(blockchainType, coinType, address) ??
        MessageModel.error();
    return rData.error ? BigInt.zero : rData.data as BigInt;
  }

  // ---------------------------------------------------------------------------
  // Price calculation
  // ---------------------------------------------------------------------------

  Future<bool> getCoinPrice() async {
    final String keys = 'n,${youPay!.payCoin?.toLowerCase() ?? ""}';
    final Map<String, dynamic> list = await MarketApi().getWalletCoinsInfo(
      keys,
    );
    if (!mounted) return false;
    if (list['error'] as bool) {
      errorMessage = S.of(context).g_swap_key_15;
      return false;
    }
    coinMarketInfo = extractMarketCoinItems(list['data']);
    if (!setCoinModelPrice()) {
      errorMessage = S.of(context).g_swap_key_15;
      return false;
    }
    errorMessage = "";
    return true;
  }

  bool setCoinModelPrice() {
    if (getCoinModel == null || youPay == null) return false;

    final Map<String, dynamic>? astCoinInfo = findSwapAstMarketCoin(
      coinMarketInfo,
      'n',
    );
    final Map<String, dynamic>? payCoinInfo = findSwapAstMarketCoin(
      coinMarketInfo,
      youPay?.payCoin ?? '',
    );
    final double? astPrice = (astCoinInfo?['price'] as num?)?.toDouble();
    final double? payPrice = (payCoinInfo?['price'] as num?)?.toDouble();

    if (astPrice == null ||
        astPrice <= 0 ||
        payPrice == null ||
        payPrice <= 0) {
      return false;
    }

    getCoinModel!.coinPrice = astPrice;
    youPay!.price = payPrice;
    setState(() {});
    return true;
  }

  // ---------------------------------------------------------------------------
  // Input handling
  // ---------------------------------------------------------------------------

  bool _isValidNumericInput(String value) =>
      _regular.regularNums(value) || _regular.regularDouble(value);

  String _formatAmount(double value) => _regular
      .formartNumDouble(
        dec.Decimal.parse(value.toString()).toDouble(),
        8,
        isCrop: true,
        isFill0: false,
      )
      .toString();

  void payInput({String? value}) {
    value ??= payTextEditingController.text;
    if (!_isValidNumericInput(value) || value == "0") return;
    final double converted = calculateSwapAstConvertedAmount(
      value: value,
      fromPrice: youPay?.price ?? 0,
      toPrice: getCoinModel?.coinPrice ?? 0,
    );
    if (converted <= 0) return;
    getTextEditingController.text = _formatAmount(converted);
    setState(() {});
  }

  void getInput({String? value}) {
    value ??= getTextEditingController.text;
    if (!_isValidNumericInput(value) || value == "0") return;
    final double converted = calculateSwapAstConvertedAmount(
      value: value,
      fromPrice: getCoinModel?.coinPrice ?? 0,
      toPrice: youPay?.price ?? 0,
    );
    if (converted <= 0) return;
    payTextEditingController.text = _formatAmount(converted);
    setState(() {});
  }

  bool checkPayInput() {
    final String value = payTextEditingController.text;
    if (!_isValidNumericInput(value)) return false;
    final double pay = double.parse(value);
    return pay > 0 && (youPay?.balance ?? 0) >= pay;
  }

  void percentTap(int percent) {
    if (load != Load.finish) return;
    final double ypBalance = youPay?.balance ?? 0;
    if (ypBalance <= 0) return;
    final double amount = ypBalance * (percent / 100);
    payTextEditingController.text = _formatAmount(amount);
    payInput(value: amount.toString());
  }
}
