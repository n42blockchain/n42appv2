import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/whiteboard/whiteboard_controller.dart';

/// Roadmap #30 白板/涂鸦 —— 纯绘制状态机测试。
void main() {
  test('starts empty', () {
    final c = WhiteboardController();
    expect(c.isEmpty, isTrue);
    expect(c.strokes, isEmpty);
  });

  test('startStroke + addPoint builds one stroke', () {
    final c = WhiteboardController();
    c.startStroke(const Offset(0, 0));
    c.addPoint(const Offset(1, 1));
    c.addPoint(const Offset(2, 2));
    expect(c.strokes.length, 1);
    expect(c.strokes.first.points.length, 3);
    expect(c.isNotEmpty, isTrue);
  });

  test('addPoint without startStroke auto-starts a stroke', () {
    final c = WhiteboardController();
    c.addPoint(const Offset(5, 5));
    expect(c.strokes.length, 1);
    expect(c.strokes.first.points.single, const Offset(5, 5));
  });

  test('color/width apply to new strokes only', () {
    final c = WhiteboardController();
    c.startStroke(const Offset(0, 0));
    c.color = const Color(0xFFFF0000);
    c.width = 10;
    c.startStroke(const Offset(1, 1));
    expect(c.strokes.first.color, isNot(const Color(0xFFFF0000)));
    expect(c.strokes.last.color, const Color(0xFFFF0000));
    expect(c.strokes.last.width, 10);
  });

  test('undo removes last stroke; clear empties', () {
    final c = WhiteboardController();
    c.startStroke(const Offset(0, 0));
    c.startStroke(const Offset(1, 1));
    c.undo();
    expect(c.strokes.length, 1);
    c.clear();
    expect(c.isEmpty, isTrue);
  });

  test('notifies listeners on mutation', () {
    final c = WhiteboardController();
    var n = 0;
    c.addListener(() => n++);
    c.startStroke(const Offset(0, 0)); // 1
    c.addPoint(const Offset(1, 1)); // 2
    c.startStroke(const Offset(2, 2)); // 3
    c.clear(); // 4 (non-empty -> notifies)
    expect(n, 4);
    // 空画布上的 clear/undo 不再触发通知
    c.clear();
    c.undo();
    expect(n, 4);
  });

  group('collaboration serialization', () {
    test('toJson normalizes to 0-1; fromJson restores on different canvas', () {
      final stroke = WhiteboardStroke(
        color: const Color(0xFFE53935),
        width: 6,
        points: const [Offset(100, 200), Offset(400, 800)],
      );
      final json = stroke.toJson(const Size(400, 800));
      final points = json['points'] as List;
      // 归一化：(100/400, 200/800) = (0.25, 0.25)；(400/400, 800/800) = (1,1)
      expect((points[0] as List)[0], closeTo(0.25, 1e-6));
      expect((points[0] as List)[1], closeTo(0.25, 1e-6));
      expect((points[1] as List)[0], closeTo(1.0, 1e-6));

      // 在 2x 尺寸画布上还原：坐标按比例放大（跨设备尺寸无关）
      final restored = WhiteboardStroke.fromJson(json, const Size(800, 1600))!;
      expect(restored.points.first.dx, closeTo(200, 0.5));
      expect(restored.points.first.dy, closeTo(400, 0.5));
      expect(restored.points.last.dx, closeTo(800, 0.5));
      expect(restored.color.toARGB32(), 0xFFE53935);
      expect(restored.width, 6);
    });

    test('fromJson rejects malformed payloads', () {
      const canvas = Size(400, 800);
      expect(WhiteboardStroke.fromJson({}, canvas), isNull);
      expect(WhiteboardStroke.fromJson({'points': <Object>[]}, canvas), isNull);
      expect(
        WhiteboardStroke.fromJson({
          'points': [
            ['bad', null],
          ],
        }, canvas),
        isNull,
      );
    });

    test('remote stroke mid-draw does not steal local sample points', () {
      // 复审 P1:双方同时作画——本地落笔→远端整笔插入→本地继续移动,
      // 本地点必须仍进本地笔画,不能串进远端笔画。
      final c = WhiteboardController(color: const Color(0xFF222222));
      c.startStroke(const Offset(0, 0));
      c.addPoint(const Offset(1, 1));
      // 远端一整笔到达(插到 _strokes 末尾)
      c.addRemoteStroke(
        WhiteboardStroke(
          color: const Color(0xFF1E88E5),
          width: 8,
          points: const [Offset(9, 9), Offset(10, 10)],
        ),
      );
      // 本地继续移动
      c.addPoint(const Offset(2, 2));
      // 本地笔画应有 3 点(0,0)(1,1)(2,2);远端笔画仍是 2 点
      final local = c.strokes[0];
      final remote = c.strokes[1];
      expect(local.color, const Color(0xFF222222));
      expect(local.points.length, 3);
      expect(local.points.last, const Offset(2, 2));
      expect(remote.color, const Color(0xFF1E88E5));
      expect(remote.points.length, 2);
      // 抬笔后再画另起一笔
      c.endLocalStroke();
      c.addPoint(const Offset(5, 5));
      expect(c.strokes.length, 3);
      expect(c.strokes.last.points.single, const Offset(5, 5));
    });

    test('addRemoteStroke appends without touching local pen state', () {
      final c = WhiteboardController(color: const Color(0xFF222222));
      c.startStroke(const Offset(1, 1));
      final remote = WhiteboardStroke(
        color: const Color(0xFF1E88E5),
        width: 8,
        points: const [Offset(5, 5), Offset(6, 6)],
      );
      c.addRemoteStroke(remote);
      expect(c.strokes.length, 2);
      expect(c.strokes.last.color, const Color(0xFF1E88E5));
      expect(c.color, const Color(0xFF222222)); // 本端画笔颜色不受影响
      // 空远端笔画被忽略
      c.addRemoteStroke(
        WhiteboardStroke(color: const Color(0xFF000000), width: 2),
      );
      expect(c.strokes.length, 2);
    });
  });
}
