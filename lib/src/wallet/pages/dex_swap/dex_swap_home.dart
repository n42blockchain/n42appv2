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

/// 支持链列表（显示标签 + 后端 chain 参数）
const List<Map<String, String>> _kSupportedChains = [
  {'label': 'ETH', 'value': 'ETH'},
  {'label': 'BSC', 'value': 'BSC'},
  {'label': 'Polygon', 'value': 'POLYGON'},
  {'label': 'ARB', 'value': 'ARB'},
  {'label': 'OP', 'value': 'OP'},
  {'label': 'SOL', 'value': 'SOL'},
];

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

  String _chain = 'ETH';
  DexTokenModel? _tokenIn;
  DexTokenModel? _tokenOut;
  DexQuoteModel? _quote;
  Load _quoteLoad = Load.finish;
  Load _swapLoad = Load.finish;
  String _errorMsg = '';

  // 用户 EVM 地址（用于获取报价）
  String _userAddr = '';

  @override
  void initState() {
    super.initState();
    _initUserAddress();
    _amountCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initUserAddress() {
    // 从钱包 provider 中取出第一个 EVM 地址
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final WalletActionProvider wa = ref.read(wapBridgeProvider);
      for (final CoinModel cm in wa.coinModels) {
        final addr = cm.address ?? '';
        if (addr.startsWith('0x')) {
          setState(() => _userAddr = addr);
          return;
        }
      }
      // 非 EVM 链（Solana）使用 uuid 作为 fallback
      setState(() => _userAddr = AppGlobals.userInfo?.uuid ?? '');
    });
  }

  void _onChainChanged(String chain) {
    setState(() {
      _chain = chain;
      _tokenIn = null;
      _tokenOut = null;
      _quote = null;
      _errorMsg = '';
    });
    _amountCtrl.clear();
    _initUserAddress();
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
        });
      }
    });
  }

  Future<void> _fetchQuote(String amountHuman) async {
    if (_tokenIn == null || _tokenOut == null || _userAddr.isEmpty) return;

    // 将人类可读金额转换为最小单位字符串
    final BigInt amountWei = _toWei(amountHuman, _tokenIn!.decimals);
    if (amountWei == BigInt.zero) return;

    setState(() {
      _quoteLoad = Load.loading;
      _errorMsg = '';
      _quote = null;
    });

    final MessageModel res = await _dexApi.getQuote(
      chain: _chain,
      tokenIn: _tokenIn!.address,
      tokenOut: _tokenOut!.address,
      amountIn: amountWei.toString(),
      userAddr: _userAddr,
    );
    if (!mounted) return;

    if (res.error) {
      setState(() {
        _quoteLoad = Load.finish;
        _errorMsg = res.data?.toString() ?? S.of(context).g_key_dex_quote_failed;
      });
    } else {
      final quote = DexQuoteModel.fromJson(res.data as Map<String, dynamic>);
      setState(() {
        _quoteLoad = Load.finish;
        _quote = quote;
      });
    }
  }

  BigInt _toWei(String amount, int decimals) {
    try {
      final double d = double.parse(amount);
      if (d <= 0) return BigInt.zero;
      final BigInt multiplier = BigInt.from(10).pow(decimals);
      // 避免浮点精度问题：使用整数运算
      final BigInt result =
          BigInt.from((d * multiplier.toDouble()).round());
      return result;
    } catch (_) {
      return BigInt.zero;
    }
  }

  Future<void> _executeSwap(int slippageBps) async {
    final DexQuoteModel? q = _quote;
    if (q == null) return;
    if (_swapLoad == Load.loading) return;

    setState(() {
      _swapLoad = Load.loading;
      _errorMsg = '';
    });

    // Solana：calldata 是 base64 序列化 tx，暂不支持 in-app 广播
    if (_chain == 'SOL') {
      setState(() {
        _swapLoad = Load.finish;
        _errorMsg = S.of(context).g_key_dex_sol_unsupported;
      });
      return;
    }

    // EVM：通过 TransferApi.transfer 广播 calldata
    // message 参数会设置为 EVM 交易的 data 字段
    final MessageModel txRes = await _transferApi.transfer(
      _tokenIn?.chain ?? _chain,
      q.routerAddr,
      0.0, // 纯代币兑换时 ETH value = 0
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

    // 广播成功后通知后端 commit
    await _dexApi.commit(
      AppGlobals.userInfo?.uuid ?? '',
      q.orderId,
      txHash,
    );
    if (!mounted) return;

    setState(() {
      _swapLoad = Load.finish;
      _quote = null;
    });
    _amountCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).g_key_dex_swap_success)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_earn_dex_swap,
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
              _swapButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chainChips() {
    return Wrap(
      spacing: ScreenUtil().setWidth(12),
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

  Widget _tokenInRow() {
    return _tokenRow(
      label: S.of(context).g_swap_key_3,
      token: _tokenIn,
      controller: _amountCtrl,
      onTokenTap: () async {
        final DexTokenModel? result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DexTokenSelect(chain: _chain)),
        );
        if (result != null) {
          setState(() {
            _tokenIn = result;
            _quote = null;
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
          MaterialPageRoute(
              builder: (_) => DexTokenSelect(chain: _chain)),
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
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor4.name),
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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
                      if (token != null)
                        SizedBox(
                          width: ScreenUtil().setWidth(36),
                          height: ScreenUtil().setWidth(36),
                          child: ImageNetWork(
                            imageUrl: token.logoUri,
                            placeholder: 'assets/img/list_default.png',
                          ),
                        ),
                      if (token != null)
                        SizedBox(width: ScreenUtil().setWidth(8)),
                      Text(
                        token?.symbol ?? S.of(context).g_key_dex_select_token,
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

  Widget _swapArrow() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_tokenIn != null && _tokenOut != null) {
            setState(() {
              final tmp = _tokenIn;
              _tokenIn = _tokenOut;
              _tokenOut = tmp;
              _quote = null;
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

  Widget _quoteCard(DexQuoteModel q) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          _quoteRow(S.of(context).g_key_dex_best_route, q.source),
          _quoteRow(S.of(context).g_key_dex_price_impact, q.priceImpact),
          _quoteRow(S.of(context).g_key_dex_gas_estimate, q.gasEstimate),
        ],
      ),
    );
  }

  Widget _quoteRow(String label, String value) {
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
          const Expanded(child: SizedBox()),
          Text(
            value,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _swapButton() {
    final bool canSwap = _quote != null && _swapLoad == Load.finish;
    final bool loading = _swapLoad == Load.loading;

    return SizedBox(
      height: ScreenUtil().setWidth(88),
      width: double.infinity,
      child: buttonStyle6(
        context,
        canSwap
            ? () async {
                FocusScope.of(context).unfocus();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DexSwapConfirm(quote: _quote!),
                  ),
                );
                if (!mounted) return;
                if (result is int) {
                  // result 是用户选择的 slippageBps
                  await _executeSwap(result);
                }
              }
            : () {},
        S.of(context).g_key_dex_swap_btn,
        canSwap
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
