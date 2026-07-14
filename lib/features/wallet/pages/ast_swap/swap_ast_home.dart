import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/api/swap_ast_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/models/ast_swap/swap_ast_model.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
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

Map<String, dynamic>? _swapMapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return null;
}

List<dynamic> _swapListValue(dynamic value) {
  if (value is List) return value;
  return const [];
}

String _swapStringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int _swapIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _swapDoubleValue(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

BigInt _swapBigIntValue(dynamic value, {BigInt? fallback}) {
  if (value is BigInt) return value;
  if (value is int) return BigInt.from(value);
  if (value is num) return BigInt.from(value.toInt());
  return BigInt.tryParse(value?.toString() ?? '') ?? (fallback ?? BigInt.zero);
}

bool _swapBoolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return fallback;
}

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

  Map<String, dynamic> get _payCoinData => payCoinModel?.coin ?? const {};

  String get _payCoinType => _swapStringValue(_payCoinData['coinType']);

  String get _payBlockchainType =>
      _swapStringValue(_payCoinData['blockchainType']);

  String? get _payServiceRpc {
    final service = _payCoinData['service'];
    final value = _swapStringValue(service);
    return value.isEmpty ? null : value;
  }

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
    if (payCoinModel != null && _payCoinType.isNotEmpty) {
      getUsdtMap(_payCoinType, youPay?.payCoinContract ?? "");
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
    if (!mounted) return;
    if (ok) {
      estimateGasEth();
    }
    load = ok ? Load.finish : Load.error;
    setState(() {});
  }

  Future<void> getAstChainModel() async {
    final WalletActionProvider wa = ref.read(wapBridgeProvider);
    final Map<String, dynamic>? astModel = _swapMapValue(
      wa.walletMap[CoinType.N.name],
    );
    final Map<String, dynamic>? baseInfo = _swapMapValue(astModel?['baseInfo']);
    if (astModel == null || baseInfo == null) {
      errorMessage = S.of(context).g_key_132;
      return;
    }
    final CoinModel cm = CoinModel.fromMap(baseInfo);
    cm.showList = astModel['showList'];
    cm.isTest = false;
    cm.addrType = astModel['addrType'];
    cm.pathIndex = astModel['pathIndex'] ?? 0;
    getCoinModel = cm;
    await buildCoinWallet(getCoinModel!, wa);
    if (!mounted) return;
    applyCachedBalance(getCoinModel!);
    setState(() {});
    getBalanceGet();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<bool> getAstList() async {
    final MessageModel rData = await _swapAstApi.getNftOrAstList(2);
    if (!mounted) return false;
    if (rData.error) {
      setState(() {
        load = Load.error;
        errorMessage = _swapStringValue(rData.data, fallback: 'Error');
      });
      return false;
    }

    swapAstList
      ..clear()
      ..addAll(
        _swapListValue(rData.data).whereType<Map>().map(
          (e) => SwapAstModel.fromJson(
            e.map((key, value) => MapEntry(key.toString(), value)),
          ),
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
    if (payCoinModel != null && _payCoinType.isNotEmpty) {
      getUsdtMap(_payCoinType, youPay?.payCoinContract ?? "");
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
      final Map<String, dynamic>? txChainMap = _swapMapValue(
        ref.read(wapBridgeProvider).walletMap[chainSymbol.toUpperCase()],
      );
      final Map<String, dynamic>? mainnets = _swapMapValue(
        txChainMap?['mainnets'],
      );
      if (mainnets != null && mainnets.isNotEmpty) {
        token = _swapMapValue(mainnets[contractAddress.toUpperCase()]);
      }
    }
    setState(() {});
  }

  Future<void> getBalanceChainPay() async {
    if (payCoinModel == null || payLoad == Load.loading) return;
    if (_payBlockchainType.isEmpty || _payCoinType.isEmpty) {
      setState(() => payLoad = Load.finish);
      return;
    }
    setState(() => payLoad = Load.loading);
    payCoinModel!.balance = await _fetchBalance(
      _payBlockchainType,
      _payCoinType,
      payCoinModel!.address.toString(),
    );
    if (!mounted) return;
    setState(() => payLoad = Load.finish);
  }

  Future<void> getBalancePay() async {
    if (youPay == null || payCoinModel == null) return;
    if (_payBlockchainType.isEmpty || _payCoinType.isEmpty) {
      youPay!.balance = 0;
      return;
    }
    setState(() => youPay!.load = Load.loading);

    final MessageModel rData =
        await _tokenViewApi.getBalance(
          _payBlockchainType,
          _payCoinType.toUpperCase(),
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
    if (!mounted) return;
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
    if (!mounted) return;
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
    return rData.error ? BigInt.zero : _swapBigIntValue(rData.data);
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
    if (_swapBoolValue(list['error'])) {
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
    final double astPrice = _swapDoubleValue(astCoinInfo?['price']);
    final double payPrice = _swapDoubleValue(payCoinInfo?['price']);

    if (astPrice <= 0 || payPrice <= 0) {
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
