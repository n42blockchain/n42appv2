part of 'create_finish.dart';

mixin _CreateFinishContentMixin on ConsumerState<CreateFinish> {

  // 以下字段由 _CreateFinishState 声明，mixin 通过 abstract getter 访问
  Load get load;
  bool get exportKeystore;
  set exportKeystore(bool value);
  String get pageName;

  bool get _isImport =>
      widget.createMetod == "Import" || widget.createMetod == "PrivateKey";

  Color _themeColor(String key) =>
      AppThemeUtils.getColorByKey(context, key);
  Widget _titleText(String text, {TextAlign? textAlign}) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(56.0),
          color: _themeColor(AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
      ),
    );
  }

  Widget _subtitleText(String text, {String? colorKey, TextAlign? textAlign}) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(32.0),
          color: _themeColor(colorKey ?? AppThemeKeys.mainTextColor6.name),
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }

  Widget _bottomLinkButton(String label, VoidCallback onTap) {
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor.name);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(60.0)),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28.0),
            color: blueColor,
            decoration: TextDecoration.underline,
            decorationColor: blueColor,
          ),
        ),
      ),
    );
  }

  Widget _bottomButtonBar({
    required String buttonLabel,
    required VoidCallback onPressed,
    Widget? linkButton,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Visibility(
        visible: load == Load.finish,
        child: Column(
          children: [
            Divider(height: 1, indent: 0, endIndent: 0),
            Container(
              height: ScreenUtil().setWidth(148.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
              width: double.infinity,
              color: _themeColor(AppThemeKeys.backGroundColor.name),
              child: AppButton(label: buttonLabel, onPressed: onPressed),
            ),
            ?linkButton,
          ],
        ),
      ),
    );
  }

  Widget _centeredImage(String asset, double size) {
    final w = ScreenUtil().setWidth(size);
    return Container(
      height: w,
      width: w,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50.0)),
      child: Image.asset(
        asset,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (load == Load.finish) return SizedBox();

    final dotCount = _isImport ? 2 : 4;
    final dotWidth = _isImport ? 144.0 : 88.0;
    final gap = SizedBox(width: ScreenUtil().setWidth(20.0));

    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          dotCount * 2 - 1,
          (i) => i.isEven ? _progressDot(width: dotWidth) : gap,
        ),
      ),
    );
  }

  Widget _progressDot({required double width}) {
    return Container(
      height: ScreenUtil().setWidth(10.0),
      width: ScreenUtil().setWidth(width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10.0)),
        color: _themeColor(AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _visibleLayer(bool visible, Widget child) {
    return Positioned.fill(child: Visibility(visible: visible, child: child));
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        _visibleLayer(
          load == Load.loading,
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                alignment: Alignment.center,
                child: Text(
                  _isImport
                      ? S.of(context).g_key_wallet_c13
                      : S.of(context).g_key_wallet_c14,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(40.0),
                    color: _themeColor(AppThemeKeys.mainTextColor.name),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: _buildLoadingSpinner()),
            ],
          ),
        ),
        if (_isImport)
          _visibleLayer(
            load == Load.finish,
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImportFinishImage(),
                _titleText(S.of(context).g_key_wallet_c15),
                _subtitleText(S.of(context).g_key_wallet_c16),
                Spacer(),
              ],
            ),
          ),
        if (widget.createMetod == "Create")
          _visibleLayer(
            load == Load.finish,
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _centeredImage("assets/home/create_successful.png", 320.0),
                _titleText(S.of(context).g_key_wallet_c22),
                _subtitleText(S.of(context).g_key_wallet_c23),
                SizedBox(height: ScreenUtil().setWidth(248)),
              ],
            ),
          ),
        _bottomButtonBar(
          buttonLabel: S.of(context).g_key_wallet_c17,
          onPressed: () => Navigator.popUntil(
            context,
            ModalRoute.withName(pageName),
          ),
          linkButton: widget.createMetod == "Create"
              ? _bottomLinkButton(
                  S.of(context).g_key_wallet_c24,
                  () => setState(() => exportKeystore = true),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildLoadingSpinner() {
    final spinnerSize = ScreenUtil().setWidth(100.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: ScreenUtil().setWidth(160.0),
          width: ScreenUtil().setWidth(160.0),
          padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
          decoration: BoxDecoration(
            color: _themeColor(AppThemeKeys.mainButtonBgColor3.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(80.0)),
          ),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Positioned.fill(
                child: SizedBox(
                  height: spinnerSize,
                  width: spinnerSize,
                  child: CircularProgressIndicator(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  height: spinnerSize,
                  width: spinnerSize,
                  alignment: Alignment.center,
                  child: Container(
                    height: ScreenUtil().setWidth(48.0),
                    width: ScreenUtil().setWidth(48.0),
                    decoration: BoxDecoration(
                      color: _themeColor(AppThemeKeys.backGroundColor.name),
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(24.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/home/money.png",
                      width: ScreenUtil().setWidth(28.0),
                      height: ScreenUtil().setWidth(28.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportFinishImage() {
    return SizedBox(
      height: ScreenUtil().setWidth(560.0),
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/wallet/create_finish.gif",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: ScreenUtil().setWidth(50.0),
            child: Container(
              height: ScreenUtil().setWidth(200.0),
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/ast_big.png",
                height: ScreenUtil().setWidth(200.0),
                width: ScreenUtil().setWidth(200.0),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportKeystoreContent() {
    final hintStyle = TextStyle(
      fontSize: ScreenUtil().setSp(32.0),
      color: _themeColor(AppThemeKeys.mainTextColor7.name),
      fontWeight: FontWeight.bold,
    );
    final s = S.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _centeredImage("assets/wallet/illustration.png", 320.0),
              _titleText(s.g_key_wallet_c25, textAlign: TextAlign.center),
              _subtitleText(s.g_key_wallet_c26),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0),
                  vertical: ScreenUtil().setWidth(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [s.g_key_wallet_c27, s.g_key_wallet_c28, s.g_key_wallet_c29]
                      .map((text) => Text(
                            text,
                            style: hintStyle,
                            textAlign: TextAlign.center,
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(248)),
            ],
          ),
        ),
        _bottomButtonBar(
          buttonLabel: s.g_key_wallet_c30,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WalletList()),
            );
            if (!mounted) return;
            Navigator.popUntil(context, ModalRoute.withName(pageName));
          },
          linkButton: _bottomLinkButton(
            s.g_key_wallet_c31,
            () => Navigator.popUntil(context, ModalRoute.withName(pageName)),
          ),
        ),
      ],
    );
  }
}
