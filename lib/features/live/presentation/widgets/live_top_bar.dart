import 'package:flutter/material.dart';

/// 直播间顶部栏：主播头像 + 标题 + 关注 + 在线人数 + 关闭。
class LiveTopBar extends StatelessWidget {
  const LiveTopBar({
    super.key,
    required this.title,
    required this.onlineCount,
    required this.onClose,
    this.onFollow,
    this.showFollow = true,
  });

  final String title;
  final int onlineCount;
  final VoidCallback onClose;
  final VoidCallback? onFollow;
  final bool showFollow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  if (showFollow) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap:
                          onFollow ??
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('关注功能开发中')),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '关注',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            _OnlineBadge(count: onlineCount),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
