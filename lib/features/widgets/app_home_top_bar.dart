import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/responsive_utils.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  final Key? leftActionKey;

  const AppHomeTopBar({
    super.key,
    this.onLeftImageClick,
    this.onLeftImageUri,
    this.isText = true,
    this.title,
    this.actions,
    this.titleChild,
    this.leftActionKey,
  });

  @override
  ConsumerState<AppHomeTopBar> createState() => _AppHomeTopBarState();
}

class _AppHomeTopBarState extends ConsumerState<AppHomeTopBar> {
  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(currentUserProvider);
    final isWide = ResponsiveUtils.isTablet(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 16.0 : 8.0),
      height: isWide ? 56.0 : ScreenUtil().setWidth(110.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 标题绝对居中于整个顶部栏
          Center(
            child:
                widget.titleChild ??
                (widget.isText
                    ? Text(
                        widget.title ?? '',
                        style: AppTypography.headline.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      )
                    : Image.asset(
                        'assets/images/ast_nft.png',
                        width: ScreenUtil().setWidth(64.0),
                        height: ScreenUtil().setWidth(64.0),
                        fit: BoxFit.cover,
                        color: AppColorTokens.of(context).textPrimary,
                      )),
          ),
          // 左右两侧按钮叠加在标题上方
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLeftWidget(userInfo?.image),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions ?? [],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftWidget(String? userImage) {
    if (widget.onLeftImageUri == null) {
      return GestureDetector(
        key: widget.leftActionKey,
        onTap: widget.onLeftImageClick,
        child: Container(
          width: ScreenUtil().setWidth(64.0),
          height: ScreenUtil().setWidth(64.0),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(32.0)),
          ),
          child: ImageNetWork(
            imageUrl: userImage ?? '',
            placeholder: "assets/img/person_def_1.png",
          ),
        ),
      );
    }
    return GestureDetector(
      key: widget.leftActionKey,
      behavior: HitTestBehavior.opaque,
      onTap: widget.onLeftImageClick,
      child: Container(
        width: ScreenUtil().setWidth(80.0),
        height: ScreenUtil().setWidth(80.0),
        alignment: Alignment.centerLeft,
        child: Image.asset(
          widget.onLeftImageUri ?? "",
          width: ScreenUtil().setWidth(44),
          color: AppColorTokens.of(context).brand,
        ),
      ),
    );
  }
}
