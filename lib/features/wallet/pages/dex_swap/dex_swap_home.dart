import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show getPathWithIndex;
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_constants.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_history.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_order_form.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_orders_page.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_quote_card.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_token_card.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/builder/calldata_builder.dart';
import 'package:n42_wallet/features/wallet/api/sender/aa_transfer_handler.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes;
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

class DexSwapHome extends ConsumerStatefulWidget {
  const DexSwapHome({super.key});

  @override
  ConsumerState<DexSwapHome> createState() => _DexSwapHomeState();
}

class _DexSwapHomeState extends ConsumerState<DexSwapHome> {
  final DexSwapApi _dexApi = DexSwapApi();
  final TextEditingController _amountCtrl = TextEditingController();

  Timer? _debounce;
  Timer? _expiryTicker;

  // ── Chain / token state ───────────────────────────────────────────────────
  String _chain = 'ETH';
  DexTokenModel? _tokenIn;
  DexTokenModel? _tokenOut;

  // ── Quote state ───────────────────────────────────────────────────────────
  DexQuoteModel? _quote;
  Load _quoteLoad = Load.finish;
  int _quoteSecsLeft = 0;

  // ── Slippage (baked into quote calldata — must re-fetch on change) ────────
  // Options: 10 = 0.1%, 50 = 0.5%, 100 = 1%, 200 = 2%
  static const List<int> _slippageOptions = [10, 50, 100, 200];
  int _slippageBps = 50;

  // ── ERC-20 approval state ─────────────────────────────────────────────────
  bool _needsApproval = false;
  Load _approveLoad = Load.finish;

  /// When true, approves exact amountIn instead of MaxUint256.
  bool _exactApprove = false;

  // ── Swap / error state ────────────────────────────────────────────────────
  Load _swapLoad = Load.finish;
  String _errorMsg = '';

  // ── Price chart state ─────────────────────────────────────────────────────
  bool _showChart = false;
  List<double> _chartPrices = [];
  bool _chartLoading = false;
  int _chartPeriodDays = 1;

  // ── Mode: Market swap vs Limit order ────────────────────────────────────────
  bool _isLimitMode = false;

  // ── Gas-free (AA / Paymaster) state ────────────────────────────────────────
  bool _gasFreeEnabled = false;

  /// Max uint256 for unlimited ERC-20 approvals
  static final BigInt _maxUint256 = BigInt.two.pow(256) - BigInt.one;

  // ── Wallet addresses by chain ─────────────────────────────────────────────
  String _evmAddr = '';
  String _solAddr = '';

  String get _userAddr => _chain == 'SOL' ? _solAddr : _evmAddr;

  /// Check if current chain supports AA Gas-free swaps
  bool get _canUseGasFree {
    return _smartAccount != null;
  }

