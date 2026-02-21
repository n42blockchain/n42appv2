import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/dex_swap_api.dart';
import 'package:n42appv2/src/wallet/models/dex/dex_history_model.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:date_format/date_format.dart' as dformat;
import 'package:n42appv2/generated/l10n.dart';

class DexSwapHistory extends StatefulWidget {
  const DexSwapHistory({super.key});

  @override
  State<DexSwapHistory> createState() => _DexSwapHistoryState();
}

class _DexSwapHistoryState extends State<DexSwapHistory> {
  final DexSwapApi _api = DexSwapApi();

  String _statusText(BuildContext context, int status) {
    final s = S.of(context);
    switch (status) {
      case 1: return s.g_key_dex_status_pending;
      case 2: return s.g_key_dex_status_confirmed;
      case 3: return s.g_key_dex_status_failed;
      default: return s.g_key_dex_status_quoted;
    }
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
            final MessageModel res =
                await _api.getHistory(uuid, page: page, size: pageSize);
            if (res.error) return [];
            return ((res.data as List?) ?? [])
                .map((e) =>
                    DexHistoryModel.fromJson(e as Map<String, dynamic>))
                .toList();
          },
          buildItem:
              (BuildContext context, List<dynamic> results, int index) {
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

            Color statusColor;
            switch (item.status) {
              case 2:
                statusColor = AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.rightTextColor.name);
              case 3:
                statusColor = AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name);
              default:
                statusColor = AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.textColorOrange.name);
            }

            return Container(
              height: ScreenUtil().setWidth(100),
              margin:
                  EdgeInsets.only(bottom: ScreenUtil().setWidth(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${item.tokenInSymbol} → ${item.tokenOutSymbol}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        '+${item.amountOut} ${item.tokenOutSymbol}',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(28),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(24),
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
                              ScreenUtil().setWidth(4)),
                        ),
                        child: Text(
                          item.source,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(20),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        _statusText(context, item.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: ScreenUtil().setSp(24),
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
