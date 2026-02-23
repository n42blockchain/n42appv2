import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/dex_swap_api.dart';
import 'package:n42appv2/src/wallet/api/transfer_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/dex/dex_quote_model.dart';
import 'package:n42appv2/src/wallet/models/dex/dex_token_model.dart';
import 'package:n42appv2/src/wallet/pages/dex_swap/dex_swap_confirm.dart';
import 'package:n42appv2/src/wallet/pages/dex_swap/dex_swap_history.dart';
import 'package:n42appv2/src/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';

// ── Supported chains ──────────────────────────────────────────────────────────

/// DEX chain label → backend chain value → app-internal coinType for RPC calls.
const List<Map<String, String>> _kSupportedChains = [
  {'label': 'ETH',     'value': 'ETH',     'coinType': 'ETH'},
  {'label': 'BSC',     'value': 'BSC',     'coinType': 'BNB'},
  {'label': 'Polygon', 'value': 'POLYGON', 'coinType': 'MATIC'},
  {'label': 'ARB',     'value': 'ARB',     'coinType': 'ARB'},
  {'label': 'OP',      'value': 'OP',      'coinType': 'OP'},
  {'label': 'BASE',    'value': 'BASE',    'coinType': 'BASE'},
  {'label': 'SOL',     'value': 'SOL',     'coinType': 'SOL'},
];

/// Lookup coinType for a given DEX chain value.
String _coinTypeForChain(String dexChain) {
  return _kSupportedChains
      .firstWhere(
        (c) => c['value'] == dexChain,
        orElse: () => {'coinType': dexChain},
      )['coinType']!;
}

// ── Constants ─────────────────────────────────────────────────────────────────

/// Seconds before a fetched quote is considered stale and auto-refreshed.
const int _kQuoteTtlSeconds = 30;

class DexSwapHome extends ConsumerStatefulWidget {
  const DexSwapHome({super.key});

  @override
  ConsumerState<DexSwapHome> createState() => _DexSwapHomeState();
}

class _DexSwapHomeState extends ConsumerState<DexSwapHome> {
  final DexSwapApi _dexApi = DexSwapApi();
  final TransferApi _transferApi = TransferApi();
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
  int _quoteSecsLeft = 0; // countdown to expiry

  // ── Slippage (baked into quote calldata — must re-fetch on change) ────────
  // Options: 10 = 0.1%, 50 = 0.5%, 100 = 1%, 200 = 2%
  static const List<int> _slippageOptions = [10, 50, 100, 200];
  int _slippageBps = 50;

  // ── ERC-20 approval state ─────────────────────────────────────────────────
  bool _needsApproval = false;
  Load _approveLoad = Load.finish;

  // ── Swap / error state ────────────────────────────────────────────────────
  Load _swapLoad = Load.finish;
  String _errorMsg = '';

  // ── Wallet addresses by chain ─────────────────────────────────────────────
  /// EVM 0x address (all EVM chains share the same key)
  String _evmAddr = '';

  /// Solana base58 address
  String _solAddr = '';

