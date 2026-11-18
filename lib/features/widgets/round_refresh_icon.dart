import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
    // Both states keep the 44pt footprint so the spinner does not shift the
    // layout; the icon itself stays 20pt.
    return isLoading
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: AppTouch.target,
              minHeight: AppTouch.target,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: EdgeInsets.all(
                  widget.padding ?? ScreenUtil().setWidth(4),
                ),
                child: Container(
                  width: widget.width ?? ScreenUtil().setWidth(40),
                  height: widget.height ?? ScreenUtil().setWidth(40),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: widget.height ?? ScreenUtil().setWidth(40),
                    //如何在flutter中调整CircularProgressIndicator的大小？
                    //https://cloud.tencent.com/developer/ask/sof/339120
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          )
        : AppTapArea(
            // Icon-only control: tooltip is also the screen-reader label.
            tooltip: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
            customBorder: const CircleBorder(),
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
              padding: EdgeInsets.all(
                widget.padding ?? ScreenUtil().setWidth(4),
              ),
              child: Image.asset(
                "assets/img/shuaxin.png",
                width: widget.width ?? ScreenUtil().setWidth(40),
                height: widget.height ?? ScreenUtil().setWidth(40),
                color: AppColorTokens.of(context).textPrimary,
                // fit: BoxFit.cover,
              ),
            ),
          );
  }
}
