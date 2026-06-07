// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 跨链桥链选择页面
class BridgeSelectChainPage extends StatefulWidget {
  final List<BridgeChain> chains;
  final BridgeChain? selectedChain;
  final BridgeChain? excludeChain;

  const BridgeSelectChainPage({
    super.key,
    required this.chains,
    this.selectedChain,
    this.excludeChain,
  });

  @override
  State<BridgeSelectChainPage> createState() => _BridgeSelectChainPageState();
}

class _BridgeSelectChainPageState extends State<BridgeSelectChainPage> {
  final TextEditingController _searchController = TextEditingController();
  List<BridgeChain> _filteredChains = [];

  @override
  void initState() {
    super.initState();
    _filteredChains = _getAvailableChains();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BridgeChain> _getAvailableChains() {
    return widget.chains
        .where((c) => c.chainId != widget.excludeChain?.chainId)
        .toList();
  }

  void _filterChains(String query) {
    final available = _getAvailableChains();
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredChains = query.isEmpty
          ? available
          : available
                .where(
                  (chain) =>
                      chain.name.toLowerCase().contains(lowerQuery) ||
                      chain.nativeToken.toLowerCase().contains(lowerQuery),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_17, // Select Chain
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 搜索框
            Container(
              margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
              ),
              decoration: BoxDecoration(
                color: AppColorTokens.of(context).bgSurface,
                borderRadius: AppRadius.brMd,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: S.of(context).g_key_bridge_search_chain,
                  hintStyle: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.textFieldHintColor.name,
                    ),
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterChains('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterChains,
              ),
            ),

            // 链列表
            Expanded(
              child: _filteredChains.isEmpty
                  ? Center(
                      child: Text(
                        S.of(context).g_key_132, // No data
                        style: AppTypography.body.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredChains.length,
                      itemBuilder: (context, index) {
                        final chain = _filteredChains[index];
                        final isSelected =
                            chain.chainId == widget.selectedChain?.chainId;

                        return _buildChainItem(context, chain, isSelected);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainInitial(BuildContext context, BridgeChain chain) {
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).brand,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          chain.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChainItem(
    BuildContext context,
    BridgeChain chain,
    bool isSelected,
  ) {
    final blueColor = AppColorTokens.of(context).brand;
    return InkWell(
      onTap: () => Navigator.pop(context, chain),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(8),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: isSelected
              ? blueColor.withAlpha(30)
              : AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
          border: isSelected ? Border.all(color: blueColor, width: 2) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.brLg,
              child: chain.logoUri.isNotEmpty
                  ? Image.network(
                      chain.logoUri,
                      width: ScreenUtil().setWidth(48),
                      height: ScreenUtil().setWidth(48),
                      errorBuilder: (ctx, err, stack) =>
                          _buildChainInitial(context, chain),
                    )
                  : _buildChainInitial(context, chain),
            ),

            SizedBox(width: ScreenUtil().setWidth(20)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chain.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    chain.nativeToken,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                ],
              ),
            ),

            // 选中标记
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: blueColor,
                size: ScreenUtil().setWidth(40),
              ),
          ],
        ),
      ),
    );
  }
}
