import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/core/utils/responsive_utils.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home Top Bar - Migrated to Riverpod
/// 
/// Common app bar for main pages with user avatar and notification badge
class AppHomeTopBar extends ConsumerStatefulWidget {
  final GestureTapCallback? onLeftImageClick;
  final String? onLeftImageUri;
  final bool isText;
  final String? title;
  final List<Widget>? actions;
  final Widget? titleChild;

  const AppHomeTopBar({
    super.key,
    this.onLeftImageClick,
    this.onLeftImageUri,
    this.isText = true,
    this.title,
    this.actions,
    this.titleChild,
  });

  @override
  ConsumerState<AppHomeTopBar> createState() => _AppHomeTopBarState();
}

class _AppHomeTopBarState extends ConsumerState<AppHomeTopBar> {
  @override
  Widget build(BuildContext context) {
    // Watch user info and unread count from Riverpod
    final userInfo = ref.watch(currentUserProvider);
    final messageNotReadCount = ref.watch(unreadCountProvider);
    final isWide = ResponsiveUtils.isTablet(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 16.0 : ScreenUtil().setWidth(30.0)),
      height: isWide ? 56.0 : ScreenUtil().setWidth(110.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Row(
                children: [
                  // 左侧都显示头像
                  _buildLeftWidget(userInfo?.image, messageNotReadCount),
                ],
              )),
          if(widget.titleChild ==null)
            Center(
              child: widget.isText
                  ? Text(
                widget.title ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(32.0),
                ),
              )
                  : Image.asset(
                'assets/images/ast_nft.png',
                width: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                height: ScreenUtil().setWidth(64.0) ,// 375 * MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          if(widget.titleChild !=null)
            Center(
              child: widget.titleChild,
            ),
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.actions != null && widget.actions!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions!,
                    )
                ],
              ))
        ],
      ),
    );
  }

  /// Build left widget with avatar and notification badge
  Widget _buildLeftWidget(String? userImage, int messageNotReadCount) {
    Widget child;
    if (widget.onLeftImageUri == null) {
      child = GestureDetector(
        onTap: widget.onLeftImageClick,
        child: Container(
          width: ScreenUtil().setWidth(64.0),
          height: ScreenUtil().setWidth(64.0),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ScreenUtil().setWidth(32.0),
            ),
          ),
          child: ImageNetWork(
            imageUrl: userImage ?? '',
            placeholder: "assets/img/person_def_1.png",
          ),
        ),
      );
    } else {
      // 扩大点击区域，让用户更容易点击
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onLeftImageClick,
        child: Container(
          width: ScreenUtil().setWidth(80.0),
          height: ScreenUtil().setWidth(80.0),
          alignment: Alignment.center,
          child: Image.asset(
            widget.onLeftImageUri ?? "",
            width: ScreenUtil().setWidth(44),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      );
    }

    return SizedBox(
      width: ScreenUtil().setWidth(80.0),
      height: ScreenUtil().setWidth(80.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: child,
          ),
          if (messageNotReadCount != 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: ScreenUtil().setWidth(30),
                height: ScreenUtil().setWidth(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${messageNotReadCount > 99 ? 99 : messageNotReadCount}",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                    fontSize: ScreenUtil().setSp(14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}