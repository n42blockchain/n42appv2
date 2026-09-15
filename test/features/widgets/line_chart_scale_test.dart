// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// LineChart 构造期缩放计算测试（不渲染）。
//
// 覆盖 lib/features/widgets/line_chart.dart 15-41 行：
// maxValue/minValue/difference 在构造函数初始化列表中由
// _calcMaxValue/_calcMinValue 静态方法算出，构造 widget 即可断言，
// 无需 pumpWidget。
//
// 历史缺陷（已修复，MODULARITY_PLAN 批次6）：_calcMaxValue 曾以 0.0 为
// 起始值做比较，全负数序列会错误返回 0；现改为以首元素起始，空列表
// 保持返回 0.0 的现状语义。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/line_chart.dart';

void main() {
  group('LineChart 构造期 max/min/difference 计算', () {
    test('混合正数序列：max/min/difference 正确', () {
      final chart = LineChart([1.0, 5.0, 3.0, 2.5], true, 100, 10);
      expect(chart.maxValue, 5.0);
      expect(chart.minValue, 1.0);
      expect(chart.difference, 4.0);
    });

    test('int 与 double 混合序列（List<dynamic> 输入）正确换算', () {
      final chart = LineChart([2, 7.5, 4], true, 100, 10);
      expect(chart.maxValue, 7.5);
      expect(chart.minValue, 2.0);
      expect(chart.difference, 5.5);
    });

    test('全等值序列：difference == 0', () {
      final chart = LineChart([3.0, 3.0, 3.0], false, 100, 10);
      expect(chart.maxValue, 3.0);
      expect(chart.minValue, 3.0);
      expect(chart.difference, 0.0);
    });

    test('单元素序列：max == min == 元素值，difference == 0', () {
      final chart = LineChart([7.0], true, 100, 10);
      expect(chart.maxValue, 7.0);
      expect(chart.minValue, 7.0);
      expect(chart.difference, 0.0);
    });

    test('空列表：现状断言 max/min/difference 均为 0', () {
      // 现状：_calcMaxValue/_calcMinValue 对空列表都返回起始值 0.0
      final chart = LineChart([], true, 100, 10);
      expect(chart.maxValue, 0.0);
      expect(chart.minValue, 0.0);
      expect(chart.difference, 0.0);
    });

    test('负数与正数混合：min 取到负值', () {
      final chart = LineChart([-2.0, 1.0, 3.0], false, 100, 10);
      expect(chart.maxValue, 3.0);
      expect(chart.minValue, -2.0);
      expect(chart.difference, 5.0);
    });

    test('全负数序列 maxValue 为序列最大值（修复后不再被 0.0 起始值污染）', () {
      final chart = LineChart([-5.0, -1.0, -3.0], false, 100, 10);
      expect(chart.maxValue, -1.0);
    });

    test('全负数序列 minValue 正确（起始值取 values[0]）', () {
      final chart = LineChart([-5.0, -1.0, -3.0], false, 100, 10);
      expect(chart.minValue, -5.0);
      // 修复后：difference = max(-1.0) - min(-5.0) = 4.0
      expect(chart.difference, 4.0);
    });
  });

  group('LineChart paint 期除零保护（真实渲染）', () {
    Future<void> pumpChart(WidgetTester tester, List<dynamic> values) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, child: LineChart(values, true, 100, 10)),
          ),
        ),
      );
    }

    testWidgets('全等值序列（difference==0）渲染不抛异常', (tester) async {
      await pumpChart(tester, [3.0, 3.0, 3.0]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('单元素序列（unitWidth 除零场景）渲染不抛异常', (tester) async {
      await pumpChart(tester, [7.0]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('空列表渲染不抛异常', (tester) async {
      await pumpChart(tester, []);
      expect(tester.takeException(), isNull);
    });
  });
}
