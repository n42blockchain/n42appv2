import 'dart:async';

import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_apt.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_dot.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_ton.dart';
import 'package:n42appv2/src/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42appv2/src/wallet/pages/wallet_receive_qr.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/generated/l10n.dart';

class WalletSearchCoin extends ConsumerStatefulWidget {
  final int type; // 0 转账，1 收币
  const WalletSearchCoin(this.type, {super.key});

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
    final history = await SPUtil().getCoinSearchHistory();
    if (mounted) setState(() => _history = history);
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
      SPUtil().saveCoinSearchHistory(updated);
    });
  }

  Future<void> _removeFromHistory(String keyword) async {
    final updated = _history.where((e) => e != keyword).toList();
    setState(() => _history = updated);
    await SPUtil().saveCoinSearchHistory(updated);
  }

  Future<void> _clearHistory() async {
    setState(() => _history = []);
    await SPUtil().saveCoinSearchHistory([]);
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
        final sym = cm.coin['miniName'].toString().toLowerCase();
        final name = cm.coin['name'].toString().toLowerCase();
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
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _navigateForCoin(CoinModel coinInfo) async {
    if (widget.type == 0) {
      final bt = coinInfo.coin['blockchainType'];
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        if (bt == BlockchainType.Bitcoin.name) return WalletChainSendBtc(coinInfo);
        if (bt == BlockchainType.Solana.name) return WalletChainSendSol(coinInfo);
        if (bt == BlockchainType.Algorand.name) return WalletChainSendAlgo(coinInfo);
        if (bt == BlockchainType.Ripple.name) return WalletChainSendXrp(coinInfo);
        if (bt == BlockchainType.Filecoin.name) return WalletChainSendFil(coinInfo);
        if (bt == BlockchainType.Polkadot.name) return WalletChainSendDot(coinInfo);
        if (bt == BlockchainType.Sui.name) return WalletChainSendSui(coinInfo);
        if (bt == BlockchainType.TheOpenNetwork.name) return WalletChainSendTon(coinInfo);
        if (bt == BlockchainType.Aptos.name) return WalletChainSendApt(coinInfo);
        return WalletChainSend(coinInfo);
      }));
    } else {
      if (coinInfo.coin['isContract']) {
        final idx = ref.read(wapBridgeProvider).coinModels.indexWhere(
          (e) => e.coin['coinType'] == coinInfo.coin['coinType'],
        );
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
            SliverToBoxAdapter(child: _buildHistorySection(waValue)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _coinItem(waValue.coinList[i], waValue),
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
      itemBuilder: (_, i) => _coinItem(_searchResults[i], waValue),
    );
  }

  Widget _buildHistorySection(WalletActionProvider waValue) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(10.0),
        bottom: ScreenUtil().setWidth(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_coin_search_recent,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16.0),
                    vertical: ScreenUtil().setWidth(6.0),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  S.of(context).g_key_batch_clear_all,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(8.0)),
          Wrap(
            spacing: ScreenUtil().setWidth(12.0),
            runSpacing: ScreenUtil().setWidth(10.0),
            children: _history.map((kw) => _historyChip(kw, waValue)).toList(),
          ),
          SizedBox(height: ScreenUtil().setWidth(16.0)),
          Divider(
            height: 1,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(4.0)),
        ],
      ),
    );
  }

  Widget _historyChip(String keyword, WalletActionProvider waValue) {
    return GestureDetector(
      onTap: () => _applyHistoryKeyword(keyword, waValue),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20.0),
          vertical: ScreenUtil().setWidth(10.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8.0)),
            // 单独点击 X 只删除这条历史，不影响其他 chip
            GestureDetector(
              onTap: () => _removeFromHistory(keyword),
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close,
                size: ScreenUtil().setWidth(24.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coinItem(CoinModel coinInfo, WalletActionProvider waValue) {
    final balance = coinInfo.value;
    final balanceStr = balance >= 1000000000
        ? _regular.getMoneyAbbreviation(balance)
        : _oCcy.format(balance);

    final Widget image = coinInfo.coin['miniName'] == ""
        ? Image.asset('assets/images/list_default.png')
        : ImageNetWork(
            imageUrl: coinInfo.coin['icon'],
            placeholder: "assets/img/list_default.png",
          );

    final Widget? mainImage = coinInfo.coin['isContract']
        ? ImageNetWork(
            imageUrl: coinInfo.mainCoinIcon ?? "",
            placeholder: "assets/img/list_default.png",
          )
        : null;

    final Widget errorBadge = coinInfo.loadError
        ? Container(
            height: ScreenUtil().setWidth(30.0),
            width: ScreenUtil().setWidth(30.0),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
            child: Image.asset(
              "assets/img/error.png",
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.textColorOrange.name),
            ),
          )
        : const SizedBox.shrink();

    return InkWell(
      onTap: () async {
        _closeKeyboard();
        // 选中时把当前关键词存入历史
        final kw = _inputCtrl.text.trim();
        if (kw.isNotEmpty) _saveToHistory(kw);
        await _navigateForCoin(coinInfo);
        if (!mounted) return;
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(30.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: ScreenUtil().setWidth(1.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            errorBadge,
            Container(
              width: ScreenUtil().setWidth(52.0),
              height: ScreenUtil().setWidth(72.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: Stack(
                children: [
                  Positioned(
                    top: ScreenUtil().setWidth(10.0),
                    bottom: ScreenUtil().setWidth(10.0),
                    left: 0,
                    right: 0,
                    child: image,
                  ),
                  if (mainImage != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      height: ScreenUtil().setWidth(22.0),
                      width: ScreenUtil().setWidth(22.0),
                      child: mainImage,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$$balanceStr',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatAddress(coinInfo.address),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                      Expanded(child: Container()),
                      _percentageWidget(coinInfo.percentage),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 地址截断显示，防止短地址越界崩溃。
  String _formatAddress(dynamic address) {
    if (address == null) return '';
    final s = address.toString();
    if (s.length < 12) return s;
    return '${s.substring(0, 6)}...${s.substring(s.length - 5)}';
  }

  Widget _percentageWidget(double percentage) {
    final color = percentage >= 0
        ? AppThemeUtils.getColorByKey(
            context, AppThemeKeys.rightTextColor.name)
        : AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
    return Text(
      '${percentage.toStringAsFixed(2)}%',
      style: TextStyle(fontSize: ScreenUtil().setSp(24.0), color: color),
    );
  }
}
