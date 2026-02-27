part of 'create_two.dart';

/// Widget builder mixin for [_CreateTwoState].
///
/// Builds the mnemonic grid view (hidden/visible states) and the
/// skip-backup confirmation dialog. Applied after [State] so that
/// [widget], [context], [mounted], and state fields are accessible.
mixin _CreateTwoWidgetsMixin on State<CreateTwo> {
  // Provided by _CreateTwoState
  bool get showMnemonic;
  set showMnemonic(bool value);
  List get mnemonicWordsList;
  String get mnemonicWords;

  // ─── Mnemonic Grid View ───────────────────────────────────────────────

  Widget buildGridView() {
    if (showMnemonic) {
      return _buildMnemonicGrid();
    }
    return _buildRevealPlaceholder();
  }

  Widget _buildMnemonicGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
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
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
          ),
          child: Center(
            child: Text(
              mnemonicWordsList[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealPlaceholder() {
    return InkWell(
      onTap: () {
        setState(() {
          showMnemonic = true;
        });
      },
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(400),
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil().setWidth(80.0),
              height: ScreenUtil().setWidth(80.0),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
              child: Icon(
                Icons.visibility_off_outlined,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
                size: ScreenUtil().setWidth(80.0),
              ),
            ),
            Text(
              S.of(context).g_key_wallet_c44,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
            ),
            Text(
              S.of(context).g_key_wallet_c45,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skip Backup Dialog ───────────────────────────────────────────────

  Future<void> showSkipWidget() async {
    Widget child = Center(
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        constraints: BoxConstraints(
          minHeight: ScreenUtil().setWidth(472.0),
          maxHeight: ScreenUtil().setWidth(550.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${S.of(context).g_key_wallet_c18}?",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
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
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: buttonStyle2(
                context,
                () {
                  Navigator.pop(context, true);
                },
                S.of(context).g_mining_key62,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(30.0)),
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(80.0),
              child: buttonStyle5(
                context,
                () {
                  Navigator.pop(context, false);
                },
                S.of(context).g_key_79,
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor3.name),
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
    final flag = await tipsDialog3(context, child);
    if (!mounted) return;
    if (flag != null && flag) {
      widget.wInfo.mnemonic = mnemonicWords;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateFinish(wInfo: widget.wInfo)));
    }
  }
}
