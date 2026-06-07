import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'market_coin_info_helpers.dart';
import 'market_coin_info_widgets.dart';

// ─── social links section ──────────────────────────────────────────────────

Widget buildLinksSection(
  BuildContext context, {
  required String website,
  required List<String> browsers,
  required String? reddit,
  required String? twitter,
  required String? facebook,
  required void Function(BuildContext, String) openUrl,
}) {
  final links = <LinkItem>[
    if (website.isNotEmpty)
      (
        icon: 'assets/img/webshit1.png',
        label: S.of(context).g_key_m_9,
        url: website,
      ),
    if (facebook != null)
      (
        icon: 'assets/img/facebook.png',
        label: S.of(context).g_key_m_10,
        url: facebook,
      ),
    if (twitter != null)
      (
        icon: 'assets/img/twitter.png',
        label: S.of(context).g_key_m_11,
        url: twitter,
      ),
    if (reddit != null)
      (
        icon: 'assets/img/reddit.png',
        label: S.of(context).g_key_m_14,
        url: reddit,
      ),
  ];

  if (links.isEmpty && browsers.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: EdgeInsets.only(
      top: ScreenUtil().setWidth(24),
      left: ScreenUtil().setWidth(30),
      right: ScreenUtil().setWidth(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        coinInfoSectionTitle(context, S.of(context).g_key_m_8),
        SizedBox(height: ScreenUtil().setWidth(16)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30),
            vertical: ScreenUtil().setWidth(10),
          ),
          decoration: BoxDecoration(
            color: AppColorTokens.of(context).bgSurface,
            borderRadius: AppRadius.brMd,
          ),
          child: Column(
            children: [
              ...links.map((item) => _buildLinkRow(context, item, openUrl)),
              if (links.isNotEmpty && browsers.isNotEmpty)
                coinInfoDivider(context),
              _buildBrowserRows(context, browsers, openUrl),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildLinkRow(
  BuildContext context,
  LinkItem item,
  void Function(BuildContext, String) openUrl,
) {
  return InkWell(
    onTap: () => openUrl(context, item.url),
    child: SizedBox(
      height: ScreenUtil().setWidth(85),
      child: Row(
        children: [
          Image.asset(
            item.icon,
            width: ScreenUtil().setWidth(40),
            color: AppColorTokens.of(context).textSubtitle,
          ),
          SizedBox(width: ScreenUtil().setWidth(30)),
          Expanded(
            child: Text(
              item.label,
              style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_sharp,
            size: ScreenUtil().setWidth(30),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ],
      ),
    ),
  );
}

Widget _buildBrowserRows(
  BuildContext context,
  List<String> browsers,
  void Function(BuildContext, String) openUrl,
) {
  if (browsers.isEmpty) return const SizedBox.shrink();
  return Column(
    children: [
      SizedBox(
        height: ScreenUtil().setWidth(85),
        child: Row(
          children: [
            Image.asset(
              'assets/img/website.png',
              width: ScreenUtil().setWidth(40),
              color: AppColorTokens.of(context).textSubtitle,
            ),
            SizedBox(width: ScreenUtil().setWidth(30)),
            Expanded(
              child: Text(
                S.of(context).g_key_m_15,
                style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
              ),
            ),
          ],
        ),
      ),
      ...browsers.map(
        (url) => InkWell(
          onTap: () => openUrl(context, url),
          child: SizedBox(
            height: ScreenUtil().setWidth(85),
            child: Row(
              children: [
                SizedBox(width: ScreenUtil().setWidth(70)),
                Expanded(
                  child: Text(
                    url,
                    style: AppTypography.bodySm.copyWith(color: AppColorTokens.of(context).textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: ScreenUtil().setWidth(30),
                  color: AppColorTokens.of(context).textSubtitle,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
