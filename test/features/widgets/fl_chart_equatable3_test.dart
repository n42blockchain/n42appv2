import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bar chart data keeps value equality with Equatable 3', () {
    BarChartGroupData group(double value) =>
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: value)]);

    final first = group(2);
    final same = group(2);
    final changed = group(3);

    expect(first, isA<Equatable>());
    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(changed));
  });

  testWidgets('bar chart renders from value-equal data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 160,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2)]),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(BarChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('line and pie chart data keep equality and detect changed values', () {
    LineChartData line(double y) => LineChartData(
      lineBarsData: [
        LineChartBarData(spots: [FlSpot(0, y), const FlSpot(1, 4)]),
      ],
    );
    PieChartData pie(double value) =>
        PieChartData(sections: [PieChartSectionData(value: value)]);

    for (final (first, equal, changed) in [
      (line(2), line(2), line(3)),
      (pie(2), pie(2), pie(3)),
    ]) {
      expect(first, isA<Equatable>());
      expect(first, equal);
      expect(first.hashCode, equal.hashCode);
      expect(first, isNot(changed));
    }
  });

  testWidgets('line and pie charts render with Equatable 3 data', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 240,
                height: 160,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 2), FlSpot(1, 4)],
                      ),
                    ],
                  ),
                  duration: Duration.zero,
                ),
              ),
              SizedBox(
                width: 240,
                height: 160,
                child: PieChart(
                  PieChartData(sections: [PieChartSectionData(value: 2)]),
                  duration: Duration.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