  String get _userAddr =>
      _chain == 'SOL' ? _solAddr : _evmAddr;

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
        final addr = cm.address ?? '';
        if (addr.startsWith('0x') && _evmAddr.isEmpty) {
          _evmAddr = addr;
        } else if (!addr.startsWith('0x') && _solAddr.isEmpty) {
          // Heuristic: non-0x, 32–44 chars → Solana base58
          if (addr.length >= 32 && addr.length <= 44) {
            _solAddr = addr;
          }
        }
        if (_evmAddr.isNotEmpty && _solAddr.isNotEmpty) break;
      }
      if (mounted) setState(() {});
    });
  }

  // ── Amount / chain change ────────────────────────────────────────────────

  void _onChainChanged(String chain) {
    setState(() {
      _chain = chain;
      _tokenIn = null;
      _tokenOut = null;
      _quote = null;
      _needsApproval = false;
      _errorMsg = '';
      _quoteSecsLeft = 0;
    });
    _expiryTicker?.cancel();
    _amountCtrl.clear();
  }

  void _onAmountChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final amount = _amountCtrl.text.trim();
      if (amount.isNotEmpty &&
          amount != '0' &&
          _tokenIn != null &&
          _tokenOut != null) {
        _fetchQuote(amount);
      } else {
        setState(() {
          _quote = null;
          _errorMsg = '';
          _quoteSecsLeft = 0;
        });
        _expiryTicker?.cancel();
      }
    });
  }

  // ── Slippage ──────────────────────────────────────────────────────────────

  void _onSlippageChanged(int bps) {
    if (_slippageBps == bps) return;
    setState(() {
      _slippageBps = bps;
      _quote = null; // invalidate: calldata must be re-fetched with new bps
      _needsApproval = false;
      _quoteSecsLeft = 0;
    });
    _expiryTicker?.cancel();
    // Re-fetch if amount + tokens are set
    final amount = _amountCtrl.text.trim();
    if (amount.isNotEmpty && amount != '0' && _tokenIn != null && _tokenOut != null) {
      _fetchQuote(amount);
    }
  }

  // ── Quote fetching ────────────────────────────────────────────────────────

  Future<void> _fetchQuote(String amountHuman) async {
    if (_tokenIn == null || _tokenOut == null || _userAddr.isEmpty) return;

    final BigInt amountWei = _toWei(amountHuman, _tokenIn!.decimals);
    if (amountWei == BigInt.zero) return;

    _expiryTicker?.cancel();
    setState(() {
      _quoteLoad = Load.loading;
      _errorMsg = '';
      _quote = null;
      _needsApproval = false;
      _quoteSecsLeft = 0;
    });

    final MessageModel res = await _dexApi.getQuote(
      chain: _chain,
      tokenIn: _tokenIn!.address,
      tokenOut: _tokenOut!.address,
      amountIn: amountWei.toString(),
      userAddr: _userAddr,
      slippageBps: _slippageBps,
    );
    if (!mounted) return;

    if (res.error) {
      setState(() {
        _quoteLoad = Load.finish;
        _errorMsg = res.data?.toString() ?? S.of(context).g_key_dex_quote_failed;
      });
      return;
    }

    final quote = DexQuoteModel.fromJson(
      res.data as Map<String, dynamic>,
      slippageBps: _slippageBps,
    );

    // For EVM non-native tokens, check if approval is needed
    final bool needsApprove = await _checkApprovalNeeded(amountWei, quote);

    if (!mounted) return;
    setState(() {
      _quoteLoad = Load.finish;
      _quote = quote;
      _needsApproval = needsApprove;
      _quoteSecsLeft = _kQuoteTtlSeconds;
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
        // Auto-refresh
        _fetchQuote(amountHuman);
      }
    });
  }

  // ── ERC-20 approval check ─────────────────────────────────────────────────

  /// Returns true if the token-in is an ERC-20 that needs approval.
  Future<bool> _checkApprovalNeeded(
      BigInt amountIn, DexQuoteModel quote) async {
    // Native token (empty address or chain-native sentinel) → no approval
    final tokenAddr = _tokenIn?.address ?? '';
    if (tokenAddr.isEmpty || tokenAddr == '0x0000000000000000000000000000000000000000') {
      return false;
    }
    // Solana: no ERC-20 approval concept
    if (_chain == 'SOL') return false;

    final coinType = _coinTypeForChain(_chain);
    if (coinType.isEmpty || _userAddr.isEmpty || quote.routerAddr.isEmpty) {
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

    final calldata =
        DexSwapApi.buildApproveCalldata(q.routerAddr); // unlimited approval

    final MessageModel txRes = await _transferApi.transfer(
      _chain,
      _tokenIn!.address, // approve on the token contract
      0.0,
      fromAddress: _userAddr,
      contractAddress: '',
      isTest: false,
      message: calldata,
    );
    if (!mounted) return;

    if (txRes.error) {
      setState(() {
        _approveLoad = Load.finish;
        _errorMsg = txRes.data?.toString() ?? S.of(context).g_key_dex_tx_failed;
      });
      return;
    }

    setState(() {
      _approveLoad = Load.finish;
      _needsApproval = false;
      _errorMsg = '';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_dex_approval_success),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  // ── Swap execution ────────────────────────────────────────────────────────

  Future<void> _executeSwap() async {
    final DexQuoteModel? q = _quote;
    if (q == null || _swapLoad == Load.loading) return;

    setState(() {
      _swapLoad = Load.loading;
      _errorMsg = '';
    });

    final MessageModel txRes = await _transferApi.transfer(
      _tokenIn?.chain ?? _chain,
      q.routerAddr,
      0.0, // ERC-20 swap: ETH value = 0
      fromAddress: _userAddr,
      contractAddress: '',
      isTest: false,
      message: q.calldata,
    );
    if (!mounted) return;

    if (txRes.error) {
      setState(() {
        _swapLoad = Load.finish;
        _errorMsg = txRes.data?.toString() ?? S.of(context).g_key_dex_tx_failed;
      });
      return;
    }

    final String txHash = txRes.data['txHash'] as String? ?? '';
    await _dexApi.commit(AppGlobals.userInfo?.uuid ?? '', q.orderId, txHash);
    if (!mounted) return;

    _expiryTicker?.cancel();
    setState(() {
      _swapLoad = Load.finish;
      _quote = null;
      _needsApproval = false;
      _quoteSecsLeft = 0;
    });
    _amountCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).g_key_dex_swap_success)),
    );
  }

  // ── Amount conversion (pure BigInt — no float precision loss) ────────────

  /// Convert a human-readable decimal amount string to wei (smallest unit).
  ///
  /// Uses pure integer arithmetic to avoid double precision issues.
  /// e.g. "1.23456789012345678" with 18 decimals → correct BigInt
  static BigInt _toWei(String amount, int decimals) {
    try {
      final trimmed = amount.trim();
      if (trimmed.isEmpty) return BigInt.zero;

      final dotIdx = trimmed.indexOf('.');
      final String intStr;
      String fracStr;

      if (dotIdx == -1) {
        intStr = trimmed;
        fracStr = '';
      } else {
        intStr = trimmed.substring(0, dotIdx);
        fracStr = trimmed.substring(dotIdx + 1);
      }

      // Trim or pad fractional part to exactly [decimals] digits
      if (fracStr.length > decimals) {
        fracStr = fracStr.substring(0, decimals); // truncate
      } else {
        fracStr = fracStr.padRight(decimals, '0'); // pad with zeros
      }

      final intPart = BigInt.parse(intStr.isEmpty ? '0' : intStr);
      final fracPart = BigInt.parse(fracStr.isEmpty ? '0' : fracStr);
      final multiplier = BigInt.from(10).pow(decimals);

      final result = intPart * multiplier + fracPart;
      return result > BigInt.zero ? result : BigInt.zero;
    } catch (_) {
      return BigInt.zero;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBarWidget(
        text: s.g_key_earn_dex_swap,
        actions: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DexSwapHistory()),
            ),
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(30)),
              child: Icon(
                Icons.history,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(48),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chainChips(),
              SizedBox(height: ScreenUtil().setWidth(16)),
              _slippageRow(),
              SizedBox(height: ScreenUtil().setWidth(24)),
              _tokenInRow(),
              SizedBox(height: ScreenUtil().setWidth(16)),
              _swapArrow(),
              SizedBox(height: ScreenUtil().setWidth(16)),
              _tokenOutRow(),
              if (_errorMsg.isNotEmpty) ...[
                SizedBox(height: ScreenUtil().setWidth(16)),
                _errorWidget(),
              ],
              if (_quoteLoad == Load.loading) ...[
                SizedBox(height: ScreenUtil().setWidth(24)),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_quote != null) ...[
                SizedBox(height: ScreenUtil().setWidth(24)),
                _quoteCard(_quote!),
              ],
              SizedBox(height: ScreenUtil().setWidth(40)),
              _actionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chain chips ───────────────────────────────────────────────────────────

  Widget _chainChips() {
    return Wrap(
      spacing: ScreenUtil().setWidth(12),
      runSpacing: ScreenUtil().setWidth(8),
      children: _kSupportedChains.map((c) {
        final bool selected = c['value'] == _chain;
        return ChoiceChip(
          label: Text(c['label']!),
          selected: selected,
          selectedColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name),
          backgroundColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          labelStyle: TextStyle(
            color: selected
                ? AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name)
                : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
          onSelected: (_) => _onChainChanged(c['value']!),
        );
      }).toList(),
    );
  }

  // ── Slippage selector ─────────────────────────────────────────────────────

  Widget _slippageRow() {
    final s = S.of(context);
    return Row(
      children: [
        Text(
          s.g_key_dex_slippage_label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        ..._slippageOptions.map((bps) {
          final selected = _slippageBps == bps;
          return GestureDetector(
            onTap: () => _onSlippageChanged(bps),
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonBgColor.name)
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor.name),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(6)),
                border: Border.all(
                  color: selected
                      ? AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name)
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.dividerColor.name),
                ),
              ),
              child: Text(
                '${(bps / 100).toStringAsFixed(bps % 100 == 0 ? 0 : 1)}%',
                style: TextStyle(
                  color: selected
                      ? AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonTextColor.name)
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Token rows ────────────────────────────────────────────────────────────

  Widget _tokenInRow() {
    return _tokenRow(
      label: S.of(context).g_swap_key_3,
      token: _tokenIn,
      controller: _amountCtrl,
      onTokenTap: () async {
        final DexTokenModel? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DexTokenSelect(chain: _chain)),
        );
        if (result != null) {
          setState(() {
            _tokenIn = result;
            _quote = null;
            _needsApproval = false;
          });
          _onAmountChanged();
        }
      },
    );
  }

  Widget _tokenOutRow() {
    return _tokenRow(
      label: S.of(context).g_swap_key_4,
      token: _tokenOut,
      controller: null,
      amountReadOnly: _quote?.amountOut,
      onTokenTap: () async {
        final DexTokenModel? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DexTokenSelect(chain: _chain)),
        );
        if (result != null) {
          setState(() {
            _tokenOut = result;
            _quote = null;
          });
          _onAmountChanged();
        }
      },
    );
  }

  Widget _tokenRow({
    required String label,
    required DexTokenModel? token,
    required VoidCallback onTokenTap,
    TextEditingController? controller,
    String? amountReadOnly,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor4.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(
                child: controller != null
                    ? TextField(
                        controller: controller,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(44),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.textFieldHintColor.name),
                            fontSize: ScreenUtil().setSp(44),
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        amountReadOnly ?? '—',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(44),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: onTokenTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemBgColor.name),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (token != null) ...[
                        SizedBox(
                          width: ScreenUtil().setWidth(36),
                          height: ScreenUtil().setWidth(36),
                          child: ImageNetWork(
                            imageUrl: token.logoUri,
                            placeholder: 'assets/img/list_default.png',
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                      ],
                      Text(
                        token?.symbol ??
                            S.of(context).g_key_dex_select_token,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(4)),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        size: ScreenUtil().setWidth(36),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Swap arrow ────────────────────────────────────────────────────────────

  Widget _swapArrow() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_tokenIn != null || _tokenOut != null) {
            setState(() {
              final tmp = _tokenIn;
              _tokenIn = _tokenOut;
              _tokenOut = tmp;
              _quote = null;
              _needsApproval = false;
            });
            _onAmountChanged();
          }
        },
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.swap_vert,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonTextColor.name),
            size: ScreenUtil().setWidth(36),
          ),
        ),
      ),
    );
  }

  // ── Quote card ────────────────────────────────────────────────────────────

  Widget _quoteCard(DexQuoteModel q) {
    final s = S.of(context);
    final double impactNum = q.priceImpactNum;
    final Color impactColor = impactNum >= 3.0
        ? const Color(0xFFF44336)    // red ≥ 3 %
        : impactNum >= 1.0
            ? const Color(0xFFFF9800) // orange 1–3 %
            : AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          // Route + countdown in same row
          _quoteRowWidget(
            s.g_key_dex_best_route,
            q.source,
            trailing: _quoteSecsLeft > 0
                ? Text(
                    s.g_key_dex_quote_expires(_quoteSecsLeft.toString()),
                    style: TextStyle(
                      color: _quoteSecsLeft <= 10
                          ? const Color(0xFFF44336)
                          : AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                      fontSize: ScreenUtil().setSp(22),
                    ),
                  )
                : null,
          ),
          // Price impact with color coding
          _quoteRowWidget(
            s.g_key_dex_price_impact,
            q.priceImpact,
            valueColor: impactColor,
          ),
          _quoteRow(s.g_key_dex_gas_estimate, q.gasEstimate),
          // Minimum received
          _quoteRow(s.g_key_dex_min_received,
              '${q.minAmountOut} ${q.tokenOutSymbol}'),
          // High impact warning
          if (impactNum >= 3.0) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withAlpha(20),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: const Color(0xFFF44336),
                      size: ScreenUtil().setWidth(28)),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Expanded(
                    child: Text(
                      s.g_key_dex_price_impact_high(q.priceImpact),
                      style: TextStyle(
                        color: const Color(0xFFF44336),
                        fontSize: ScreenUtil().setSp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Approve notice
          if (_needsApproval) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withAlpha(20),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      color: const Color(0xFFFF9800),
                      size: ScreenUtil().setWidth(28)),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Expanded(
                    child: Text(
                      s.g_key_dex_approve_required(
                          _tokenIn?.symbol ?? ''),
                      style: TextStyle(
                        color: const Color(0xFFFF9800),
                        fontSize: ScreenUtil().setSp(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quoteRowWidget(String label, String value,
      {Color? valueColor, Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: ScreenUtil().setWidth(8)),
            trailing,
          ],
          const Expanded(child: SizedBox()),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
              fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quoteRow(String label, String value, {Color? valueColor}) =>
      _quoteRowWidget(label, value, valueColor: valueColor);

  // ── Error widget ──────────────────────────────────────────────────────────

  Widget _errorWidget() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Text(
        _errorMsg,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
          fontSize: ScreenUtil().setSp(26),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _actionButtons() {
    final s = S.of(context);
    final bool hasQuote = _quote != null;
    final bool loading =
        _swapLoad == Load.loading || _approveLoad == Load.loading;

    // Show Approve button if needed, otherwise Swap button
    if (_needsApproval && hasQuote) {
      return SizedBox(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        child: buttonStyle6(
          context,
          _approveLoad == Load.finish ? _executeApprove : () {},
          _approveLoad == Load.loading
              ? s.g_key_dex_approving
              : s.g_key_dex_approve_required(_tokenIn?.symbol ?? ''),
          AppThemeUtils.getColorByKey(
              context, AppThemeKeys.textColorOrange.name),
          AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonTextColor.name),
          _approveLoad == Load.loading,
        ),
      );
    }

    return SizedBox(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      child: buttonStyle6(
        context,
        hasQuote && !loading
            ? () async {
                FocusScope.of(context).unfocus();
                final bool? confirmed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DexSwapConfirm(quote: _quote!),
                  ),
                );
                if (!mounted) return;
                if (confirmed == true) {
                  await _executeSwap();
                }
              }
            : () {},
        s.g_key_dex_swap_btn,
        hasQuote && !loading
            ? AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor.name)
            : AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainButtonBgColor3.name),
        AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        loading,
      ),
    );
  }
}
