import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_trx.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

CoinModel _coin() => CoinModel()
  ..coin = {'coinType': 'TRX', 'unit': 'TRX', 'decimals': 6}
  ..address = 'Towner-address';

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
  testWidgets('confirmed transaction renders explorer details', (tester) async {
    _setPhoneViewport(tester);
    String? requestedHash;
    String? requestedAddress;
    Future<MessageModel> lookup(String hash, {bool isTest = false}) async {
      requestedHash = hash;
      expect(isTest, isFalse);
      return _result({
        'hash': hash,
        'confirmed': true,
        'block': 98765,
        'ownerAddress': 'Towner-address',
        'toAddress': 'Trecipient-address',
        'amount': 2500000,
        'cost': {'net_fee_cost': 3500, 'fee': 42000},
      });
    }

    await tester.pumpWidget(
      _app(
        TransactionDetailTrx(
          _coin(),
          'tx-confirmed',
          transactionLookupForTesting: lookup,
          recordLoaderForTesting: (hash, address) async {
            expect(hash, 'tx-confirmed');
            requestedAddress = address;
            return [];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedHash, 'tx-confirmed');
    expect(requestedAddress, 'Towner-address');
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('tx-confirmed'), findsNWidgets(2));
    expect(find.text('98765'), findsOneWidget);
    expect(find.text('2.5 TRX'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('transaction error can be retried into a loaded result', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    var requests = 0;
    Future<MessageModel> lookup(String hash, {bool isTest = false}) async {
      requests++;
      if (requests == 1) return _result('server unavailable', error: true);
      return _result({
        'hash': hash,
        'confirmed': true,
        'block': 8,
        'ownerAddress': 'Towner-address',
        'toAddress': 'Trecipient-address',
        'amount': 1000000,
        'cost': {'net_fee_cost': 10, 'fee': 20},
      });
    }

    await tester.pumpWidget(
      _app(
        TransactionDetailTrx(
          _coin(),
          'tx-retry',
          transactionLookupForTesting: lookup,
          recordLoaderForTesting: (_, _) async => [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('server unavailable'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('server unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending transaction polls until the API confirms it', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    var requests = 0;
    Future<MessageModel> lookup(String hash, {bool isTest = false}) async {
      requests++;
      return _result({
        'hash': hash,
        'confirmed': requests > 1,
        'block': 9,
        'ownerAddress': 'Towner-address',
        'toAddress': 'Trecipient-address',
        'amount': 1000000,
        'cost': {'net_fee_cost': 10, 'fee': 20},
      });
    }

    await tester.pumpWidget(
      _app(
        TransactionDetailTrx(
          _coin(),
          'tx-pending',
          transactionLookupForTesting: lookup,
          recordLoaderForTesting: (_, _) async => [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pending'), findsOneWidget);
    expect(requests, 1);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(requests, 2);
    expect(find.text('Success'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty transaction hash does not call the explorer API', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    var requests = 0;
    await tester.pumpWidget(
      _app(
        TransactionDetailTrx(
          _coin(),
          '',
          transactionLookupForTesting: (_, {bool isTest = false}) async {
            requests++;
            return _result(null);
          },
          recordLoaderForTesting: (_, _) async => [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(requests, 0);
    expect(find.byIcon(Icons.open_in_browser_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
