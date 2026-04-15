// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';
import 'package:n42_wallet/features/pay/offramp/offramp_service.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Off-ramp entry page — allows users to sell crypto for fiat.
///
/// Shows available providers and supported tokens, then opens the
/// appropriate WebView (MoonPay Sell or Transak) for the transaction.
class OfframpPage extends StatefulWidget {
  final CoinModel? coinModel;

  const OfframpPage({super.key, this.coinModel});

  @override
  State<OfframpPage> createState() => _OfframpPageState();
}

class _OfframpPageState extends State<OfframpPage> {
  String _selectedFiat = 'USD';
  String? _selectedCrypto;

  @override
  void initState() {
    super.initState();
    _selectedCrypto = widget.coinModel?.coin['miniName']?.toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final supportedCrypto = OfframpService.getAllSupportedCrypto();
    final supportedFiat = OfframpService.getAllSupportedFiat();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sell Crypto',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(34),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.backGroundColor.name,
        ),
        elevation: 0,
      ),
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.backGroundColor.name,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                    size: ScreenUtil().setWidth(36),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(16)),
                  Expanded(
                    child: Text(
                      'Convert your crypto to fiat currency. Funds will be sent to your bank account or card.',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ScreenUtil().setWidth(32)),

            // Crypto selector
            Text(
              'Sell',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w500,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            _buildDropdown(
              value: _selectedCrypto ?? supportedCrypto.first,
              items: supportedCrypto,
              onChanged: (v) => setState(() => _selectedCrypto = v),
            ),

            SizedBox(height: ScreenUtil().setWidth(24)),

            // Fiat selector
            Text(
              'Receive',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w500,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            _buildDropdown(
              value: _selectedFiat,
              items: supportedFiat,
              onChanged: (v) => setState(() => _selectedFiat = v ?? 'USD'),
            ),

            SizedBox(height: ScreenUtil().setWidth(24)),

            // Provider info
            _buildProviderInfo(),

            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: ElevatedButton(
                onPressed: _canProceed ? _proceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemBorderColor.name,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemBgColor.name,
          ),
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    final crypto = _selectedCrypto ?? '';
    final provider = OfframpService.getBestProvider(
      cryptoCurrency: crypto,
      fiatCurrency: _selectedFiat,
    );

    if (provider == null) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Text(
          'No provider available for $crypto → $_selectedFiat',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: Colors.orange,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: ScreenUtil().setWidth(32)),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Text(
            'Via ${provider.name}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canProceed {
    final crypto = _selectedCrypto ?? '';
    return OfframpService.getBestProvider(
      cryptoCurrency: crypto,
      fiatCurrency: _selectedFiat,
    ) != null;
  }

  void _proceed() {
    // Open MoonPay sell WebView (type=1 for sell)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Moonpay(
          coinModel: widget.coinModel,
          type: 1, // sell mode
        ),
      ),
    );
  }
}
