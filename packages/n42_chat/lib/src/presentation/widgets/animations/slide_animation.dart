import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 滑动删除组件
class SlideToDeleteWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 删除按钮标签
  final String deleteLabel;

  /// 其他操作（左滑显示）
  final List<SlideAction>? actions;

  /// 背景色
  final Color backgroundColor;

  const SlideToDeleteWidget({
    super.key,
    required this.child,
    this.onDelete,
    this.deleteLabel = 'Delete',
    this.actions,
    this.backgroundColor = AppColors.error,
  });

  @override
  State<SlideToDeleteWidget> createState() => _SlideToDeleteWidgetState();
}

class _SlideToDeleteWidgetState extends State<SlideToDeleteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;

  double get _actionWidth {
    final actionCount = (widget.actions?.length ?? 0) + (widget.onDelete != null ? 1 : 0);
    return actionCount * 70.0;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.primaryDelta!).clamp(-_actionWidth, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > _actionWidth / 2) {
      // 展开操作区域
      setState(() {
        _dragExtent = -_actionWidth;
      });
    } else {
      // 关闭
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  void _close() {
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // 操作按钮区域
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 自定义操作
                if (widget.actions != null)
                  ...widget.actions!.map((action) => _buildAction(action)),

                // 删除按钮
                if (widget.onDelete != null)
                  _buildAction(SlideAction(
                    icon: Icons.delete,
                    label: widget.deleteLabel,
                    backgroundColor: AppColors.error,
                    onTap: () {
                      _close();
                      widget.onDelete?.call();
                    },
                  )),
              ],
            ),
          ),

          // 主内容
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildAction(SlideAction action) {
    return GestureDetector(
      onTap: () {
        _close();
        action.onTap?.call();
      },
      child: Container(
        width: 70,
        color: action.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (action.icon != null)
              Icon(
                action.icon,
                color: action.foregroundColor,
                size: 22,
              ),
            if (action.label != null) ...[
              const SizedBox(height: 4),
              Text(
                action.label!,
                style: TextStyle(
                  fontSize: 12,
                  color: action.foregroundColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 滑动操作配置
class SlideAction {
  final IconData? icon;
  final String? label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const SlideAction({
    this.icon,
    this.label,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.white,
    this.onTap,
  });
}

/// 下拉刷新指示器
class PullToRefreshIndicator extends StatelessWidget {
  /// 刷新状态
  final RefreshIndicatorState state;

  /// 拉动距离
  final double pullDistance;

  /// 触发刷新的距离
  final double refreshTriggerPullDistance;

  const PullToRefreshIndicator({
    super.key,
    required this.state,
    required this.pullDistance,
    this.refreshTriggerPullDistance = 80,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (pullDistance / refreshTriggerPullDistance).clamp(0.0, 1.0);

    return SizedBox(
      height: pullDistance.clamp(0, refreshTriggerPullDistance * 1.5),
      child: Center(
        child: _buildContent(progress),
      ),
    );
  }

  Widget _buildContent(double progress) {
    switch (state) {
      case RefreshIndicatorState.pulling:
        return Transform.rotate(
          angle: progress * 3.14159 * 2,
          child: Icon(
            Icons.arrow_downward,
            size: 24,
            color: Colors.grey.withValues(alpha: progress),
          ),
        );
      case RefreshIndicatorState.armed:
        return const Icon(
          Icons.arrow_upward,
          size: 24,
          color: Colors.grey,
        );
      case RefreshIndicatorState.refreshing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      case RefreshIndicatorState.done:
        return const Icon(
          Icons.check,
          size: 24,
          color: AppColors.success,
        );
      case RefreshIndicatorState.idle:
        return const SizedBox.shrink();
    }
  }
}

/// 刷新状态
enum RefreshIndicatorState {
  /// 空闲
  idle,

  /// 下拉中
  pulling,

  /// 已达到刷新触发点
  armed,

  /// 刷新中
  refreshing,

  /// 完成
  done,
}

