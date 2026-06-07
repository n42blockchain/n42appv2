// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/services/ens_expiry_reminder_service.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_price_card.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_renew_success_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

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
  final EnsRegistrationService _ensService =
      EnsRegistrationServiceProvider.instance;

  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

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
    try {
      final result = await _ensService.getPrice(
        widget.ownedEns.name,
        _selectedYears,
      );

      if (mounted) {
        setState(() {
          _isLoadingPrice = false;
          if (!result.error) {
            _priceInfo = result.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPrice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Load ENS price failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    try {
      final result = await _ensService.renew(
        widget.ownedEns.name,
        _selectedYears,
      );
      if (!mounted) return;

      setState(() {
        _isRenewing = false;
        _renewResult = result.data;
      });

      final data = result.data;
      if (result.error || data == null || !data.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data?.error ?? S.of(context).g_key_error_3),
            backgroundColor: Colors.red,
          ),
        );
      } else if (data.newExpiresAt != null) {
        await EnsExpiryReminderService.setReminder(
          widget.ownedEns.name,
          data.newExpiresAt!,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRenewing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ENS renew failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_ens_renew),
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
              EnsRenewSuccessCard(
                ensName: widget.ownedEns.name,
                renewResult: _renewResult!,
              ),
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
              if (_priceInfo != null) _buildExpiryPreview(),
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
    final ens = widget.ownedEns;
    final (statusColor, statusIcon, baseColor) = switch ((
      ens.isExpired,
      ens.isExpiringSoon,
    )) {
      (true, _) => (Colors.red, Icons.error, Colors.red),
      (_, true) => (Colors.orange, Icons.warning, Colors.orange),
      _ => (
        _color(AppThemeKeys.itemSubtitleTextColor),
        Icons.access_time,
        _color(AppThemeKeys.mainBlueColor),
      ),
    };

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withAlpha(30), baseColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          Text(
            ens.name,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(36),
              fontWeight: FontWeight.w600,
              color: _color(AppThemeKeys.mainTextColor),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                statusIcon,
                size: ScreenUtil().setWidth(20),
                color: statusColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(6)),
              Flexible(
                child: Text(
                  ens.isExpired
                      ? S.of(context).g_key_ens_expired
                      : '${S.of(context).g_key_ens_expires}: ${ens.formattedExpiresAt}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: statusColor,
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
            color: _color(AppThemeKeys.mainTextColor),
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
                    color: _color(
                      isSelected
                          ? AppThemeKeys.mainBlueColor
                          : AppThemeKeys.itemBgColor,
                    ),
                    borderRadius: AppRadius.brMd,
                    border: Border.all(
                      color: isSelected
                          ? _color(AppThemeKeys.mainBlueColor)
                          : _color(
                              AppThemeKeys.itemSubtitleTextColor,
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
                          : _color(AppThemeKeys.mainTextColor),
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
        borderRadius: AppRadius.brMd,
        border: Border.all(color: Colors.green.withAlpha(40)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_ens_current_expiry,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: _color(AppThemeKeys.itemSubtitleTextColor),
                  ),
                ),
              ),
              Text(
                _formatDate(currentExpiry),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: _color(AppThemeKeys.mainTextColor),
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
              Flexible(
                child: Text(
                  S.of(context).g_key_ens_new_expiry,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
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

  Widget _buildActionButton() {
    if (_renewResult?.success == true) {
      return ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
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
        backgroundColor: _color(AppThemeKeys.mainBlueColor),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
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
}
