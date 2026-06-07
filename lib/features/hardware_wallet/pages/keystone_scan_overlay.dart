// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'keystone_sign_page.dart';

/// 扫描框遮罩 Painter
class _ScanOverlayPainter extends CustomPainter {
  final double scanBoxSize;
  final Color borderColor;

  _ScanOverlayPainter({required this.scanBoxSize, required this.borderColor});

  /// 便捷构建方法：返回带遮罩的全屏 Widget
  static Widget buildOverlay(BuildContext context) {
    final scanBoxSize = ScreenUtil().setWidth(260);
    return CustomPaint(
      painter: _ScanOverlayPainter(
        scanBoxSize: scanBoxSize,
        borderColor: AppColorTokens.of(context).brand,
      ),
      child: const SizedBox.expand(),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final half = scanBoxSize / 2;

    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final innerRect = Rect.fromLTRB(
      centerX - half,
      centerY - half,
      centerX + half,
      centerY + half,
    );

    final path = Path()
      ..addRect(outerRect)
      ..addRect(innerRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    final r = innerRect;

    // Top-left
    canvas.drawLine(r.topLeft, r.topLeft.translate(cornerLen, 0), bracketPaint);
    canvas.drawLine(r.topLeft, r.topLeft.translate(0, cornerLen), bracketPaint);
    // Top-right
    canvas.drawLine(
      r.topRight,
      r.topRight.translate(-cornerLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      r.topRight,
      r.topRight.translate(0, cornerLen),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawLine(
      r.bottomLeft,
      r.bottomLeft.translate(cornerLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      r.bottomLeft,
      r.bottomLeft.translate(0, -cornerLen),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawLine(
      r.bottomRight,
      r.bottomRight.translate(-cornerLen, 0),
      bracketPaint,
    );
    canvas.drawLine(
      r.bottomRight,
      r.bottomRight.translate(0, -cornerLen),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanBoxSize != scanBoxSize || old.borderColor != borderColor;
}

/// Keystone 通用信息卡片组件
class _KeystoneInfoCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _KeystoneInfoCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColorTokens.of(context).brand,
            size: ScreenUtil().setWidth(36),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keystone 扫描错误卡片组件
class _KeystoneScanErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _KeystoneScanErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withAlpha(230),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            style: AppTypography.caption.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(10),
              ),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                s.g_key_hw_load_more,
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
