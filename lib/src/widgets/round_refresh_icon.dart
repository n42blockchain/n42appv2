import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
typedef RefreshData = Future Function();
class RoundRefreshIcon extends StatefulWidget {
  final RefreshData? refreshData;
  final double? width;
  final double? height;
  final double? padding;

  const RoundRefreshIcon({
    super.key,
    this.refreshData,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<RoundRefreshIcon> createState() => _RoundRefreshIconState();
}

class _RoundRefreshIconState extends State<RoundRefreshIcon> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Padding(
      padding: EdgeInsets.all(widget.padding ?? ScreenUtil().setWidth(4)),
      child: Container(
        width:
        widget.width ?? ScreenUtil().setWidth(40),
        height:
        widget.height ?? ScreenUtil().setWidth(40),
        alignment: Alignment.center,
        child: SizedBox(
          height: widget.height ??ScreenUtil().setWidth(40),
          //如何在flutter中调整CircularProgressIndicator的大小？
          //https://cloud.tencent.com/developer/ask/sof/339120
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    )
        : GestureDetector(
      onTap: () async {
        try {
          setState(() {
            isLoading = true;
          });
          if (widget.refreshData != null) {
            await widget.refreshData!();
          }
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.all(widget.padding ?? ScreenUtil().setWidth(4)),
        child: Image.asset(
          "assets/img/shuaxin.png",
          width: widget.width ??ScreenUtil().setWidth(40),
          height: widget.height ??ScreenUtil().setWidth(40),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          // fit: BoxFit.cover,
        ),
      ),
    );
  }
}
