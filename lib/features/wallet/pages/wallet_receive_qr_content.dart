part of 'wallet_receive_qr.dart';

extension _WalletReceiveQrContent on _WalletReceiveQrState {
  Widget buildChainSelector(
    List<CoinModel> chains,
    Color blueColor,
    Color mainText,
  ) {
    // 过滤掉地址为空的链（通常代表还未初始化）
    final available = chains.where((c) => c.address.isNotEmpty).toList();
    if (available.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: ScreenUtil().setWidth(72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space12),
        itemCount: available.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: AppSpacing.space6),
        itemBuilder: (_, i) {
          final cm = available[i];
          final ct = cm.coin['coinType'] as String? ?? '';
          final chipColor = _kChainColors[ct] ?? blueColor;
          final isSelected = ct == coinType;

          return InkWell(
            onTap: () => _switchChain(cm),
            borderRadius: AppRadius.brPill,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
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
                borderRadius: AppRadius.brPill,
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
                  SizedBox(width: AppSpacing.space2),
                  Text(
                    ct,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? chipColor : mainText,
                      fontWeight: isSelected
                          ? FontWeight.w600
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
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space6,
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
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: Text(
                    network,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTypography.title.copyWith(color: mainText),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space4),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: chainColor.withValues(alpha: 0.12),
                border: Border.all(color: chainColor, width: 1.2),
                borderRadius: AppRadius.brPill,
              ),
              child: Text(
                coinType,
                style: AppTypography.caption.copyWith(
                  color: chainColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space12),

            Container(
              width: ScreenUtil().setWidth(360.0),
              height: ScreenUtil().setWidth(360.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.0,
                  color: AppColorTokens.of(context).border,
                ),
                borderRadius: AppRadius.brXl,
              ),
              child: QrImageView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                data: qrData,
                version: QrVersions.auto,
              ),
            ),
            SizedBox(height: AppSpacing.space6),

            EnsAddressDisplay(
              address: address,
              coinType: coinType,
              style: EnsDisplayStyle.detailed,
              showAvatar: true,
              showCopy: false,
              fontSize: ScreenUtil().setSp(26.0),
            ),
            SizedBox(height: AppSpacing.space6),

            Text(
              S.of(context).g_app_share_key_1,
              style: AppTypography.caption.copyWith(
                color: mainText.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space6),

            Text(
              S.of(context).g_app_share_key_2,
              style: AppTypography.bodyStrong.copyWith(color: blueColor),
            ),
            SizedBox(height: AppSpacing.space2),
          ],
        ),
      ),
    );
  }

  Widget buildInteractionArea({
    required Color mainText,
    required Color blueColor,
  }) {
    final btnRadius = AppRadius.brMd;
    final btnPadding = EdgeInsets.symmetric(vertical: AppSpacing.space8);
    final btnTextStyle = AppTypography.headline;
    final iconSize = ScreenUtil().setWidth(36);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space6,
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
          SizedBox(height: AppSpacing.space6),

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
          SizedBox(height: AppSpacing.space8),

          Text(
            '${S.of(context).g_key_44} ($symbol)',
            style: AppTypography.body.copyWith(
              color: mainText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.space4),

          _buildAmountField(mainText: mainText, blueColor: blueColor),
        ],
      ),
    );
  }

  Widget _buildAmountField({
    required Color mainText,
    required Color blueColor,
  }) {
    final radius = AppRadius.brMd;
    final defaultSide = BorderSide(color: AppColorTokens.of(context).border);
    final textStyle = AppTypography.body.copyWith(color: mainText);

    return TextField(
      controller: amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(_amountInputRegex)],
      style: textStyle,
      decoration: InputDecoration(
        hintText: '0.0',
        hintStyle: textStyle.copyWith(color: mainText.withValues(alpha: 0.35)),
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
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space6,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: defaultSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: defaultSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: blueColor, width: 1.5),
        ),
      ),
    );
  }
}
