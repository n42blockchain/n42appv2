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
}
