import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _InitializedWalletProvider extends WalletActionProvider {
  @override
  WalletInfo get walletInfo => WalletInfo(password: '');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  BtcTransactionRecodeModel makeBitcoinTransfer() => BtcTransactionRecodeModel()
    ..address = 'bc1qsender000000000000000000000000000000000'
    ..to1 = 'bc1qrecipient00000000000000000000000000000000'
    ..price = 125000000
    ..gasPrice = 2500
    ..coin = {
      'coinType': 'BTC',
      'blockchainType': 'Bitcoin',
      'unit': 'BTC',
      'decimals': 8,
    };

  TransationRecordModel makePolkadotTransfer() => TransationRecordModel()
    ..from1 = '1senderAddress'
    ..to1 = '1recipientAddress'
    ..price = BigInt.from(125000000)
    ..gasPrice = BigInt.from(2500)
    ..coin = {
      'coinType': 'DOT',
      'blockchainType': 'Polkadot',
      'unit': 'DOT',
      'decimals': 10,
    };

  testWidgets('review shows Bitcoin sender, recipient, amount, and miner fee', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(WalletBaseSend(null, makeBitcoinTransfer(), 'BTC')),
    );
    await tester.pumpAndSettle();

    expect(find.text('bc1qsender...00000000'), findsOneWidget);
    expect(find.text('bc1qrecipi...00000000'), findsOneWidget);
    expect(find.text('1.25 BTC'), findsOneWidget);
    expect(find.text('0.000025 BTC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel returns false to the send flow', (tester) async {
    bool? result;
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            key: const Key('open-review'),
            onPressed: () async {
              result = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (_) =>
                      WalletBaseSend(null, makeBitcoinTransfer(), 'BTC'),
                ),
              );
            },
            child: const Text('Open review'),
          ),
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _InitializedWalletProvider()),
        ],
      ),
    );
    await tester.tap(find.byKey(const Key('open-review')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.byType(WalletBaseSend), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-EVM review renders transaction model and resource fee', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(WalletBaseSend(makePolkadotTransfer(), null, 'DOT')),
    );
    await tester.pumpAndSettle();

    expect(find.text('1senderAddress'), findsOneWidget);
    expect(find.text('1recipientAddress'), findsOneWidget);
    expect(find.text('0.0125 DOT'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continue opens wallet security verification', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            key: const Key('open-review'),
            onPressed: () => Navigator.push<bool>(
              context,
              MaterialPageRoute<bool>(
                builder: (_) =>
                    WalletBaseSend(null, makeBitcoinTransfer(), 'BTC'),
              ),
            ),
            child: const Text('Open review'),
          ),
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _InitializedWalletProvider()),
        ],
      ),
    );
    await tester.tap(find.byKey(const Key('open-review')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(WalletSecurityVerification), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
