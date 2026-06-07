// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// ENS 价格显示卡片
class EnsPriceCard extends StatelessWidget {
  final EnsPrice price;

  const EnsPriceCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: AppColorTokens.of(context).brand.withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_ens_price_breakdown,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 基础价格
          _buildPriceRow(
            context,
            S.of(context).g_key_ens_base_price,
            '${price.basePrice.toStringAsFixed(4)} ETH',
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),

          // 年费
          _buildPriceRow(
            context,
            '${S.of(context).g_key_ens_annual_fee} x ${price.years}',
            '${(price.annualPrice * price.years).toStringAsFixed(4)} ETH',
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
            child: Divider(
              color: AppColorTokens.of(context).textSubtitle.withAlpha(30),
            ),
          ),

          // 总价
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_ens_total,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price.formattedTotalPrice,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).brand,
                    ),
                  ),
                  if (price.usdPrice != null)
                    Text(
                      '≈ \$${price.usdPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppColorTokens.of(context).textSubtitle,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 名称长度定价提示
          if (price.nameLength <= 4) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: AppRadius.brSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: ScreenUtil().setWidth(20),
                    color: Colors.orange,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Expanded(
                    child: Text(
                      price.nameLength == 3
                          ? S.of(context).g_key_ens_premium_name
                          : S.of(context).g_key_ens_standard_name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ],
    );
  }
}
