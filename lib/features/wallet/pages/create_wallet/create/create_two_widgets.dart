part of 'create_two.dart';

/// Widget builder mixin for [_CreateTwoState].
///
/// Builds the mnemonic grid view (hidden/visible states) and the
/// skip-backup confirmation dialog. Applied after [State] so that
/// [widget], [context], [mounted], and state fields are accessible.
mixin _CreateTwoWidgetsMixin on State<CreateTwo> {
  bool get showMnemonic;
  set showMnemonic(bool value);
  List get mnemonicWordsList;
  String get mnemonicWords;

  Color _itemBgColor() => AppColorTokens.of(context).bgSurface;

  Color _itemTextColor() => AppColorTokens.of(context).textItem;

  Widget buildGridView() {
    return showMnemonic ? _buildMnemonicGrid() : _buildRevealPlaceholder();
  }

  Widget _buildMnemonicGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      itemCount: mnemonicWordsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: ScreenUtil().setWidth(20.0),
        crossAxisSpacing: ScreenUtil().setWidth(20.0),
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: _itemBgColor(),
            borderRadius: AppRadius.brSm,
          ),
          child: Center(
            child: Text(
              mnemonicWordsList[index],
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: _itemTextColor()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealPlaceholder() {
    final textStyle = AppTypography.body.copyWith(color: _itemTextColor());
    return InkWell(
      onTap: () => setState(() => showMnemonic = true),
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(400),
        padding: EdgeInsets.all(AppSpacing.space8),
        decoration: BoxDecoration(
          color: _itemBgColor(),
          borderRadius: AppRadius.brMd,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
              child: Icon(
                Icons.visibility_off_outlined,
                color: _itemTextColor(),
                size: ScreenUtil().setWidth(80.0),
              ),
            ),
            Text(S.of(context).g_key_wallet_c44, style: textStyle),
            Text(
              S.of(context).g_key_wallet_c45,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showSkipWidget() async {
    final mainTextColor = AppColorTokens.of(context).textPrimary;
    final child = Center(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.space8),
        decoration: BoxDecoration(
          color: _itemBgColor(),
          borderRadius: AppRadius.brMd,
        ),
        constraints: BoxConstraints(
          minHeight: ScreenUtil().setWidth(472.0),
          maxHeight: ScreenUtil().setWidth(550.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${S.of(context).g_key_wallet_c18}?",
              style: AppTypography.headline.copyWith(
                color: mainTextColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              height: ScreenUtil().setWidth(200.0),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_key_wallet_c19,
                style: AppTypography.bodySm.copyWith(color: mainTextColor),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: AppButton(
                label: S.of(context).g_mining_key62,
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: AppButton(
                label: S.of(context).g_key_79,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
          ],
        ),
      ),
    );
    final flag = await tipsDialog3(context, child);
    if (!mounted) return;
    if (flag == true) {
      widget.wInfo.mnemonic = mnemonicWords;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateFinish(wInfo: widget.wInfo),
        ),
      );
    }
  }
}
