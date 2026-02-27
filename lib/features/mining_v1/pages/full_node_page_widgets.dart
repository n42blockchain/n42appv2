part of 'full_node_page.dart';

/// Payment method UI widgets for [FullNodePage].
mixin _FullNodePageWidgets on State<FullNodePage> {
  _FullNodePageState get _state => this as _FullNodePageState;

  Widget _buildPayMethods() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPayMethodv2(
          "assets/mining/pay_wallet.png",
          "${S.current.g_mining_key_42}: ${_state.astBalance ?? 0} ${CoinType.N.name}",
          errTips: S.current.g_mining_key_43,
          isSelected: _state._payMethod == 0,
          onTap: () {
            setState(() {
              _state._payMethod = 0;
            });
          },
          isEnough:
              _state.astBalance != null && _state.astBalance! > widget.astNum,
        ),
      ],
    );
  }

  Widget _buildPayMethod(
    String icon,
    String payType, {
    bool isSelected = false,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(24),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: ScreenUtil().setWidth(68),
              fit: BoxFit.cover,
            ),
            SizedBox(width: ScreenUtil().setWidth(26)),
            Expanded(
              child: Text(
                payType,
                style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30)),
              ),
            ),
            _buildRadioDot(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildPayMethodv2(
    String icon,
    String payType, {
    bool isSelected = false,
    GestureTapCallback? onTap,
    String? errTips,
    bool isEnough = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(24),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: ScreenUtil().setWidth(44),
              fit: BoxFit.cover,
            ),
            SizedBox(width: ScreenUtil().setWidth(26)),
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
                        fontSize: ScreenUtil().setSp(30)),
                  ),
                  if (!isEnough)
                    Text(
                      errTips ?? '',
                      style: TextStyle(
                        color: const Color(0xffEB5851),
                        fontSize: ScreenUtil().setSp(20),
                      ),
                    ),
                ],
              ),
            ),
            _buildRadioDot(isSelected),
          ],
        ),
      ),
    );
  }

  /// Shared radio-style dot indicator used by both payment method builders.
  Widget _buildRadioDot(bool isSelected) {
    return Container(
      width: ScreenUtil().setWidth(36),
      height: ScreenUtil().setWidth(36),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xff32D74B) : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
          width: 1.0,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: ScreenUtil().setWidth(24),
              color: Colors.white,
            )
          : null,
    );
  }
}
