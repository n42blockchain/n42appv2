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

  // ── Section builders ───────────────────────────────────────────────────────

  /// Shared section title style used by label, chain, and type selectors.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(26),
        fontWeight: FontWeight.w600,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainTextColor.name,
        ),
      ),
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).g_key_aa_account_name),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextField(
          controller: labelController,
          decoration: InputDecoration(
            hintText: S.of(context).g_key_aa_account_name_hint,
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(16),
              vertical: ScreenUtil().setWidth(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChainSelector() {
    final chains = AAConfig.supportedChains.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bug 2 fix: was g_key_17 (wrong key), now g_key_aa_select_chain
        _buildSectionTitle(S.of(context).g_key_aa_select_chain),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Wrap(
          spacing: ScreenUtil().setWidth(12),
          runSpacing: ScreenUtil().setWidth(12),
          children: chains.map((chain) {
            final isSelected = selectedChain == chain;
            return GestureDetector(
              onTap: () =>
                  (this as _AAAccountCreatePageState)._onChainChanged(chain),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                  vertical: ScreenUtil().setWidth(12),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        )
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemBgColor.name,
                        ),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(12)),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          )
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ).withAlpha(30),
                  ),
                ),
                child: Text(
                  chain,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
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
    // Bug 3 fix: added biconomy to the type list
    final types = [
      SmartAccountType.simpleAccount,
      SmartAccountType.safe,
      SmartAccountType.biconomy,
      SmartAccountType.kernel,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(S.of(context).g_key_aa_account_type),
        SizedBox(height: ScreenUtil().setWidth(12)),
        ...types.map((type) => _buildTypeOption(type)),
      ],
    );
  }

  Widget _buildTypeOption(SmartAccountType type) {
    final isSelected = selectedType == type;
    // Bug 4 fix: SimpleAccount, Safe, Biconomy are all available; Kernel is coming soon
    final isAvailable = type == SmartAccountType.simpleAccount ||
        type == SmartAccountType.safe ||
        type == SmartAccountType.biconomy;
    final typeColor = _getTypeColor(type);

    return GestureDetector(
      onTap: isAvailable
          ? () =>
              (this as _AAAccountCreatePageState)._onTypeChanged(type)
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: isSelected
              ? typeColor.withAlpha(15)
              : AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
          border: Border.all(
            color: isSelected
                ? typeColor
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  size: ScreenUtil().setWidth(24),
                  color: typeColor,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontWeight: FontWeight.w600,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                        if (!isAvailable) ...[
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setWidth(2),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha(30),
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(6)),
                            ),
                            child: Text(
                              S.of(context).g_key_aa_coming_soon,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      _getTypeDescription(type),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: ScreenUtil().setWidth(28),
                  color: typeColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ).withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ).withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_preview_address,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildPreviewAddressContent(),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_aa_counterfactual_note,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAddressContent() {
    if (isCalculating) {
      return Row(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(20),
            height: ScreenUtil().setWidth(20),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_aa_address_calculating,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      );
    }

    if (addressError != null) {
      return Row(
        children: [
          Icon(Icons.error_outline,
              size: ScreenUtil().setWidth(20), color: Colors.red),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              addressError!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: (this as _AAAccountCreatePageState)
                ._calculatePreviewAddress,
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
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontFamily: 'monospace',
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ),
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
            icon: Icon(
              Icons.copy,
              size: ScreenUtil().setWidth(22),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: Colors.amber.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: ScreenUtil().setWidth(22),
            color: Colors.amber[700],
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              S.of(context).g_key_aa_deployment_note,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: Colors.amber[700],
              ),
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
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        disabledBackgroundColor: Colors.grey,
      ),
      child: isCreating
          ? SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              S.of(context).g_key_aa_create_account,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
