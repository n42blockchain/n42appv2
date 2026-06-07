// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/perps/hyperliquid_service.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Perpetual futures trading page — Hyperliquid integration.
///
/// Displays available markets, user's positions, and provides
/// basic order placement (market/limit).
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
          'Perpetuals',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(34),
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
          controller: _tabController,
          indicatorColor: AppColorTokens.of(context).brand,
          labelColor: AppColorTokens.of(context).textPrimary,
          unselectedLabelColor: AppColorTokens.of(context).textSubtitle,
          tabs: [
            Tab(text: 'Markets (${_markets.length})'),
            Tab(text: 'Positions (${_positions.length})'),
            Tab(text: 'Orders (${_orders.length})'),
          ],
        ),
      ),
      backgroundColor: AppColorTokens.of(context).bgBase,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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

  Widget _buildMarginBar(MarginSummary margin) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24),
        vertical: ScreenUtil().setWidth(12),
      ),
      color: AppColorTokens.of(context).bgSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMarginItem(
            'Account',
            '\$${margin.accountValue.toStringAsFixed(2)}',
          ),
          _buildMarginItem(
            'Used',
            '\$${margin.totalMarginUsed.toStringAsFixed(2)}',
          ),
          _buildMarginItem('Free', '\$${margin.freeMargin.toStringAsFixed(2)}'),
          _buildMarginItem(
            'Util',
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
          style: TextStyle(
            fontSize: ScreenUtil().setSp(20),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketsList() {
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
      itemCount: _markets.length,
      itemBuilder: (context, index) {
        final m = _markets[index];
        final isPositive = m.priceChangePct >= 0;
        return ListTile(
          dense: true,
          title: Text(
            '${m.symbol}-PERP',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          subtitle: Text(
            'Vol: \$${_formatCompact(m.volume24h)} · OI: \$${_formatCompact(m.openInterest)}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${m.markPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${m.priceChangePct.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: FontWeight.w500,
                  color: isPositive
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          onTap: () {
            // TODO: Navigate to trading detail page
          },
        );
      },
    );
  }

  Widget _buildPositionsList() {
    if (_positions.isEmpty) {
      return Center(
        child: Text(
          'No open positions',
          style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final p = _positions[index];
        final isProfitable = p.unrealizedPnl >= 0;
        return Container(
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
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
                      horizontal: ScreenUtil().setWidth(12),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color:
                          (p.isLong
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444))
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${p.sideLabel} ${p.leverage.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        fontWeight: FontWeight.w600,
                        color: p.isLong
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    p.symbol,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
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
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          fontWeight: FontWeight.w700,
                          color: isProfitable
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      Text(
                        '${isProfitable ? '+' : ''}${p.pnlPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: isProfitable
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPosDetail('Size', p.size.abs().toStringAsFixed(4)),
                  _buildPosDetail(
                    'Entry',
                    '\$${p.entryPrice.toStringAsFixed(2)}',
                  ),
                  _buildPosDetail(
                    'Liq',
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
          style: TextStyle(
            fontSize: ScreenUtil().setSp(20),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
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
          'No open orders',
          style: TextStyle(color: AppColorTokens.of(context).textSubtitle),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final o = _orders[index];
        return ListTile(
          dense: true,
          leading: Icon(
            o.isBuy ? Icons.arrow_upward : Icons.arrow_downward,
            color: o.isBuy ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            size: 20,
          ),
          title: Text(
            '${o.sideLabel} ${o.symbol} × ${o.size}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          subtitle: Text(
            'Limit \$${o.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () {
              // TODO: Cancel order
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
