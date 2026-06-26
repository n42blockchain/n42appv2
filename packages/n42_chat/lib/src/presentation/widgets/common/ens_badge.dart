import 'package:flutter/material.dart';

import '../../../core/theme/app_dimensions.dart';

/// ENS 域名显示标签——在用户名旁边或下方显示 ENS 域名。
class EnsBadge extends StatelessWidget {
  static const Color _ensBlue = Color(0xFF5298FF);

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
    return ConstrainedBox(
      // 限宽防止超长 ENS 域名（如 *.eth subdomain）撑破父容器。
      constraints: const BoxConstraints(maxWidth: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _ensBlue.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: _ensBlue.withValues(alpha: 0.30),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(Icons.verified_rounded, size: fontSize + 2, color: _ensBlue),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                ensName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  color: _ensBlue,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
