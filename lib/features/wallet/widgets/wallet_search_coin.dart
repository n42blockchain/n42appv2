import 'dart:async';

import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_apt.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_dot.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_ton.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'wallet_search_coin_item.dart';

class WalletSearchCoin extends ConsumerStatefulWidget {
  final int type; // 0 转账，1 收币
  final String? toAddress;
  const WalletSearchCoin(this.type, {this.toAddress, super.key});

  @override
  ConsumerState<WalletSearchCoin> createState() => _WalletSearchCoinState();
}

class _WalletSearchCoinState extends ConsumerState<WalletSearchCoin> {
  final Regular _regular = Regular();
  final NumberFormat _oCcy = NumberFormat("#,##0.0#", "en_US");
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  Timer? _saveHistoryDebounce; // 搜索历史 IO 防抖，避免高频磁盘写入
  List<CoinModel> _searchResults = [];
  List<String> _history = [];

  static const int _maxHistory = 10;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const Duration _historyIoDuration = Duration(milliseconds: 800);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // 如果有待写入的历史记录，dispose 前立即触发（fire-and-forget）
    if (_saveHistoryDebounce?.isActive == true) {
      _saveHistoryDebounce!.cancel();
      SPUtil().saveCoinSearchHistory(_history);
    }
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Search history ────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    try {
      final history = await SPUtil().getCoinSearchHistory();
      if (mounted) setState(() => _history = history);
    } catch (e) {
      debugPrint('WalletSearchCoin._loadHistory error: $e');
    }
  }

  /// 将关键词插到历史头部，去重后截断为 _maxHistory 条。
  /// UI 立即更新；IO 写入防抖 800ms 后执行，避免高频磁盘写。
  void _saveToHistory(String keyword) {
    final kw = keyword.trim();
    if (kw.isEmpty || kw.length > 50) return; // 拒绝空或超长关键词
    final updated = [kw, ..._history.where((e) => e != kw)].take(_maxHistory).toList();
    if (!mounted) return;
    setState(() => _history = updated);
    // 防抖写入：取消前次定时，重新计时
    _saveHistoryDebounce?.cancel();
    _saveHistoryDebounce = Timer(_historyIoDuration, () {
      SPUtil().saveCoinSearchHistory(updated).catchError((e) {
        debugPrint('WalletSearchCoin._saveToHistory error: $e');
      });
    });
  }

  Future<void> _removeFromHistory(String keyword) async {
    final updated = _history.where((e) => e != keyword).toList();
    final previous = List<String>.from(_history);
    setState(() => _history = updated);
    try {
      await SPUtil().saveCoinSearchHistory(updated);
    } catch (e) {
      debugPrint('WalletSearchCoin._removeFromHistory error: $e');
      if (mounted) {
        setState(() => _history = previous);
      }
    }
  }

  Future<void> _clearHistory() async {
    final previous = List<String>.from(_history);
    setState(() => _history = []);
    try {
      await SPUtil().saveCoinSearchHistory([]);
    } catch (e) {
      debugPrint('WalletSearchCoin._clearHistory error: $e');
      if (mounted) {
        setState(() => _history = previous);
      }
    }
  }

  // ── Search logic ──────────────────────────────────────────────────────────

  void _onTextChanged(String value, WalletActionProvider waValue) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(_debounceDuration, () => _runSearch(waValue));
  }

  void _runSearch(WalletActionProvider waValue) {
    final raw = _inputCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final input = raw.toLowerCase();
    try {
      // 单次遍历同时完成过滤 + 缓存 toLowerCase 结果，避免 sort 阶段重复转换
      final matched = <({CoinModel coin, String sym, String name})>[];
      for (final cm in waValue.coinList) {
        final sym = (cm.coin['miniName'] ?? cm.coin['coinType'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final name = (cm.coin['name'] ?? cm.coin['coinType'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (sym.isEmpty && name.isEmpty) continue;
        if (sym.contains(input) || name.contains(input)) {
          matched.add((coin: cm, sym: sym, name: name));
        }
      }
      // 相关性排序：精确 symbol=5 > symbol前缀=4 > name前缀=3 >
      //             symbol包含=2 > name包含=1；同权时持仓价值降序
      matched.sort((a, b) {
        final ra = _rankScoreCached(a.sym, a.name, input);
        final rb = _rankScoreCached(b.sym, b.name, input);
        if (ra != rb) return rb.compareTo(ra);
        return b.coin.value.compareTo(a.coin.value);
      });
      setState(() => _searchResults = matched.map((e) => e.coin).toList());
    } catch (e) {
      ToastUtils.show(e.toString());
    }
  }

  /// 返回搜索相关性权重 1–5（值越高越优先）。
  /// sym 与 name 已预处理为小写，避免在 sort 内部重复转换。
  int _rankScoreCached(String sym, String name, String input) {
    if (sym == input) return 5;
    if (sym.startsWith(input)) return 4;
    if (name.startsWith(input)) return 3;
    if (sym.contains(input)) return 2;
    return 1;
  }

  /// 点击历史 chip 时填充搜索框并立即执行搜索。
  void _applyHistoryKeyword(String keyword, WalletActionProvider waValue) {
    _inputCtrl.text = keyword;
    _inputCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _runSearch(waValue);
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _navigateForCoin(CoinModel coinInfo) async {
    if (widget.type == 0) {
      final bt = coinInfo.coin['blockchainType']?.toString() ?? '';
      final toAddr = widget.toAddress;
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        if (bt == BlockchainType.Bitcoin.name) return WalletChainSendBtc(coinInfo, toAddress: toAddr);
        if (bt == BlockchainType.Solana.name) return WalletChainSendSol(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Algorand.name) return WalletChainSendAlgo(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Ripple.name) return WalletChainSendXrp(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Filecoin.name) return WalletChainSendFil(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Polkadot.name) return WalletChainSendDot(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Sui.name) return WalletChainSendSui(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.TheOpenNetwork.name) return WalletChainSendTon(coinInfo, initialToAddress: toAddr);
        if (bt == BlockchainType.Aptos.name) return WalletChainSendApt(coinInfo, initialToAddress: toAddr);
        return WalletChainSend(coinInfo, initialToAddress: toAddr);
      }));
    } else {
      if (coinInfo.coin['isContract'] == true) {
        final idx = ref.read(wapBridgeProvider).coinModels.indexWhere(
          (e) => e.coin['coinType'] == coinInfo.coin['coinType'],
        );
        if (idx < 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalletReceiveQr(coinInfo)),
          );
          return;
        }
        final chainCoin = ref.read(wapBridgeProvider).coinModels[idx];
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletReceiveQr(chainCoin, tokenCoinModel: coinInfo),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletReceiveQr(coinInfo)),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);
    return SizedBox(
      height: ScreenUtil().setWidth(800.0),
      width: double.infinity,
      child: Column(
        children: [
          _buildSearchBar(waValue),
          Expanded(child: _buildBody(waValue)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WalletActionProvider waValue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16.0)),
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(100.0),
        maxHeight: ScreenUtil().setWidth(100.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: ScreenUtil().setWidth(36.0),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(width: ScreenUtil().setWidth(8.0)),
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              focusNode: _focusNode,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setWidth(30.0),
              ),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(26.0)),
                isCollapsed: true,
                hintText: S.of(context).g_key_163,
                hintStyle: TextStyle(
                  fontSize: ScreenUtil().setWidth(30.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (v) => _onTextChanged(v, waValue),
              onSubmitted: (v) {
                _closeKeyboard();
                final kw = v.trim();
                if (kw.isNotEmpty) _saveToHistory(kw);
                _runSearch(waValue);
              },
            ),
          ),
          // 有文字时显示清除按钮，否则显示搜索触发按钮
          if (_inputCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _inputCtrl.clear();
                setState(() => _searchResults = []);
                _focusNode.requestFocus();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(8.0)),
                child: Icon(
                  Icons.cancel,
                  size: ScreenUtil().setWidth(36.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            )
          else
            InkWell(
              onTap: () {
                _closeKeyboard();
                _runSearch(waValue);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20.0)),
                height: ScreenUtil().setWidth(60.0),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setWidth(60.0))),
                ),
                alignment: Alignment.center,
                child: Text(
                  S.of(context).search,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonTextColor.name),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(WalletActionProvider waValue) {
    final query = _inputCtrl.text.trim();

    if (query.isEmpty) {
      // 空状态：历史记录（若有）+ 全量代币列表
      return CustomScrollView(
        slivers: [
          if (_history.isNotEmpty)
            SliverToBoxAdapter(child: buildHistorySection(waValue)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => coinItemWidget(waValue.coinList[i], waValue),
              childCount: waValue.coinList.length,
            ),
          ),
        ],
      );
    }

    // 搜索结果（已按相关性排序）
    if (_searchResults.isEmpty) return const EmptyView();
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (_, i) => coinItemWidget(_searchResults[i], waValue),
    );
  }
}
