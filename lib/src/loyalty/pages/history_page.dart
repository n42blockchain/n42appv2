// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/loyalty/models/loyalty_model.dart';
import 'package:intl/intl.dart';

/// 积分历史页面
class HistoryPage extends StatelessWidget {
  final List<PointsHistory> history;

  const HistoryPage({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: ScreenUtil().setWidth(80),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'No history yet',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
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

    // 按日期分组
    final groupedHistory = _groupByDate(history);

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final date = groupedHistory.keys.elementAt(index);
        final items = groupedHistory[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(4),
                top: index == 0 ? 0 : ScreenUtil().setWidth(16),
                bottom: ScreenUtil().setWidth(12),
              ),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ),
            // 历史记录列表
            ...items.map((item) => _buildHistoryItem(context, item)),
          ],
        );
      },
    );
  }

  Map<DateTime, List<PointsHistory>> _groupByDate(List<PointsHistory> items) {
    final map = <DateTime, List<PointsHistory>>{};
    for (final item in items) {
      final date = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      map.putIfAbsent(date, () => []);
      map[date]!.add(item);
    }
    return map;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _buildHistoryItem(BuildContext context, PointsHistory item) {
    final isEarn = item.action == PointsAction.earn;
    final color = isEarn ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 30 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Icon(
                _getActionIcon(item.action),
                color: color,
                size: ScreenUtil().setWidth(24),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),

          // 描述
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(item.createdAt),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                    if (item.txHash != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                      Text(
                        _shortenHash(item.txHash!),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 积分变化
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarn ? '+' : ''}${item.points}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'pts',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20),
                  color: AppThemeUtils.getColorByKey(
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

  IconData _getActionIcon(PointsAction action) {
    switch (action) {
      case PointsAction.earn:
        return Icons.add_circle_outline;
      case PointsAction.spend:
        return Icons.remove_circle_outline;
      case PointsAction.expire:
        return Icons.timer_off_outlined;
      case PointsAction.adjust:
        return Icons.tune;
    }
  }

  String _shortenHash(String hash) {
    if (hash.length <= 10) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}';
  }
}
