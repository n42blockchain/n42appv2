import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('empty NFT gallery keeps search clear interaction available', (
    tester,
  ) async {
    final coin = CoinModel.fromJson({
      'coin': {'coinType': 'UNSUPPORTED'},
      'address': 'fixture-address',
    });

    await tester.pumpWidget(wrapForTest(NftListPage(coin)));
    await tester.pumpAndSettle();

    final pageContext = tester.element(find.byType(NftListPage));
    expect(find.text(S.of(pageContext).g_key_nft_no_items), findsOneWidget);
    expect(find.byIcon(Icons.collections_outlined), findsOneWidget);

    final search = find.byType(TextField);
    await tester.enterText(search, 'art');
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsNothing);
    expect(find.text(S.of(pageContext).g_key_nft_no_items), findsOneWidget);
  });
}
