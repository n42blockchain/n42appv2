import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _UninitializedWalletProvider extends WalletActionProvider {
  @override
  bool get isWalletReady => false;

  @override
  Future<void> initWallet({bool shouldInitCoinInfo = false}) async {}

  @override
  void refresh() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('wallet home shows loading until the selected wallet is ready', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapForTest(
        const WalletPage(),
        overrides: [
          wapBridgeProvider.overrideWith(
            (ref) => _UninitializedWalletProvider(),
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
