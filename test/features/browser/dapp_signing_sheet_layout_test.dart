import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/widgets/dapp_signing_sheet.dart';

import '../../helpers/widget_test_helpers.dart';

/// 真机四测发现：签名弹窗的批准/拒绝按钮会超出 iPhone 可视区域，用户无法
/// 批准或拒绝请求。根因是风险横幅位于 Flexible 之外、高度不受限，会把可滚动
/// 区压到 0 并把底部按钮顶出屏幕；且底部缺 SafeArea，home indicator 还会再
/// 遮住一截。此处以小屏 + 超长内容锁定该回归。
void main() {
  /// 断言两个按钮都完整落在屏幕内。
  Future<void> expectButtonsVisible(WidgetTester tester) async {
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    for (final label in ['Cancel', 'Confirm', '取消', '确认']) {
      final finder = find.text(label);
      if (finder.evaluate().isEmpty) continue;
      final rect = tester.getRect(finder.first);
      expect(
        rect.bottom <= screen.height,
        isTrue,
        reason: '按钮 "$label" 底部 ${rect.bottom} 超出屏幕高度 ${screen.height}',
      );
      expect(rect.top >= 0, isTrue, reason: '按钮 "$label" 顶部超出屏幕上沿');
    }
    // 至少要能找到一个可点击的确认控件，否则说明按钮压根没被布局出来。
    expect(find.byType(ElevatedButton).evaluate().isNotEmpty ||
        find.byType(TextButton).evaluate().isNotEmpty ||
        find.byType(InkWell).evaluate().isNotEmpty, isTrue);
  }

  Future<void> pumpSheet(
    WidgetTester tester, {
    required String method,
    required Map<String, dynamic> details,
    Size size = const Size(390, 664), // iPhone 逻辑分辨率，偏矮以逼近临界
  }) async {
    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      wrapForTest(
        Align(
          alignment: Alignment.bottomCenter,
          child: DAppSigningSheet(
            origin: 'https://app.uniswap.org',
            method: method,
            details: details,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DAppSigningSheet 布局', () {
    testWidgets('超长 calldata 交易：按钮仍在可视区域内', (tester) async {
      await pumpSheet(
        tester,
        method: 'eth_sendTransaction',
        details: {
          'from': '0x1111111111111111111111111111111111111111',
          'to': '0x2222222222222222222222222222222222222222',
          'value': '0xde0b6b3a7640000',
          'data': '0x095ea7b3${'f' * 400}',
        },
      );
      await expectButtonsVisible(tester);
    });

    testWidgets('超长 personal_sign 文本：按钮仍在可视区域内', (tester) async {
      await pumpSheet(
        tester,
        method: 'personal_sign',
        details: {'message': 'A' * 3000},
      );
      await expectButtonsVisible(tester);
    });

    testWidgets('连接授权：按钮在可视区域内且不显示签名数据', (tester) async {
      await pumpSheet(
        tester,
        method: 'eth_requestAccounts',
        details: {
          'address': '0x1111111111111111111111111111111111111111',
          'chainId': '0x1',
        },
      );
      await expectButtonsVisible(tester);
      // 连接授权不应渲染 "Method"/"Data" 这类签名字段
      expect(find.text('Method'), findsNothing);
      expect(find.text('Data'), findsNothing);
    });

    testWidgets('内容不超高时也不应溢出', (tester) async {
      await pumpSheet(
        tester,
        method: 'personal_sign',
        details: {'message': 'hello'},
      );
      await expectButtonsVisible(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
