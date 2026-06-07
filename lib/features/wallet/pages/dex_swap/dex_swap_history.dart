import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_history_model.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:date_format/date_format.dart' as dformat;
import 'package:n42_wallet/generated/l10n.dart';

class DexSwapHistory extends StatefulWidget {
  const DexSwapHistory({super.key});

  @override
  State<DexSwapHistory> createState() => _DexSwapHistoryState();
}

class _DexSwapHistoryState extends State<DexSwapHistory> {
  final DexSwapApi _api = DexSwapApi();

  String _statusText(BuildContext context, int status) {
    final s = S.of(context);
    return switch (status) {
      1 => s.g_key_dex_status_pending,
      2 => s.g_key_dex_status_confirmed,
      3 => s.g_key_dex_status_failed,
      _ => s.g_key_dex_status_quoted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_dex_history_title),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        child: BaseList(
          firstRefresh: true,
          pageIndex: 1,
          pageSize: 20,
          getData: (int page, int pageSize) async {
            final String uuid = AppGlobals.userInfo?.uuid ?? '';
            final MessageModel res = await _api.getHistory(
              uuid,
              page: page,
              size: pageSize,
            );
            if (res.error) return [];
            return ((res.data as List?) ?? [])
                .map((e) => DexHistoryModel.fromJson(e as Map<String, dynamic>))
                .toList();
          },
          buildItem: (BuildContext context, List<dynamic> results, int index) {
            final DexHistoryModel item = results[index] as DexHistoryModel;
            final String timeStr = dformat.formatDate(
              DateTime.fromMillisecondsSinceEpoch(item.createdAt * 1000),
              [
                dformat.yyyy,
                '/',
                dformat.mm,
                '/',
                dformat.dd,
                ' ',
                dformat.hh,
                ':',
                dformat.nn,
              ],
            );

            final statusColor = AppThemeUtils.getColorByKey(
              context,
              switch (item.status) {
                2 => AppThemeKeys.rightTextColor.name,
                3 => AppThemeKeys.errorTextColor.name,
                _ => AppThemeKeys.textColorOrange.name,
              },
            );

            return Container(
              height: ScreenUtil().setWidth(100),
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${item.tokenInSymbol} → ${item.tokenOutSymbol}',
                        style: AppTypography.body.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${item.amountOut} ${item.tokenOutSymbol}',
                        style: AppTypography.body.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: AppTypography.caption.copyWith(
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(12)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(12),
                          vertical: ScreenUtil().setWidth(4),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            ScreenUtil().setWidth(4),
                          ),
                        ),
                        child: Text(
                          item.source,
                          style: AppTypography.captionSm.copyWith(
                            color: AppColorTokens.of(context).textSubtitle,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _statusText(context, item.status),
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
