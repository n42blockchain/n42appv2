// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Lending page — in-wallet Aave V3 supply and borrow interface.
///
/// Replaces the need to navigate to DApp browser for basic lending operations.
/// Shows available markets with APY rates and provides supply/borrow actions.
class LendingPage extends StatefulWidget {
  final int chainId;
  final String walletAddress;

  const LendingPage({
    super.key,
    required this.chainId,
    required this.walletAddress,
  });

  @override
  State<LendingPage> createState() => _LendingPageState();
}

class _LendingPageState extends State<LendingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AaveReserve> _reserves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReserves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReserves() async {
    setState(() => _loading = true);
    final reserves = await AaveService.getReserves(widget.chainId);
    if (mounted) {
      setState(() {
        _reserves = reserves;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aave V3 Lending',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(34),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        backgroundColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.backGroundColor.name,
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name,
          ),
          labelColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainTextColor.name,
          ),
          unselectedLabelColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name,
          ),
          tabs: const [
            Tab(text: 'Supply'),
            Tab(text: 'Borrow'),
          ],
        ),
      ),
      backgroundColor: AppThemeUtils.getColorByKey(
        context, AppThemeKeys.backGroundColor.name,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMarketList(isSupply: true),
                _buildMarketList(isSupply: false),
              ],
            ),
    );
  }

  Widget _buildMarketList({required bool isSupply}) {
    if (_reserves.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              AaveService.isAvailable(widget.chainId)
                  ? 'No markets available'
                  : 'Aave V3 not available on this chain',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReserves,
      child: ListView.builder(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        itemCount: _reserves.length,
        itemBuilder: (context, index) {
          final reserve = _reserves[index];
          return _buildReserveCard(reserve, isSupply: isSupply);
        },
      ),
    );
  }

  Widget _buildReserveCard(AaveReserve reserve, {required bool isSupply}) {
    final apy = isSupply ? reserve.supplyApy : reserve.borrowApy;
    final apyColor = isSupply
        ? const Color(0xFF22C55E) // green for supply
        : const Color(0xFFF97316); // orange for borrow

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(8),
        ),
        leading: CircleAvatar(
          backgroundColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name,
          ).withValues(alpha: 0.1),
          child: Text(
            reserve.symbol.length > 3
                ? reserve.symbol.substring(0, 3)
                : reserve.symbol,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name,
              ),
            ),
          ),
        ),
        title: Text(
          reserve.symbol,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        subtitle: Text(
          reserve.name,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${apy.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w700,
                color: apyColor,
              ),
            ),
            Text(
              isSupply ? 'Supply APY' : 'Borrow APR',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to supply/borrow detail page with amount input
        },
      ),
    );
  }
}
