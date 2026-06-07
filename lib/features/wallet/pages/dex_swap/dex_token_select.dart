import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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

  bool _remoteSearching = false;
  List<DexTokenModel> _remoteResults = [];
  String _remoteError = '';
  int _remoteSearchRequestId = 0;

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

  List<DexTokenModel> _parseTokens(dynamic data) {
    return ((data as List?) ?? [])
        .map((e) => DexTokenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadTokens() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await _api.getTokens(widget.chain);
      if (!mounted) return;
      if (res.error) {
        setState(() {
          _loading = false;
          _error = res.data?.toString() ?? 'Load failed';
        });
        return;
      }
      final list = _parseTokens(res.data);
      setState(() {
        _loading = false;
        _all = list;
        _filtered = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  static final _evmHexRe = RegExp(r'^[0-9a-fA-F]{40}$');
  static final _solBase58Re = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');

  bool _isAddressLike(String q) {
    if (q.startsWith('0x') && q.length == 42) {
      return _evmHexRe.hasMatch(q.substring(2));
    }
    if (!q.startsWith('0x') && q.length >= 32 && q.length <= 50) {
      return _solBase58Re.hasMatch(q);
    }
    return false;
  }

  void _onSearch() {
    final raw = _searchCtrl.text.trim();
    final q = raw.toLowerCase();
    _remoteSearchRequestId++;

    final local = q.isEmpty
        ? _all
        : _all
              .where(
                (t) =>
                    t.symbol.toLowerCase().contains(q) ||
                    t.name.toLowerCase().contains(q) ||
                    t.address.toLowerCase().contains(q),
              )
              .toList();

    setState(() {
      _remoteResults = [];
      _remoteError = '';
      _remoteSearching = false;
      _filtered = local;
    });

    if (local.isEmpty && _isAddressLike(raw)) _searchByAddress(raw);
  }

  Future<void> _searchByAddress(String address) async {
    final requestId = ++_remoteSearchRequestId;
    if (!mounted) return;
    setState(() => _remoteSearching = true);
    try {
      final res = await _api.getTokens(widget.chain, q: address);
      if (!mounted ||
          requestId != _remoteSearchRequestId ||
          _searchCtrl.text.trim() != address) {
        return;
      }
      if (res.error) {
        setState(() {
          _remoteSearching = false;
          _remoteError = 'Search failed';
        });
        return;
      }
      final results = _parseTokens(res.data);
      setState(() {
        _remoteSearching = false;
        _remoteResults = results;
        if (results.isEmpty) _remoteError = 'Token not found';
      });
    } catch (_) {
      if (!mounted ||
          requestId != _remoteSearchRequestId ||
          _searchCtrl.text.trim() != address) {
        return;
      }
      setState(() {
        _remoteSearching = false;
        _remoteError = 'Search failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_9),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space4,
            ),
            child: TextField(
              controller: _searchCtrl,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).g_key_dex_search_hint,
                hintStyle: AppTypography.body.copyWith(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.textFieldHintColor.name,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColorTokens.of(context).textSubtitle,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColorTokens.of(context).bgSurface,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.brSm,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.space4,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading || _remoteSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error,
              style: TextStyle(color: AppColorTokens.of(context).danger),
            ),
            SizedBox(height: AppSpacing.space4),
            TextButton(
              onPressed: _loadTokens,
              child: Text(S.of(context).g_key_aa_retry),
            ),
          ],
        ),
      );
    }
    if (_filtered.isNotEmpty) return _buildList(_filtered);
    if (_remoteResults.isNotEmpty) return _buildList(_remoteResults);

    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final message = _remoteError.isNotEmpty
        ? _remoteError
        : _searchCtrl.text.isEmpty
        ? S.of(context).g_key_dex_no_tokens
        : S.of(context).g_key_dex_no_tokens_found;
    return Center(
      child: Text(message, style: TextStyle(color: subtitleColor)),
    );
  }

  Widget _buildList(List<DexTokenModel> tokens) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      itemCount: tokens.length,
      separatorBuilder: (_, _) => Divider(
        height: ScreenUtil().setWidth(1),
        color: AppColorTokens.of(context).border,
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
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.symbol,
                        style: AppTypography.body.copyWith(
                          color: mainText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        token.name,
                        style: AppTypography.caption.copyWith(
                          color: subtitleText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _shortenAddress(token.address),
                  style: AppTypography.captionSm.copyWith(color: subtitleText),
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
