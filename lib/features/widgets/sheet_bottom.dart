import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 应用通用的底部弹框体
/// title 不传 没有标题
/// child 根据需求自定义实现
///
/// iPad / 宽屏上自动限制最大宽度，避免全宽拉伸。
void sheetBottom(BuildContext context, String title, Widget child,
    {bool enableDrag = true, bool isDismissible = true}) {
  final isWide = ResponsiveUtils.isTablet(context);

  showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: enableDrag,
    constraints: isWide
        ? const BoxConstraints(maxWidth: 500)
        : null,
    builder: (context) {
      return _NFTSheet(title: title, child: child);
    },
  );
}

/// 带标题的下方弹出控件
/// [child]无内置的margin、padding，需自行设置
class _NFTSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const _NFTSheet({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(16.0))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title == null || title!.isEmpty
                ? const SizedBox()
                : Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(30)),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: ScreenUtil().setWidth(1.0), color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBorderColor.name)))
                  ),
                  child: Center(
                      child: Text(
                        title ?? '',
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30), vertical: ScreenUtil().setWidth(30)),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
