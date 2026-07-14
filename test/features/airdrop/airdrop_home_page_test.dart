import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/airdrop/pages/airdrop_home_page.dart';
import 'package:n42_wallet/features/airdrop/services/airdrop_service.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('keeps trusted source directories available without campaigns', (
    tester,
  ) async {
    final service = AirdropService(
      client: MockClient(
        (_) async => http.Response('{"code":200,"data":[]}', 200),
      ),
      baseUrl: 'https://test',
    );

    await tester.pumpWidget(
      wrapForTest(AirdropHomePage(walletAddress: '', service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No verified campaigns available'), findsOneWidget);
    await tester.tap(find.text('Sources'));
    await tester.pumpAndSettle();
    expect(find.text('CoinMarketCap'), findsOneWidget);
    expect(find.text('Galxe'), findsOneWidget);

    service.dispose();
  });
}
