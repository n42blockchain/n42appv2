part of 'wallet_receive_qr.dart';

extension _WalletReceiveQrContent on _WalletReceiveQrState {
  Widget buildChainSelector(
      List<CoinModel> chains, Color blueColor, Color mainText) {
    // 过滤掉地址为空的链（通常代表还未初始化）
    final available = chains.where((c) => c.address.isNotEmpty).toList();
    if (available.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: ScreenUtil().setWidth(72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(40)),
        itemCount: available.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: ScreenUtil().setWidth(12)),
        itemBuilder: (_, i) {
          final cm = available[i];
          final ct = cm.coin['coinType'] as String? ?? '';
          final chipColor = _kChainColors[ct] ?? blueColor;
          final isSelected = ct == coinType;

          return GestureDetector(
            onTap: () => _switchChain(cm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? chipColor
                      : mainText.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1.0,
                ),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(36)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageNetWork(
                    imageUrl: cm.coin['icon'] ?? '',
                    width: ScreenUtil().setWidth(32),
                    height: ScreenUtil().setWidth(32),
                    placeholder: 'assets/img/list_default.png',
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    ct,
                    style: TextStyle(
                      color: isSelected ? chipColor : mainText,
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildQrCard({
    required Color bgColor,
    required Color mainText,
    required Color blueColor,
    required Color chainColor,
  }) {
    return RepaintBoundary(
      key: previewKey,
      child: Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(40),
          vertical: ScreenUtil().setWidth(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageNetWork(
                  imageUrl: logoUrl,
                  width: ScreenUtil().setWidth(60.0),
                  height: ScreenUtil().setWidth(60.0),
                  placeholder: 'assets/img/list_default.png',
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                Expanded(
                  child: Text(
                    network,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: mainText,
                      fontSize: ScreenUtil().setSp(38.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(28),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: chainColor.withValues(alpha: 0.12),
                border:
                    Border.all(color: chainColor, width: 1.2),
                borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(40)),
              ),
              child: Text(
                coinType,
                style: TextStyle(
                  color: chainColor,
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40)),

            Container(
              width: ScreenUtil().setWidth(360.0),
              height: ScreenUtil().setWidth(360.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.0,
                  color: const Color(0xFFE4E4E4),
                ),
                borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(30.0)),
              ),
              child: QrImageView(
                padding: EdgeInsets.all(
                    ScreenUtil().setWidth(20.0)),
                data: qrData,
                version: QrVersions.auto,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            EnsAddressDisplay(
              address: address,
              coinType: coinType,
              style: EnsDisplayStyle.detailed,
              showAvatar: true,
              showCopy: false,
              fontSize: ScreenUtil().setSp(26.0),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            Text(
              S.of(context).g_app_share_key_1,
              style: TextStyle(
                color: mainText.withValues(alpha: 0.55),
                fontSize: ScreenUtil().setSp(24.0),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),

            Text(
              S.of(context).g_app_share_key_2,
              style: TextStyle(
                color: blueColor,
                fontSize: ScreenUtil().setSp(28.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
          ],
        ),
      ),
    );
  }

  Widget buildInteractionArea({
    required Color mainText,
    required Color blueColor,
  }) {
    final btnRadius = BorderRadius.circular(ScreenUtil().setWidth(16));
    final btnPadding =
        EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(28));
    final btnTextStyle = TextStyle(
      fontSize: ScreenUtil().setSp(32),
      fontWeight: FontWeight.w600,
    );
    final iconSize = ScreenUtil().setWidth(36);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(60),
        vertical: ScreenUtil().setWidth(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: copyAddress,
            icon: Icon(Icons.copy_outlined, size: iconSize),
            label: Text(S.of(context).g_key_119),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              padding: btnPadding,
              shape: RoundedRectangleBorder(borderRadius: btnRadius),
              textStyle: btnTextStyle,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),

          OutlinedButton.icon(
            onPressed: shareLink,
            icon: Icon(Icons.link_rounded, size: iconSize),
            label: Text(S.of(context).g_key_share_link),
            style: OutlinedButton.styleFrom(
              foregroundColor: blueColor,
              side: BorderSide(color: blueColor, width: 1.2),
              padding: btnPadding,
              shape: RoundedRectangleBorder(borderRadius: btnRadius),
              textStyle: btnTextStyle,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(36)),

          Text(
            '${S.of(context).g_key_44} ($symbol)',
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          _buildAmountField(mainText: mainText, blueColor: blueColor),
        ],
      ),
    );
  }

  Widget _buildAmountField({
    required Color mainText,
    required Color blueColor,
  }) {
    final radius = BorderRadius.circular(ScreenUtil().setWidth(16));
    const defaultSide = BorderSide(color: Color(0xFFE4E4E4));
    final fontSize = ScreenUtil().setSp(28);

    return TextField(
      controller: amountCtrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(_amountInputRegex),
      ],
      style: TextStyle(color: mainText, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: '0.0',
        hintStyle: TextStyle(
          color: mainText.withValues(alpha: 0.35),
          fontSize: fontSize,
        ),
        suffixIcon: amountCtrl.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  size: ScreenUtil().setWidth(36),
                  color: mainText.withValues(alpha: 0.5),
                ),
                onPressed: amountCtrl.clear,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(28),
          vertical: ScreenUtil().setWidth(22),
        ),
        border: OutlineInputBorder(
            borderRadius: radius, borderSide: defaultSide),
        enabledBorder: OutlineInputBorder(
            borderRadius: radius, borderSide: defaultSide),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: blueColor, width: 1.5),
        ),
      ),
    );
  }
}
