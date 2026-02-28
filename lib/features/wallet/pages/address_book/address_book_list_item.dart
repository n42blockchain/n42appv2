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
    final content = _buildItemContent(context, info);

    if (isPickerMode) {
      return GestureDetector(
        onTap: () => Navigator.pop(context, info.address),
        child: content,
      );
    }

    return Dismissible(
      key: ValueKey(info.id ?? '${info.address}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(info),
      onDismissed: (_) => deleteItem(info),
      background: Container(
        alignment: Alignment.centerRight,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name),
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ScreenUtil().setWidth(52),
        ),
      ),
      child: GestureDetector(
        onTap: () => navigateToEdit(info),
        child: content,
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, AddressBookModel info) {
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final mutedText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20),
      ),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          _buildAvatar(info),
          SizedBox(width: ScreenUtil().setWidth(20)),

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
                        style: TextStyle(
                          color: mainText,
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(14),
                        vertical: ScreenUtil().setWidth(4),
                      ),
                      decoration: BoxDecoration(
                        color: subtitleText.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(20)),
                      ),
                      child: Text(
                        info.coinName ?? '',
                        style: TextStyle(
                          color: subtitleText,
                          fontSize: ScreenUtil().setSp(20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),

                EnsAddressText(
                  address: info.address ?? '',
                  coinType: info.coinName ?? 'ETH',
                  style: TextStyle(
                    color: subtitleText,
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),

                if (info.desc != null && info.desc!.isNotEmpty) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Text(
                    info.desc!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: ScreenUtil().setSp(24),
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
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.w700,
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
