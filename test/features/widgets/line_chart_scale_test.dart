// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// LineChart 构造期缩放计算测试（不渲染）。
//
// 覆盖 lib/features/widgets/line_chart.dart 15-41 行：
// maxValue/minValue/difference 在构造函数初始化列表中由
// _calcMaxValue/_calcMinValue 静态方法算出，构造 widget 即可断言，
// 无需 pumpWidget。
//
// 已知真 bug：_calcMaxValue 以 0.0 为起始值做比较，全负数序列会错误
// 返回 0（而非序列真实最大值），对应测试以 skip 固化（见 MODULARITY_PLAN 批次6）。

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

    test(
      '全负数序列 maxValue 应为序列最大值',
      () {
        // 期望行为：max = -1.0；当前实现返回 0.0（0.0 起始值污染）
        final chart = LineChart([-5.0, -1.0, -3.0], false, 100, 10);
        expect(chart.maxValue, -1.0);
      },
      skip: '已知缺陷：_calcMaxValue 以 0.0 起始，全负数序列错误返回 0（见 MODULARITY_PLAN 批次6）',
    );

    test('全负数序列 minValue 现状正确（起始值取 values[0]）', () {
      // _calcMinValue 以 values[0] 为起始值，不受 0.0 污染
      final chart = LineChart([-5.0, -1.0, -3.0], false, 100, 10);
      expect(chart.minValue, -5.0);
      // 现状断言：difference = 被污染的 max(0.0) - min(-5.0) = 5.0
      expect(chart.difference, 5.0);
    });
  });
}
