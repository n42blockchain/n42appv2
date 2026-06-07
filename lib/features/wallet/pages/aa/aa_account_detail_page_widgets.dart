part of 'aa_account_detail_page.dart';

/// Widget builder mixin for [_AAAccountDetailPageState].
///
/// Builds all UI sections: account card, quick actions, details, and
/// transaction history. Applied after the State base so that [widget],
/// [context], and state fields are accessible.
mixin _AAAccountDetailWidgetsMixin on State<AAAccountDetailPage> {
  // Provided by _AAAccountDetailPageState
  void copyAddress();

  // ─── Theme helpers ──────────────────────────────────────────────────

  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  Color get _mainText => _themeColor(AppThemeKeys.mainTextColor.name);
  Color get _subText => _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
  Color get _itemBg => _themeColor(AppThemeKeys.itemBgColor.name);

  BoxDecoration _sectionDecoration() =>
      BoxDecoration(color: _itemBg, borderRadius: AppRadius.brMd);

  // ─── Account Card ─────────────────────────────────────────────────────

  Widget buildAccountCard() {
    final typeColor = _getAccountTypeColor();

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [typeColor.withAlpha(30), typeColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAccountIcon(),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.w600,
                        color: _mainText,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      widget.account.type.displayName,
                      style: AppTypography.caption.copyWith(color: _subText),
                    ),
                  ],
                ),
              ),
              DeploymentStatusIndicator(state: widget.account.state),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: _themeColor(
                AppThemeKeys.backGroundColor.name,
              ).withAlpha(100),
              borderRadius: AppRadius.brMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_155,
                        style: AppTypography.captionSm.copyWith(color: _subText),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        widget.account.address,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          fontFamily: 'monospace',
                          color: _mainText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: copyAddress,
                  icon: Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(24),
                    color: _themeColor(AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountIcon() {
    final typeColor = _getAccountTypeColor();

    return Container(
      width: ScreenUtil().setWidth(64),
      height: ScreenUtil().setWidth(64),
      decoration: BoxDecoration(
        color: typeColor.withAlpha(30),
        borderRadius: AppRadius.brMd,
      ),
      child: Center(
        child: Icon(
          _getAccountTypeIcon(),
          size: ScreenUtil().setWidth(36),
          color: typeColor,
        ),
      ),
    );
  }

  // ─── Quick Actions ────────────────────────────────────────────────────

  Widget buildQuickActions({
    required VoidCallback? onSend,
    required VoidCallback onReceive,
    required VoidCallback? onCheckStatus,
    required bool isDeploying,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.send,
            label: S.of(context).g_key_48,
            color: const Color(0xFF5E97F6),
            onTap: onSend,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code,
            label: S.of(context).g_key_33,
            color: const Color(0xFF66BB6A),
            onTap: onReceive,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildActionButton(
            icon: Icons.radar,
            label: S.of(context).g_key_aa_check_status,
            color: const Color(0xFFFF9800),
            onTap: isDeploying ? null : onCheckStatus,
            isLoading: isDeploying,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final isDisabled = onTap == null && !isLoading;
    final effectiveColor = isDisabled ? Colors.grey : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: effectiveColor.withAlpha(20),
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: effectiveColor.withAlpha(isDisabled ? 30 : 40),
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: ScreenUtil().setWidth(28),
                height: ScreenUtil().setWidth(28),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
            else
              Icon(
                icon,
                size: ScreenUtil().setWidth(28),
                color: effectiveColor,
              ),
            SizedBox(height: ScreenUtil().setWidth(6)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w500,
                color: isDisabled ? Colors.grey : _mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Details Section ──────────────────────────────────────────────────

  Widget buildDetailsSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_aa_account_details,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: _mainText,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildDetailRow(
            S.of(context).g_key_aa_chain_id,
            widget.account.chainId.toString(),
          ),
          _buildDetailRow(
            S.of(context).g_key_aa_factory,
            _shortenAddress(widget.account.factoryAddress),
          ),
          _buildDetailRow(
            S.of(context).g_key_aa_owner,
            _shortenAddress(widget.account.ownerAddress),
          ),
          _buildDetailRow(
            S.of(context).g_key_aa_created,
            _formatDate(widget.account.createdAt),
          ),
          if (widget.account.lastActivityAt != null)
            _buildDetailRow(
              S.of(context).g_key_aa_last_activity,
              _formatDate(widget.account.lastActivityAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: _subText)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w500,
              color: _mainText,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Transaction History ──────────────────────────────────────────────

  Widget buildTransactionHistory() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_tran_1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: _mainText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(S.of(context).g_key_aa_view_all),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(24),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: ScreenUtil().setWidth(48),
                    color: _subText.withAlpha(100),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  Text(
                    S.of(context).g_key_132,
                    style: AppTypography.caption.copyWith(color: _subText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────

  Color _getAccountTypeColor() {
    return switch (widget.account.type) {
      SmartAccountType.simpleAccount => const Color(0xFF5E97F6),
      SmartAccountType.simple7702Account => const Color(0xFF9333EA),
      SmartAccountType.safe => const Color(0xFF12A87B),
      SmartAccountType.kernel => const Color(0xFF8B5CF6),
      SmartAccountType.biconomy => const Color(0xFFFF6B4A),
      SmartAccountType.custom => const Color(0xFF6B7280),
    };
  }

  IconData _getAccountTypeIcon() {
    return switch (widget.account.type) {
      SmartAccountType.simpleAccount => Icons.account_balance_wallet,
      SmartAccountType.simple7702Account => Icons.flash_on,
      SmartAccountType.safe => Icons.security,
      SmartAccountType.kernel => Icons.memory,
      SmartAccountType.biconomy => Icons.auto_awesome,
      SmartAccountType.custom => Icons.code,
    };
  }

  String _shortenAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
