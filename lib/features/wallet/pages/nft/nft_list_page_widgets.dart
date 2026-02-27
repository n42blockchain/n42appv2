part of 'nft_list_page.dart';

/// Widget builder methods for [_NftListPageState].
extension _NftListPageWidgets on _NftListPageState {
  Widget buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(12),
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(4),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).g_key_nft_search_hint,
          hintStyle: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: ScreenUtil().setWidth(28),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  iconSize: ScreenUtil().setWidth(24),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(12),
            horizontal: ScreenUtil().setWidth(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            borderSide: BorderSide(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withAlpha(60),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            borderSide: BorderSide(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withAlpha(60),
            ),
          ),
          filled: true,
          fillColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
        ),
        style: TextStyle(fontSize: ScreenUtil().setSp(26)),
      ),
    );
  }

  Widget buildFilterChips(BuildContext context) {
    final filters = [
      (_NftFilter.all, S.of(context).g_key_nft_filter_all),
      if (_nfts.any((n) => n.hasVideo))
        (_NftFilter.video, S.of(context).g_key_nft_filter_video),
      if (!_hasOrdinals && _nfts.any((n) => n.nftType == 'ERC721'))
        (_NftFilter.erc721, 'ERC721'),
      if (!_hasOrdinals && _nfts.any((n) => n.isErc1155))
        (_NftFilter.erc1155, 'ERC1155'),
      if (_hasOrdinals || _nfts.any((n) => n.isOrdinal))
        (_NftFilter.ordinals, S.of(context).g_key_nft_ordinals),
    ];

    if (filters.length <= 1) return const SizedBox.shrink();

    final accentColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return SizedBox(
      height: ScreenUtil().setWidth(52),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
        itemCount: filters.length,
        separatorBuilder: (ctx, i) => SizedBox(width: ScreenUtil().setWidth(8)),
        itemBuilder: (context, i) {
          final (type, label) = filters[i];
          final selected = _filter == type;
          return GestureDetector(
            onTap: () => setState(() => _filter = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: selected ? accentColor : accentColor.withAlpha(20),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildError(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _retry,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: ScreenUtil().setWidth(60),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              S.of(context).g_key_nft_error_retry,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_outlined,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_nft_no_items,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid(BuildContext context, List<NftModel> nfts) {
    return GridView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ScreenUtil().setWidth(12),
        mainAxisSpacing: ScreenUtil().setWidth(12),
        childAspectRatio: 0.75,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) => _buildNftCard(context, nfts[index]),
    );
  }

  Widget _buildNftCard(BuildContext context, NftModel nft) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NftDetailPage(nft, widget.coinModel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name)
                .withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImageSection(nft)),
            _buildInfoSection(context, nft),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(NftModel nft) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil().setWidth(12)),
            topRight: Radius.circular(ScreenUtil().setWidth(12)),
          ),
          child: _buildThumbnail(nft),
        ),
        if (nft.hasVideo)
          Positioned(
            top: ScreenUtil().setWidth(8),
            right: ScreenUtil().setWidth(8),
            child: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
              ),
              child: Icon(Icons.play_circle_outline,
                  color: Colors.white, size: ScreenUtil().setWidth(22)),
            ),
          ),
        if (nft.isOrdinal)
          Positioned(
            top: ScreenUtil().setWidth(8),
            left: ScreenUtil().setWidth(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(6),
                vertical: ScreenUtil().setWidth(3),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7931A).withAlpha(220),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
              ),
              child: Text(
                'BTC',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, NftModel nft) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nft.name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (nft.floorPriceDisplay != null) ...[
            SizedBox(height: ScreenUtil().setWidth(4)),
            Row(
              children: [
                Text(
                  '${S.of(context).g_key_nft_floor_price}: ',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                Expanded(
                  child: Text(
                    nft.floorPriceDisplay!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      fontWeight: FontWeight.w500,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnail(NftModel nft) {
    if (nft.imageUrl != null && nft.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: nft.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildPlaceholder(nft),
        errorWidget: (context, url, error) => _buildPlaceholder(nft),
      );
    }
    return _buildPlaceholder(nft);
  }

  Widget _buildPlaceholder(NftModel nft) {
    return Builder(
      builder: (context) => Container(
        color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(20),
        child: Center(
          child: Icon(
            nft.isOrdinal ? Icons.currency_bitcoin : Icons.image_outlined,
            size: ScreenUtil().setWidth(50),
            color: nft.isOrdinal
                ? const Color(0xFFF7931A)
                : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ),
    );
  }
}
