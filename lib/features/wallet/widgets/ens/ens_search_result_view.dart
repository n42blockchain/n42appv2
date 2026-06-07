// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_price_card.dart';

/// ENS 搜索结果区域
///
/// 根据搜索状态展示：初始引导、搜索中、错误、可用、不可用
class EnsSearchResultView extends StatelessWidget {
  final String searchQuery;
  final bool isSearching;
  final bool isLoadingPrice;
  final EnsAvailabilityResult? availabilityResult;
  final EnsPrice? priceInfo;
  final int selectedYears;
  final ValueChanged<int> onYearsChanged;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onRetry;
  final VoidCallback? onRegisterTap;

  const EnsSearchResultView({
    super.key,
    required this.searchQuery,
    required this.isSearching,
    required this.isLoadingPrice,
    required this.availabilityResult,
    required this.priceInfo,
    required this.selectedYears,
    required this.onYearsChanged,
    required this.onSuggestionTap,
    required this.onRetry,
    required this.onRegisterTap,
  });

  /// Shorthand for theme color lookup to reduce repetitive boilerplate.
  Color _themeColor(BuildContext context, String key) =>
      AppThemeUtils.getColorByKey(context, key);

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty || searchQuery.length < 3) {
      return _buildInitialState(context);
    }
    if (isSearching) {
      return _buildSearchingState(context);
    }
    if (availabilityResult == null) {
      return _buildInitialState(context);
    }
    if (availabilityResult!.error != null) {
      return _buildErrorState(context);
    }
    if (availabilityResult!.isAvailable) {
      return _buildAvailableState(context);
    }
    return _buildUnavailableState(context);
  }

  Widget _buildInitialState(BuildContext context) {
    final subtitleColor = _themeColor(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.space16),
          Icon(
            Icons.search_rounded,
            size: ScreenUtil().setWidth(80),
            color: subtitleColor.withAlpha(80),
          ),
          SizedBox(height: AppSpacing.space6),
          Text(
            S.of(context).g_key_ens_search_prompt,
            style: AppTypography.body.copyWith(color: subtitleColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_ens_min_length,
            style: AppTypography.caption.copyWith(
              color: subtitleColor.withAlpha(150),
            ),
          ),
          SizedBox(height: AppSpacing.space12),
          _buildSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    // Web3 / N42 ecosystem oriented suggestions as search starters
    final suggestions = [
      'n42user',
      'web3',
      'builder',
      'trader',
      'hodler',
      'degen',
    ];
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ens_suggestions,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: _themeColor(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        Wrap(
          spacing: ScreenUtil().setWidth(12),
          runSpacing: ScreenUtil().setWidth(12),
          children: suggestions.map((name) {
            return GestureDetector(
              onTap: () => onSuggestionTap(name),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                decoration: BoxDecoration(
                  color: _themeColor(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: AppRadius.brMd,
                  border: Border.all(color: blueColor.withAlpha(30)),
                ),
                child: Text(
                  '$name.eth',
                  style: AppTypography.caption.copyWith(color: blueColor),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: AppSpacing.space6),
          Text(
            S.of(context).g_key_ens_checking,
            style: AppTypography.bodySm.copyWith(
              color: _themeColor(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(64),
            color: Colors.red,
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            availabilityResult!.error!,
            style: AppTypography.bodySm.copyWith(
              color: _themeColor(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.space6),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(S.of(context).g_swap_key_6),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvailabilityCard(context, isAvailable: true),
          SizedBox(height: AppSpacing.space6),
          _buildYearsSelector(context),
          SizedBox(height: AppSpacing.space6),
          if (isLoadingPrice)
            const Center(child: CircularProgressIndicator())
          else if (priceInfo != null)
            EnsPriceCard(price: priceInfo!),
          SizedBox(height: AppSpacing.space8),
          ElevatedButton(
            onPressed: onRegisterTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space4,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
            ),
            child: Text(
              S.of(context).g_key_ens_register_now,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvailabilityCard(context, isAvailable: false),
          SizedBox(height: AppSpacing.space6),
          if (availabilityResult!.ownerAddress != null ||
              availabilityResult!.expiresAt != null)
            _buildUnavailableDetails(context),
          SizedBox(height: AppSpacing.space6),
          Text(
            S.of(context).g_key_ens_try_another,
            style: AppTypography.bodySm.copyWith(
              color: _themeColor(
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

  Widget _buildAvailabilityCard(
    BuildContext context, {
    required bool isAvailable,
  }) {
    final statusColor = isAvailable ? Colors.green : Colors.red;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: AppRadius.brMd,
        border: Border.all(color: statusColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: ScreenUtil().setWidth(48),
            color: statusColor,
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$searchQuery.eth',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _themeColor(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  isAvailable
                      ? S.of(context).g_key_ens_available
                      : S.of(context).g_key_ens_unavailable,
                  style: AppTypography.bodySm.copyWith(
                    color: statusColor,
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

  Widget _buildUnavailableDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor.name),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          if (availabilityResult!.ownerAddress != null)
            _buildDetailRow(
              context,
              S.of(context).g_key_ens_owner,
              _shortenAddress(availabilityResult!.ownerAddress!),
            ),
          if (availabilityResult!.expiresAt != null) ...[
            if (availabilityResult!.ownerAddress != null)
              Divider(height: ScreenUtil().setWidth(24)),
            _buildDetailRow(
              context,
              S.of(context).g_key_ens_expires,
              _formatDate(availabilityResult!.expiresAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: _themeColor(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w500,
            color: _themeColor(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ],
    );
  }

  Widget _buildYearsSelector(BuildContext context) {
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor.name);
    final mainTextColor = _themeColor(context, AppThemeKeys.mainTextColor.name);
    final yearOptions = [1, 2, 3, 5];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ens_registration_period,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: mainTextColor,
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        Row(
          children: [
            for (var i = 0; i < yearOptions.length; i++) ...[
              Expanded(
                child: _buildYearChip(
                  context,
                  years: yearOptions[i],
                  isSelected: selectedYears == yearOptions[i],
                  isLast: i == yearOptions.length - 1,
                  blueColor: blueColor,
                  mainTextColor: mainTextColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildYearChip(
    BuildContext context, {
    required int years,
    required bool isSelected,
    required bool isLast,
    required Color blueColor,
    required Color mainTextColor,
  }) {
    final itemBgColor = _themeColor(context, AppThemeKeys.itemBgColor.name);
    final subtitleColor = _themeColor(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );
    return GestureDetector(
      onTap: () => onYearsChanged(years),
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : ScreenUtil().setWidth(12)),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        decoration: BoxDecoration(
          color: isSelected ? blueColor : itemBgColor,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isSelected ? blueColor : subtitleColor.withAlpha(50),
          ),
        ),
        child: Text(
          '$years ${years == 1 ? S.of(context).g_key_ens_year : S.of(context).g_key_ens_years}',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : mainTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
