import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/widgets/item_mining_node.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('long RPC endpoints fit in a narrow node option', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    await tester.pumpWidget(
      wrapForTest(
        Center(
          child: SizedBox(
            width: 330,
            child: ItemMiningNode(
              countryName: 'USA',
              nodeAddress: 'https://rpc.n42.world',
              socketUrl: 'wss://ws.n42.world',
              icon: '',
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('USA'), findsOneWidget);
    expect(find.text('https://rpc.n42.world'), findsOneWidget);
    expect(find.text('wss://ws.n42.world'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ItemMiningNode));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unselected node uses spacing instead of the selected marker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapForTest(
        Center(
          child: SizedBox(
            width: 330,
            child: const ItemMiningNode(
              countryName: 'Canada',
              nodeAddress: 'https://node.example',
              socketUrl: 'wss://socket.example',
              icon: '',
              isSelected: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Canada'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
