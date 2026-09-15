// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/earn/utils/stablecoin_earn_utils.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';
import 'package:n42_wallet/features/wallet/pages/lending/lending_page.dart';

/// 稳定币活期收益（Stablecoin Earn）—— Wallet Roadmap S1。
///
/// 聚合 Aave V3 各链上的稳定币（USDC/USDT/DAI…）供给市场，按 APY 降序展示，
/// 点击「存入」进入既有 [LendingPage] 的 Supply 流程。对标 Trust Stablecoin Earn。
class StablecoinEarnPage extends StatefulWidget {
  final String walletAddress;

  const StablecoinEarnPage({super.key, required this.walletAddress});

  @override
  State<StablecoinEarnPage> createState() => _StablecoinEarnPageState();
}

class _StablecoinEarnEntry {
  final int chainId;
  final String chainName;
  final AaveReserve reserve;
  const _StablecoinEarnEntry(this.chainId, this.chainName, this.reserve);
}

class _StablecoinEarnPageState extends State<StablecoinEarnPage> {
  /// 仅 Aave 子图可读 reserve 的链（与 AaveService 子图覆盖一致）。
  static const Map<int, String> _chains = {
    1: 'Ethereum',
    137: 'Polygon',
    42161: 'Arbitrum',
    10: 'Optimism',
  };

  bool _loading = true;
  List<_StablecoinEarnEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    if (initial && mounted) setState(() => _loading = true);
    final results = await Future.wait(
      _chains.entries.map((e) async {
        try {
          final reserves = await AaveService.getReserves(e.key);
          return StablecoinEarnUtils.filterSortStablecoins(
            reserves,
          ).map((r) => _StablecoinEarnEntry(e.key, e.value, r)).toList();
        } catch (_) {
          return <_StablecoinEarnEntry>[];
        }
      }),
    );
    if (!mounted) return;
    final flat = results.expand((e) => e).toList()
      ..sort((a, b) => b.reserve.supplyApy.compareTo(a.reserve.supplyApy));
    setState(() {
      _entries = flat;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tokens = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.bgBase,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        elevation: 0,
        title: Text(
          s.g_key_earn_stablecoin_title,
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _entries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: ScreenUtil().setWidth(120)),
                        _buildEmpty(context),
                      ],
                    )
                  : _buildList(context),
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final su = ScreenUtil();
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(su.setWidth(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_outlined,
              size: su.setWidth(48),
              color: tokens.textSubtitle.withAlpha(100),
            ),
            SizedBox(height: su.setWidth(12)),
            Text(
              S.of(context).g_key_earn_stablecoin_empty,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(color: tokens.textSubtitle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final su = ScreenUtil();
    final tokens = AppColorTokens.of(context);
    final best = _entries.first.reserve.supplyApy;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(su.setWidth(20)),
      children: [
        // 顶部说明 + 最佳 APY
        Container(
          padding: EdgeInsets.all(su.setWidth(16)),
          decoration: BoxDecoration(
            color: tokens.success.withAlpha(18),
            borderRadius: BorderRadius.circular(su.setWidth(16)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).g_key_earn_stablecoin_desc,
                  style: AppTypography.bodySm.copyWith(
                    color: tokens.textSubtitle,
                  ),
                ),
              ),
              SizedBox(width: su.setWidth(8)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).g_key_earn_best_apy,
                    style: AppTypography.captionSm.copyWith(
                      color: tokens.textSubtitle,
                    ),
                  ),
                  Text(
                    '${best.toStringAsFixed(2)}%',
                    style: AppTypography.headline.copyWith(
                      color: tokens.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: su.setWidth(16)),
        ..._entries.map((e) => _buildEntry(context, e)),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, _StablecoinEarnEntry e) {
    final su = ScreenUtil();
    final tokens = AppColorTokens.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: su.setWidth(12)),
      padding: EdgeInsets.all(su.setWidth(16)),
      decoration: BoxDecoration(
        color: tokens.bgSurface,
        borderRadius: BorderRadius.circular(su.setWidth(16)),
        border: Border.all(color: tokens.brand.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: su.setWidth(44),
            height: su.setWidth(44),
            decoration: BoxDecoration(
              color: tokens.success.withAlpha(28),
              borderRadius: BorderRadius.circular(su.setWidth(12)),
            ),
            child: Icon(
              Icons.attach_money,
              color: tokens.success,
              size: su.setWidth(24),
            ),
          ),
          SizedBox(width: su.setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.reserve.symbol,
                  style: AppTypography.bodyStrong.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  '${e.chainName} · TVL ${_formatUsd(e.reserve.totalLiquidityUsd)}',
                  style: AppTypography.caption.copyWith(
                    color: tokens.textSubtitle,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${e.reserve.supplyApy.toStringAsFixed(2)}% APY',
                style: AppTypography.bodyStrong.copyWith(color: tokens.success),
              ),
              SizedBox(height: su.setWidth(6)),
              GestureDetector(
                onTap: () => _openLending(e.chainId),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: su.setWidth(14),
                    vertical: su.setWidth(6),
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brand,
                    borderRadius: BorderRadius.circular(su.setWidth(8)),
                  ),
                  child: Text(
                    S.of(context).g_key_earn_stablecoin_deposit,
                    style: AppTypography.captionSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 紧凑 USD 金额（如 $1.2M / $345K）。
  static String _formatUsd(double v) {
    if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(0)}';
  }

  void _openLending(int chainId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LendingPage(chainId: chainId, walletAddress: widget.walletAddress),
      ),
    );
  }
}
