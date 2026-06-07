// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';

part 'mining_node_detail_widgets.dart';

class MiningNodeDetailPage extends ConsumerStatefulWidget {
  const MiningNodeDetailPage({super.key});

  @override
  ConsumerState<MiningNodeDetailPage> createState() =>
      _MiningNodeDetailPageState();
}

class _MiningNodeDetailPageState extends ConsumerState<MiningNodeDetailPage>
    with _MiningNodeDetailWidgets {
  @override
  Widget build(BuildContext context) {
    final mpValue = ref.watch(miningBridgeProvider);
    final node = mpValue.fullNodeEntity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_mining_node_key1),
      body: SafeArea(
        child: DetailRefreshWidget(
          callback: () async {
            await mpValue.getBeaconValidator();
          },
          childWidget: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(20),
            ),
            child: node == null
                ? _buildEmpty(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusHeader(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      _buildTwoColumnCards(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      _buildInfoList(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(24)),
                      _buildRedemptionSection(context, mpValue),
                      SizedBox(height: ScreenUtil().setWidth(60)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    BuildContext context,
    MiningV2Provider mpValue,
    FullNodeEntity node,
    bool isDark,
  ) {
    final badgeColor = _statusColor(context, node.status);
    final pubKey = node.id;
    final shortKey = pubKey.length > 12
        ? '${pubKey.substring(0, 8)}...${pubKey.substring(pubKey.length - 6)}'
        : pubKey;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: _cardDecoration(context, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(10),
                      height: ScreenUtil().setWidth(10),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Text(
                      _statusLabel(context, node.status),
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: ScreenUtil().setSp(22),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                node.name,
                style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textSubtitle),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              Flexible(
                flex: 0,
                child: Text(
                  '${S.of(context).g_mining_node_key2}: ',
                  style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textSubtitle),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: Text(
                  shortKey,
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: pubKey));
                  ToastUtils.show(S.of(context).copy);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
                  child: Icon(
                    Icons.copy_outlined,
                    size: ScreenUtil().setWidth(32),
                    color: AppColorTokens.of(context).brand,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final subColor = AppColorTokens.of(context).textSubtitle;
    return SizedBox(
      height: ScreenUtil().setWidth(400),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(96),
              height: ScreenUtil().setWidth(96),
              decoration: BoxDecoration(
                color: subColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hub_outlined,
                size: ScreenUtil().setWidth(48),
                color: subColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            Text(
              S.of(context).g_mining_key_47,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}
