// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/pages/perps/perp_market_details_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/perps/hyperliquid_service.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Perpetual futures page — Hyperliquid integration (read-only).
///
/// Displays available markets, the user's positions/orders and margin
/// summary. Order placement/cancellation requires Hyperliquid's EIP-712
/// action signing, which is NOT implemented yet — the page banner says so.
class PerpsPage extends StatefulWidget {
  final String walletAddress;

  const PerpsPage({super.key, required this.walletAddress});

  @override
  State<PerpsPage> createState() => _PerpsPageState();
}

class _PerpsPageState extends State<PerpsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PerpMarket> _markets = [];
  List<PerpPosition> _positions = [];
  List<PerpOrder> _orders = [];
  MarginSummary? _margin;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Fetch markets, clearinghouse (positions+margin), and orders in parallel.
    // getClearinghouseState combines positions + margin in a single API call.
    final results = await Future.wait([
      HyperliquidService.getMarkets(),
      HyperliquidService.getClearinghouseState(widget.walletAddress),
      HyperliquidService.getOpenOrders(widget.walletAddress),
    ]);

    if (mounted) {
      final chState = results[1] as ClearinghouseState;
      setState(() {
        _markets = results[0] as List<PerpMarket>;
        _positions = chState.positions;
        _orders = results[2] as List<PerpOrder>;
        _margin = chState.margin;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).g_key_earn_perps,
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        backgroundColor: AppColorTokens.of(context).bgBase,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          indicatorColor: AppColorTokens.of(context).brand,
          labelColor: AppColorTokens.of(context).textPrimary,
          unselectedLabelColor: AppColorTokens.of(context).textSubtitle,
          tabs: [
            Tab(text: S.of(context).g_ui_markets_count('${_markets.length}')),
            Tab(
              text: S.of(context).g_ui_positions_count('${_positions.length}'),
            ),
            Tab(text: S.of(context).g_ui_orders_count('${_orders.length}')),
          ],
        ),
      ),
      backgroundColor: AppColorTokens.of(context).bgBase,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 如实标注：本页仅只读行情/仓位/订单查询。下单需要 Hyperliquid
                // 专有的 EIP-712 action 签名，尚未实现——不摆无效的交易按钮。
                _buildReadOnlyBanner(),

                // Margin summary
                if (_margin != null) _buildMarginBar(_margin!),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMarketsList(),
                      _buildPositionsList(),
                      _buildOrdersList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReadOnlyBanner() {
    final c = AppColorTokens.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space2,
      ),
      color: c.warning.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 16, color: c.warning),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              S.of(context).g_key_perps_read_only,
              style: AppTypography.captionSm.copyWith(color: c.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginBar(MarginSummary margin) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space4,
      ),
      color: AppColorTokens.of(context).bgSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMarginItem(
            S.of(context).g_key_dapp_connect_account,
            '\$${margin.accountValue.toStringAsFixed(2)}',
          ),
          _buildMarginItem(
            S.of(context).g_key_loyalty_used,
            '\$${margin.totalMarginUsed.toStringAsFixed(2)}',
          ),
          _buildMarginItem(
            S.of(context).g_ui_free_margin,
            '\$${margin.freeMargin.toStringAsFixed(2)}',
          ),
          _buildMarginItem(
            S.of(context).g_ui_margin_utilization,
            '${margin.marginUtilization.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMarginItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.captionSm.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketsList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space2),
      itemCount: _markets.length,
      itemBuilder: (context, index) {
        final m = _markets[index];
        final isPositive = m.priceChangePct >= 0;
        return ListTile(
          dense: true,
          title: Text(
            '${m.symbol}-PERP',
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          subtitle: Text(
            S
                .of(context)
                .g_ui_volume_interest(
                  '\$${_formatCompact(m.volume24h)}',
                  '\$${_formatCompact(m.openInterest * m.markPrice)}',
                ),
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${m.markPrice.toStringAsFixed(2)}',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${m.priceChangePct.toStringAsFixed(2)}%',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isPositive
                      ? AppColorTokens.of(context).success
                      : AppColorTokens.of(context).danger,
                ),
              ),
            ],
          ),
          onTap: () => showPerpMarketDetails(context, m),
        );
      },
    );
  }

  Widget _buildPositionsList() {
    if (_positions.isEmpty) {
      return Center(
        child: Text(
          S.of(context).g_ui_no_positions,
          style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space2),
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final p = _positions[index];
        final isProfitable = p.unrealizedPnl >= 0;
        final c = AppColorTokens.of(context);
        return Container(
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
          padding: EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgSurface,
            borderRadius: AppRadius.brMd,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space2,
                    ),
                    decoration: BoxDecoration(
                      color: (p.isLong ? c.success : c.danger).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${p.sideLabel} ${p.leverage.toStringAsFixed(1)}x',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: p.isLong ? c.success : c.danger,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space2),
                  Text(
                    p.symbol,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isProfitable ? '+' : ''}\$${p.unrealizedPnl.toStringAsFixed(2)}',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isProfitable ? c.success : c.danger,
                        ),
                      ),
                      Text(
                        '${isProfitable ? '+' : ''}${p.pnlPercentage.toStringAsFixed(2)}%',
                        style: AppTypography.caption.copyWith(
                          color: isProfitable ? c.success : c.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.space2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPosDetail(
                    S.of(context).g_ui_position_size,
                    p.size.abs().toStringAsFixed(4),
                  ),
                  _buildPosDetail(
                    S.of(context).g_ui_entry_price,
                    '\$${p.entryPrice.toStringAsFixed(2)}',
                  ),
                  _buildPosDetail(
                    S.of(context).g_ui_liquidation_price,
                    '\$${p.liquidationPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPosDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.captionSm.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
        child: Text(
          S.of(context).g_ui_no_orders,
          style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space2),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final o = _orders[index];
        return ListTile(
          dense: true,
          leading: Icon(
            o.isBuy ? Icons.arrow_upward : Icons.arrow_downward,
            color: o.isBuy
                ? AppColorTokens.of(context).success
                : AppColorTokens.of(context).danger,
            size: 20,
          ),
          title: Text(
            '${o.sideLabel} ${o.symbol} × ${o.size}',
            style: AppTypography.caption.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          subtitle: Text(
            S.of(context).g_ui_limit_value('\$${o.price.toStringAsFixed(2)}'),
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: AppColorTokens.of(context).danger,
            ),
            onPressed: () {
              // 撤单同样需要 Hyperliquid EIP-712 签名，未实现——如实提示。
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).g_key_perps_read_only)),
              );
            },
          ),
        );
      },
    );
  }

  String _formatCompact(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
