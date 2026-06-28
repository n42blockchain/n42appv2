// ignore_for_file: invalid_use_of_protected_member

part of 'nft_list_page.dart';

extension _NftListPageWidgets on _NftListPageState {
  Widget buildSearchBar(BuildContext context) {
    final su = ScreenUtil();
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final borderRadius = BorderRadius.circular(su.setWidth(12));
    final borderSide = BorderSide(color: subtitleColor.withAlpha(60));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        su.setWidth(16),
        su.setWidth(12),
        su.setWidth(16),
        su.setWidth(4),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).g_key_nft_search_hint,
          hintStyle: AppTypography.bodySm.copyWith(color: subtitleColor),
          prefixIcon: Icon(
            Icons.search,
            size: su.setWidth(28),
            color: subtitleColor,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  iconSize: su.setWidth(24),
                  onPressed: () {
                    _searchController.clear();
                    _updateView(() => _query = '');
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: su.setWidth(12),
            horizontal: su.setWidth(16),
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: borderSide,
          ),
          filled: true,
          fillColor: AppColorTokens.of(context).bgBase,
        ),
        style: AppTypography.bodySm,
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

    final showTypeFilters = filters.length > 1;
    final showSpamToggle = _nfts.any((n) => n.balance > 0) && _spamCount > 0;
    if (!showTypeFilters && !showSpamToggle) return const SizedBox.shrink();

    final accentColor = AppColorTokens.of(context).brand;

    return SizedBox(
      height: ScreenUtil().setWidth(52),
      child: Row(
        children: [
          if (showTypeFilters)
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                itemCount: filters.length,
                separatorBuilder: (ctx, i) => SizedBox(width: AppSpacing.space2),
                itemBuilder: (context, i) {
                  final (type, label) = filters[i];
                  final selected = _filter == type;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _updateView(() => _filter = type),
                      borderRadius: AppRadius.brMd,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.space4,
                          vertical: AppSpacing.space2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected ? accentColor : accentColor.withAlpha(20),
                          borderRadius: AppRadius.brMd,
                        ),
                        child: Text(
                          label,
                          style: AppTypography.caption.copyWith(
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                            color: selected
                                ? Colors.white
                                : AppColorTokens.of(context).textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Spacer(),
          if (showSpamToggle) _buildSpamToggle(context),
          SizedBox(width: AppSpacing.space4),
        ],
      ),
    );
  }

  /// S4: 隐藏/显示疑似垃圾 NFT 的开关。
  Widget _buildSpamToggle(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final active = _hideSpam;
    final color = active ? tokens.brand : tokens.textSubtitle;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateView(() => _hideSpam = !_hideSpam),
        borderRadius: AppRadius.brMd,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: active ? tokens.brand.withAlpha(20) : Colors.transparent,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.shield : Icons.shield_outlined,
                size: ScreenUtil().setWidth(16),
                color: color,
              ),
              SizedBox(width: AppSpacing.space2),
              Text(
                '${S.of(context).g_key_nft_hide_spam} ($_spamCount)',
                style: AppTypography.captionSm.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError(BuildContext context) {
    final su = ScreenUtil();
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _retry,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: su.setWidth(60),
                color: AppColorTokens.of(context).brand,
              ),
              SizedBox(height: su.setWidth(16)),
              Text(
                _loadErrorMessage?.isNotEmpty == true
                    ? _loadErrorMessage!
                    : S.of(context).g_key_nft_error_retry,
                style: AppTypography.body.copyWith(color: subtitleColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmpty(BuildContext context) {
    final su = ScreenUtil();
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_outlined,
            size: su.setWidth(80),
            color: subtitleColor,
          ),
          SizedBox(height: su.setWidth(20)),
          Text(
            S.of(context).g_key_nft_no_items,
            style: AppTypography.headline.copyWith(
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid(BuildContext context, List<NftModel> nfts) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.space4),
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
    final su = ScreenUtil();
    final radius = BorderRadius.circular(su.setWidth(12));
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NftDetailPage(nft, widget.coinModel)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgBase,
          borderRadius: radius,
          border: Border.all(
            color: AppColorTokens.of(context).textSubtitle.withAlpha(40),
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
    final su = ScreenUtil();
    final badgeRadius = BorderRadius.circular(su.setWidth(6));
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(su.setWidth(12)),
            topRight: Radius.circular(su.setWidth(12)),
          ),
          child: _buildThumbnail(nft),
        ),
        if (nft.hasVideo)
          Positioned(
            top: su.setWidth(8),
            right: su.setWidth(8),
            child: Container(
              padding: EdgeInsets.all(su.setWidth(4)),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: badgeRadius,
              ),
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: su.setWidth(22),
              ),
            ),
          ),
        if (nft.isOrdinal)
          Positioned(
            top: su.setWidth(8),
            left: su.setWidth(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: su.setWidth(6),
                vertical: su.setWidth(3),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7931A).withAlpha(220),
                borderRadius: badgeRadius,
              ),
              child: Text(
                'BTC',
                style: AppTypography.captionSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, NftModel nft) {
    final su = ScreenUtil();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(10),
        vertical: su.setWidth(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nft.name,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (nft.floorPriceDisplay != null) ...[
            SizedBox(height: su.setWidth(4)),
            Row(
              children: [
                Flexible(
                  flex: 0,
                  child: Text(
                    '${S.of(context).g_key_nft_floor_price}: ',
                    style: AppTypography.captionSm.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  child: Text(
                    nft.floorPriceDisplay!,
                    style: AppTypography.captionSm.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColorTokens.of(context).brand,
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
    final blueColor = AppColorTokens.of(context).brand;
    return Container(
      color: blueColor.withAlpha(20),
      child: Center(
        child: Icon(
          nft.isOrdinal ? Icons.currency_bitcoin : Icons.image_outlined,
          size: ScreenUtil().setWidth(50),
          color: nft.isOrdinal ? const Color(0xFFF7931A) : blueColor,
        ),
      ),
    );
  }
}
