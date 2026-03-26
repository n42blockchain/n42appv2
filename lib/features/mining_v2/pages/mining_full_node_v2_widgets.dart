part of 'mining_full_node_v2.dart';

/// Widget builder mixin for MiningFullNodeV2.
/// Provides extracted widget builder methods used in the build tree.
mixin _MiningFullNodeV2WidgetsMixin on ConsumerState<MiningFullNodeV2>, _MiningFullNodeV2LogicMixin {

  /// 区块标题（带左侧蓝色竖条）
  Widget buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(6),
          height: ScreenUtil().setWidth(28),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            borderRadius:
                BorderRadius.circular(ScreenUtil().setWidth(3)),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Text(
          title,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 支付方式选项（单选样式）
  Widget buildPayMethod(String icon, String payType,
      {bool isSelected = false, GestureTapCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final idleBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected ? blueColor : idleBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(60),
              height: ScreenUtil().setWidth(60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9A9E).withValues(alpha: 0.3),
                    const Color(0xFFFECFEF).withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: ScreenUtil().setWidth(36),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            Expanded(
              child: Text(
                payType,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildRadioCircle(isSelected),
          ],
        ),
      ),
    );
  }

  /// 提示信息卡片
  Widget buildInfoTip(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(16),
      ),
      decoration: BoxDecoration(
        color: blueColor.withValues(alpha: 0.06),
        borderRadius:
            BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: blueColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: ScreenUtil().setWidth(32),
            color: blueColor,
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              S.of(context).g_mining_key46,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 支付方式列表（含余额展示）
  Widget buildPayMethods() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnough = nBalance != null && nBalance! > widget.nNum;

    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius:
            BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPayMethodv2(
            "assets/mining/pay_wallet.png",
            "${S.current.g_mining_key_42}: ${nBalance ?? 0} ${CoinType.N.name}",
            errTips: S.current.g_mining_key_43,
            isSelected: _payMethod == 0,
            onTap: () {
              setState(() {
                _payMethod = 0;
              });
            },
            isEnough: isEnough,
          ),
        ],
      ),
    );
  }

  /// 支付方式选项 v2（含余额不足警告）
  Widget _buildPayMethodv2(String icon, String payType,
      {bool isSelected = false,
      GestureTapCallback? onTap,
      String? errTips,
      bool isEnough = true}) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              decoration: BoxDecoration(
                color: blueColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: ScreenUtil().setWidth(28),
                  fit: BoxFit.contain,
                  color: blueColor,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    payType,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isEnough)
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(6)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: ScreenUtil().setWidth(20),
                            color: const Color(0xFFEB5851),
                          ),
                          SizedBox(
                              width: ScreenUtil().setWidth(6)),
                          Flexible(
                            child: Text(
                              errTips ?? '',
                              style: TextStyle(
                                color: const Color(0xFFEB5851),
                                fontSize: ScreenUtil().setSp(22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _buildRadioCircle(isSelected),
          ],
        ),
      ),
    );
  }

  /// 私钥保存卡片
  Widget buildPrivateKeyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          EdgeInsets.only(top: ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                EdgeInsets.all(ScreenUtil().setWidth(24)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: ScreenUtil().setWidth(44),
                  height: ScreenUtil().setWidth(44),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(
                    Icons.vpn_key_outlined,
                    color: Colors.white,
                    size: ScreenUtil().setWidth(24),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                Expanded(
                  child: Text(
                    S.of(context).g_mining_key_78,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                _buildCheckCircle(),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(24),
              0,
              ScreenUtil().setWidth(24),
              ScreenUtil().setWidth(24),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MiningOutputTip()),
                );
                if (result != null && mounted) {
                  setState(() {
                    savePrivateKey = true;
                    encrypteData = result;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B35),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      ScreenUtil().setWidth(12)),
                ),
              ),
              child: Text(
                S.of(context).g_mining_key_79,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部确认按钮
  Widget buildBottomButton(BuildContext context, Load depositLoad) {
    final isLoading = depositLoad == Load.loading;
    final bgColorKey = isLoading
        ? AppThemeKeys.mainButtonBgColor3.name
        : AppThemeKeys.mainButtonBgColor.name;
    final textColorKey = isLoading
        ? AppThemeKeys.mainButtonTextColor3.name
        : AppThemeKeys.mainButtonTextColor.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          Container(
            width: double.infinity,
            height: ScreenUtil().setWidth(148),
            padding:
                EdgeInsets.all(ScreenUtil().setWidth(30)),
            child: buttonStyle6(
              context,
              () async {
                if (isLoading) return;
                if (_payType != 0 || _payMethod != 0) return;

                if (nBalance == null || nBalance! < widget.nNum) {
                  await checkNBalance();
                }
                if (!mounted) return;
                if (nBalance == null || nBalance! < widget.nNum) return;

                showGroupConfirmDialog(
                    this.context, widget.nNum, '640s',
                    () async {
                  await handlerData();
                });
              },
              S.of(context).g_key_78,
              AppThemeUtils.getColorByKey(context, bgColorKey),
              AppThemeUtils.getColorByKey(context, textColorKey),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }

  /// 通用勾选圆圈指示器
  Widget _buildSelectionCircle({
    required bool isSelected,
    required Color fillColor,
    required Color borderColor,
    required Color checkColor,
  }) {
    return Container(
      width: ScreenUtil().setWidth(36),
      height: ScreenUtil().setWidth(36),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? fillColor : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.transparent : borderColor,
          width: 2.0,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, size: ScreenUtil().setWidth(22), color: checkColor)
          : null,
    );
  }

  /// 通用单选圆圈指示器
  Widget _buildRadioCircle(bool isSelected) {
    return _buildSelectionCircle(
      isSelected: isSelected,
      fillColor: const Color(0xff32D74B),
      borderColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemSubtitleTextColor.name),
      checkColor: Colors.white,
    );
  }

  /// 私钥保存勾选圆圈
  Widget _buildCheckCircle() {
    return _buildSelectionCircle(
      isSelected: savePrivateKey,
      fillColor: Colors.white,
      borderColor: Colors.white,
      checkColor: const Color(0xFFFF6B35),
    );
  }
}
