import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../helpers/widget_test_helpers.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

class _Storage {
  bool fail = false;
  Map<String, dynamic>? saved;
  Future<void> write(WalletInfo info, int index) async {
    if (fail) throw StateError('disk unavailable');
    saved = info.toJson();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('asset controls disclose local scope and persist hide choice', (
    tester,
  ) async {
    final storage = _Storage();
    final wallet = WalletActionProvider(assetVisibilityWriter: storage.write)
      ..walletInfoLsit.add(WalletInfo())
      ..walletIndex = 0;
    final coin = CoinModel()
      ..coin = {
        'coinType': 'ETH',
        'chainId': 1,
        'miniName': 'ETH',
        'name': 'Ethereum',
        'unit': 'ETH',
        'decimals': 18,
      };
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinItem(coinInfo: coin, itemKey: 'test', group: 'test'),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('wallet_coin_open_test')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Hiding does not revoke approvals'),
      findsOneWidget,
    );
    await tester.tap(find.text('Hide from list'));
    await tester.pumpAndSettle();
    expect(wallet.assetVisibilityState(coin), 'hidden');
    expect(tester.takeException(), isNull);
  });
  test(
    'all display states persist, restore, and remain wallet/network scoped',
    () async {
      final storage = _Storage();
      final wallet = WalletActionProvider(assetVisibilityWriter: storage.write)
        ..walletInfoLsit.add(WalletInfo())
        ..walletIndex = 0;
      addTearDown(wallet.dispose);
      final coin = CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'chainId': 1,
          'contract': '0x${'ab' * 20}',
          'miniName': 'TEST',
        };
      for (final state in ['warning', 'hidden', 'quarantined']) {
        expect(await wallet.setAssetVisibility(coin, state), isTrue);
        expect(wallet.assetVisibilityState(coin), state);
        final restored = WalletInfo.fromJson(storage.saved!);
        expect(
          (restored.assetVisibility.values.single as Map)['source'],
          'User choice',
        );
        coin.isTest = true;
        expect(wallet.assetVisibilityState(coin), 'visible');
        coin.isTest = false;
        expect(
          await wallet.restoreAssetVisibility(wallet.assetVisibilityKey(coin)),
          isTrue,
        );
        expect(wallet.assetVisibilityState(coin), 'visible');
      }
      await wallet.setAssetVisibility(coin, 'hidden');
      wallet.walletInfoLsit.add(WalletInfo());
      wallet.walletIndex = 1;
      expect(wallet.assetVisibilityState(coin), 'visible');
    },
  );
  test(
    'storage failure rolls back preference instead of claiming saved',
    () async {
      final storage = _Storage();
      final wallet = WalletActionProvider(assetVisibilityWriter: storage.write)
        ..walletInfoLsit.add(WalletInfo())
        ..walletIndex = 0;
      addTearDown(wallet.dispose);
      final coin = CoinModel()
        ..coin = {'coinType': 'ETH', 'chainId': 1, 'miniName': 'ETH'};
      storage.fail = true;
      expect(await wallet.setAssetVisibility(coin, 'hidden'), isFalse);
      expect(wallet.assetVisibilityState(coin), 'visible');
      storage.fail = false;
      await wallet.setAssetVisibility(coin, 'hidden');
      storage.fail = true;
      expect(
        await wallet.restoreAssetVisibility(wallet.assetVisibilityKey(coin)),
        isFalse,
      );
      expect(wallet.assetVisibilityState(coin), 'hidden');
    },
  );
}
