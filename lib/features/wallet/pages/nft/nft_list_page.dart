// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_detail_page.dart';
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
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
      widget.coinModel.coin['coinType'] as String?,
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

    return list;
  }

  bool get _hasOrdinals {
    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    return coinType.toUpperCase() == 'BTC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_nft_gallery),
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

                return buildGrid(context, filtered);
              },
            ),
          ),
        ],
      ),
    );
  }
}
