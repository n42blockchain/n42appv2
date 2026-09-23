import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _ConfirmationHost extends StatefulWidget {
  const _ConfirmationHost({required this.transaction});

  final BtcTransactionRecodeModel transaction;

  @override
  State<_ConfirmationHost> createState() => _ConfirmationHostState();
}

class _ConfirmationHostState extends State<_ConfirmationHost> {
  bool? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            key: const ValueKey('open-btc-confirmation'),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WalletBaseSend(null, widget.transaction, 'BTC'),
                ),
              );
              if (mounted) setState(() => _result = result);
            },
            child: const Text('Open confirmation'),
          ),
          Text('result: $_result'),
        ],
      ),
    );
  }
}

BtcTransactionRecodeModel _transaction() => BtcTransactionRecodeModel()
  ..address = 'bc1qsenderaddress'
  ..to1 = 'bc1qrecipientaddress'
  ..price = 125000000
  ..gasPrice = 2500
  ..coin = {
    'coinType': 'BTC',
    'blockchainType': 'Bitcoin',
    'unit': 'BTC',
    'decimals': 8,
  };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets(
    'Bitcoin confirmation shows transfer and fee and cancel returns false',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(_ConfirmationHost(transaction: _transaction())),
      );
      await tester.tap(find.byKey(const ValueKey('open-btc-confirmation')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(WalletBaseSend));
      final strings = S.of(context);
      expect(find.text('1.25 BTC'), findsOneWidget);
      expect(find.text('0.000025 BTC'), findsOneWidget);
      expect(find.text(strings.g_key_sim_unavailable), findsOneWidget);
      expect(find.text(strings.g_key_79), findsOneWidget);

      await tester.tap(find.text(strings.g_key_79));
      await tester.pumpAndSettle();

      expect(find.text('result: false'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
