import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart';
import 'package:n42_wallet/features/wallet/widgets/create_wallet_button.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_4.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'wallet_list_tiles.dart';
part 'wallet_list_actions.dart';

class WalletList extends ConsumerStatefulWidget {
  const WalletList({super.key});

  @override
  ConsumerState<WalletList> createState() => _WalletListState();
}

class _WalletListState extends ConsumerState<WalletList>
    with _WalletListActionsMixin, _WalletListTilesMixin {
  List<WalletInfo> walletList = [];
  Load load = Load.finish;
  String? _selectedTag;
  List<String> _cachedTags = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    walletList = ref.read(wapBridgeProvider).walletInfoLsit;
    _rebuildTagCache();
    setState(() {});
  }

  void _rebuildTagCache() {
    final tags = <String>{};
    for (final w in walletList) {
      tags.addAll(w.tags);
    }
    _cachedTags = tags.toList()..sort();
  }

  /// Filter wallets by selected tag
  List<WalletInfo> get _filteredWalletList {
    if (_selectedTag == null) return walletList;
    return walletList.where((w) => w.tags.contains(_selectedTag)).toList();
  }

  Widget _buildTagFilter() {
    final tags = _cachedTags;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  'All',
                  style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                ),
                selected: _selectedTag == null,
                onSelected: (_) => setState(() => _selectedTag = null),
                selectedColor: AppColorTokens.of(context).brand,
                labelStyle: AppTypography.caption.copyWith(color: _selectedTag == null ? Colors.white : null),
                side: BorderSide.none,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            ...tags.map(
              (tag) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    tag,
                    style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                  ),
                  selected: _selectedTag == tag,
                  onSelected: (_) => setState(() => _selectedTag = tag),
                  selectedColor: AppColorTokens.of(context).brand,
                  labelStyle: AppTypography.caption.copyWith(color: _selectedTag == tag ? Colors.white : null),
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_wallet_manage,
        actions: [
          IconButton(
            onPressed: () async {
              sheetBottom(
                context,
                "",
                CreateWalletButton(
                  onTapBack: () {
                    initData();
                  },
                ),
              );
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColorTokens.of(context).brand,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_cachedTags.isNotEmpty) _buildTagFilter(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(20.0),
                        bottom: ScreenUtil().setWidth(10.0),
                        left: ScreenUtil().setWidth(30.0),
                      ),
                      child: Text(
                        S.of(context).g_key_ex_keystore_13,
                        style: AppTypography.headline.copyWith(color: AppColorTokens.of(context).textPrimary),
                      ),
                    ),
                    _buildList(),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Visibility(
                visible: load == Load.loading,
                child: LoadingPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
