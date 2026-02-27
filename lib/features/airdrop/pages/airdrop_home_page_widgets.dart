// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'airdrop_home_page.dart';

/// Widgets mixin: stats card, airdrop list, and airdrop card builders.
mixin AirdropHomeWidgetsMixin on State<AirdropHomePage>, AirdropHomeLogicMixin {
  // ---------------------------------------------------------------------------
  // Stats card
  // ---------------------------------------------------------------------------

  Widget buildStatsCard(AirdropProvider p) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withValues(alpha: 180 / 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pending',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    '\$${p.stats.pendingValueUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(40),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
                child: Text(
                  '${p.stats.eligibleAirdrops} Eligible',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${p.stats.totalAirdrops}',
                  Icons.list_alt,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Claimed',
                  '${p.stats.claimedAirdrops}',
                  Icons.check_circle_outline,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Value Claimed',
                  '\$${p.stats.claimedValueUsd.toStringAsFixed(0)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: ScreenUtil().setWidth(24)),
          SizedBox(height: ScreenUtil().setWidth(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Airdrop list + card
  // ---------------------------------------------------------------------------

  Widget buildAirdropList(List<AirdropModel> airdrops, AirdropProvider p) {
    if (airdrops.isEmpty) {
      return buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: p.refresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(8),
        ),
        itemCount: airdrops.length + (p.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == airdrops.length) {
            // 加载更多 - 在帧回调中触发以避免在 build 过程中修改状态
            WidgetsBinding.instance.addPostFrameCallback((_) {
              p.loadMore();
            });
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildAirdropCard(airdrops[index]);
        },
      ),
    );
  }

  Widget _buildAirdropCard(AirdropModel airdrop) {
    return GestureDetector(
      onTap: () => navigateToDetail(airdrop),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: airdrop.isExpiringSoon
              ? Border.all(color: Colors.orange, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 项目 Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                  child: Image.network(
                    airdrop.projectLogo,
                    width: ScreenUtil().setWidth(48),
                    height: ScreenUtil().setWidth(48),
                    errorBuilder: (ctx, error, stack) => Container(
                      width: ScreenUtil().setWidth(48),
                      height: ScreenUtil().setWidth(48),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 30 / 255),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                      ),
                      child: Icon(Icons.token, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),

                // 项目信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              airdrop.name,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontWeight: FontWeight.w600,
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainTextColor.name,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          buildStatusBadge(airdrop.status),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        airdrop.projectName,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtil().setWidth(12)),

            // 标签和信息
            Row(
              children: [
                buildChainTag(airdrop.chainSymbol),
                SizedBox(width: ScreenUtil().setWidth(8)),
                buildTypeTag(airdrop.type),
                Spacer(),
                if (airdrop.estimatedValueUsd != null)
                  Text(
                    '~\$${airdrop.estimatedValueUsd!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),

            // 截止时间提示
            if (airdrop.isExpiringSoon && airdrop.daysLeft != null) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 20 / 255),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: ScreenUtil().setWidth(20),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(4)),
                    Text(
                      '${airdrop.daysLeft} days left to claim',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 领取按钮
            if (airdrop.isClaimable) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => claimAirdrop(airdrop),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                  ),
                  child: Text(
                    'Claim ${airdrop.userClaimableAmount ?? ""} ${airdrop.tokenSymbol ?? ""}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
