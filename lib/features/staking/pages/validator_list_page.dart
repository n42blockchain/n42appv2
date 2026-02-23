// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 验证者排序方式
enum ValidatorSortBy {
  apy,
  commission,
  totalStaked,
  name,
}

/// 验证者列表页面
///
/// 用于选择质押的验证者
class ValidatorListPage extends StatefulWidget {
  final StakingProtocol protocol;
  final List<Validator> validators;
  final Validator? selectedValidator;

  const ValidatorListPage({
    super.key,
    required this.protocol,
    required this.validators,
    this.selectedValidator,
  });

  @override
  State<ValidatorListPage> createState() => _ValidatorListPageState();
}

class _ValidatorListPageState extends State<ValidatorListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Validator> _filteredValidators = [];
  ValidatorSortBy _sortBy = ValidatorSortBy.apy;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _filteredValidators = List.from(widget.validators);
    _sortValidators();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterValidators(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredValidators = List.from(widget.validators);
      } else {
        _filteredValidators = widget.validators.where((v) {
          return v.name.toLowerCase().contains(query.toLowerCase()) ||
              v.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _sortValidators();
    });
  }

  void _sortValidators() {
    _filteredValidators.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case ValidatorSortBy.apy:
          comparison = a.apy.compareTo(b.apy);
          break;
        case ValidatorSortBy.commission:
          comparison = a.commission.compareTo(b.commission);
          break;
        case ValidatorSortBy.totalStaked:
          comparison = a.totalStaked.compareTo(b.totalStaked);
          break;
        case ValidatorSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _changeSortBy(ValidatorSortBy sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = false;
      }
      _sortValidators();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_stake_select_validator,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 搜索框
            _buildSearchBar(context),

            // 排序栏
            _buildSortBar(context),

            // 验证者列表
            Expanded(
              child: _filteredValidators.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                      itemCount: _filteredValidators.length,
                      itemBuilder: (context, index) {
                        final validator = _filteredValidators[index];
                        final isSelected = validator.address == widget.selectedValidator?.address;
                        return _buildValidatorItem(context, validator, isSelected, index + 1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).g_key_stake_search_validator,
          hintStyle: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textFieldHintColor.name),
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterValidators('');
                  },
                )
              : null,
        ),
        onChanged: _filterValidators,
      ),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          Text(
            S.of(context).g_key_stake_sort_by,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          _buildSortChip(context, S.of(context).g_key_stake_apy, ValidatorSortBy.apy),
          SizedBox(width: ScreenUtil().setWidth(8)),
          _buildSortChip(context, S.of(context).g_key_stake_commission, ValidatorSortBy.commission),
          SizedBox(width: ScreenUtil().setWidth(8)),
          _buildSortChip(context, S.of(context).g_key_stake_staked, ValidatorSortBy.totalStaked),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, String label, ValidatorSortBy sortBy) {
    final isSelected = _sortBy == sortBy;

    return GestureDetector(
      onTap: () => _changeSortBy(sortBy),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: isSelected
                    ? Colors.white
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: ScreenUtil().setWidth(4)),
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: ScreenUtil().setWidth(20),
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_stake_no_validators,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidatorItem(
    BuildContext context,
    Validator validator,
    bool isSelected,
    int rank,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, validator),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: isSelected
              ? Border.all(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            // 排名
            Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
              decoration: BoxDecoration(
                color: rank <= 3
                    ? _getRankColor(rank)
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                        .withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: ScreenUtil().setWidth(16)),

            // 验证者 Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              child: validator.logoUri.isNotEmpty
                  ? Image.network(
                      validator.logoUri,
                      width: ScreenUtil().setWidth(48),
                      height: ScreenUtil().setWidth(48),
                      errorBuilder: (ctx, error, stackTrace) => _buildDefaultValidatorLogo(context, validator),
                    )
                  : _buildDefaultValidatorLogo(context, validator),
            ),

            SizedBox(width: ScreenUtil().setWidth(16)),

            // 验证者信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          validator.name,
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
                      if (validator.isActive)
                        Container(
                          width: ScreenUtil().setWidth(12),
                          height: ScreenUtil().setWidth(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    shortenStakingAddress(validator.address),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        'APY',
                        '${validator.apy.toStringAsFixed(1)}%',
                        Colors.green,
                      ),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      _buildInfoChip(
                        context,
                        'Fee',
                        '${validator.commission.toStringAsFixed(1)}%',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 选中标记
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(36),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultValidatorLogo(BuildContext context, Validator validator) {
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          validator.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // Gold
      case 2:
        return Color(0xFFC0C0C0); // Silver
      case 3:
        return Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

}
