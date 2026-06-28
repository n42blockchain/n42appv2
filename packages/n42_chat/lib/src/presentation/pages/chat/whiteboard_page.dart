import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/utils/debug_log.dart';
import '../../widgets/chat/whiteboard/whiteboard_controller.dart';

/// 白板 / 涂鸦页（仿微信「涂鸦」、对标 iMessage Digital Touch 的轻量版）。
///
/// 单人绘制 → 栅格化为 PNG → `Navigator.pop` 返回字节，由聊天页走既有图片
/// 发送链路上传发送。实时协作（多端共绘）属后续：可把 [WhiteboardStroke] 序列
/// 化为自定义 Matrix 事件增量广播；当前先交付单人涂鸦。
class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key});

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  final WhiteboardController _controller = WhiteboardController();
  final GlobalKey _canvasKey = GlobalKey();
  bool _exporting = false;

  static const List<Color> _palette = [
    Color(0xFF222222),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFFFFFFF),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_controller.isEmpty || _exporting) return;
    setState(() => _exporting = true);
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _exporting = false);
        return;
      }
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: dpr);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      final bytes = byteData?.buffer.asUint8List();
      Navigator.of(context).pop<Uint8List>(bytes);
    } catch (e) {
      debugLog('WhiteboardPage export failed: $e');
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Whiteboard'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Semantics(
              button: true,
              label: 'Send',
              child: TextButton(
                onPressed: _controller.isNotEmpty && !_exporting
                    ? _export
                    : null,
                child: Text(
                  'Send',
                  style: TextStyle(
                    color: _controller.isNotEmpty
                        ? Colors.lightBlueAccent
                        : Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: Container(
                color: const Color(0xFF1A1A1A),
                child: GestureDetector(
                  onPanStart: (d) =>
                      _controller.startStroke(d.localPosition),
                  onPanUpdate: (d) => _controller.addPoint(d.localPosition),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _WhiteboardPainter(_controller.strokes),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Undo',
              child: IconButton(
                icon: const Icon(Icons.undo, color: Colors.white),
                onPressed: _controller.undo,
              ),
            ),
            Semantics(
              button: true,
              label: 'Clear',
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: _controller.clear,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final color in _palette)
                      _buildColorDot(color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    final selected = _controller.color == color;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Color',
      child: GestureDetector(
        onTap: () => _controller.color = color,
        child: Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.lightBlueAccent : Colors.white24,
              width: selected ? 2.5 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<WhiteboardStroke> strokes;

  _WhiteboardPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        // 单点：画一个圆点
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
