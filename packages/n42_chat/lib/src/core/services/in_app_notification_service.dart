import 'package:flutter/material.dart';

/// 应用内通知数据
class InAppNotification {
  final String title;
  final String body;
  final String? avatarUrl;
  final String? roomId;
  final VoidCallback? onTap;

  const InAppNotification({
    required this.title,
    required this.body,
    this.avatarUrl,
    this.roomId,
    this.onTap,
  });
}

/// 应用内通知服务
///
/// 使用 OverlayEntry 在顶部显示 3 秒通知横幅
class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._();
  static InAppNotificationService get instance => _instance;

  InAppNotificationService._();

  OverlayEntry? _currentEntry;
  bool enabled = true;
  final Set<String> mutedRoomIds = {};
  String? _currentChatRoomId;
  int _notificationId = 0;

  /// 设置当前聊天房间 ID（用于过滤通知）
  void setCurrentChatRoom(String? roomId) {
    _currentChatRoomId = roomId;
  }

  /// 显示通知横幅
  void show(BuildContext context, InAppNotification notification) {
    if (!enabled) return;

    // 不显示当前聊天房间的通知
    if (notification.roomId != null &&
        notification.roomId == _currentChatRoomId) {
      return;
    }

    // 不显示已静音房间的通知
    if (notification.roomId != null &&
        mutedRoomIds.contains(notification.roomId)) {
      return;
    }

    dismiss();

    _notificationId++;
    final thisId = _notificationId;

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        notification: notification,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentEntry!);

    // 3 秒后自动消失（仅当此通知仍为当前通知时）
    Future.delayed(const Duration(seconds: 3), () {
      if (_notificationId == thisId) {
        dismiss();
      }
    });
  }

  /// 关闭当前通知
  void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _NotificationBanner extends StatefulWidget {
  final InAppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 8,
      right: 8,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            widget.onDismiss();
            widget.notification.onTap?.call();
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -100) {
              widget.onDismiss();
            }
          },
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notification.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.notification.body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
