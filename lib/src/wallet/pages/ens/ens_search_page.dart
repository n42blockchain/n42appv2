// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/pages/ens/ens_purchase_page.dart';
import 'package:n42_wallet/src/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/src/wallet/widgets/ens/ens_price_card.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// ENS 搜索页面
///
/// 搜索 ENS 名称可用性并显示价格信息
class EnsSearchPage extends StatefulWidget {
  /// 当前钱包地址
  final String walletAddress;

  const EnsSearchPage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<EnsSearchPage> createState() => _EnsSearchPageState();
}

class _EnsSearchPageState extends State<EnsSearchPage> {
  final EnsRegistrationService _ensService = EnsRegistrationServiceProvider.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounceTimer;
  String _searchQuery = '';
  EnsAvailabilityResult? _availabilityResult;
  EnsPrice? _priceInfo;
  bool _isSearching = false;
  bool _isLoadingPrice = false;
  int _selectedYears = 1;

  @override
  void initState() {
    super.initState();
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        _performSearch(value);
      } else {
        setState(() {
          _availabilityResult = null;
          _priceInfo = null;
          _searchQuery = value;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
      _availabilityResult = null;
      _priceInfo = null;
    });

    final result = await _ensService.checkAvailability(query);

    if (mounted && _searchQuery == query) {
      setState(() {
        _isSearching = false;
        _availabilityResult = result;
      });

      // 如果可用，加载价格
      if (result.isAvailable) {
        _loadPrice(query);
      }
    }
  }

  Future<void> _loadPrice(String name) async {
    setState(() => _isLoadingPrice = true);

    final result = await _ensService.getPrice(name, _selectedYears);

    if (mounted) {
      setState(() {
        _isLoadingPrice = false;
        if (!result.error) {
          _priceInfo = result.data;
        }
      });
    }
  }

  void _onYearsChanged(int years) {
    setState(() => _selectedYears = years);
    if (_availabilityResult?.isAvailable == true) {
      _loadPrice(_searchQuery);
    }
  }

  void _navigateToPurchase() {
    if (_availabilityResult?.isAvailable != true || _priceInfo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnsPurchasePage(
          name: _searchQuery,
          walletAddress: widget.walletAddress,
          years: _selectedYears,
          price: _priceInfo!,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_ens_search_title,
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.backGroundColor.name,
              ),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              border: Border.all(
                color: _searchFocusNode.hasFocus
                    ? AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      )
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: ScreenUtil().setWidth(16)),
                Icon(
                  Icons.search,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                  size: ScreenUtil().setWidth(28),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_ens_search_hint,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(16),
                      ),
                    ),
                  ),
                ),
                // .eth 后缀标签
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ).withAlpha(20),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Text(
                    '.eth',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
              ],
            ),
          ),
          if (_searchQuery.isNotEmpty && !_ensService.isValidEnsName(_searchQuery))
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
              child: Text(
                S.of(context).g_key_ens_invalid_name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchQuery.isEmpty || _searchQuery.length < 3) {
      return _buildInitialState();
    }

    if (_isSearching) {
      return _buildSearchingState();
    }

    if (_availabilityResult == null) {
      return _buildInitialState();
    }

    if (_availabilityResult!.error != null) {
      return _buildErrorState();
    }

    if (_availabilityResult!.isAvailable) {
      return _buildAvailableState();
    } else {
      return _buildUnavailableState();
    }
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        children: [
          SizedBox(height: ScreenUtil().setWidth(60)),
          Icon(
            Icons.search_rounded,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(80),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_key_ens_search_prompt,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_min_length,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ).withAlpha(150),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(40)),
          // 热门域名建议
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    // Web3 / N42 ecosystem oriented suggestions as search starters
    final suggestions = ['n42user', 'web3', 'builder', 'trader', 'hodler', 'degen'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ens_suggestions,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Wrap(
          spacing: ScreenUtil().setWidth(12),
          runSpacing: ScreenUtil().setWidth(12),
          children: suggestions.map((name) {
            return GestureDetector(
              onTap: () {
                _searchController.text = name;
                _onSearchChanged(name);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(10),
                ),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemBgColor.name,
                  ),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  border: Border.all(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ).withAlpha(30),
                  ),
                ),
                child: Text(
                  '$name.eth',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_key_ens_checking,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(64),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            _availabilityResult!.error!,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          ElevatedButton(
            onPressed: () => _performSearch(_searchQuery),
            child: Text(S.of(context).g_swap_key_6),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 可用状态卡片
          _buildAvailabilityCard(isAvailable: true),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 年限选择
          _buildYearsSelector(),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 价格卡片
          if (_isLoadingPrice)
            const Center(child: CircularProgressIndicator())
          else if (_priceInfo != null)
            EnsPriceCard(price: _priceInfo!),
          SizedBox(height: ScreenUtil().setWidth(32)),

          // 注册按钮
          ElevatedButton(
            onPressed: _priceInfo != null ? _navigateToPurchase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
            ),
            child: Text(
              S.of(context).g_key_ens_register_now,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 不可用状态卡片
          _buildAvailabilityCard(isAvailable: false),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 详细信息
          if (_availabilityResult!.ownerAddress != null ||
              _availabilityResult!.expiresAt != null)
            _buildUnavailableDetails(),
          SizedBox(height: ScreenUtil().setWidth(24)),

          // 建议
          Text(
            S.of(context).g_key_ens_try_another,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard({required bool isAvailable}) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withAlpha(20)
            : Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withAlpha(50)
              : Colors.red.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: ScreenUtil().setWidth(48),
            color: isAvailable ? Colors.green : Colors.red,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_searchQuery.eth',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  isAvailable
                      ? S.of(context).g_key_ens_available
                      : S.of(context).g_key_ens_unavailable,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableDetails() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          if (_availabilityResult!.ownerAddress != null)
            _buildDetailRow(
              S.of(context).g_key_ens_owner,
              _shortenAddress(_availabilityResult!.ownerAddress!),
            ),
          if (_availabilityResult!.expiresAt != null) ...[
            if (_availabilityResult!.ownerAddress != null)
              Divider(height: ScreenUtil().setWidth(24)),
            _buildDetailRow(
              S.of(context).g_key_ens_expires,
              _formatDate(_availabilityResult!.expiresAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w500,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ens_registration_period,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Row(
          children: [1, 2, 3, 5].map((years) {
            final isSelected = _selectedYears == years;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onYearsChanged(years),
                child: Container(
                  margin: EdgeInsets.only(
                    right: years != 5 ? ScreenUtil().setWidth(12) : 0,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(14),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          )
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemBgColor.name,
                          ),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                    border: Border.all(
                      color: isSelected
                          ? AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainBlueColor.name,
                            )
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ).withAlpha(50),
                    ),
                  ),
                  child: Text(
                    '$years ${years == 1 ? S.of(context).g_key_ens_year : S.of(context).g_key_ens_years}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
