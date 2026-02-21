import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/dex_swap_api.dart';
import 'package:n42appv2/src/wallet/models/dex/dex_token_model.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

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
      final list = (res.data as List)
          .map((e) => DexTokenModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _loading = false;
        _all = list;
        _filtered = list;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((t) =>
                  t.symbol.toLowerCase().contains(q) ||
                  t.name.toLowerCase().contains(q) ||
                  t.address.toLowerCase().contains(q))
              .toList();
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
                hintText: 'Search symbol / name / address',
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
            TextButton(onPressed: _loadTokens, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text('No tokens found',
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name))),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      itemCount: _filtered.length,
      separatorBuilder: (context, i) => Divider(
        height: ScreenUtil().setWidth(1),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.dividerColor.name),
      ),
      itemBuilder: (context, index) {
        final token = _filtered[index];
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
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(22),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
