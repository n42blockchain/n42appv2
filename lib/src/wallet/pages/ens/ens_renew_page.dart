// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/services/ens_registration_service.dart';
import 'package:n42appv2/src/wallet/widgets/ens/ens_price_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// ENS 续费页面
class EnsRenewPage extends StatefulWidget {
  /// 已拥有的 ENS 信息
  final OwnedEns ownedEns;

  /// 钱包地址
  final String walletAddress;

  const EnsRenewPage({
    super.key,
    required this.ownedEns,
    required this.walletAddress,
  });

  @override
  State<EnsRenewPage> createState() => _EnsRenewPageState();
}

class _EnsRenewPageState extends State<EnsRenewPage> {
  final EnsRegistrationService _ensService = EnsRegistrationServiceProvider.instance;

  int _selectedYears = 1;
  EnsPrice? _priceInfo;
  bool _isLoadingPrice = false;
  bool _isRenewing = false;
  RenewResult? _renewResult;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    setState(() => _isLoadingPrice = true);

    final result = await _ensService.getPrice(widget.ownedEns.name, _selectedYears);

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
    _loadPrice();
  }

  Future<void> _executeRenew() async {
    setState(() {
      _isRenewing = true;
      _renewResult = null;
    });

    final result = await _ensService.renew(widget.ownedEns.name, _selectedYears);

    if (mounted) {
      setState(() {
        _isRenewing = false;
        _renewResult = result.data;
      });

      if (result.error || result.data == null || !result.data!.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data?.error ?? S.of(context).g_key_error_3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_ens_renew,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 域名信息卡片
            _buildDomainCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 续费成功后显示结果
            if (_renewResult?.success == true) ...[
              _buildSuccessCard(),
              SizedBox(height: ScreenUtil().setWidth(24)),
            ],

            // 续费期限选择
            if (_renewResult?.success != true) ...[
              _buildYearsSelector(),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // 价格信息
              if (_isLoadingPrice)
                const Center(child: CircularProgressIndicator())
              else if (_priceInfo != null)
                EnsPriceCard(price: _priceInfo!),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // 新到期时间预览
              if (_priceInfo != null)
                _buildExpiryPreview(),
              SizedBox(height: ScreenUtil().setWidth(32)),
            ],

            // 操作按钮
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard() {
    final isExpiringSoon = widget.ownedEns.isExpiringSoon;
    final isExpired = widget.ownedEns.isExpired;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red.withAlpha(30), Colors.red.withAlpha(10)]
              : isExpiringSoon
                  ? [Colors.orange.withAlpha(30), Colors.orange.withAlpha(10)]
                  : [
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withAlpha(30),
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withAlpha(10),
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        children: [
          Text(
            widget.ownedEns.name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(36),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpired
                    ? Icons.error
                    : isExpiringSoon
                        ? Icons.warning
                        : Icons.access_time,
                size: ScreenUtil().setWidth(20),
                color: isExpired
                    ? Colors.red
                    : isExpiringSoon
                        ? Colors.orange
                        : AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
              ),
              SizedBox(width: ScreenUtil().setWidth(6)),
              Text(
                isExpired
                    ? S.of(context).g_key_ens_expired
                    : '${S.of(context).g_key_ens_expires}: ${widget.ownedEns.formattedExpiresAt}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: isExpired
                      ? Colors.red
                      : isExpiringSoon
                          ? Colors.orange
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_ens_extend_period,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
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
                    vertical: ScreenUtil().setWidth(16),
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
                    '+$years ${years == 1 ? S.of(context).g_key_ens_year : S.of(context).g_key_ens_years}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
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

  Widget _buildExpiryPreview() {
    final currentExpiry = widget.ownedEns.expiresAt;
    final newExpiry = currentExpiry.add(Duration(days: _selectedYears * 365));

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: Colors.green.withAlpha(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_ens_current_expiry,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                _formatDate(currentExpiry),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
            child: Icon(
              Icons.arrow_downward,
              size: ScreenUtil().setWidth(24),
              color: Colors.green,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_ens_new_expiry,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Text(
                _formatDate(newExpiry),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: Colors.green.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: ScreenUtil().setWidth(64),
            color: Colors.green,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_ens_renew_success,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (_renewResult?.newExpiresAt != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              '${S.of(context).g_key_ens_new_expiry}: ${_formatDate(_renewResult!.newExpiresAt!)}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
          if (_renewResult?.txHash != null) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                'Tx: ${_shortenHash(_renewResult!.txHash!)}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontFamily: 'monospace',
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_renewResult?.success == true) {
      return ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          ),
        ),
        child: Text(
          S.of(context).g_swap_key_18,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _priceInfo != null && !_isRenewing ? _executeRenew : null,
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
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isRenewing
          ? SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Text(
              S.of(context).g_key_ens_confirm_renew,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }
}
