part of 'aa_account_create_page.dart';

/// Form state and UI widgets mixin for [_AAAccountCreatePageState].
///
/// Holds all mutable form state fields and builds the individual
/// form sections: label input, chain selector, type selector,
/// preview address, info banner, and create button.
///
/// Requires [_AAAccountCreateHelpersMixin] to be applied first so that
/// helper functions (_getTypeColor, _getTypeIcon, _getTypeDescription)
/// are accessible within widget builders.
mixin _AAAccountCreateFormMixin on _AAAccountCreateHelpersMixin {
  final TextEditingController labelController = TextEditingController();

  SmartAccountType selectedType = SmartAccountType.simpleAccount;
  String selectedChain = 'ETH';
  String? previewAddress;
  bool isCalculating = false;
  bool isCreating = false;
  String? addressError;

  // ── Theme helpers ──────────────────────────────────────────────────────────

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  // ── Section builders ───────────────────────────────────────────────────────

  /// Shared section title style used by label, chain, and type selectors.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodySm.copyWith(
        fontWeight: FontWeight.w600,
        color: _themeColor(AppThemeKeys.mainTextColor),
      ),
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).g_key_aa_account_name),
        SizedBox(height: 12.w),
        TextField(
          controller: labelController,
          decoration: InputDecoration(
            hintText: S.of(context).g_key_aa_account_name_hint,
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(borderRadius: AppRadius.brMd),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: 14.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChainSelector() {
    final chains = AAConfig.supportedChains.toList();
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor);
    final itemBg = _themeColor(AppThemeKeys.itemBgColor);
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final textColor = _themeColor(AppThemeKeys.mainTextColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).g_key_aa_select_chain),
        SizedBox(height: 12.w),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: chains.map((chain) {
            final isSelected = selectedChain == chain;
            return GestureDetector(
              onTap: () =>
                  (this as _AAAccountCreatePageState)._onChainChanged(chain),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
                decoration: BoxDecoration(
                  color: isSelected ? blueColor : itemBg,
                  borderRadius: AppRadius.brMd,
                  border: Border.all(
                    color: isSelected ? blueColor : subtitleColor.withAlpha(30),
                  ),
                ),
                child: Text(
                  chain,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    const types = [
      SmartAccountType.simpleAccount,
      SmartAccountType.simple7702Account,
      SmartAccountType.safe,
      SmartAccountType.biconomy,
      SmartAccountType.kernel,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).g_key_aa_account_type),
        SizedBox(height: 12.w),
        ...types.map((type) => _buildTypeOption(type)),
      ],
    );
  }

  Widget _buildTypeOption(SmartAccountType type) {
    final isSelected = selectedType == type;
    final isAvailable =
        type == SmartAccountType.simpleAccount ||
        type == SmartAccountType.simple7702Account ||
        type == SmartAccountType.safe ||
        type == SmartAccountType.biconomy;
    final typeColor = _getTypeColor(type);
    final itemBg = _themeColor(AppThemeKeys.itemBgColor);
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final textColor = _themeColor(AppThemeKeys.mainTextColor);

    return GestureDetector(
      onTap: isAvailable
          ? () => (this as _AAAccountCreatePageState)._onTypeChanged(type)
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.w),
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: isSelected ? typeColor.withAlpha(15) : itemBg,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isSelected ? typeColor : subtitleColor.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(25),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(_getTypeIcon(type), size: 24.w, color: typeColor),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: AppSpacing.space2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.space2,
                              vertical: 2.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorTokens.of(
                                context,
                              ).textTertiary.withAlpha(30),
                              borderRadius: AppRadius.brSm,
                            ),
                            child: Text(
                              S.of(context).g_key_aa_coming_soon,
                              style: AppTypography.captionSm.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColorTokens.of(context).textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.w),
                    Text(
                      _getTypeDescription(type),
                      style: AppTypography.caption.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 28.w, color: typeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: blueColor.withAlpha(15),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: blueColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_preview_address,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: _themeColor(AppThemeKeys.mainTextColor),
            ),
          ),
          SizedBox(height: 12.w),
          _buildPreviewAddressContent(),
          SizedBox(height: AppSpacing.space2),
          Text(
            S.of(context).g_key_aa_counterfactual_note,
            style: AppTypography.captionSm.copyWith(
              fontWeight: FontWeight.w400,
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAddressContent() {
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor);
    final blueColor = _themeColor(AppThemeKeys.mainBlueColor);

    if (isCalculating) {
      return Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              S.of(context).g_key_aa_address_calculating,
              style: AppTypography.caption.copyWith(color: subtitleColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (addressError != null) {
      return Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: AppColorTokens.of(context).danger,
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              addressError!,
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).danger,
              ),
            ),
          ),
          TextButton(
            onPressed:
                (this as _AAAccountCreatePageState)._calculatePreviewAddress,
            child: Text(S.of(context).g_key_aa_retry),
          ),
        ],
      );
    }

    if (previewAddress != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              previewAddress!,
              style: AppTypography.caption.copyWith(
                fontFamily: 'monospace',
                color: blueColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: previewAddress!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).g_key_119),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(Icons.copy, size: 22.w, color: blueColor),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoSection() {
    final warning = AppColorTokens.of(context).warning;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: warning.withAlpha(20),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: warning.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 22.w, color: warning),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              S.of(context).g_key_aa_deployment_note,
              style: AppTypography.caption.copyWith(color: warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final canCreate = previewAddress != null && !isCalculating;
    return ElevatedButton(
      onPressed: (isCreating || !canCreate)
          ? null
          : (this as _AAAccountCreatePageState)._createAccount,
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeColor(AppThemeKeys.mainBlueColor),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18.w),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        disabledBackgroundColor: AppColorTokens.of(context).textTertiary,
      ),
      child: isCreating
          ? SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              S.of(context).g_key_aa_create_account,
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
