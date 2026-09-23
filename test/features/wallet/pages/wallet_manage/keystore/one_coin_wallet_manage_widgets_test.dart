import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../../helpers/widget_test_helpers.dart';

CoinModel _coin() => CoinModel()
  ..coin = {
    'coinType': 'ETH',
    'blockchainType': 'Ethereum',
    'name': 'Ethereum',
    'miniName': 'ETH',
    'path': {'legacy': "m/44'/60'/0'/0"},
  }
  ..addrType = 'legacy'
  ..address = '0x1234567890123456789012345678901234567890';

WalletInfo _wallet({required String? privateKey, required String? password}) =>
    WalletInfo(
      mnemonic: 'test mnemonic is not used by these display-only cases',
      privateKey: privateKey,
      password: password,
      coinInfo: {
        'ETH': {
          'addrType': 'legacy',
          'baseInfo': {
            'path': {'legacy': "m/44'/60'/0'/0"},
          },
          'pathList': [0],
          'pathIndex': 0,
        },
      },
    );

Future<void> _mount(
  WidgetTester tester, {
  required String? privateKey,
  required String? password,
}) async {
  await tester.pumpWidget(
    wrapForTest(
      OneCoinWalletManage(
        walletInfo: _wallet(privateKey: privateKey, password: password),
        model: _coin(),
        walletIndex: 0,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'mnemonic wallet offers keystore export and password-gated key export',
    (tester) async {
      await _mount(tester, privateKey: null, password: 'wallet-password');

      expect(find.text(S.current.g_key_ex_keystore), findsOneWidget);
      expect(find.text(S.current.g_key_ex_keystore_19), findsOneWidget);
      expect(find.text(S.current.g_key_181), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mnemonic wallet without a password hides private-key export', (
    tester,
  ) async {
    await _mount(tester, privateKey: null, password: '');

    expect(find.text(S.current.g_key_ex_keystore), findsOneWidget);
    expect(find.text(S.current.g_key_ex_keystore_19), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'raw private-key wallet does not show mnemonic keystore exports',
    (tester) async {
      await _mount(
        tester,
        privateKey: '0xprivate-key',
        password: 'wallet-password',
      );

      expect(find.text(S.current.g_key_181), findsNothing);
      expect(find.text(S.current.g_key_ex_keystore), findsNothing);
      expect(find.text(S.current.g_key_ex_keystore_19), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
