import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class DexTokenSelect extends StatefulWidget {
  final String chain;
  const DexTokenSelect({required this.chain, super.key});

  @override
  State<DexTokenSelect> createState() => _DexTokenSelectState();
}

class _DexTokenSelectState extends State<DexTokenSelect> {
  final DexSwapApi _api = DexSwapApi();
  final TextEditingController _searchCtrl = TextEditingController();

  List<DexTokenModel> _all = [];
  List<DexTokenModel> _filtered = [];
  bool _loading = true;
  String _error = '';

  // 地址搜索状态（当本地无结果且输入像合约地址时触发）
  bool _remoteSearching = false;
  List<DexTokenModel> _remoteResults = [];
  String _remoteError = '';

  @override
  void initState() {
    super.initState();
    _loadTokens();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final MessageModel res = await _api.getTokens(widget.chain);
    if (!mounted) return;
    if (res.error) {
      setState(() {
        _loading = false;
        _error = res.data?.toString() ?? 'Load failed';
      });
    } else {
      final list = ((res.data as List?) ?? [])
          .map((e) => DexTokenModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _loading = false;
        _all = list;
        _filtered = list;
      });
    }
  }

  /// 判断输入字符串是否像一个合约地址
  /// - EVM：0x 开头 + 40 个 hex 字符（共 42 字符）
  /// - Solana：base58，通常 32-50 字符，不含 0x 前缀
  bool _isAddressLike(String q) {
    if (q.startsWith('0x') && q.length == 42) {
      // 简单 hex 校验
      final hex = q.substring(2);
      return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
    }
    // Solana base58 地址（含字母和数字，不含 0/O/I/l 等歧义字符）
    if (!q.startsWith('0x') && q.length >= 32 && q.length <= 50) {
      return RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(q);
    }
    return false;
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();

    // 重置地址搜索状态
    setState(() {
      _remoteResults = [];
      _remoteError = '';
      _remoteSearching = false;
    });

    if (q.isEmpty) {
      setState(() => _filtered = _all);
      return;
    }

    // 本地过滤
    final local = _all
        .where((t) =>
            t.symbol.toLowerCase().contains(q) ||
            t.name.toLowerCase().contains(q) ||
            t.address.toLowerCase().contains(q))
        .toList();

    setState(() => _filtered = local);

    // 当本地无结果且输入看起来是合约地址时，向后端查询
    if (local.isEmpty && _isAddressLike(_searchCtrl.text.trim())) {
      _searchByAddress(_searchCtrl.text.trim());
    }
  }

  /// 用完整地址向后端搜索（后端精确匹配 address 字段）
  Future<void> _searchByAddress(String address) async {
    if (!mounted) return;
    setState(() => _remoteSearching = true);

    final MessageModel res =
        await _api.getTokens(widget.chain, q: address);

    if (!mounted) return;
    if (res.error) {
      setState(() {
        _remoteSearching = false;
        _remoteError = 'Search failed';
      });
      return;
    }

    final rawList = res.data as List? ?? [];
    final results = rawList
        .map((e) => DexTokenModel.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _remoteSearching = false;
      _remoteResults = results;
      if (results.isEmpty) {
        _remoteError = 'Token not found';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_9),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30),
                vertical: ScreenUtil().setWidth(16)),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28),
              ),
              decoration: InputDecoration(
                hintText: S.of(context).g_key_dex_search_hint,
                hintStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.textFieldHintColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(8)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(20)),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorTextColor.name))),
            SizedBox(height: ScreenUtil().setWidth(20)),
            TextButton(onPressed: _loadTokens, child: Text(S.of(context).g_key_dex_retry)),
          ],
        ),
      );
    }

    // 有本地结果 → 直接展示
    if (_filtered.isNotEmpty) {
      return _buildList(_filtered);
    }

    // 正在做地址远程搜索
    if (_remoteSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // 远程搜索有结果
    if (_remoteResults.isNotEmpty) {
      return _buildList(_remoteResults);
    }

    // 远程搜索无结果
    if (_remoteError.isNotEmpty) {
      return Center(
        child: Text(
          _remoteError,
          style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name)),
        ),
      );
    }

    // 本地无结果且输入不像地址
    return Center(
      child: Text(
        _searchCtrl.text.isEmpty
            ? S.of(context).g_key_dex_no_tokens
            : S.of(context).g_key_dex_no_tokens_found,
        style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name)),
      ),
    );
  }

  Widget _buildList(List<DexTokenModel> tokens) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      itemCount: tokens.length,
      separatorBuilder: (context, i) => Divider(
        height: ScreenUtil().setWidth(1),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.dividerColor.name),
      ),
      itemBuilder: (context, index) {
        final token = tokens[index];
        return InkWell(
          onTap: () => Navigator.pop(context, token),
          child: SizedBox(
            height: ScreenUtil().setWidth(110),
            child: Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(52),
                  height: ScreenUtil().setWidth(52),
                  child: ImageNetWork(
                    imageUrl: token.logoUri,
                    placeholder: 'assets/img/list_default.png',
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.symbol,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        token.name,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(22),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 地址缩略展示
                Text(
                  _shortenAddress(token.address),
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
  }
}
