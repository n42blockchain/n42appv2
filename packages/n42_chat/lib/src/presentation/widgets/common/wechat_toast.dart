/// 微信风格的 Toast 提示
///
/// 居中显示的半透明黑色圆角提示框
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// Toast 类型
enum ToastType {
  /// 普通信息
  info,

  /// 成功
  success,

  /// 警告
  warning,

  /// 错误
  error,
}

/// 微信风格 Toast
class WeChatToast {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// 显示 Toast
  ///
  /// [context] BuildContext
  /// [message] 提示消息
  /// [type] Toast 类型，默认为 info
  /// [duration] 显示时长，默认 2 秒
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 移除当前的 Toast
    dismiss();

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
      ),
    );

    overlay.insert(_currentEntry!);

    // 设置自动消失
    _timer = Timer(duration, dismiss);
  }

  /// 显示信息提示
  static void info(BuildContext context, String message) {
    show(context, message, type: ToastType.info);
  }

  /// 显示成功提示
  static void success(BuildContext context, String message) {
    show(context, message, type: ToastType.success);
  }

  /// 显示警告提示
  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastType.warning);
  }

  /// 显示错误提示
  static void error(BuildContext context, String message) {
    show(context, message, type: ToastType.error);
  }

  /// 关闭 Toast
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
  });

  final String message;
  final ToastType type;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData? get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.info:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 120,
                  maxWidth: 240,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: _icon != null ? 20 : 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_icon != null) ...[
                      Icon(
                        _icon,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
