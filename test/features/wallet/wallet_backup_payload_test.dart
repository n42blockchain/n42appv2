import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/utils/wallet_backup_payload.dart';

void main() {
  group('walletInfoToBackupPayload / walletInfoFromBackupPayload', () {
    test('round-trips full wallet metadata and rewrites UUID', () {
      final wallet =
          WalletInfo(
              walletName: 'Account 1',
              mnemonic: 'alpha beta gamma',
              password: 'secret123',
              privateKey: 'encoded-private-key',
              walletUuid: 'old-user',
              timestamp: '12345',
              coinInfo: {
                CoinType.N.name: {
                  'baseInfo': {'coinType': CoinType.N.name},
                  'addrType': 'legacy',
                },
              },
            )
            ..mainWallet = true
            ..watchOnly = false
            ..watchAddress = ''
            ..chainOrder = [CoinType.N.name]
            ..pinnedCoins = ['N'];

      final payload = walletInfoToBackupPayload(wallet);
      final restored = walletInfoFromBackupPayload(
        payload,
        userUUID: 'new-user',
      );

      expect(restored.walletName, 'Account 1');
      expect(restored.password, 'secret123');
      expect(restored.timestamp, '12345');
      expect(restored.walletUuid, 'new-user');
      expect(restored.coinInfo?[CoinType.N.name], isNotNull);
      expect(restored.mainWallet, isTrue);
      expect(restored.chainOrder, [CoinType.N.name]);
      expect(restored.pinnedCoins, ['N']);
    });

    test(
      'restores legacy mnemonic backup by falling back to default chain map',
      () {
        final restored = walletInfoFromBackupPayload({
          'walletName': 'Legacy Account',
          'mnemonic': 'alpha beta gamma',
          'timestamp': '999',
        }, userUUID: 'user-1');

        expect(restored.walletName, 'Legacy Account');
        expect(restored.walletUuid, 'user-1');
        expect(restored.coinInfo, isNotEmpty);
        expect(restored.coinInfo?[CoinType.N.name], isNotNull);
      },
    );

    test(
      'restores legacy private-key backup when primary coin type is present',
      () {
        final restored = walletInfoFromBackupPayload({
          'walletName': 'Imported ETH',
          'privateKey': 'encoded-private-key',
          'primaryCoinType': CoinType.ETH.name,
        }, userUUID: 'user-1');

        expect(restored.privateKey, 'encoded-private-key');
        expect(restored.coinInfo?.keys, [CoinType.ETH.name]);
      },
    );

    test('rejects payloads with no recoverable credentials', () {
      expect(
        () => walletInfoFromBackupPayload({
          'walletName': 'Broken',
        }, userUUID: 'user-1'),
        throwsFormatException,
      );
    });
  });
}
