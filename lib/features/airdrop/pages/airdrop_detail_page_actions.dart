// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'airdrop_detail_page.dart';

/// Actions mixin: badges (status, chain, type) and action buttons.
mixin AirdropDetailActionsMixin on State<AirdropDetailPage>, AirdropDetailLogicMixin {
  // ---------------------------------------------------------------------------
  // Status / chain / type badges
  // ---------------------------------------------------------------------------

  static final _statusProps = {
    AirdropStatus.upcoming: (color: Colors.blue, text: 'Upcoming'),
    AirdropStatus.active: (color: Colors.green, text: 'Active'),
    AirdropStatus.claimed: (color: Colors.grey, text: 'Claimed'),
    AirdropStatus.expired: (color: Colors.red, text: 'Expired'),
    AirdropStatus.ineligible: (color: Colors.orange, text: 'Not Eligible'),
  };

  Widget buildStatusBadge(BuildContext context, AirdropStatus status) {
    final props = _statusProps[status]!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: props.color.withValues(alpha: 30 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Text(
        props.text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: props.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildChainTag(BuildContext context, String chain) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        chain,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static final _typeProps = {
    AirdropType.token: (color: Colors.purple, text: 'Token'),
    AirdropType.nft: (color: Colors.pink, text: 'NFT'),
    AirdropType.points: (color: Colors.amber, text: 'Points'),
    AirdropType.testnet: (color: Colors.teal, text: 'Testnet'),
  };

  Widget buildTypeTag(BuildContext context, AirdropType type) {
    final props = _typeProps[type]!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: props.color.withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        props.text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: props.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------

  Widget buildActionButtons(BuildContext context, AirdropModel airdrop) {
    if (airdrop.status == AirdropStatus.claimed) {
      return _buildStatusBanner(
        color: Colors.green,
        icon: Icons.check_circle,
        label: 'Already Claimed',
      );
    }

    if (airdrop.status == AirdropStatus.expired) {
      return _buildStatusBanner(
        color: Colors.red,
        icon: Icons.cancel,
        label: 'Claim Period Ended',
      );
    }

    final isChecking = widget.provider.eligibilityChecking[airdrop.id] == true;

    return Column(
      children: [
        // 资格未知时显示检测按钮/进度
        if (airdrop.isEligible == null &&
            (airdrop.status == AirdropStatus.active ||
                airdrop.status == AirdropStatus.upcoming))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isChecking
                  ? null
                  : () => widget.provider.checkEligibility(airdrop.id),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
              child: isChecking
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(28),
                          height: ScreenUtil().setWidth(28),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          'Checking Eligibility...',
                          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          'Check Eligibility',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

        // 不符合条件时显示提示
        if (airdrop.isEligible == false)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 20 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Text(
                  'Not Eligible',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // 符合条件且有领取链接时显示 Claim 按钮
        if (airdrop.isClaimable && airdrop.claimUrl != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => launchExternalUrl(context, airdrop.claimUrl!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.redeem),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    'Claim Now',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // upcoming 空投显示提醒按钮
        if (airdrop.status == AirdropStatus.upcoming)
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => subscribeAlert(context, airdrop),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Text(
                      'Remind Me',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBanner({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
