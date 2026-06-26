// ignore_for_file: invalid_use_of_protected_member

part of 'wallet_coin_add_all.dart';

/// Import-token form-field widgets for [_WalletCoinAddAllState].
///
/// Contains: addressWidget, symbolWidget, decimalWidget,
/// _buildContractStateWidget.
extension _WalletCoinAddAllImportFormUI on _WalletCoinAddAllState {
  // ── 主题色快捷取色 ──────────────────────────────────────────
  Color _formColor(String key) => AppThemeUtils.getColorByKey(context, key);

  // ── 通用组件 ────────────────────────────────────────────────

  /// 带标签、输入框和可选错误信息的表单行
  Widget _formField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String errorMessage,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onChanged,
    List<Widget> trailing = const [],
  }) {
    final su = ScreenUtil();
    final Color mainText = _formColor(AppThemeKeys.mainTextColor.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(color: mainText),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: su.setWidth(30.0),
            right: su.setWidth(10.0),
          ),
          margin: EdgeInsets.only(top: su.setWidth(20.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(su.setWidth(8.0))),
            color: _formColor(AppThemeKeys.itemBgColor.name),
          ),
          height: su.setWidth(88.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  style: AppTypography.headline.copyWith(
                    color: mainText,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: su.setWidth(10.0),
                    ),
                  ),
                  maxLines: 1,
                  onChanged: onChanged,
                  onEditingComplete: onEditingComplete,
                ),
              ),
              ...trailing,
            ],
          ),
        ),
        if (errorMessage.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              errorMessage,
              style: AppTypography.caption.copyWith(
                color: _formColor(AppThemeKeys.errorTextColor.name),
              ),
            ),
          ),
      ],
    );
  }

  // ── 公共 API ────────────────────────────────────────────────

  Widget addressWidget() {
    final su = ScreenUtil();
    final Color blueColor = _formColor(AppThemeKeys.mainBlueColor.name);

    return Container(
      margin: EdgeInsets.symmetric(vertical: su.setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formField(
            label: S.of(context).g_token_m_key_6,
            controller: tokenEditingController,
            focusNode: tokenFocusNode,
            hintText: S.of(context).g_key_155,
            errorMessage: tokenErrorMessage,
            onChanged: _onContractAddressChanged,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(symbolFocusNode);
              addressCheck(tokenEditingController.text);
              updateView();
            },
            trailing: [
              // 扫码按钮
              InkWell(
                onTap: scanQR,
                child: Container(
                  width: su.setWidth(60.0),
                  height: su.setWidth(60.0),
                  padding: EdgeInsets.all(su.setWidth(8.0)),
                  child: Image.asset(
                    "assets/wallet/scan.png",
                    color: blueColor,
                  ),
                ),
              ),
              // 粘贴按钮
              InkWell(
                onTap: () async {
                  final cd = await Clipboard.getData(Clipboard.kTextPlain);
                  if (!mounted) return;
                  final text = cd?.text;
                  if (text != null && text != "null") {
                    tokenEditingController.text = text;
                    addressCheck(text);
                    updateView();
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(left: su.setWidth(10.0)),
                  height: su.setWidth(60.0),
                  padding: EdgeInsets.symmetric(horizontal: su.setWidth(20.0)),
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(su.setWidth(60.0)),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).g_key_166,
                    style: AppTypography.bodySm.copyWith(
                      color: _formColor(AppThemeKeys.mainWhiteColor.name),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 合约校验状态提示
          _buildContractStateWidget(),
        ],
      ),
    );
  }

  Widget _buildContractStateWidget() {
    if (_contractState.isEmpty) return const SizedBox.shrink();

    final su = ScreenUtil();
    final double iconSize = su.setWidth(28);
    final double gap = su.setWidth(10);

    final content = switch (_contractState) {
      'loading' => Row(
        children: [
          SizedBox(
            width: su.setWidth(24),
            height: su.setWidth(24),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _formColor(AppThemeKeys.mainBlueColor.name),
            ),
          ),
          SizedBox(width: su.setWidth(12)),
          Text(
            'Looking up token info…',
            style: AppTypography.caption.copyWith(
              color: _formColor(AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
      'found' => Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColorTokens.of(context).success,
            size: iconSize,
          ),
          SizedBox(width: gap),
          Expanded(
            child: Text(
              'Token found: $_contractHint',
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).success,
              ),
            ),
          ),
        ],
      ),
      'notFound' => () {
        final orange = _formColor(AppThemeKeys.textColorOrange.name);
        return Row(
          children: [
            Icon(Icons.info_outline, color: orange, size: iconSize),
            SizedBox(width: gap),
            Expanded(
              child: Text(
                'Token not found in list — fill symbol & decimals manually',
                style: AppTypography.caption.copyWith(color: orange),
              ),
            ),
          ],
        );
      }(),
      _ => const SizedBox.shrink(),
    };

    return Padding(
      padding: EdgeInsets.only(top: su.setWidth(12)),
      child: content,
    );
  }

  Widget symbolWidget() {
    return _formField(
      label: S.of(context).g_token_m_key_7,
      controller: symbolEditingController,
      focusNode: symbolFocusNode,
      hintText: S.of(context).g_token_m_key_7,
      errorMessage: symbolErrorMessage,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(decimalFocusNode);
      },
    );
  }

  Widget decimalWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: _formField(
        label: S.of(context).g_token_m_key_8,
        controller: decimalEditingController,
        focusNode: decimalFocusNode,
        hintText: S.of(context).g_token_m_key_8,
        errorMessage: decimalErrorMessage,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(tokenFocusNode);
        },
      ),
    );
  }
}
