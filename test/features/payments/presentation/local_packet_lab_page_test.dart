import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';
import 'package:n42_wallet/features/payments/data/local_payment_pending_store.dart';
import 'package:n42_wallet/features/payments/presentation/local_packet_lab_page.dart';

final packetId = 'packet_${'a' * 64}';

class MockPreferences extends Mock implements SharedPreferences {}

Finder key(String name) => find.byKey(ValueKey('packet_$name'));

http.Response response(http.Request request) {
  final body = request.method == 'POST'
      ? jsonDecode(request.body) as Map<String, dynamic>
      : <String, dynamic>{};
  return http.Response(
    jsonEncode({
      'mode': 'localSimulation',
      'asset': 'test-usdc',
      if (request.method == 'GET') 'available': '80',
      if (request.url.path == '/packets') ...{'id': packetId, ...body},
      if (request.url.path.endsWith('/claims')) ...{
        'packet': packetId,
        'amount': '10',
      },
      if (request.url.path.endsWith('/refunds')) ...{
        'id': 'refund_${'b' * 64}',
        'amount': '20',
      },
    }),
    200,
  );
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.drag(find.byType(ListView), const Offset(0, 5000));
    await tester.pump();
    await tester.scrollUntilVisible(
      finder,
      180,
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
  SharedPreferences? preferences,
  int port = 8765,
}) async {
  final journalPreferences =
      preferences ?? await SharedPreferences.getInstance();
  final transport = MockClient(handler);
  addTearDown(transport.close);
  final client = LocalPaymentClient(
    endpoint: Uri.parse('http://127.0.0.1:$port'),
    transport: transport,
    enabled: enabled,
  );
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: LocalPacketLabPage(
        client: client,
        pendingStore: Future.value(
          LocalPaymentPendingStore(
            preferences: journalPreferences,
            mode: 'localSimulation',
          ),
        ),
      ),
    ),
  );
  await enter(tester, 'token', 'synthetic-test-accounta');
  await tap(tester, 'activate');
  return client;
}

