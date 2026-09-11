import 'dart:async';
import 'package:n42_wallet/core/providers/core_providers.dart'
    show currentUserProvider;
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_execution_guard.dart';

import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_quote_validity.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_approval_confirmation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
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
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_router_whitelist.dart';
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
  const DexSwapHome({super.key, this.api, this.senderForChain});
  final DexSwapApi? api;
  final ChainSender Function(String chain)? senderForChain;

  @override
  ConsumerState<DexSwapHome> createState() => _DexSwapHomeState();
}

class _DexSwapHomeState extends ConsumerState<DexSwapHome> {
  late final DexSwapApi _dexApi = widget.api ?? DexSwapApi();
  ChainSender _sender(String chain) =>
      widget.senderForChain?.call(chain) ??
      SenderFactory.instance.getSender(chain);
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
  DateTime? _quoteExpiresAt;

  // ── Slippage (baked into quote calldata — must re-fetch on change) ────────
  // Options: 10 = 0.1%, 50 = 0.5%, 100 = 1%, 200 = 2%
  static const List<int> _slippageOptions = [10, 50, 100, 200];
  int _slippageBps = 50;

  // ── ERC-20 approval state ─────────────────────────────────────────────────
  bool _needsApproval = false;
  Load _approveLoad = Load.finish;

  /// When true, approves exact amountIn instead of MaxUint256.
  bool _exactApprove = true;

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
  bool _useSmartAccount = false;

  /// Max uint256 for unlimited ERC-20 approvals
  static final BigInt _maxUint256 = BigInt.two.pow(256) - BigInt.one;

  Object? _quoteAccountKey;
  Object? _requestAccountKey;
  CoinModel? get _signingCoin => _chainCoinModel(dexCoinTypeForChain(_chain));
  String get _userAddr => _useSmartAccount
      ? _smartAccount?.address ?? ''
      : _signingCoin?.address?.toString() ?? '';
  Object get _executionKey {
    final wallet = ref.read(wapBridgeProvider).walletInfo;
    final coin = _signingCoin;
    return (
      ref.read(currentUserProvider)?.uuid,
      wallet.timestamp,
      wallet.walletUuid,
      wallet.watchOnly,
      _chain,
      coin?.address,
      coin?.pathIndex,
      coin?.addrType,
      coin?.isTest,
      _useSmartAccount,
      _userAddr,
    );
  }

  /// Check if current chain supports AA Gas-free swaps
  bool get _canUseSmartAccount {
    return _smartAccount != null;
  }

