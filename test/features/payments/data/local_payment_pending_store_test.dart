import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/payments/data/local_payment_pending_store.dart';

class MockPreferences extends Mock implements SharedPreferences {}

const tokenA = 'synthetic-test-accounta';
const tokenB = 'synthetic-test-accountb';

LocalPaymentPendingScope scope({String token = tokenA, int port = 8765}) =>
    LocalPaymentPendingScope.fromAccount(
      endpoint: Uri.parse('http://127.0.0.1:$port'),
      syntheticToken: token,
    );
LocalPaymentPendingEntry transfer(String key, {String amount = '25'}) =>
    LocalPaymentPendingEntry(
      key: key,
      operation: LocalPaymentPendingOperation.transfer,
      parameters: {'recipient': 'b', 'asset': 'test-usdc', 'amount': amount},
    );
Matcher failure(String code) => isA<LocalPaymentPendingStoreException>().having(
  (e) => e.code,
  'code',
  code,
);

void main() {
  late SharedPreferences preferences;
  late LocalPaymentPendingStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    store = LocalPaymentPendingStore(
      preferences: preferences,
      mode: 'localSimulation',
    );
  });

  test('explicit simulation and synthetic loopback scope only', () {
    expect(
      () => LocalPaymentPendingStore(
        preferences: preferences,
        mode: 'production',
      ),
      throwsA(failure('disabled')),
    );
    for (final endpoint in [
      'https://127.0.0.1',
      'http://localhost',
      'http://127.0.0.1/api',
      'http://user@127.0.0.1',
      'http://127.0.0.1?x=1',
    ]) {
      expect(
        () => LocalPaymentPendingScope.fromAccount(
          endpoint: Uri.parse(endpoint),
          syntheticToken: tokenA,
        ),
        throwsA(failure('invalid_scope')),
      );
    }
    expect(
      () => LocalPaymentPendingScope.fromAccount(
        endpoint: Uri.parse('http://127.0.0.1'),
        syntheticToken: 'real-token',
      ),
      throwsA(failure('invalid_scope')),
    );
    final plain = LocalPaymentPendingScope.fromAccount(
      endpoint: Uri.parse('http://127.0.0.1'),
      syntheticToken: tokenA,
    );
    final slash = LocalPaymentPendingScope.fromAccount(
      endpoint: Uri.parse('http://127.0.0.1:80/'),
      syntheticToken: tokenA,
    );
    expect(plain.storageKey, slash.storageKey);
  });

  test(
    'restart retains exact key expiry and parameters without bearer token',
    () async {
      final entry = LocalPaymentPendingEntry(
        key: '/original?key%+',
        operation: LocalPaymentPendingOperation.create,
        parameters: {
          'room': 'test-room',
          'asset': 'test-usdc',
          'total': '9000000000000000',
          'slots': '2',
          'expiresAt': '100',
        },
      );
      await store.save(scope(), entry);
      final persisted = preferences.getString(scope().storageKey)!;
      expect(persisted, isNot(contains(tokenA)));
      expect(persisted, isNot(contains('Bearer')));
      final restart = LocalPaymentPendingStore(
        preferences: await SharedPreferences.getInstance(),
        mode: 'localSimulation',
      );
      final loaded = await restart.load(scope());
      expect(loaded.status, LocalPaymentPendingStatus.ready);
      expect(loaded.entries.single.key, entry.key);
      expect(loaded.entries.single.parameters, entry.parameters);
      expect(loaded.entries.single.parameters['expiresAt'], '100');
      expect(() => loaded.entries.clear(), throwsUnsupportedError);
      expect(
        () => loaded.entries.single.parameters['total'] = '1',
        throwsUnsupportedError,
      );
    },
  );

  test('account and endpoint namespaces isolate reads and removals', () async {
    await store.save(scope(), transfer('a'));
    await store.save(scope(token: tokenB), transfer('b'));
    await store.save(scope(port: 8766), transfer('other-server'));
    await store.remove(scope(), 'a');
    expect((await store.load(scope())).status, LocalPaymentPendingStatus.empty);
    expect((await store.load(scope(token: tokenB))).entries.single.key, 'b');
    expect(
      (await store.load(scope(port: 8766))).entries.single.key,
      'other-server',
    );
  });

  test(
    'same key is idempotent and differing parameters cannot replace pending',
    () async {
      await store.save(scope(), transfer('original'));
      await store.save(scope(), transfer('original'));
      await expectLater(
        store.save(scope(), transfer('original', amount: '26')),
        throwsA(failure('key_conflict')),
      );
      expect(
        (await store.load(scope())).entries.single.parameters['amount'],
        '25',
      );
      await store.remove(scope(), 'unknown');
      expect((await store.load(scope())).entries, hasLength(1));
    },
  );

  test('concurrent separate stores preserve all pending entries', () async {
    final second = LocalPaymentPendingStore(
      preferences: preferences,
      mode: 'localSimulation',
    );
    await Future.wait(
      List.generate(
        16,
        (i) => (i.isEven ? store : second).save(scope(), transfer('k$i')),
      ),
    );
    expect((await store.load(scope())).entries, hasLength(16));
    await Future.wait(List.generate(8, (i) => second.remove(scope(), 'k$i')));
    expect((await store.load(scope())).entries, hasLength(8));
  });

  test(
    'all operation snapshots validate exact fields and packet identifiers',
    () async {
      final packet = 'packet_${List.filled(64, 'a').join()}';
      for (final operation in [
        LocalPaymentPendingOperation.claim,
        LocalPaymentPendingOperation.refund,
      ]) {
        await store.save(
          scope(),
          LocalPaymentPendingEntry(
            key: operation.name,
            operation: operation,
            parameters: {'packet': packet},
          ),
        );
      }
      expect((await store.load(scope())).entries, hasLength(2));
      expect(
        () => LocalPaymentPendingEntry(
          key: 'bad',
          operation: LocalPaymentPendingOperation.claim,
          parameters: {'packet': 'wrong'},
        ),
        throwsA(failure('invalid_entry')),
      );
      expect(
        () => LocalPaymentPendingEntry(
          key: 'bad',
          operation: LocalPaymentPendingOperation.transfer,
          parameters: {
            'recipient': 'b',
            'asset': 'x',
            'amount': '1',
            'token': tokenA,
          },
        ),
        throwsA(failure('invalid_entry')),
      );
      for (final amount in [
        '0',
        '-1',
        '1.0',
        '1e2',
        '01',
        '9000000000000001',
      ]) {
        expect(
          () => transfer('key', amount: amount),
          throwsA(failure('invalid_entry')),
        );
      }
    },
  );

  test('corrupt journals remain blocked instead of becoming empty', () async {
    await store.save(scope(), transfer('original'));
    final valid = preferences.getString(scope().storageKey)!;
    final corrupt = <Object>['{', 42, ' ' * 65537];
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (data) => data['mode'] = 'production',
      (data) => data['accountHash'] = scope(token: tokenB).accountHash,
      (data) => data['endpoint'] = 'http://127.0.0.1:8766',
      (data) => data['version'] = 2,
      (data) => data['extra'] = 'unknown',
      (data) => data['entries'][0]['parameters']['amount'] = 25,
      (data) => data['entries'][0]['operation'] = 'unknown',
      (data) => data['entries'].add(data['entries'][0]),
    ]) {
      final data = jsonDecode(valid) as Map<String, dynamic>;
      mutate(data);
      corrupt.add(jsonEncode(data));
    }
    corrupt.add(valid.replaceFirst('"version":1', '"version":2,"version":1'));
    for (final value in corrupt) {
      if (value is int) {
        await preferences.setInt(scope().storageKey, value);
      } else {
        await preferences.setString(scope().storageKey, value as String);
      }
      expect(
        (await store.load(scope())).status,
        LocalPaymentPendingStatus.corrupt,
      );
      await expectLater(
        store.save(scope(), transfer('new')),
        throwsA(failure('corrupt')),
      );
      await expectLater(
        store.remove(scope(), 'original'),
        throwsA(failure('corrupt')),
      );
      expect(preferences.get(scope().storageKey), value);
    }
  });

  test(
    'read failures are unavailable and write failures prevent caller POST',
    () async {
      final broken = MockPreferences();
      when(
        () => broken.reload(),
      ).thenThrow(StateError('private platform detail'));
      final failing = LocalPaymentPendingStore(
        preferences: broken,
        mode: 'localSimulation',
      );
      expect(
        (await failing.load(scope())).status,
        LocalPaymentPendingStatus.unavailable,
      );
      await expectLater(
        failing.save(scope(), transfer('original')),
        throwsA(failure('unavailable')),
      );
      when(() => broken.reload()).thenAnswer((_) async {});
      when(() => broken.get(any())).thenReturn(null);
      when(() => broken.setString(any(), any())).thenAnswer((_) async => false);
      var posts = 0;
      Future<void> dispatch() async {
        await failing.save(scope(), transfer('original'));
        posts++;
      }

      await expectLater(dispatch(), throwsA(failure('write_failed')));
      expect(posts, 0);
      when(
        () => broken.setString(any(), any()),
      ).thenThrow(StateError('secret'));
      await expectLater(dispatch(), throwsA(failure('write_failed')));
      expect(posts, 0);
    },
  );

  test('journal capacity fails closed without dropping older keys', () async {
    for (var i = 0; i < 32; i++) {
      await store.save(scope(), transfer('k$i'));
    }
    await expectLater(
      store.save(scope(), transfer('overflow')),
      throwsA(failure('journal_full')),
    );
    expect((await store.load(scope())).entries, hasLength(32));
  });
}
