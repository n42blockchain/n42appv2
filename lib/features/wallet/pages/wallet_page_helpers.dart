import 'dart:math' show max;

import 'package:n42_wallet/generated/l10n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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

  static double get touchExtent => max(44, ScreenUtil().setWidth(88));

  final bool isPinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isPinned
        ? S.of(context).g_wallet_unpin_token
        : S.of(context).g_wallet_pin_token;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        toggled: isPinned,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brPill,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: touchExtent,
              minHeight: touchExtent,
            ),
            child: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: ScreenUtil().setWidth(32),
              color: isPinned
                  ? AppColorTokens.of(context).brand
                  : AppColorTokens.of(context).textTertiary,
            ),
          ),
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
        final base = AppColorTokens.of(context).bgSurface;
        final shimmer =
            Color.lerp(base, AppColorTokens.of(context).border, _anim.value) ??
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
  const WalletSkeletonCoinRow({super.key, required this.shimmerColor});
  final Color shimmerColor;

  Widget _shimmerBox(double w, double h) => Container(
    width: ScreenUtil().setWidth(w),
    height: ScreenUtil().setWidth(h),
    decoration: BoxDecoration(
      color: shimmerColor,
      borderRadius: AppRadius.brSm,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColorTokens.of(context).border.withValues(alpha: 0.55),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtil().setWidth(64),
            height: ScreenUtil().setWidth(64),
            margin: EdgeInsets.only(right: AppSpacing.space4),
            decoration: BoxDecoration(
              color: shimmerColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: WalletPinIconButton.touchExtent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_shimmerBox(80, 22), _shimmerBox(60, 22)],
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_shimmerBox(100, 18), _shimmerBox(50, 18)],
                  ),
                ],
              ),
            ),
          ),
          SizedBox.square(dimension: WalletPinIconButton.touchExtent),
        ],
      ),
    );
  }
}
