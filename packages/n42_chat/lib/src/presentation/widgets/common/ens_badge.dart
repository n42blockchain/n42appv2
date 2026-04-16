import 'package:flutter/material.dart';

/// ENS 域名显示标签
///
/// 在用户名旁边或下方显示 ENS 域名。
class EnsBadge extends StatelessWidget {
  final String ensName;
  final double fontSize;
  final bool showIcon;

  const EnsBadge({
    super.key,
    required this.ensName,
    this.fontSize = 12,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF5298FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF5298FF).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.verified,
              size: fontSize + 2,
              color: const Color(0xFF5298FF),
            ),
            const SizedBox(width: 3),
          ],
          Text(
            ensName,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF5298FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
