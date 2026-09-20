import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';
import 'package:n42_wallet/features/payments/presentation/local_payment_lab_page.dart';

const tokenA = 'synthetic-test-accounta';
const tokenB = 'synthetic-test-accountb';

http.Response balance(String amount) => http.Response(
  jsonEncode({
    'mode': 'localSimulation',
    'asset': 'test-usdc',
    'available': amount,
  }),
  200,
);

http.Response receipt(http.Request request) => http.Response(
  jsonEncode({
    'mode': 'localSimulation',
    'id': 'transfer_${List.filled(64, 'a').join()}',
    ...jsonDecode(request.body) as Map<String, dynamic>,
  }),
  200,
);

Finder key(String name) => find.byKey(ValueKey('lab_$name'));

Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.drag(find.byType(ListView), const Offset(0, 2500));
    await tester.pump();
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pump();
}

Future<void> enter(WidgetTester tester, String name, String value) async {
  await reveal(tester, key(name));
  await tester.enterText(key(name), value);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, String name) async {
  await reveal(tester, key(name));
  await tester.tap(key(name));
  await tester.pump();
}

Future<LocalPaymentClient> open(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) handler, {
  double scale = 1,
  bool enabled = true,
}) async {
  final transport = MockClient(handler);
  final client = LocalPaymentClient(
    endpoint: Uri.parse('http://127.0.0.1:8765'),
    transport: transport,
    enabled: enabled,
  );
  addTearDown(transport.close);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: LocalPaymentLabPage(client: client),
    ),
  );
  return client;
}

Future<void> activate(WidgetTester tester) async {
  await reveal(tester, key('token'));
  expect(tester.widget<TextField>(key('token')).controller!.text, isEmpty);
  await enter(tester, 'token', tokenA);
  await tap(tester, 'activate');
  await enter(tester, 'asset', 'test-usdc');
  await enter(tester, 'recipient', 'b');
  await enter(tester, 'amount', '25');
}

