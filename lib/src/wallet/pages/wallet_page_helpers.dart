import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

class WalletSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  WalletSliverAppBarDelegate({
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

/// 代币列表项中的图钉按钮。
///
/// 独立 [StatelessWidget] 以缩小 rebuild 范围：仅当 [isPinned] 变化时
/// Flutter diff 算法才会重建此节点，不受父节点其他字段更新的影响。
class WalletPinIconButton extends StatelessWidget {
  const WalletPinIconButton({
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

// ── Skeleton 加载占位组件 ────────────────────────────────────────────────────

/// 资产列表骨架屏：初始加载时显示 5 个脉冲占位行，无需外部依赖。
class WalletCoinListSkeleton extends StatefulWidget {
  const WalletCoinListSkeleton();

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
        // 在背景色和稍亮色之间脉冲
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
  const WalletSkeletonCoinRow({required this.shimmerColor});
  final Color shimmerColor;

  @override
  Widget build(BuildContext context) {
    final radius = ScreenUtil().setWidth(8);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 圆形头像占位
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(14)),
            decoration: BoxDecoration(
              color: shimmerColor,
              shape: BoxShape.circle,
            ),
          ),
          // 文字占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：符号 + 数量
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setWidth(22),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(60),
                      height: ScreenUtil().setWidth(22),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(10)),
                // 第二行：价格 + 总价值
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setWidth(18),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setWidth(18),
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
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
