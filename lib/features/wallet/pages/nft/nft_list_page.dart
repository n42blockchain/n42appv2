// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_batch_send_page.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_batch_transfer_utils.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_detail_page.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
import 'package:n42_wallet/features/wallet/utils/nft_gallery_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'nft_list_page_widgets.dart';

/// NFT 列表页
///
/// 展示某链下当前钱包地址持有的所有 NFT（2 列 grid）。
/// 支持按名称/Collection 搜索、按类型过滤（全部/Video/ERC721/ERC1155/Ordinals）。
/// 点击任意 NFT → 进入 [NftDetailPage]。
class NftListPage extends StatefulWidget {
  final CoinModel coinModel;

  const NftListPage(this.coinModel, {super.key});

  @override
  State<NftListPage> createState() => _NftListPageState();
}

/// 类型过滤枚举
enum _NftFilter { all, video, erc721, erc1155, ordinals }

class _NftListPageState extends State<NftListPage> {
  late Future<List<NftModel>> _future;
  final _api = SimpleHashNftApi();
  final _searchController = TextEditingController();

  List<NftModel> _nfts = [];
  _NftFilter _filter = _NftFilter.all;
  String _query = '';
  String? _loadErrorMessage;
  // S4: 默认隐藏疑似垃圾/空投钓鱼 NFT。
  bool _hideSpam = true;
  // S4 v2: 按系列分组视图。
  bool _groupByCollection = false;
  bool _selectionMode = false;
  final Set<String> _selectedNftKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateView([VoidCallback? fn]) {
    if (!mounted) return;
    setState(() {
      fn?.call();
    });
  }

  void _load() {
    final address = FeatureAddressUtils.normalize(
      widget.coinModel.address?.toString(),
    );
    final coinType = FeatureAddressUtils.normalize(
      widget.coinModel.config.coinType,
    );
    _loadErrorMessage = null;

    if (!FeatureAddressUtils.hasValue(address) ||
        !FeatureAddressUtils.hasValue(coinType)) {
      _future = Future.value(const <NftModel>[]);
      _updateView(() => _nfts = []);
      return;
    }

    _future = _api
        .fetchNfts(address, coinType)
        .then((list) {
          _updateView(() => _nfts = list);
          return list;
        })
        .catchError((error, stackTrace) {
          _loadErrorMessage = error.toString();
          throw error;
        });
  }

  void _retry() {
    setState(() {
      _nfts = [];
      _selectionMode = false;
      _selectedNftKeys.clear();
      _load();
    });
  }

  List<NftModel> get _filtered {
    var list = _nfts.where((n) => n.balance > 0).toList();

    final typeTest = switch (_filter) {
      _NftFilter.all => null,
      _NftFilter.video => (NftModel n) => n.hasVideo,
      _NftFilter.erc721 => (NftModel n) => n.nftType == 'ERC721',
      _NftFilter.erc1155 => (NftModel n) => n.isErc1155,
      _NftFilter.ordinals => (NftModel n) => n.isOrdinal,
    };
    if (typeTest != null) list = list.where(typeTest).toList();

    if (_query.isNotEmpty) {
      list = list.where((n) {
        return n.name.toLowerCase().contains(_query) ||
            (n.collectionName?.toLowerCase().contains(_query) ?? false);
      }).toList();
    }

    // S4: 隐藏疑似垃圾 NFT（启发式）。
    if (_hideSpam) list = NftGalleryUtils.filterSpam(list);

    return list;
  }

  /// 当前过滤集合中被隐藏的垃圾 NFT 数量（用于角标提示）。
  int get _spamCount {
    final base = _nfts.where((n) => n.balance > 0).length;
    final keptIfShown = _nfts
        .where((n) => n.balance > 0 && !NftGalleryUtils.isLikelySpam(n))
        .length;
    return base - keptIfShown;
  }

  bool get _hasOrdinals {
    final coinType = widget.coinModel.config.coinType;
    return coinType.toUpperCase() == 'BTC';
  }

  List<NftModel> get _selectedNfts => _filtered
      .where((nft) => _selectedNftKeys.contains(_selectionKey(nft)))
      .toList(growable: false);

  String _selectionKey(NftModel nft) => NftBatchTransferUtils.selectionKey(nft);

  bool _isSelected(NftModel nft) =>
      _selectedNftKeys.contains(_selectionKey(nft));

  void _toggleSelection(NftModel nft) {
    if (!NftBatchTransferUtils.isBatchTransferable(nft)) {
      ToastUtils.showWarning(
        nft.isOrdinal
            ? S.of(context).g_key_nft_ordinals_unsupported
            : nft.isSolana
            ? S.of(context).g_key_nft_send_sol_unsupported
            : 'NFT transfer is not supported',
      );
      return;
    }
    setState(() {
      _selectionMode = true;
      final key = _selectionKey(nft);
      if (_selectedNftKeys.contains(key)) {
        _selectedNftKeys.remove(key);
      } else {
        _selectedNftKeys.add(key);
      }
      if (_selectedNftKeys.isEmpty) _selectionMode = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectionMode = false;
      _selectedNftKeys.clear();
    });
  }

  Future<void> _openBatchSend() async {
    final selected = _selectedNfts;
    if (selected.isEmpty) return;
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NftBatchSendPage(selected, widget.coinModel),
      ),
    );
    if (!mounted) return;
    if (completed == true) {
      _clearSelection();
      _retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: _selectionMode
            ? '${_selectedNftKeys.length} selected'
            : S.of(context).g_key_nft_gallery,
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: [
          if (_selectionMode)
            IconButton(
              tooltip: S.of(context).g_key_48,
              icon: const Icon(Icons.send_outlined),
              onPressed: _selectedNftKeys.isEmpty ? null : _openBatchSend,
            )
          else if (_nfts.any(NftBatchTransferUtils.isBatchTransferable))
            IconButton(
              tooltip: 'Select',
              icon: const Icon(Icons.checklist_outlined),
              onPressed: () => setState(() => _selectionMode = true),
            ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(context),
          buildFilterChips(context),
          Expanded(
            child: FutureBuilder<List<NftModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _nfts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && _nfts.isEmpty) {
                  return buildError(context);
                }

                final filtered = _filtered;
                if (filtered.isEmpty) {
                  return buildEmpty(context);
                }

                return _groupByCollection
                    ? buildGroupedView(context, filtered)
                    : buildGrid(context, filtered);
              },
            ),
          ),
        ],
      ),
    );
  }
}
