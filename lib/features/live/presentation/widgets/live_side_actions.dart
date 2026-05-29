import 'package:flutter/material.dart';

/// 直播间右侧竖排操作：点赞 / 分享 / 礼物（抖音式）。
class LiveSideActions extends StatelessWidget {
  const LiveSideActions({
    super.key,
    required this.onLike,
    this.onShare,
    this.onGift,
  });

  final VoidCallback onLike;
  final VoidCallback? onShare;
  final VoidCallback? onGift;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(icon: Icons.favorite, label: '点赞', onTap: onLike),
        const SizedBox(height: 20),
        _ActionButton(
          icon: Icons.card_giftcard,
          label: '礼物',
          onTap: onGift ?? () => _toast(context, '礼物功能开发中'),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          icon: Icons.share,
          label: '分享',
          onTap: onShare ?? () => _toast(context, '分享功能开发中'),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
