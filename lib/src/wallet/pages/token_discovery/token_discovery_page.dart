import 'package:n42_wallet/core/token_discovery/discovered_token.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Shows tokens discovered on-chain but not yet in the user's wallet.
/// Pops `true` if at least one token was added so the caller can clear
/// its discovery state.
class TokenDiscoveryPage extends ConsumerStatefulWidget {
  final List<DiscoveredToken> tokens;
  const TokenDiscoveryPage({required this.tokens, super.key});

  @override
  ConsumerState<TokenDiscoveryPage> createState() => _TokenDiscoveryPageState();
}

class _TokenDiscoveryPageState extends ConsumerState<TokenDiscoveryPage> {
  late List<DiscoveredToken> _tokens;
  bool _anyAdded = false;

  @override
  void initState() {
    super.initState();
    // Copy so we can mutate isSelected safely.
    _tokens = widget.tokens
        .map(
          (t) => DiscoveredToken(
            coinType: t.coinType,
            blockchainType: t.blockchainType,
            contractAddress: t.contractAddress,
            symbol: t.symbol,
            name: t.name,
            decimals: t.decimals,
            rawBalance: t.rawBalance,
            isSelected: true,
          ),
        )
        .toList();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<DiscoveredToken> get _selected =>
      _tokens.where((t) => t.isSelected).toList();

  Future<void> _addToken(DiscoveredToken token) async {
    final wap = ref.read(wapBridgeProvider);
    final chainData = wap.walletMap[token.coinType];
    if (chainData == null) {
      ToastUtils.show(S.of(context).g_key_3); // "Chain not found"
      return;
    }
    final baseInfo = chainData['baseInfo'] as Map<String, dynamic>?;
    if (baseInfo == null) return;
    wap.addWalletChainToken(token.toTokenMap(baseInfo));
    setState(() {
      _tokens.remove(token);
      _anyAdded = true;
    });
    ToastUtils.show(S.of(context).g_key_token_discovery_added);
  }

  Future<void> _addSelected() async {
    final toAdd = _selected.toList(); // snapshot before mutation
    for (final token in toAdd) {
      await _addToken(token);
    }
  }

  Future<void> _ignoreToken(DiscoveredToken token) async {
    await SPUtil().addIgnoredTokenContract(token.contractAddress);
    setState(() => _tokens.remove(token));
  }

  void _popResult() {
    Navigator.of(context).pop(_anyAdded);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_token_discovery_title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _popResult,
        ),
      ),
      body: _tokens.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                Expanded(child: _buildList()),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        S.of(context).g_key_token_discovery_empty,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(30),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
    );
  }

  Widget _buildList() {
    // Group by coinType.
    final grouped = <String, List<DiscoveredToken>>{};
    for (final t in _tokens) {
      grouped.putIfAbsent(t.coinType, () => []).add(t);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(16),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final chainType = grouped.keys.elementAt(index);
        final chainTokens = grouped[chainType]!;
        return _buildChainSection(chainType, chainTokens);
      },
    );
  }

  Widget _buildChainSection(String chainType, List<DiscoveredToken> tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chain header
        Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil().setWidth(20),
            bottom: ScreenUtil().setWidth(10),
          ),
          child: Text(
            chainType,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...tokens.map((t) => _buildTokenRow(t)),
      ],
    );
  }

  Widget _buildTokenRow(DiscoveredToken token) {
    final selectedColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(18),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          // Selection checkbox
          GestureDetector(
            onTap: () => setState(() => token.isSelected = !token.isSelected),
            child: Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
              decoration: BoxDecoration(
                color: token.isSelected
                    ? selectedColor
                    : Colors.transparent,
                border: Border.all(
                  color: token.isSelected
                      ? selectedColor
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.dividerColor.name),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: token.isSelected
                  ? Icon(Icons.check_rounded,
                      color: Colors.white, size: ScreenUtil().setWidth(24))
                  : null,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          // Token info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.displaySymbol,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  token.displayName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Balance + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                token.humanBalance,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w500,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ignore button
                  GestureDetector(
                    onTap: () => _ignoreToken(token),
                    child: Text(
                      S.of(context).g_key_token_discovery_ignore,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(16)),
                  // Add single token button
                  GestureDetector(
                    onTap: () => _addToken(token),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                        vertical: ScreenUtil().setWidth(8),
                      ),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                      child: Text(
                        S.of(context).g_key_token_discovery_add,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final selectedCount = _selected.length;
    return Container(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(30),
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(30),
        ScreenUtil().setWidth(36),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Select-all toggle
          GestureDetector(
            onTap: () {
              final allSelected = _selected.length == _tokens.length;
              setState(() {
                for (final t in _tokens) {
                  t.isSelected = !allSelected;
                }
              });
            },
            child: Text(
              _selected.length == _tokens.length
                  ? S.of(context).g_key_token_discovery_deselect_all
                  : S.of(context).g_key_token_discovery_select_all,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
          const Spacer(),
          // Add selected button
          SizedBox(
            height: ScreenUtil().setWidth(80),
            child: buttonStyle2(
              context,
              selectedCount > 0 ? _addSelected : null,
              S.of(context).g_key_token_discovery_add_selected(selectedCount),
            ),
          ),
        ],
      ),
    );
  }
}
