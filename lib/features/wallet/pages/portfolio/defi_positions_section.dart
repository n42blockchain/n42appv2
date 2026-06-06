// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/api_hub/datasources/debank_datasource.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// DeFi positions section for the Portfolio page.
///
/// Displays aggregated DeFi positions from DeBank across:
/// - Lending (supplied/borrowed)
/// - Liquidity pools
/// - Staking
/// - Claimable rewards
class DeFiPositionsSection extends StatefulWidget {
  final String walletAddress;

  const DeFiPositionsSection({super.key, required this.walletAddress});

  @override
  State<DeFiPositionsSection> createState() => _DeFiPositionsSectionState();
}

class _DeFiPositionsSectionState extends State<DeFiPositionsSection> {
  DeFiPortfolio? _portfolio;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final portfolio = await DeBankDatasource.getPortfolio(
        widget.walletAddress,
      );
      if (mounted) {
        setState(() {
          _portfolio = portfolio;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load DeFi positions';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final portfolio = _portfolio;
    if (portfolio == null || portfolio.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(32),
            vertical: ScreenUtil().setWidth(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DeFi Positions',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
              Text(
                fmtUsd(portfolio.totalUsdValue),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).brand,
                ),
              ),
            ],
          ),
        ),

        // Category summary chips
        _buildCategorySummary(portfolio),

        SizedBox(height: ScreenUtil().setWidth(8)),

        // Protocol list
        ...portfolio.protocols.take(10).map((p) => _buildProtocolCard(p)),

        if (portfolio.protocolCount > 10)
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: navigate to full DeFi positions page
              },
              child: Text(
                'View all ${portfolio.protocolCount} protocols',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppColorTokens.of(context).brand,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySummary(DeFiPortfolio portfolio) {
    final categories = <_CategoryChip>[];

    if (portfolio.lendingValue > 0) {
      categories.add(
        _CategoryChip(
          'Lending',
          portfolio.lendingValue,
          const Color(0xFF3B82F6),
        ),
      );
    }
    if (portfolio.lpValue > 0) {
      categories.add(
        _CategoryChip('LP', portfolio.lpValue, const Color(0xFF22C55E)),
      );
    }
    if (portfolio.stakingValue > 0) {
      categories.add(
        _CategoryChip(
          'Staking',
          portfolio.stakingValue,
          const Color(0xFF9333EA),
        ),
      );
    }
    if (portfolio.rewardsValue > 0) {
      categories.add(
        _CategoryChip(
          'Rewards',
          portfolio.rewardsValue,
          const Color(0xFFF97316),
        ),
      );
    }

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32)),
      child: Wrap(
        spacing: ScreenUtil().setWidth(12),
        runSpacing: ScreenUtil().setWidth(8),
        children: categories.map((c) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(16),
              vertical: ScreenUtil().setWidth(8),
            ),
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              '${c.label}: ${fmtUsd(c.value)}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: c.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProtocolCard(ProtocolPosition protocol) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(32),
        vertical: ScreenUtil().setWidth(6),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Protocol header
          Row(
            children: [
              if (protocol.logoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  child: Image.network(
                    protocol.logoUrl!,
                    width: ScreenUtil().setWidth(36),
                    height: ScreenUtil().setWidth(36),
                    errorBuilder: (context2, error2, stack2) => Icon(
                      Icons.account_balance,
                      size: ScreenUtil().setWidth(36),
                    ),
                  ),
                ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protocol.name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      protocol.chain.toUpperCase(),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        color: AppColorTokens.of(context).textSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                fmtUsd(protocol.totalUsdValue),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
            ],
          ),

          // Position details
          ...protocol.positions.map((pos) => _buildPositionRow(pos)),
        ],
      ),
    );
  }

  Widget _buildPositionRow(Position position) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supply tokens
          ...position.supplyTokens.map((t) => _buildTokenRow(t, '+')),
          // Borrow tokens
          ...position.borrowTokens.map((t) => _buildTokenRow(t, '-')),
          // Claimable rewards
          if (position.hasClaimableRewards) ...[
            ...position.rewardTokens.map((t) => _buildTokenRow(t, '🎁')),
          ],
        ],
      ),
    );
  }

  Widget _buildTokenRow(PositionToken token, String prefix) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(48),
        top: ScreenUtil().setWidth(4),
      ),
      child: Row(
        children: [
          Text(
            '$prefix ${token.amount.toStringAsFixed(4)} ${token.symbol}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: prefix == '-'
                  ? const Color(0xFFEF4444)
                  : AppColorTokens.of(context).textSubtitle,
            ),
          ),
          const Spacer(),
          Text(
            fmtUsd(token.usdValue),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              'Loading DeFi positions...',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      child: Center(
        child: TextButton.icon(
          onPressed: _loadPositions,
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(_error ?? 'Error'),
        ),
      ),
    );
  }
}

class _CategoryChip {
  final String label;
  final double value;
  final Color color;
  _CategoryChip(this.label, this.value, this.color);
}