  /// Get the primary smart account for the current chain
  SmartAccount? get _smartAccount {
    final walletInfo = ref.read(wapBridgeProvider).walletInfo;
    if (!walletInfo.hasAAAccounts) return null;
    if (_signingCoin?.isTest != false) return null;
    final chainId = AAConfig.chainIds[dexCoinTypeForChain(_chain)];
    if (chainId == null) return null;
    final account = walletInfo.getPrimarySmartAccount(chainId);
    if (account?.signerType != SignerType.eoa) return null;
    if (account?.ownerAddress.toLowerCase() !=
        _signingCoin?.address?.toString().toLowerCase()) {
      return null;
    }
    return account;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
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

  String? _buildChainPath(String chainCoinType) {
    final coin = _chainCoinModel(chainCoinType);
    if (coin == null) return null;
    final base = coin.config.pathForAddrType(coin.addrType);
    return base == null || base.isEmpty
        ? null
        : getPathWithIndex(base, coin.pathIndex);
  }

  CoinModel? _chainCoinModel(String chainCoinType) =>
      dexSigningCoin(ref.read(wapBridgeProvider).coinModels, chainCoinType);

  // ── Quote state helpers ───────────────────────────────────────────────────

  void _clearQuote() {
    _expiryTicker?.cancel();
    ++_quoteRequestId;
    setState(() {
      _quote = null;
      _quoteAccountKey = null;
      _requestAccountKey = null;
      _quoteExpiresAt = null;
      _quoteLoad = Load.finish;
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
      _useSmartAccount = false;
    });
    _amountCtrl.clear();
  }

  void _onAmountChanged() {
    _debounce?.cancel();
    _clearQuote();
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
    if (_approveLoad == Load.loading || _swapLoad == Load.loading) return;
    if (_tokenIn == null || _tokenOut == null) return;
    if (_signingCoin == null || _signingCoin!.isTest || _userAddr.isEmpty) {
      _clearQuote();
      setState(() => _errorMsg = S.of(context).g_dex_account_unavailable);
      return;
    }

    if (_tokenIn!.chain != _chain || _tokenOut!.chain != _chain) {
      _clearQuote();
      setState(() => _errorMsg = S.of(context).g_dex_execution_invalid);
      return;
    }
    final BigInt amountWei = dexToWei(amountHuman, _tokenIn!.decimals);
    if (amountWei == BigInt.zero) return;

    _clearQuote();
    final requestId = ++_quoteRequestId;
    final accountKey = _executionKey;
    _requestAccountKey = accountKey;
    final expiresAt = DateTime.now().add(
      const Duration(seconds: kDexQuoteTtlSeconds),
    );
    setState(() => _quoteLoad = Load.loading);

    final MessageModel res = await _dexApi.getQuote(
      chain: _chain,
      tokenIn: _tokenIn!.address,
      tokenOut: _tokenOut!.address,
      amountIn: amountWei.toString(),
      userAddr: _userAddr,
      slippageBps: _slippageBps,
    );
    if (!mounted ||
        requestId != _quoteRequestId ||
        accountKey != _executionKey) {
      return;
    }

    if (res.error) {
      setState(() {
        _quoteLoad = Load.finish;
        _errorMsg =
            res.data?.toString() ?? S.of(context).g_key_dex_quote_failed;
      });
      return;
    }

    final DexQuoteModel quote;
    try {
      quote = DexQuoteModel.fromJson(
        {
          ...res.data as Map<String, dynamic>,
          // Input display comes from the request that this response belongs to.
          'amount_in': amountHuman,
          'user_addr': _userAddr,
          'token_in_symbol': _tokenIn!.symbol,
          'token_out_symbol': _tokenOut!.symbol,
        },
        slippageBps: _slippageBps,
        outputDecimals: _tokenOut!.decimals,
      );
      validatedDexValue(
        quote: quote,
        chain: _chain,
        tokenAddress: _tokenIn!.address,
        amountIn: amountWei,
      );
    } catch (_) {
      setState(() {
        _quoteLoad = Load.finish;
        _errorMsg = S.of(context).g_key_dex_quote_failed;
      });
      return;
    }

    // For EVM non-native tokens, check if approval is needed
    final bool needsApprove = await _checkApprovalNeeded(amountWei, quote);
    if (!mounted ||
        requestId != _quoteRequestId ||
        accountKey != _executionKey) {
      return;
    }

    setState(() {
      _quoteLoad = Load.finish;
      _quote = quote;
      _quoteAccountKey = accountKey;
      _quoteExpiresAt = expiresAt;
      _needsApproval = needsApprove;
      _quoteSecsLeft = kDexQuoteTtlSeconds;
    });
    _startExpiryTimer(amountHuman);
  }

  // ── Quote expiry timer ────────────────────────────────────────────────────

  void _startExpiryTimer(String amountHuman) {
    _expiryTicker?.cancel();
    _expiryTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _expiryTicker?.cancel();
        return;
      }
      setState(
        () => _quoteSecsLeft =
            (_quoteExpiresAt?.difference(DateTime.now()).inSeconds ?? 0).clamp(
              0,
              kDexQuoteTtlSeconds,
            ),
      );
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
        isDexNativeToken(tokenAddr) ||
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

  /// 校验报价里的 router 是否受信任。不信任后端返回的任意地址——恶意 router
  /// 会让 approve 授权给攻击者、swap 把币打进攻击者合约。返回 false 时已置错误
  /// 文案，调用方直接中止。
  bool _assertTrustedRouter(DexQuoteModel q) {
    if (DexRouterWhitelist.isTrusted(q.routerAddr)) return true;
    AppLogger.e(
      'DexSwap',
      'Untrusted router from backend, aborting: ${q.routerAddr}',
    );
    setState(() {
      _approveLoad = Load.finish;
      _swapLoad = Load.finish;
      _errorMsg = S.of(context).g_key_dex_untrusted_router;
    });
    return false;
  }

  bool _isCurrentQuote(DexQuoteModel quote) => isCurrentDexQuote(
    confirmed: quote,
    current: _quote,
    expiresAt: _quoteExpiresAt,
    now: DateTime.now(),
    confirmedAccountKey: _quoteAccountKey,
    currentAccountKey: _executionKey,
  );

  bool _assertExecutableAccount() {
    if (ref.read(wapBridgeProvider).walletInfo.watchOnly ||
        _signingCoin == null ||
        _signingCoin!.isTest ||
        _userAddr.isEmpty) {
      setState(() => _errorMsg = S.of(context).g_dex_account_unavailable);
      return false;
    }
    return true;
  }

  Future<void> _executeApprove() async {
    if (_approveLoad == Load.loading ||
        _swapLoad == Load.loading ||
        !_assertExecutableAccount()) {
      return;
    }
    try {
      await _approve();
    } catch (e) {
      if (mounted) setState(() => _errorMsg = S.of(context).g_key_175);
    } finally {
      if (mounted) {
        setState(() => _approveLoad = Load.finish);
        if (_quote != null) _startExpiryTimer(_amountCtrl.text.trim());
      }
    }
  }

  Future<void> _approve() async {
    final DexQuoteModel? q = _quote;
    if (q == null ||
        _approveLoad == Load.loading ||
        _swapLoad == Load.loading ||
        !_isCurrentQuote(q)) {
      return;
    }
    _expiryTicker?.cancel();

    // 授权前先校验 spender(=router) 受信任，避免把额度授权给恶意合约。
    if (!_assertTrustedRouter(q)) return;

    setState(() {
      _approveLoad = Load.loading;
      _errorMsg = '';
    });

    final approved = await confirmDexApproval(
      context,
      tokenSymbol: _tokenIn!.symbol,
      tokenAddress: _tokenIn!.address,
      spender: q.routerAddr,
      chain: _chain,
      amountLabel: _exactApprove
          ? _amountCtrl.text.trim()
          : S.of(context).g_key_dex_approve_unlimited,
    );
    if (!mounted) return;
    if (!approved || !_isCurrentQuote(q)) {
      setState(() {
        _approveLoad = Load.finish;
        if (approved) _errorMsg = S.of(context).g_audit_quote_changed;
      });
      _startExpiryTimer(_amountCtrl.text.trim());
      return;
    }

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

    final SendResult approveResult;
    if (_useSmartAccount) {
      final result = await _sendAACalls(q.routerAddr, [
        ExecuteCall.erc20Approve(
          token: _tokenIn!.address,
          spender: q.routerAddr,
          amount: exactAmount ?? _maxUint256,
        ),
      ]);
      approveResult = result.error
          ? SendResult.fail(result.data?.toString())
          : SendResult.ok(result.data['txHash'] as String?);
    } else {
      approveResult = await _sender(coinType).send(
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
    }
    if (!mounted) return;

    if (!approveResult.success) {
      setState(() {
        _approveLoad = Load.finish;
        _errorMsg = approveResult.error ?? S.of(context).g_key_175;
      });
      _startExpiryTimer(_amountCtrl.text.trim());
      return;
    }

    setState(() {
      _approveLoad = Load.finish;
      _errorMsg = '';
    });
    _clearQuote();
    _tryFetchQuote();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_dex_approval_success),
        backgroundColor: AppColorTokens.of(context).success,
      ),
    );
  }

  // ── Swap execution ────────────────────────────────────────────────────────

  /// Validates that the swap calldata routes its output back to the wallet
  /// owner, not a backend-injected third party. Blocks only on a recognized
  /// selector whose recipient is a concrete foreign address; unrecognized
  /// selectors are logged and allowed (the router whitelist stays the primary
  /// defense). Returns false and sets an error message when the swap must abort.
  bool _assertSwapRecipient(DexQuoteModel q) {
    final check = DexSwapCalldataGuard.checkRecipient(q.calldata, _userAddr);
    if (check == SwapRecipientCheck.mismatch) {
      AppLogger.e(
        'DexSwap',
        'Swap calldata recipient does not match owner, aborting',
      );
      setState(() {
        _swapLoad = Load.finish;
        _errorMsg = S.of(context).g_key_dex_untrusted_router;
      });
      return false;
    }
    if (check == SwapRecipientCheck.unknown) {
      AppLogger.w(
        'DexSwap',
        'Swap calldata selector not recognized; recipient not verified',
      );
    }
    return true;
  }

  Future<void> _executeSwap(DexQuoteModel confirmedQuote) async {
    if (_approveLoad == Load.loading ||
        _swapLoad == Load.loading ||
        !_assertExecutableAccount()) {
      return;
    }
    try {
      await _swap(confirmedQuote);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = S.of(context).g_dex_execution_invalid);
      }
    } finally {
      if (mounted) {
        setState(() => _swapLoad = Load.finish);
        if (_quote != null) _startExpiryTimer(_amountCtrl.text.trim());
      }
    }
  }

  Future<void> _swap(DexQuoteModel confirmedQuote) async {
    if (!mounted || _swapLoad == Load.loading || _approveLoad == Load.loading) {
      return;
    }
    if (!_isCurrentQuote(confirmedQuote)) {
      setState(() => _errorMsg = S.of(context).g_audit_quote_changed);
      return;
    }
    if (_needsApproval) {
      setState(
        () => _errorMsg = S
            .of(context)
            .g_key_dex_approve_required(_tokenIn!.symbol),
      );
      return;
    }
    final q = confirmedQuote;
    final executionUserId = ref.read(currentUserProvider)?.uuid ?? '';
    final executionKey = _executionKey;
    final value = validatedDexValue(
      quote: q,
      chain: _chain,
      tokenAddress: _tokenIn!.address,
      amountIn: dexToWei(_amountCtrl.text.trim(), _tokenIn!.decimals),
    );
    _expiryTicker?.cancel();

    // 广播前校验交易 to(=router) 受信任，避免把资金打进后端伪造的恶意合约。
    if (!_assertTrustedRouter(q)) return;
    // 并校验 calldata 里的 output recipient 指向本人，防受信 router + 篡改
    // recipient 的组合把换出资金导走。
    if (!_assertSwapRecipient(q)) return;

    setState(() {
      _swapLoad = Load.loading;
      _errorMsg = '';
    });

    String txHash;

    // Smart account path: attach the verified native value to the call.
    if (_useSmartAccount && _smartAccount != null) {
      final txRes = await _sendAACalls(q.routerAddr, [
        ExecuteCall(
          target: q.routerAddr,
          value: value,
          data: hexToBytes(q.calldata.replaceFirst('0x', '')),
        ),
      ]);
      if (txRes.error) {
        if (!mounted) return;
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = txRes.data?.toString() ?? S.of(context).g_key_175;
        });
        return;
      }
      txHash = txRes.data['txHash'] as String? ?? '';
    } else {
      final swapChain = dexCoinTypeForChain(_chain);
      final chainCoin = _chainCoinModel(swapChain);
      final path = _buildChainPath(swapChain);
      if (path == null) {
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = S.of(context).g_key_175;
        });
        return;
      }
      final swapResult = await _sender(swapChain).send(
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
          valueWeiOverride: value,
        ),
      );
      if (!swapResult.success) {
        if (!mounted) return;
        setState(() {
          _swapLoad = Load.finish;
          _errorMsg = swapResult.error ?? S.of(context).g_key_175;
        });
        return;
      }
      txHash = swapResult.txHash ?? '';
    }
    // A broadcast quote must never become executable again if recording fails.
    if (mounted && identical(_quote, q)) {
      _clearQuote();
      _amountCtrl.clear();
    }
    if (txHash.isEmpty) {
      if (mounted) {
        setState(() => _errorMsg = S.of(context).g_dex_execution_invalid);
      }
      return;
    }
    var recorded = false;
    try {
      final result = await _dexApi.commit(executionUserId, q.orderId, txHash);
      recorded = !result.error;
    } catch (_) {
      // The broadcast succeeded; a history-service error must not invite resend.
    }
    if (!mounted || executionKey != _executionKey) return;
    setState(() => _swapLoad = Load.finish);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recorded
              ? S.of(context).g_key_dex_swap_success
              : '${S.of(context).g_dex_history_record_failed}\n$txHash',
        ),
      ),
    );
  }

  Future<MessageModel> _sendAACalls(
    String target,
    List<ExecuteCall> calls,
  ) async {
    final account = _smartAccount;
    final coin = _signingCoin;
    final chain = dexCoinTypeForChain(_chain);
    if (account == null || coin == null || !AAConfig.isChainSupported(chain)) {
      return MessageModel.error()
        ..data = S.of(context).g_dex_account_unavailable;
    }
    return AATransferHandler(chain).transfer(
      AATransferParams(
        chainSymbol: chain,
        fromAddress: account.address,
        toAddress: target,
        value: 0,
        smartAccount: account,
        batchCalls: calls,
        privateKey: coin.privateKey,
        pathIndex: coin.pathIndex,
        chainMap: {...coin.coin, 'path': _buildChainPath(chain) ?? ''},
      ),
    );
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

  Widget _buildSmartAccountToggle() {
    final c = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        children: [
          Icon(
            Icons.local_gas_station_outlined,
            size: 18,
            color: _useSmartAccount ? c.success : c.textTertiary,
          ),
          SizedBox(width: AppSpacing.space2),
          Text(
            S.of(context).g_dex_use_smart_account,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w500,
              color: _useSmartAccount ? c.success : c.textTertiary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: _useSmartAccount,
              onChanged:
                  _approveLoad == Load.loading || _swapLoad == Load.loading
                  ? null
                  : (v) {
                      _clearQuote();
                      setState(() => _useSmartAccount = v);
                      _tryFetchQuote();
                    },
              activeTrackColor: c.success,
            ),
          ),
        ],
      ),
    );
  }

  void _accountChanged() {
    if (!mounted) return;
    if (_requestAccountKey != null && _requestAccountKey != _executionKey) {
      _clearQuote();
      _tryFetchQuote();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(wapBridgeProvider, (_, _) => _accountChanged());
    ref.listen(currentUserProvider, (_, _) => _accountChanged());
    ref.watch(wapBridgeProvider);
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
                    ? DexLimitOrdersPage(api: _dexApi)
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
                DexLimitOrderForm(chain: _chain, api: _dexApi)
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
                if (_canUseSmartAccount) ...[
                  SizedBox(height: AppSpacing.space4),
                  _buildSmartAccountToggle(),
                  if (_useSmartAccount)
                    Text(
                      s.g_dex_smart_account_fees,
                      style: AppTypography.caption,
                    ),
                ],
                if (_userAddr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${s.g_dex_spending_account}: $_userAddr',
                      style: AppTypography.caption,
                    ),
                  ),
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
