import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

const _owner = '0x0000000000000000000000000000000000000001';
const _recipient = '0x0000000000000000000000000000000000000002';
final _hash = '0x${List<String>.filled(64, 'a').join()}';

CoinModel _coin() => CoinModel()
  ..coin = {
    'coinType': 'N42',
    'blockchainType': 'Ethereum',
    'unit': 'N42',
    'decimals': 18,
    'chainId': 4242,
    'contract': '',
  }
  ..address = _owner
  ..balance = BigInt.from(3);

TransationRecordModel _record() => TransationRecordModel()
  ..address = _owner
  ..from1 = _owner
  ..to1 = _recipient
  ..txHash = _hash
  ..message = 'local transfer note'
  ..contract = '';

MessageModel _result(dynamic data, {bool error = false}) => MessageModel()
  ..error = error
  ..data = data;

Widget _app(Widget child) => ScreenUtilInit(
  designSize: const Size(360, 800),
  builder: (context, child) => MaterialApp(
    theme: ThemeData.light(),
    localizationsDelegates: const [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: child,
  ),
  child: child,
);

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('confirmed local transaction displays its detail sections', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        TransactionDetailEth(
          _coin(),
          _hash,
          recordLoaderForTesting: (_, _) async => [_record()],
          transactionLookupForTesting:
              (hash, {coinType, isTest = false}) async {
                expect(hash, _hash);
                expect(coinType, 'N42');
                expect(isTest, isFalse);
                return _result({
                  'hash': _hash,
                  'blockHash': '0xblock',
                  'from': _owner,
                  'to': _recipient,
                  'gas': '0x5208',
                  'gasPrice': '0x3b9aca00',
                  'nonce': '0x2',
                  'value': '0xde0b6b3a7640000',
                  'input': '0x6c6f63616c207472616e73666572206e6f7465',
                });
              },
          receiptLookupForTesting: (_, {coinType, isTest = false}) async =>
              _result({'status': '0x1'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Success'), findsOneWidget);
    expect(find.text(_hash), findsNWidgets(2));
    expect(find.text('0xblock'), findsOneWidget);
    expect(find.text('1 N42'), findsOneWidget);
    expect(find.text('21000'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('local transfer note'), findsOneWidget);
    expect(find.text('0x00000000...00000001'), findsOneWidget);
    expect(find.text('0x00000000...00000002'), findsOneWidget);
    expect(find.textContaining('speed'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed receipt renders the failed result label', (tester) async {
    _setPhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        TransactionDetailEth(
          _coin(),
          _hash,
          recordLoaderForTesting: (_, _) async => [_record()],
          transactionLookupForTesting: (_, {coinType, isTest = false}) async =>
              _result({
                'hash': _hash,
                'from': '0xexternal',
                'to': _recipient,
                'gas': '0x5208',
                'gasPrice': '0x3b9aca00',
                'nonce': '0x2',
                'value': '0x0',
                'input': '0x',
              }),
          receiptLookupForTesting: (_, {coinType, isTest = false}) async =>
              _result({'status': '0x0'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('owned pending transaction shows replace actions', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        TransactionDetailEth(
          _coin(),
          _hash,
          recordLoaderForTesting: (_, _) async => [_record()],
          transactionLookupForTesting: (_, {coinType, isTest = false}) async =>
              _result({
                'hash': _hash,
                'from': _owner,
                'to': _recipient,
                'gas': '0x5208',
                'gasPrice': '0x3b9aca00',
                'nonce': '0x2',
                'value': '0x0',
                'input': '0x',
              }),
          receiptLookupForTesting: (_, {coinType, isTest = false}) async =>
              _result(null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Unmount cancels the pending receipt poll timer before it can fire.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('invalid hash shows a retryable error without loading data', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    var calls = 0;
    await tester.pumpWidget(
      _app(
        TransactionDetailEth(
          _coin(),
          'not-a-transaction-hash',
          recordLoaderForTesting: (_, _) async {
            calls++;
            return [];
          },
          transactionLookupForTesting:
              (_, {required coinType, required isTest}) async {
                calls++;
                return _result(null);
              },
          receiptLookupForTesting:
              (_, {required coinType, required isTest}) async {
                calls++;
                return _result(null);
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid transaction hash'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(calls, 0);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Invalid transaction hash'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
