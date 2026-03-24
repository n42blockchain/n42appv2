import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const WalletSliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(WalletSliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class WalletPinIconButton extends StatelessWidget {
  const WalletPinIconButton({
    super.key,
    required this.isPinned,
    required this.onTap,
  });

  final bool isPinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(12),
          ScreenUtil().setWidth(16),
          0,
          ScreenUtil().setWidth(16),
        ),
        child: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          size: ScreenUtil().setWidth(30),
          color: isPinned
              ? AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class WalletCoinListSkeleton extends StatefulWidget {
  const WalletCoinListSkeleton({super.key});

  @override
  State<WalletCoinListSkeleton> createState() => _WalletCoinListSkeletonState();
}

class _WalletCoinListSkeletonState extends State<WalletCoinListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final base = AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name);
        final shimmer = Color.lerp(
              base,
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.dividerColor.name),
              _anim.value,
            ) ??
            base;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => WalletSkeletonCoinRow(shimmerColor: shimmer),
          ),
        );
      },
    );
  }
}

class WalletSkeletonCoinRow extends StatelessWidget {
  const WalletSkeletonCoinRow({
    super.key,
    required this.shimmerColor,
  });
  final Color shimmerColor;

  Widget _shimmerBox(double w, double h, double radius) => Container(
        width: ScreenUtil().setWidth(w),
        height: ScreenUtil().setWidth(h),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final radius = ScreenUtil().setWidth(8);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(14)),
            decoration: BoxDecoration(
              color: shimmerColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(80, 22, radius),
                    _shimmerBox(60, 22, radius),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(100, 18, radius),
                    _shimmerBox(50, 18, radius),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
