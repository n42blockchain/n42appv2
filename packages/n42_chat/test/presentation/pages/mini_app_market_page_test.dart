import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/mini_app_entity.dart';
import 'package:n42_chat/src/presentation/pages/mini_app/mini_app_market_page.dart';

void main() {
  testWidgets(
    'MiniAppMarketPage builds every category tab without controller mismatch',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MiniAppMarketPage(roomId: '!room:server')),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Commerce'), findsWidgets);
      expect(find.text('Social'), findsOneWidget);
      expect(
        find.byType(Tab),
        findsNWidgets(MiniAppCategory.values.length + 1),
      );
    },
  );
}