void main() {
  testWidgets(
    'busy transfer sends once, shows synthetic receipt and fresh balance',
    (tester) async {
      final pending = Completer<http.Response>();
      final requests = <http.Request>[];
      await open(tester, (request) async {
        requests.add(request);
        return request.method == 'POST' ? pending.future : balance('75');
      });
      expect(find.text('Local simulation / synthetic funds'), findsOneWidget);
      await activate(tester);
      await tap(tester, 'transfer');
      await tap(tester, 'transfer');
      expect(requests.where((r) => r.method == 'POST'), hasLength(1));
      expect(tester.widget<FilledButton>(key('transfer')).onPressed, isNull);
      expect(tester.widget<TextField>(key('amount')).enabled, isFalse);
      final transfer = requests.single;
      expect(transfer.headers['Authorization'], 'Bearer $tokenA');
      expect(jsonDecode(transfer.body), {
        'recipient': 'b',
        'asset': 'test-usdc',
        'amount': '25',
      });
      pending.complete(receipt(transfer));
      await tester.pumpAndSettle();
      await reveal(
        tester,
        find.text('Simulated transfer receipt — synthetic funds only'),
      );
      expect(
        find.text('Simulated transfer receipt — synthetic funds only'),
        findsOneWidget,
      );
      expect(find.text('Amount: 25 base units'), findsOneWidget);
      await reveal(tester, key('balance'));
      expect(
        find.text('Synthetic balance: 75 base units (test-usdc)'),
        findsOneWidget,
      );
      expect(requests.where((r) => r.method == 'GET'), hasLength(1));
    },
  );

  testWidgets(
    'inline failure can retry the same transfer with the same idempotency key',
    (tester) async {
      final attempts = <http.Request>[];
      await open(tester, (request) async {
        if (request.method == 'GET') return balance('75');
        attempts.add(request);
        if (attempts.length == 1) throw http.ClientException('offline');
        return receipt(request);
      });
      await activate(tester);
      await tap(tester, 'transfer');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(find.textContaining('Retry with the same inputs'), findsOneWidget);
      await tap(tester, 'transfer');
      await tester.pumpAndSettle();
      expect(attempts, hasLength(2));
      expect(
        attempts[0].headers['Idempotency-Key'],
        attempts[1].headers['Idempotency-Key'],
      );
      expect(key('error'), findsNothing);
    },
  );

  testWidgets(
    'switching accounts clears balance and ignores late old-account results',
    (tester) async {
      final oldBalance = Completer<http.Response>();
      final newBalance = Completer<http.Response>();
      await open(
        tester,
        (request) async => request.headers['Authorization'] == 'Bearer $tokenA'
            ? oldBalance.future
            : newBalance.future,
      );
      await activate(tester);
      await tap(tester, 'refresh');
      await enter(tester, 'token', tokenB);
      await tap(tester, 'activate');
      await reveal(tester, key('balance'));
      expect(find.text('Synthetic balance: not loaded'), findsOneWidget);
      newBalance.complete(balance('200'));
      await tester.pumpAndSettle();
      oldBalance.complete(balance('999'));
      await tester.pumpAndSettle();
      expect(
        find.text('Synthetic balance: 200 base units (test-usdc)'),
        findsOneWidget,
      );
      expect(find.textContaining('999 base units'), findsNothing);
      expect(key('error'), findsNothing);
    },
  );

  testWidgets(
    'account switch clears previous receipt and invalid token disables session',
    (tester) async {
      await open(
        tester,
        (request) async =>
            request.method == 'POST' ? receipt(request) : balance('75'),
      );
      await activate(tester);
      await tap(tester, 'transfer');
      await tester.pumpAndSettle();
      await reveal(
        tester,
        find.text('Simulated transfer receipt — synthetic funds only'),
      );
      await enter(tester, 'token', 'not-a-synthetic-token');
      await tap(tester, 'activate');
      await tester.pumpAndSettle();
      expect(find.text('No synthetic account active'), findsOneWidget);
      await reveal(tester, key('balance'));
      expect(find.text('Synthetic balance: not loaded'), findsOneWidget);
      await reveal(tester, key('transfer'));
      expect(tester.widget<FilledButton>(key('transfer')).onPressed, isNull);
      expect(
        find.text('Simulated transfer receipt — synthetic funds only'),
        findsNothing,
      );
      await reveal(tester, key('error'));
      expect(find.text('Use a synthetic-test account token.'), findsOneWidget);
    },
  );

  testWidgets(
    'successful transfer survives balance error without asking to resend',
    (tester) async {
      final methods = <String>[];
      await open(tester, (request) async {
        methods.add(request.method);
        if (request.method == 'POST') return receipt(request);
        throw http.ClientException('offline');
      });
      await activate(tester);
      await tap(tester, 'transfer');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Simulated transfer completed; balance refresh failed. Use Refresh synthetic balance.',
        ),
        findsOneWidget,
      );
      await reveal(
        tester,
        find.text('Simulated transfer receipt — synthetic funds only'),
      );
      expect(
        find.text('Simulated transfer receipt — synthetic funds only'),
        findsOneWidget,
      );
      await tap(tester, 'refresh');
      await tester.pumpAndSettle();
      expect(methods, ['POST', 'GET', 'GET']);
    },
  );

  testWidgets(
    'narrow large text remains scrollable and exact amount validation prevents dispatch',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var dispatched = 0;
      await open(tester, (request) async {
        dispatched++;
        return balance('0');
      }, scale: 2);
      await activate(tester);
      for (final invalid in ['0', '0.25', '1e3', '9000000000000001']) {
        await enter(tester, 'amount', invalid);
        await tap(tester, 'transfer');
        await reveal(tester, key('error'));
        expect(find.textContaining('Enter whole base units'), findsOneWidget);
      }
      expect(dispatched, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'disabled client makes no requests and page disposal leaves caller-owned client reusable',
    (tester) async {
      var dispatched = 0;
      await open(tester, (request) async {
        dispatched++;
        return balance('0');
      }, enabled: false);
      await enter(tester, 'token', tokenA);
      await tap(tester, 'activate');
      await reveal(tester, key('error'));
      expect(find.text('The local payment lab is disabled.'), findsOneWidget);
      expect(dispatched, 0);
      final client = await open(tester, (request) async => balance('1'));
      await tester.pumpWidget(const SizedBox());
      await expectLater(
        client.balance('test-usdc'),
        throwsA(isA<LocalPaymentException>()),
      );
      client.activateTestAccount(tokenB);
      expect(await client.balance('test-usdc'), BigInt.one);
    },
  );
}