Future<void> fill(WidgetTester tester) async {
  await enter(tester, 'asset', 'test-usdc');
  await enter(tester, 'room', 'test-room');
  await enter(tester, 'total', '30');
  await enter(tester, 'slots', '3');
  await enter(tester, 'minutes', '60');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
    'creation serializes taps and shows simulated ID and refreshed balance',
    (tester) async {
      final pending = Completer<http.Response>();
      final calls = <http.Request>[];
      await open(tester, (request) async {
        calls.add(request);
        return request.method == 'POST' ? pending.future : response(request);
      });
      await fill(tester);
      await reveal(tester, key('create'));
      final create = tester.widget<FilledButton>(key('create')).onPressed!;
      create();
      create();
      await tester.pump();
      expect(calls, hasLength(1));
      expect(tester.widget<FilledButton>(key('create')).onPressed, isNull);
      final body = jsonDecode(calls.single.body) as Map<String, dynamic>;
      expect(body['total'], '30');
      expect(body['slots'], '3');
      expect(body['room'], 'test-room');
      expect(
        int.parse(body['expiresAt'] as String),
        greaterThan(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      );
      pending.complete(response(calls.single));
      await tester.pumpAndSettle();
      await reveal(
        tester,
        find.text('Simulated create receipt — synthetic funds only'),
      );
      expect(
        find.text('Simulated create receipt — synthetic funds only'),
        findsOneWidget,
      );
      await reveal(tester, key('id'));
      expect(tester.widget<TextField>(key('id')).controller!.text, packetId);
      await reveal(tester, key('balance'));
      expect(
        find.text('Synthetic balance: 80 base units (test-usdc)'),
        findsOneWidget,
      );
      expect(calls.map((r) => r.method), ['POST', 'GET']);
    },
  );

  testWidgets(
    'uncertain creation locks edits and retries exact body, expiry and key',
    (tester) async {
      final calls = <http.Request>[];
      await open(tester, (request) async {
        calls.add(request);
        if (calls.length == 1) throw http.ClientException('offline');
        return response(request);
      });
      await fill(tester);
      await tap(tester, 'create');
      await tester.pumpAndSettle();
      await reveal(tester, key('total'));
      expect(tester.widget<TextField>(key('total')).enabled, isFalse);
      await reveal(tester, key('create'));
      expect(tester.widget<FilledButton>(key('create')).onPressed, isNull);
      await tap(tester, 'retry');
      await tester.pumpAndSettle();
      expect(calls[0].body, calls[1].body);
      expect(
        calls[0].headers['Idempotency-Key'],
        calls[1].headers['Idempotency-Key'],
      );
      expect(calls.map((r) => r.method), ['POST', 'POST', 'GET']);
    },
  );

  for (final action in ['claim', 'refund']) {
    testWidgets(
      '$action failure preserves key, success refreshes only simulation asset',
      (tester) async {
        final calls = <http.Request>[];
        await open(tester, (request) async {
          calls.add(request);
          if (calls.length == 1) throw http.ClientException('offline');
          return response(request);
        });
        await enter(tester, 'id', packetId);
        await tap(tester, action);
        await tester.pumpAndSettle();
        await tap(tester, 'retry');
        await tester.pumpAndSettle();
        expect(
          calls[0].url.path,
          '/packets/$packetId/${action == 'claim' ? 'claims' : 'refunds'}',
        );
        expect(
          calls[0].headers['Idempotency-Key'],
          calls[1].headers['Idempotency-Key'],
        );
        expect(calls[2].url.queryParameters['asset'], 'test-usdc');
        await reveal(
          tester,
          find.text('Simulated $action receipt — synthetic funds only'),
        );
        expect(find.text('Packet: $packetId'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'switching discards late receipt and restores unresolved original request on return',
    (tester) async {
      final pending = Completer<http.Response>();
      final calls = <http.Request>[];
      await open(tester, (request) async {
        calls.add(request);
        return calls.length == 1 ? pending.future : response(request);
      });
      await fill(tester);
      await tap(tester, 'create');
      await enter(tester, 'token', 'synthetic-test-accountb');
      await tap(tester, 'activate');
      pending.complete(response(calls.first));
      await tester.pumpAndSettle();
      await reveal(tester, key('balance'));
      expect(find.text('Synthetic balance: not loaded'), findsOneWidget);
      expect(
        find.text('Simulated create receipt — synthetic funds only'),
        findsNothing,
      );
      await enter(tester, 'token', 'synthetic-test-accounta');
      await tap(tester, 'activate');
      await tap(tester, 'retry');
      await tester.pumpAndSettle();
      expect(
        calls[0].headers['Idempotency-Key'],
        calls[1].headers['Idempotency-Key'],
      );
      expect(calls[0].body, calls[1].body);
      expect(
        calls[1].headers['Authorization'],
        'Bearer synthetic-test-accounta',
      );
    },
  );

  testWidgets(
    'confirmed operation with failed balance refresh directs GET retry only',
    (tester) async {
      final methods = <String>[];
      await open(tester, (request) async {
        methods.add(request.method);
        if (request.method == 'GET') throw http.ClientException('offline');
        return response(request);
      });
      await enter(tester, 'id', packetId);
      await tap(tester, 'claim');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Simulation operation confirmed; balance refresh failed. Use Refresh synthetic balance.',
        ),
        findsOneWidget,
      );
      await tap(tester, 'refresh');
      await tester.pumpAndSettle();
      expect(methods, ['POST', 'GET', 'GET']);
      expect(key('retry'), findsNothing);
    },
  );

  testWidgets('narrow large text supports validation without dispatch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var calls = 0;
    await open(tester, (request) async {
      calls++;
      return response(request);
    }, scale: 2);
    await fill(tester);
    for (final invalid in ['0', '1.5', '31', '9000000000000001']) {
      await enter(tester, 'total', invalid);
      await tap(tester, 'create');
      await reveal(tester, key('error'));
      expect(find.textContaining('positive whole base units'), findsOneWidget);
    }
    await enter(tester, 'id', '../bad');
    await tap(tester, 'claim');
    await reveal(tester, key('error'));
    expect(find.textContaining('Paste a local packet ID'), findsOneWidget);
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disabled client makes no request and disposal does not close caller client',
    (tester) async {
      var calls = 0;
      await open(tester, (request) async {
        calls++;
        return response(request);
      }, enabled: false);
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Activate an enabled local client with a synthetic-test account token.',
        ),
        findsOneWidget,
      );
      expect(calls, 0);
      final client = await open(tester, (request) async => response(request));
      await tester.pumpWidget(const SizedBox());
      client.activateTestAccount('synthetic-test-accountb');
      expect(await client.balance('test-usdc'), BigInt.from(80));
    },
  );
  for (final action in ['create', 'claim', 'refund']) {
    testWidgets(
      '$action lookup completes original operation without another POST',
      (tester) async {
        final calls = <http.Request>[];
        late http.Request original;
        await open(tester, (request) async {
          calls.add(request);
          if (request.method == 'POST') {
            original = request;
            throw http.ClientException('lost acknowledgement');
          }
          if (request.url.path == '/requests') {
            expect(
              request.url.queryParameters['key'],
              original.headers['Idempotency-Key'],
            );
            return http.Response(
              jsonEncode({
                'mode': 'localSimulation',
                'status': 'completed',
                'receipt': jsonDecode(response(original).body),
              }),
              200,
            );
          }
          return response(request);
        });
        if (action == 'create') {
          await fill(tester);
        } else {
          await enter(tester, 'id', packetId);
        }
        await tap(tester, action);
        await tester.pumpAndSettle();
        await tap(tester, 'lookup');
        await tester.pumpAndSettle();
        await reveal(
          tester,
          find.text('Simulated $action receipt — synthetic funds only'),
        );
        expect(
          find.text('Simulated $action receipt — synthetic funds only'),
          findsOneWidget,
        );
        expect(key('retry'), findsNothing);
        expect(calls.map((r) => r.method), ['POST', 'GET', 'GET']);
      },
    );
  }

  for (final status in [200, 404]) {
    testWidgets('unresolved lookup HTTP $status retains original retry key', (
      tester,
    ) async {
      final posts = <http.Request>[];
      await open(tester, (request) async {
        if (request.method == 'POST') {
          posts.add(request);
          if (posts.length == 1) throw http.ClientException('offline');
          return response(request);
        }
        if (request.url.path == '/requests') {
          return http.Response(
            jsonEncode(
              status == 200
                  ? {'mode': 'localSimulation', 'status': 'unresolved'}
                  : {
                      'mode': 'localSimulation',
                      'error': {'code': 'not_found'},
                    },
            ),
            status,
          );
        }
        return response(request);
      });
      await fill(tester);
      await tap(tester, 'create');
      await tester.pumpAndSettle();
      await tap(tester, 'lookup');
      await tester.pumpAndSettle();
      await reveal(tester, key('retry'));
      expect(key('retry'), findsOneWidget);
      await tap(tester, 'retry');
      await tester.pumpAndSettle();
      expect(posts, hasLength(2));
      expect(
        posts[0].headers['Idempotency-Key'],
        posts[1].headers['Idempotency-Key'],
      );
      expect(posts[0].body, posts[1].body);
    });
  }

  testWidgets('late original-result lookup cannot populate another account', (
    tester,
  ) async {
    final lookup = Completer<http.Response>();
    late http.Request original;
    await open(tester, (request) async {
      if (request.method == 'POST') {
        original = request;
        throw http.ClientException('offline');
      }
      return lookup.future;
    });
    await fill(tester);
    await tap(tester, 'create');
    await tester.pumpAndSettle();
    await tap(tester, 'lookup');
    await enter(tester, 'token', 'synthetic-test-accountb');
    await tap(tester, 'activate');
    lookup.complete(
      http.Response(
        jsonEncode({
          'mode': 'localSimulation',
          'status': 'completed',
          'receipt': jsonDecode(response(original).body),
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();
    await reveal(tester, key('balance'));
    expect(find.text('Synthetic balance: not loaded'), findsOneWidget);
    expect(
      find.text('Simulated create receipt — synthetic funds only'),
      findsNothing,
    );
    await enter(tester, 'token', 'synthetic-test-accounta');
    await tap(tester, 'activate');
    await reveal(tester, key('retry'));
    expect(key('retry'), findsOneWidget);
  });

  testWidgets('create lookup rejects every mismatched saved term', (
    tester,
  ) async {
    late http.Request original;
    String changed = 'asset';
    var posts = 0;
    await open(tester, (request) async {
      if (request.method == 'POST') {
        posts++;
        original = request;
        throw http.ClientException('offline');
      }
      final result =
          jsonDecode(response(original).body) as Map<String, dynamic>;
      if (changed == 'recipient') {
        result['recipient'] = 'synthetic-test-designated-user';
        result['slots'] = '1';
      } else {
        result[changed] = changed == 'asset' || changed == 'room'
            ? 'different'
            : '1';
      }
      return http.Response(
        jsonEncode({
          'mode': 'localSimulation',
          'status': 'completed',
          'receipt': result,
        }),
        200,
      );
    });
    await fill(tester);
    await tap(tester, 'create');
    await tester.pumpAndSettle();
    for (final field in [
      'asset',
      'room',
      'total',
      'slots',
      'expiresAt',
      'recipient',
    ]) {
      changed = field;
      await tap(tester, 'lookup');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Original receipt does not match the saved operation. The request remains pending.',
        ),
        findsOneWidget,
      );
    }
    expect(posts, 1);
  });

  testWidgets(
    'rebuild restores exact create request from journal without automatic POST',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final posts = <http.Request>[];
      Future<http.Response> handler(http.Request request) async {
        if (request.method == 'POST') {
          posts.add(request);
          if (posts.length == 1) throw http.ClientException('offline');
        }
        return response(request);
      }

      await open(tester, handler, preferences: preferences);
      await fill(tester);
      await tap(tester, 'create');
      await tester.pumpAndSettle();
      final originalBody = posts.single.body;
      final originalKey = posts.single.headers['Idempotency-Key'];

      await tester.pumpWidget(const SizedBox());
      await open(tester, handler, preferences: preferences);
      await tester.pumpAndSettle();
      expect(posts, hasLength(1));
      await reveal(tester, key('pending'));
      expect(key('pending'), findsOneWidget);

      await tap(tester, 'retry');
      await tester.pumpAndSettle();
      expect(posts, hasLength(2));
      expect(posts.last.body, originalBody);
      expect(posts.last.headers['Idempotency-Key'], originalKey);
    },
  );

  for (final action in ['claim', 'refund']) {
    testWidgets(
      'rebuild restores exact $action request without automatic POST',
      (tester) async {
        final preferences = await SharedPreferences.getInstance();
        final posts = <http.Request>[];
        Future<http.Response> handler(http.Request request) async {
          if (request.method == 'POST') {
            posts.add(request);
            if (posts.length == 1) throw http.ClientException('offline');
          }
          return response(request);
        }

        await open(tester, handler, preferences: preferences);
        await enter(tester, 'id', packetId);
        await tap(tester, action);
        await tester.pumpAndSettle();
        final originalBody = posts.single.body;
        final originalKey = posts.single.headers['Idempotency-Key'];

        await tester.pumpWidget(const SizedBox());
        await open(tester, handler, preferences: preferences);
        await tester.pumpAndSettle();
        expect(posts, hasLength(1));
        await reveal(tester, key('id'));
        expect(tester.widget<TextField>(key('id')).controller!.text, packetId);
        await tap(tester, 'retry');
        await tester.pumpAndSettle();
        expect(posts.last.body, originalBody);
        expect(posts.last.headers['Idempotency-Key'], originalKey);
      },
    );
  }

  testWidgets('failed journal save sends no POST and blocks packet actions', (
    tester,
  ) async {
    final preferences = MockPreferences();
    when(() => preferences.reload()).thenAnswer((_) async {});
    when(() => preferences.get(any())).thenReturn(null);
    when(
      () => preferences.setString(any(), any()),
    ).thenAnswer((_) async => false);
    var posts = 0;
    await open(tester, (request) async {
      if (request.method == 'POST') posts++;
      return response(request);
    }, preferences: preferences);
    await fill(tester);
    await tap(tester, 'create');
    await tester.pumpAndSettle();
    expect(posts, 0);
    await reveal(tester, key('create'));
    expect(tester.widget<FilledButton>(key('create')).onPressed, isNull);
    await reveal(tester, key('error'));
    expect(find.textContaining('No packet operation was sent'), findsOneWidget);
  });

  for (final broken in ['corrupt', 'multiple']) {
    testWidgets('$broken packet journal blocks every money action', (
      tester,
    ) async {
      final preferences = await SharedPreferences.getInstance();
      final scope = LocalPaymentPendingScope.fromAccount(
        endpoint: Uri.parse('http://127.0.0.1:8765'),
        syntheticToken: 'synthetic-test-accounta',
      );
      if (broken == 'corrupt') {
        await preferences.setString(scope.storageKey, '{bad');
      } else {
        final store = LocalPaymentPendingStore(
          preferences: preferences,
          mode: 'localSimulation',
        );
        for (final keyValue in ['one', 'two']) {
          await store.save(
            scope,
            LocalPaymentPendingEntry(
              key: keyValue,
              operation: LocalPaymentPendingOperation.claim,
              parameters: {'packet': packetId},
            ),
          );
        }
      }
      var requests = 0;
      await open(tester, (_) async {
        requests++;
        return http.Response('', 500);
      }, preferences: preferences);
      await tester.pumpAndSettle();
      expect(requests, 0);
      await reveal(tester, key('create'));
      expect(tester.widget<FilledButton>(key('create')).onPressed, isNull);
      await reveal(tester, key('claim'));
      expect(tester.widget<FilledButton>(key('claim')).onPressed, isNull);
      await reveal(tester, key('refund'));
      expect(tester.widget<OutlinedButton>(key('refund')).onPressed, isNull);
    });
  }

  testWidgets(
    'cleanup failure keeps receipt, disables resend, and GET retries cleanup',
    (tester) async {
      final actual = await SharedPreferences.getInstance();
      final preferences = MockPreferences();
      when(() => preferences.reload()).thenAnswer((_) => actual.reload());
      when(() => preferences.get(any())).thenAnswer(
        (call) => actual.get(call.positionalArguments.first as String),
      );
      var writes = 0;
      when(() => preferences.setString(any(), any())).thenAnswer((call) async {
        writes++;
        if (writes == 2) return false;
        return actual.setString(
          call.positionalArguments[0] as String,
          call.positionalArguments[1] as String,
        );
      });
      late http.Request original;
      var posts = 0;
      await open(tester, (request) async {
        if (request.method == 'POST') {
          posts++;
          original = request;
          return response(request);
        }
        if (request.url.path == '/requests') {
          return http.Response(
            jsonEncode({
              'mode': 'localSimulation',
              'status': 'completed',
              'receipt': jsonDecode(response(original).body),
            }),
            200,
          );
        }
        return response(request);
      }, preferences: preferences);
      await enter(tester, 'id', packetId);
      await tap(tester, 'claim');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(find.textContaining('Operation confirmed'), findsOneWidget);
      expect(
        find.text('Simulated claim receipt — synthetic funds only'),
        findsOneWidget,
      );
      await reveal(tester, key('retry'));
      expect(tester.widget<FilledButton>(key('retry')).onPressed, isNull);
      await tap(tester, 'lookup');
      await tester.pumpAndSettle();
      expect(posts, 1);
      expect(key('retry'), findsNothing);
      expect(writes, 3);
    },
  );

  testWidgets('packet completion preserves an unrelated transfer entry', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final scope = LocalPaymentPendingScope.fromAccount(
      endpoint: Uri.parse('http://127.0.0.1:8765'),
      syntheticToken: 'synthetic-test-accounta',
    );
    final store = LocalPaymentPendingStore(
      preferences: preferences,
      mode: 'localSimulation',
    );
    await store.save(
      scope,
      LocalPaymentPendingEntry(
        key: 'transfer-key',
        operation: LocalPaymentPendingOperation.transfer,
        parameters: {'recipient': 'b', 'asset': 'test-usdc', 'amount': '25'},
      ),
    );
    await open(
      tester,
      (request) async => response(request),
      preferences: preferences,
    );
    await enter(tester, 'id', packetId);
    await tap(tester, 'claim');
    await tester.pumpAndSettle();
    final loaded = await store.load(scope);
    expect(loaded.entries, hasLength(1));
    expect(
      loaded.entries.single.operation,
      LocalPaymentPendingOperation.transfer,
    );
  });

  for (final action in ['claim', 'refund']) {
    testWidgets('$action lookup refuses a different packet association', (
      tester,
    ) async {
      late http.Request original;
      await open(tester, (request) async {
        if (request.method == 'POST') {
          original = request;
          throw http.ClientException('offline');
        }
        final result =
            jsonDecode(response(original).body) as Map<String, dynamic>;
        result['packet'] = 'packet_${'c' * 64}';
        return http.Response(
          jsonEncode({
            'mode': 'localSimulation',
            'status': 'completed',
            'receipt': result,
          }),
          200,
        );
      });
      await enter(tester, 'id', packetId);
      await tap(tester, action);
      await tester.pumpAndSettle();
      await tap(tester, 'lookup');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Original receipt does not match the saved operation. The request remains pending.',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets(
    'recovered receipt survives failed balance refresh without another money action',
    (tester) async {
      late http.Request original;
      final methods = <String>[];
      await open(tester, (request) async {
        methods.add(request.method);
        if (request.method == 'POST') {
          original = request;
          throw http.ClientException('offline');
        }
        if (request.url.path == '/requests') {
          return http.Response(
            jsonEncode({
              'mode': 'localSimulation',
              'status': 'completed',
              'receipt': jsonDecode(response(original).body),
            }),
            200,
          );
        }
        throw http.ClientException('balance unavailable');
      });
      await enter(tester, 'id', packetId);
      await tap(tester, 'claim');
      await tester.pumpAndSettle();
      await tap(tester, 'lookup');
      await tester.pumpAndSettle();
      await reveal(tester, key('error'));
      expect(
        find.text(
          'Simulation operation confirmed; balance refresh failed. Use Refresh synthetic balance.',
        ),
        findsOneWidget,
      );
      await tap(tester, 'refresh');
      await tester.pumpAndSettle();
      expect(methods, ['POST', 'GET', 'GET', 'GET']);
      expect(key('retry'), findsNothing);
    },
  );
}