  /// Get the primary smart account for the current chain
  SmartAccount? get _smartAccount {
    final walletInfo = ref.read(wapBridgeProvider).walletInfo;
    if (!walletInfo.hasAAAccounts) return null;
    final chainId = AAConfig.chainIds[_chain];
    if (chainId == null) return null;
    return walletInfo.getPrimarySmartAccount(chainId);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAddresses();
    _amountCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _expiryTicker?.cancel();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Address resolution ────────────────────────────────────────────────────

  void _initAddresses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final WalletActionProvider wa = ref.read(wapBridgeProvider);
      for (final CoinModel cm in wa.coinModels) {
        if (_evmAddr.isNotEmpty && _solAddr.isNotEmpty) break;
        final addr = cm.address ?? '';
        if (addr.isEmpty) continue;
        if (addr.startsWith('0x') && _evmAddr.isEmpty) {
          _evmAddr = addr;
        } else if (_solAddr.isEmpty && addr.length >= 32 && addr.length <= 44) {
          _solAddr = addr;
        }
      }
      if (mounted) setState(() {});
    });
  }

  /// Builds the HD path for [chainCoinType] from the wallet's coin models.
  /// Returns null if the coin model cannot be found.
  String? _buildChainPath(String chainCoinType) {
    final wa = ref.read(wapBridgeProvider);
    for (final cm in wa.coinModels) {
      if ((cm.coin['coinType'] as String? ?? '') == chainCoinType) {
        final addrType = cm.addrType;
        final basePath =
            cm.config.pathForAddrType(addrType) ?? "m/44'/60'/0'/0/0";
        return getPathWithIndex(basePath, cm.pathIndex);
      }
    }
    return null;
  }

  CoinModel? _chainCoinModel(String chainCoinType) {
    final wa = ref.read(wapBridgeProvider);
    for (final cm in wa.coinModels) {
      if (cm.config.coinType == chainCoinType) return cm;
    }
    return null;
  }

  // ── Quote state helpers ───────────────────────────────────────────────────

  void _clearQuote() {
    _expiryTicker?.cancel();
    setState(() {
      _quote = null;
      _needsApproval = false;
      _errorMsg = '';
      _quoteSecsLeft = 0;
    });
  }

  // ── Chain / amount change ─────────────────────────────────────────────────

  /// Try to fetch a quote if both tokens are selected and the amount is valid.
  void _tryFetchQuote() {
    final amount = _amountCtrl.text.trim();
    if (amount.isNotEmpty &&
        amount != '0' &&
        _tokenIn != null &&
        _tokenOut != null) {
      _fetchQuote(amount);
    }
  }

  void _onChainChanged(String chain) {
    _clearQuote();
    setState(() {
      _chain = chain;
      _tokenIn = null;
      _tokenOut = null;
      _chartPrices = [];
      _gasFreeEnabled = false;
    });
    _amountCtrl.clear();
  }

  void _onAmountChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_tokenIn != null && _tokenOut != null) {
        _tryFetchQuote();
      } else {
        _clearQuote();
      }
    });
  }

  // ── Slippage ──────────────────────────────────────────────────────────────

  void _onSlippageChanged(int bps) {
    if (_slippageBps == bps) return;
    setState(() => _slippageBps = bps);
    _clearQuote();
    _tryFetchQuote();
  }

  // ── Price chart ───────────────────────────────────────────────────────────

  /// Fetch price history for [_tokenIn] from CoinGecko.
  /// Silently clears chart if the token is unknown or the request fails.
  Future<void> _fetchPriceChart() async {
    final geckoId = kDexSymbolToGeckoId[_tokenIn?.symbol.toUpperCase()];
    if (geckoId == null) {
      setState(() => _chartPrices = []);
      return;
    }
    setState(() => _chartLoading = true);
    try {
      final data = await MarketApi().getMarketChart(
        geckoId,
        days: _chartPeriodDays,
      );
      if (mounted) setState(() => _chartPrices = data['prices'] ?? []);
    } catch (_) {
      if (mounted) setState(() => _chartPrices = []);
    } finally {
      if (mounted) setState(() => _chartLoading = false);
    }
  }

  // ── Quote fetching ────────────────────────────────────────────────────────

  /// 单调递增请求 ID，防止过期响应覆盖最新状态
  int _quoteRequestId = 0;

  Future<void> _fetchQuote(String amountHuman) async {
    if (_tokenIn == null || _tokenOut == null || _userAddr.isEmpty) return;

    final BigInt amountWei = dexToWei(amountHuman, _tokenIn!.decimals);
    if (amountWei == BigInt.zero) return;

    final requestId = ++_quoteRequestId;
    _clearQuote();
    setState(() => _quoteLoad = Load.loading);

    final MessageModel res = await _dexApi.getQuote(
      chain: _chain,
      tokenIn: _tokenIn!.address,
      tokenOut: _tokenOut!.address,
      amountIn: amountWei.toString(),
      userAddr: _userAddr,
      slippageBps: _slippageBps,
    );
    if (!mounted || requestId != _quoteRequestId) return;

    if (res.error) {
      setState(() {
        _quoteLoad = Load.finish;
        _errorMsg =
            res.data?.toString() ?? S.of(context).g_key_dex_quote_failed;
      });
      return;
    }

    final quote = DexQuoteModel.fromJson(
      res.data as Map<String, dynamic>,
      slippageBps: _slippageBps,
    );

    // For EVM non-native tokens, check if approval is needed
    final bool needsApprove = await _checkApprovalNeeded(amountWei, quote);
    if (!mounted || requestId != _quoteRequestId) return;

    setState(() {
      _quoteLoad = Load.finish;
      _quote = quote;
      _needsApproval = needsApprove;
      _quoteSecsLeft = kDexQuoteTtlSeconds;
    });
    _startExpiryTimer(amountHuman);
  }

  // ── Quote expiry timer ────────────────────────────────────────────────────

  void _startExpiryTimer(String amountHuman) {
    _expiryTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _expiryTicker?.cancel();
        return;
      }
      setState(() => _quoteSecsLeft--);
      if (_quoteSecsLeft <= 0) {
        _expiryTicker?.cancel();
        _fetchQuote(amountHuman);
      }
    });
  }

  // ── ERC-20 approval check ─────────────────────────────────────────────────

  /// Returns true if the token-in is an ERC-20 that needs approval.
  Future<bool> _checkApprovalNeeded(
    BigInt amountIn,
    DexQuoteModel quote,
  ) async {
    final tokenAddr = _tokenIn?.address ?? '';
    final coinType = dexCoinTypeForChain(_chain);
    // Skip approval for: native tokens, Solana, or missing context
    if (tokenAddr.isEmpty ||
        tokenAddr == '0x0000000000000000000000000000000000000000' ||
        _chain == 'SOL' ||
        coinType.isEmpty ||
        _userAddr.isEmpty ||
        quote.routerAddr.isEmpty) {
      return false;
    }
    final allowance = await DexSwapApi.checkAllowance(
      coinType: coinType,
      tokenAddr: tokenAddr,
      owner: _userAddr,
      spender: quote.routerAddr,
    );
    return allowance < amountIn;
  }

  // ── Approve ───────────────────────────────────────────────────────────────

  Future<void> _executeApprove() async {
    final DexQuoteModel? q = _quote;
    if (q == null || _approveLoad == Load.loading) return;

    setState(() {
      _approveLoad = Load.loading;
      _errorMsg = '';
    });

    BigInt? exactAmount;
    if (_exactApprove && _tokenIn != null) {
      final wei = dexToWei(_amountCtrl.text.trim(), _tokenIn!.decimals);
      if (wei > BigInt.zero) exactAmount = wei;
    }

    final coinType = dexCoinTypeForChain(_chain);
    final chainCoin = _chainCoinModel(coinType);
    final path = _buildChainPath(coinType);
    if (path == null) {
      setState(() {
        _approveLoad = Load.finish;
        _errorMsg = S.of(context).g_key_175;
      });
      return;
    }

    final approveResult = await SenderFactory.instance
        .getSender(coinType)
        .send(
          SendParams(
            coinType: coinType,
            fromAddress: _userAddr,
            toAddress: _tokenIn!.address,
            amount: 0.0,
            decimals: 18,
            path: path,
            isTest: chainCoin?.isTest ?? false,
            privateKey: chainCoin?.privateKey,
            chainConfig: chainCoin?.coin,
            calldata: DexSwapApi.buildApproveCalldata(
              q.routerAddr,
              amount: exactAmount,
            ),
          ),
        );
    if (!mounted) return;

    if (!approveResult.success) {
      setState(() {
        _approveLoad = Load.finish;
        _errorMsg = approveResult.error ?? S.of(context).g_key_175;
      });
      return;
    }

    setState(() {
      _approveLoad = Load.finish;
      _needsApproval = false;
      _errorMsg = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_dex_approval_success),
        backgroundColor: AppColorTokens.of(context).success,
      ),
    );
  }

  // ── Swap execution ────────────────────────────────────────────────────────

  Future<void> _executeSwap() async {
    final DexQuoteModel? q = _quote;
    if (q == null || _swapLoad == Load.loading) return;

    setState(() {
      _swapLoad = Load.loading;
      _errorMsg = '';
    });

    String txHash;

    // Gas-free path: route through AA handler with Paymaster
    if (_gasFreeEnabled && _smartAccount != null) {
      final txRes = await _executeAASwap(q);
      if (!mounted) return;
      if (txRes.error) {
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = txRes.data?.toString() ?? S.of(context).g_key_175;
        });
        return;
      }
      txHash = txRes.data['txHash'] as String? ?? '';
    } else {
      final swapChain = dexCoinTypeForChain(_tokenIn?.chain ?? _chain);
      final chainCoin = _chainCoinModel(swapChain);
      final path = _buildChainPath(swapChain);
      if (path == null) {
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = S.of(context).g_key_175;
        });
        return;
      }
      final swapResult = await SenderFactory.instance
          .getSender(swapChain)
          .send(
            SendParams(
              coinType: swapChain,
              fromAddress: _userAddr,
              toAddress: q.routerAddr,
              amount: 0.0,
              decimals: 18,
              path: path,
              isTest: chainCoin?.isTest ?? false,
              privateKey: chainCoin?.privateKey,
              chainConfig: chainCoin?.coin,
              calldata: q.calldata,
            ),
          );
      if (!mounted) return;
      if (!swapResult.success) {
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = swapResult.error ?? S.of(context).g_key_175;
        });
        return;
      }
      txHash = swapResult.txHash ?? '';
    }
    if (!mounted) return;

    await _dexApi.commit(AppGlobals.userInfo?.uuid ?? '', q.orderId, txHash);
    if (!mounted) return;

    _clearQuote();
    setState(() => _swapLoad = Load.finish);
    _amountCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).g_key_dex_swap_success)),
    );
  }

  /// Execute swap via Account Abstraction (ERC-4337) with Paymaster
  Future<MessageModel> _executeAASwap(DexQuoteModel quote) async {
    final smartAccount = _smartAccount;
    if (smartAccount == null) {
      return MessageModel.error()..data = 'No smart account available';
    }

    final normalizedChain = switch (_chain.toUpperCase()) {
      'BSC' => 'BNB',
      'AVAXC' => 'AVAX',
      'OPTIMISM' => 'OP',
      final s => s,
    };
    if (!AAConfig.isChainSupported(normalizedChain)) {
      return MessageModel.error()..data = 'AA not supported for $_chain';
    }
    final handler = AATransferHandler(normalizedChain);

    // Build batch calls: approve (if needed) + swap
    final batchCalls = <ExecuteCall>[];

    // Add approve call if needed (max uint256)
    if (_needsApproval && _tokenIn != null) {
      batchCalls.add(
        ExecuteCall.erc20Approve(
          token: _tokenIn!.address,
          spender: quote.routerAddr,
          amount: _maxUint256,
        ),
      );
    }

    // Add swap call with the DEX calldata
    batchCalls.add(
      ExecuteCall(
        target: quote.routerAddr,
        value: BigInt.zero,
        data: hexToBytes(quote.calldata.replaceFirst('0x', '')),
      ),
    );

    final params = AATransferParams(
      chainSymbol: _chain,
      fromAddress: smartAccount.address,
      toAddress: quote.routerAddr,
      value: 0.0,
      smartAccount: smartAccount,
      batchCalls: batchCalls,
    );

    return handler.transfer(params);
  }

  // ── Token selection helpers ───────────────────────────────────────────────

  Future<DexTokenModel?> _pushTokenSelect() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DexTokenSelect(chain: _chain)),
    );
  }

  Future<void> _selectTokenIn() async {
    final result = await _pushTokenSelect();
    if (!mounted) return;
    if (result != null) {
      _clearQuote();
      setState(() {
        _tokenIn = result;
        _chartPrices = [];
      });
      _onAmountChanged();
      if (_showChart) _fetchPriceChart();
    }
  }

  Future<void> _selectTokenOut() async {
    final result = await _pushTokenSelect();
    if (!mounted) return;
    if (result != null) {
      _clearQuote();
      setState(() => _tokenOut = result);
      _onAmountChanged();
    }
  }

  void _swapTokenDirection() {
    if (_tokenIn == null && _tokenOut == null) return;
    _clearQuote();
    final tmp = _tokenIn;
    setState(() {
      _tokenIn = _tokenOut;
      _tokenOut = tmp;
    });
    _onAmountChanged();
  }

  // ── Mode tab widget ────────────────────────────────────────────────────────

  Widget _modeTab(String label, bool active) {
    final blueColor = AppColorTokens.of(context).brand;
    return GestureDetector(
      onTap: () {
        final newMode = label == 'Limit';
        if (newMode == _isLimitMode) return;
        _clearQuote();
        setState(() => _isLimitMode = newMode);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space6,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: active ? blueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? null
              : Border.all(color: blueColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : blueColor,
          ),
        ),
      ),
    );
  }

  // ── Gas-free toggle widget ─────────────────────────────────────────────────

  Widget _buildGasFreeToggle() {
    final c = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        children: [
          Icon(
            Icons.local_gas_station_outlined,
            size: 18,
            color: _gasFreeEnabled ? c.success : c.textTertiary,
          ),
          SizedBox(width: AppSpacing.space2),
          Text(
            'Gas-free Swap',
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w500,
              color: _gasFreeEnabled ? c.success : c.textTertiary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: _gasFreeEnabled,
              onChanged: (v) => setState(() => _gasFreeEnabled = v),
              activeTrackColor: c.success,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: s.g_key_earn_dex_swap,
        actions: [
          DexAppBarActions(
            showChart: _showChart,
            onToggleChart: () {
              setState(() => _showChart = !_showChart);
              if (_showChart && _chartPrices.isEmpty) _fetchPriceChart();
            },
            onOpenHistory: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _isLimitMode
                    ? const DexLimitOrdersPage()
                    : const DexSwapHistory(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DexChainChips(
                selectedChain: _chain,
                onChainChanged: _onChainChanged,
              ),
              SizedBox(height: AppSpacing.space4),
              // Market / Limit mode toggle
              Row(
                children: [
                  _modeTab('Market', !_isLimitMode),
                  SizedBox(width: AppSpacing.space4),
                  _modeTab('Limit', _isLimitMode),
                ],
              ),
              SizedBox(height: AppSpacing.space4),
              if (_isLimitMode)
                DexLimitOrderForm(chain: _chain)
              else ...[
                if (_showChart) ...[
                  SizedBox(height: AppSpacing.space4),
                  DexPriceChart(
                    tokenInSymbol: _tokenIn?.symbol,
                    chartPrices: _chartPrices,
                    chartLoading: _chartLoading,
                    selectedPeriodDays: _chartPeriodDays,
                    onPeriodChanged: (days) {
                      setState(() => _chartPeriodDays = days);
                      _fetchPriceChart();
                    },
                  ),
                ],
                SizedBox(height: AppSpacing.space4),
                DexSlippageRow(
                  slippageOptions: _slippageOptions,
                  selectedBps: _slippageBps,
                  onChanged: _onSlippageChanged,
                ),
                if (_canUseGasFree) ...[
                  SizedBox(height: AppSpacing.space4),
                  _buildGasFreeToggle(),
                ],
                SizedBox(height: AppSpacing.space6),
                DexTokenCard(
                  label: s.g_swap_key_3,
                  token: _tokenIn,
                  controller: _amountCtrl,
                  onTokenTap: _selectTokenIn,
                ),
                SizedBox(height: AppSpacing.space4),
                DexSwapArrow(onTap: _swapTokenDirection),
                SizedBox(height: AppSpacing.space4),
                DexTokenCard(
                  label: s.g_swap_key_4,
                  token: _tokenOut,
                  amountReadOnly: _quote?.amountOut,
                  onTokenTap: _selectTokenOut,
                ),
                if (_errorMsg.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.space4),
                  DexErrorBanner(message: _errorMsg),
                ],
                if (_quoteLoad == Load.loading) ...[
                  SizedBox(height: AppSpacing.space6),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_quote != null) ...[
                  SizedBox(height: AppSpacing.space6),
                  DexQuoteCard(
                    quote: _quote!,
                    secsLeft: _quoteSecsLeft,
                    needsApproval: _needsApproval,
                    exactApprove: _exactApprove,
                    tokenInSymbol: _tokenIn?.symbol ?? '',
                    onExactApproveChanged: (exact) =>
                        setState(() => _exactApprove = exact),
                  ),
                ],
                SizedBox(height: AppSpacing.space12),
                DexActionButtons(
                  quote: _quote,
                  needsApproval: _needsApproval,
                  approveLoad: _approveLoad,
                  swapLoad: _swapLoad,
                  tokenInSymbol: _tokenIn?.symbol ?? '',
                  onApprove: _executeApprove,
                  onSwapConfirmed: _executeSwap,
                ),
              ], // end else (market mode)
            ],
          ),
        ),
      ),
    );
  }
}
