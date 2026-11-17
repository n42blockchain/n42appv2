part of 'address_book_list.dart';

/// Item builder mixin for [_AddressBookListState].
///
/// Builds list items including the contact card layout, avatar with
/// chain-icon badge, and swipe-to-delete / picker-mode behaviors.
mixin _AddressBookListItemMixin on State<AddressBookList> {
  // Provided by _AddressBookListState
  List<AddressBookModel> get filteredItems;
  bool get isPickerMode;
  Future<void> Function(AddressBookModel info) get navigateToEdit;
  Future<bool> Function(AddressBookModel info) get confirmDelete;
  Future<void> Function(AddressBookModel info) get deleteItem;

  Widget buildItem(BuildContext context, int index) {
    final info = filteredItems[index];

    if (isPickerMode) {
      return _buildItemContent(
        context,
        info,
        onTap: () => Navigator.pop(context, info.address),
      );
    }

    return Dismissible(
      key: ValueKey(info.id ?? '${info.address}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(info),
      onDismissed: (_) => deleteItem(info),
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColorTokens.of(context).danger,
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ScreenUtil().setWidth(52),
        ),
      ),
      child: _buildItemContent(
        context,
        info,
        onTap: () => navigateToEdit(info),
      ),
    );
  }

  Widget _buildItemContent(
    BuildContext context,
    AddressBookModel info, {
    required VoidCallback onTap,
  }) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    final itemBg = AppColorTokens.of(context).bgSurface;
    final mutedText = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.ff888888.name,
    );

    // Card color on a Material so the row shows press feedback.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space2,
      ),
      child: Material(
        color: itemBg,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space4,
            ),
            child: Row(
              children: [
                _buildAvatar(info),
                SizedBox(width: AppSpacing.space4),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              info.name ?? '',
                              style: AppTypography.body.copyWith(
                                color: mainText,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: AppSpacing.space4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.space4,
                              vertical: AppSpacing.space2,
                            ),
                            decoration: BoxDecoration(
                              color: subtitleText.withValues(alpha: 0.1),
                              borderRadius: AppRadius.brMd,
                            ),
                            child: Text(
                              info.coinName ?? '',
                              style: AppTypography.captionSm.copyWith(
                                color: subtitleText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.space2),

                      EnsAddressText(
                        address: info.address ?? '',
                        coinType: info.coinName ?? 'ETH',
                        style: AppTypography.caption.copyWith(
                          color: subtitleText,
                        ),
                      ),

                      if (info.desc != null && info.desc!.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.space2),
                        Text(
                          info.desc!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (!isPickerMode)
                  Icon(
                    Icons.chevron_right,
                    size: ScreenUtil().setWidth(40),
                    color: subtitleText,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AddressBookModel info) {
    final name = info.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bgColor = _avatarColor(name);
    final avatarSize = ScreenUtil().setWidth(72);
    final badgeSize = ScreenUtil().setWidth(26);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          right: -ScreenUtil().setWidth(4),
          bottom: -ScreenUtil().setWidth(4),
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(1.5),
            child: ClipOval(
              child: info.coinName == CoinType.N.name
                  ? Image.asset('assets/img/ast.png', fit: BoxFit.cover)
                  : ImageNetWork(
                      imageUrl: info.coinIcon ?? '',
                      placeholder: 'assets/img/list_default.png',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
