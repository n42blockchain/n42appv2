import 'package:n42_wallet/core/token_discovery/discovered_token.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
    for (final token in _selected) {
      await _addToken(token);
    }
  }

  Future<void> _ignoreToken(DiscoveredToken token) async {
    final contract = token.coinType == 'SOL'
        ? token.contractAddress.trim()
        : token.contractAddress.toLowerCase();
    await SPUtil().addIgnoredTokenContract(contract);
    if (!mounted) return;
    setState(() => _tokens.remove(token));
  }

  void _popResult() {
    Navigator.of(context).pop(_anyAdded);
  }

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

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
        style: AppTypography.body.copyWith(color: _color(AppThemeKeys.itemSubtitleTextColor)),
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
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space4,
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
    final su = ScreenUtil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: su.setWidth(20),
            bottom: su.setWidth(10),
          ),
          child: Text(
            chainType,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: _color(AppThemeKeys.itemSubtitleTextColor),
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...tokens.map(_buildTokenRow),
      ],
    );
  }

  Widget _buildTokenRow(DiscoveredToken token) {
    final su = ScreenUtil();
    final Color accent = _color(AppThemeKeys.mainBlueColor);
    final s = S.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: su.setWidth(12)),
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(24),
        vertical: su.setWidth(18),
      ),
      decoration: BoxDecoration(
        color: _color(AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => token.isSelected = !token.isSelected),
            child: Container(
              width: su.setWidth(40),
              height: su.setWidth(40),
              decoration: BoxDecoration(
                color: token.isSelected ? accent : Colors.transparent,
                border: Border.all(
                  color: token.isSelected
                      ? accent
                      : _color(AppThemeKeys.dividerColor),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(su.setWidth(8)),
              ),
              child: token.isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: su.setWidth(24),
                    )
                  : null,
            ),
          ),
          SizedBox(width: su.setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.displaySymbol,
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _color(AppThemeKeys.mainTextColor),
                  ),
                ),
                SizedBox(height: su.setWidth(4)),
                Text(
                  token.displayName,
                  style: AppTypography.caption.copyWith(
                    color: _color(AppThemeKeys.itemSubtitleTextColor),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                token.humanBalance,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _color(AppThemeKeys.mainTextColor),
                ),
              ),
              SizedBox(height: su.setWidth(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _ignoreToken(token),
                    child: Text(
                      s.g_key_token_discovery_ignore,
                      style: AppTypography.caption.copyWith(
                        color: _color(AppThemeKeys.itemSubtitleTextColor),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: su.setWidth(16)),
                  GestureDetector(
                    onTap: () => _addToken(token),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: su.setWidth(20),
                        vertical: su.setWidth(8),
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(su.setWidth(8)),
                      ),
                      child: Text(
                        s.g_key_token_discovery_add,
                        style: AppTypography.caption.copyWith(
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
    final su = ScreenUtil();
    final selectedCount = _selected.length;
    final allSelected = selectedCount == _tokens.length;
    final s = S.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        su.setWidth(30),
        su.setWidth(16),
        su.setWidth(30),
        su.setWidth(36),
      ),
      decoration: BoxDecoration(
        color: _color(AppThemeKeys.backGroundColor),
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
          GestureDetector(
            onTap: () => setState(() {
              for (final t in _tokens) {
                t.isSelected = !allSelected;
              }
            }),
            child: Text(
              allSelected
                  ? s.g_key_token_discovery_deselect_all
                  : s.g_key_token_discovery_select_all,
              style: AppTypography.bodySm.copyWith(
                color: _color(AppThemeKeys.mainBlueColor),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: su.setWidth(80),
            child: AppButton(
              label: s.g_key_token_discovery_add_selected(selectedCount),
              onPressed: selectedCount > 0 ? _addSelected : null,
            ),
          ),
        ],
      ),
    );
  }
}
