part of 'one_coin_wallet_manage.dart';

mixin _OneCoinWalletManageWidgetsMixin on ConsumerState<OneCoinWalletManage> {
  String? get mnemonic;
  String? get coinPath;
  set coinPath(String? value);
  String? get addrType;
  set addrType(String? value);
  String? get pk;
  int get pathIndex;
  List<dynamic> get pathList;
  Load get load;
  set load(Load value);
  void addPath();
  void removePath(int index);
  void chagePath(int index);
  Future<void> jumpExportKeystoreDescPage({String? password});
  void showChangeAddress();

  // ── Theme helpers ──────────────────────────────────────────────────────────

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  BoxDecoration get _sectionDecoration => BoxDecoration(
    color: _color(AppThemeKeys.itemBgColor),
    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
  );

  EdgeInsets get _sectionPadding => EdgeInsets.symmetric(
    vertical: ScreenUtil().setWidth(30.0),
    horizontal: ScreenUtil().setWidth(30.0),
  );

  EdgeInsets get _sectionMargin => EdgeInsets.symmetric(
    horizontal: ScreenUtil().setWidth(30.0),
    vertical: ScreenUtil().setWidth(20.0),
  );

  bool get _hasMnemonic => widget.walletInfo.privateKey == null;

  // ── Wallet info section ────────────────────────────────────────────────────

  Widget _buildWalletInfo() {
    final isBtc =
        widget.model.coin['blockchainType'] == BlockchainType.Bitcoin.name;
    final pathCount = isBtc
        ? (widget.model.coin['path'] as Map<String, dynamic>).length
        : 1;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: _sectionDecoration,
      padding: _sectionPadding,
      margin: _sectionMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoinNameRow(),
          Divider(height: ScreenUtil().setWidth(48.0)),
          _buildAddressLabelRow(pathCount),
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          EnsAddressDisplay(
            address: widget.model.address ?? "",
            coinType: widget.model.coin['coinType'] ?? 'ETH',
            style: EnsDisplayStyle.compact,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28.0),
          ),
          if (_hasMnemonic) ...[
            Divider(height: ScreenUtil().setWidth(48.0)),
            _buildPathRow(),
            _buildPathList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCoinNameRow() {
    return Row(
      children: [
        Text(
          widget.model.coin['name'] ?? '',
          style: TextStyle(
            color: _color(AppThemeKeys.mainTextColor),
            fontSize: ScreenUtil().setSp(36.0),
          ),
        ),
        Text(
          " (${widget.model.coin['miniName'] ?? ''})",
          style: TextStyle(
            color: _color(AppThemeKeys.itemSubtitleTextColor),
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressLabelRow(int pathCount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${S.of(context).g_key_address}: ",
            style: TextStyle(
              color: _color(AppThemeKeys.mainTextColor),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
        ),
        if (pathCount > 1)
          InkWell(
            onTap: showChangeAddress,
            child: Container(
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
              child: Row(
                children: [
                  Text(
                    widget.model.addrType,
                    style: TextStyle(
                      color: _color(AppThemeKeys.mainBlueColor),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: ScreenUtil().setWidth(40.0),
                    color: _color(AppThemeKeys.mainBlueColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPathRow() {
    final coinInfo = widget.walletInfo.coinInfo![widget.model.coin['coinType']];
    final displayPath = coinPath == null
        ? ""
        : getPathWithIndex(coinPath!, coinInfo['pathIndex'] ?? 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${S.of(context).g_key_wallet_k53}:",
          style: TextStyle(
            color: _color(AppThemeKeys.mainTextColor),
            fontSize: ScreenUtil().setSp(32.0),
          ),
        ),
        Expanded(
          child: Text(
            "($displayPath)",
            style: TextStyle(
              color: _color(AppThemeKeys.mainTextColor),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
        ),
        InkWell(
          onTap: addPath,
          child: Container(
            height: ScreenUtil().setWidth(50.0),
            width: ScreenUtil().setWidth(50.0),
            padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
            child: Icon(
              Icons.add_circle_outline,
              color: _color(AppThemeKeys.mainBlueColor),
              size: ScreenUtil().setWidth(40.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathList() {
    final visibleCount = pathList.length > 4 ? 4 : pathList.length;
    return SizedBox(
      height: ScreenUtil().setWidth(101.0 * visibleCount),
      child: ListView.separated(
        itemCount: pathList.length,
        separatorBuilder: (_, _) => Divider(height: ScreenUtil().setWidth(1.0)),
        itemBuilder: (context, int index) {
          final pIndex = pathList[index] as int;
          final path = getPathWithIndex(
            widget.model.coin['path'][widget.model.addrType],
            pIndex,
          );
          return _buildPathItem(index, pIndex, path);
        },
      ),
    );
  }

  Widget _buildPathItem(int index, int pIndex, String path) {
    final isSelected = pIndex == pathIndex;
    final su = ScreenUtil();
    return Container(
      alignment: Alignment.centerLeft,
      height: su.setWidth(100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: isSelected ? null : () => chagePath(index),
            child: Container(
              margin: EdgeInsets.only(right: su.setWidth(10.0)),
              height: su.setWidth(50.0),
              width: su.setWidth(50.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _color(AppThemeKeys.dividerColor),
                  width: su.setWidth(1.0),
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _color(AppThemeKeys.mainTextColor),
                      size: su.setWidth(40.0),
                    )
                  : null,
            ),
          ),
          Expanded(
            child: Text(
              path,
              style: TextStyle(
                color: _color(AppThemeKeys.itemSubtitleTextColor),
                fontSize: su.setSp(28.0),
              ),
            ),
          ),
          if (pIndex != 0 && !isSelected)
            InkWell(
              onTap: () => removePath(index),
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.remove,
                  color: _color(AppThemeKeys.mainTextColor),
                  size: su.setWidth(40.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Export section ──────────────────────────────────────────────────────────

  Widget _buildExport() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: _sectionDecoration,
      padding: _sectionPadding,
      margin: _sectionMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_181,
            style: TextStyle(
              color: _color(AppThemeKeys.mainTextColor),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
          Divider(height: ScreenUtil().setWidth(48.0)),
          _buildExportKeystoreRow(),
          Divider(height: ScreenUtil().setWidth(48.0)),
          if (widget.walletInfo.password != "") _buildExportPrivateKeyRow(),
        ],
      ),
    );
  }

  Widget _buildExportKeystoreRow() {
    return InkWell(
      onTap: _onExportKeystoreTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (load == Load.loading)
              SizedBox(
                height: ScreenUtil().setWidth(40),
                width: ScreenUtil().setWidth(40),
                child: CircularProgressIndicator(),
              ),
            Text(
              S.of(context).g_key_ex_keystore,
              style: TextStyle(
                color: _color(AppThemeKeys.mainTextColor),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(40.0),
              color: _color(AppThemeKeys.itemSubtitleTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onExportKeystoreTap() async {
    try {
      if (load == Load.loading) return;
      if (mounted) {
        setState(() => load = Load.loading);
      }
      if (widget.walletInfo.password == "") {
        await _exportKeystoreWithNewPassword();
      } else {
        await _exportKeystoreWithExistingPassword();
      }
    } finally {
      if (mounted) {
        setState(() => load = Load.finish);
      }
    }
  }

  Future<void> _exportKeystoreWithNewPassword() async {
    final controller = TextEditingController();
    final controller2 = TextEditingController();
    try {
      final flag = await tipsDialog3(
        context,
        _buildNewPasswordDialog(controller, controller2),
      );
      if (!mounted) return;
      if (flag != true) return;

      final password = controller.text.trim();
      final password2 = controller2.text.trim();
      if (password.isEmpty) {
        ToastUtils.show(S.of(context).g_key_21);
        return;
      }
      if (!Regular().isPassword(password)) {
        ToastUtils.show(S.of(context).rest_Choose_password);
        return;
      }
      if (password2.isEmpty) {
        ToastUtils.show(S.of(context).g_key_21);
        return;
      }
      if (password != password2) {
        ToastUtils.show(S.of(context).g_key_25);
        return;
      }
      await jumpExportKeystoreDescPage(password: password);
    } finally {
      controller.dispose();
      controller2.dispose();
    }
  }

  Future<void> _exportKeystoreWithExistingPassword() async {
    final controller = TextEditingController();
    try {
      final flag = await tipsDialog4(
        context,
        S.of(context).g_key_ex_keystore_pwd_title,
        controller: controller,
      );
      if (!mounted) return;
      if (flag != true) return;
      final password = controller.text.trim();
      if (password != widget.walletInfo.password) {
        ToastUtils.show(S.of(context).g_key_146);
        return;
      }
      await jumpExportKeystoreDescPage();
    } finally {
      controller.dispose();
    }
  }

  Widget _buildNewPasswordDialog(
    TextEditingController controller,
    TextEditingController controller2,
  ) {
    final su = ScreenUtil();
    final itemBg = _color(AppThemeKeys.itemBgColor);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(su.setWidth(16.0)),
        color: itemBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(su.setWidth(30)),
            alignment: Alignment.center,
            width: double.infinity,
            child: Text(
              S.of(context).g_key_21,
              style: TextStyle(
                color: _color(AppThemeKeys.mainTextColor),
                fontSize: su.setSp(30.0),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildPasswordField(controller, S.of(context).rest_Choose_password),
          Container(
            margin: EdgeInsets.only(
              top: su.setWidth(20.0),
              bottom: su.setWidth(30.0),
            ),
            child: _buildPasswordField(
              controller2,
              S.of(context).repeatPassword,
            ),
          ),
          Divider(height: su.setWidth(1)),
          SizedBox(
            height: su.setWidth(80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDialogButton(
                  S.of(context).g_key_79,
                  _color(AppThemeKeys.mainTextColor),
                  () => Navigator.of(context).pop(false),
                ),
                Container(
                  color: _color(AppThemeKeys.dividerColor),
                  width: su.setWidth(1),
                ),
                _buildDialogButton(
                  S.of(context).g_key_78,
                  _color(AppThemeKeys.mainBlueColor),
                  () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String hint) {
    final su = ScreenUtil();
    return Container(
      height: su.setWidth(80.0),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      decoration: BoxDecoration(color: _color(AppThemeKeys.itemBgColor)),
      child: CommInput(
        type: InputFieldType.password,
        hintText: hint,
        controller: ctrl,
        maxLines: 1,
      ),
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: ScreenUtil().setSp(30)),
          ),
        ),
      ),
    );
  }

  Widget _buildExportPrivateKeyRow() {
    return InkWell(
      onTap: _onExportPrivateKeyTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_ex_keystore_19,
              style: TextStyle(
                color: _color(AppThemeKeys.mainTextColor),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onExportPrivateKeyTap() async {
    final controller = TextEditingController();
    try {
      final flag = await tipsDialog4(
        context,
        S.of(context).g_key_ex_pk_pwd_title,
        controller: controller,
      );
      if (!mounted) return;
      if (flag != true) return;
      final entered = controller.text.trim();
      if (entered != widget.walletInfo.password) {
        ToastUtils.show(S.of(context).g_key_146);
        return;
      }
    } finally {
      controller.dispose();
    }
    final pk = await Trustdart().getPrivateKey(
      mnemonic ?? "",
      widget.model.coin['coinType'],
      coinPath ?? "",
    );
    if (!mounted) return;
    try {
      final pkHex = decodeExportablePrivateKey(pk);
      await Clipboard.setData(ClipboardData(text: pkHex));
      if (!mounted) return;
      ToastUtils.show(S.of(context).copy);
    } catch (_) {
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_210);
    }
  }
}
