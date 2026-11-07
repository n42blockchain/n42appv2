import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_preferences_test.dart' show FakeSecureStore;

class _DelayedStore extends FakeSecureStore {
  final firstWrite = Completer<void>();
  final started = Completer<void>();
  int writes = 0;
  bool failFirst = false;
  @override
  Future<void> write({required String key, required String value}) async {
    if (key == 'userInfo' && writes++ == 0) {
      started.complete();
      await firstWrite.future;
      if (failFirst) throw StateError('write failed');
    }
    await super.write(key: key, value: value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _DelayedStore store;
  late SecurePreferences subject;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = _DelayedStore();
    subject = SecurePreferences.test(
      prefs: await SharedPreferences.getInstance(),
      secureStorage: store,
    );
    await subject.init();
  });
  for (final operation in ['replace', 'logout', 'sensitive', 'all']) {
    test('$operation waits for earlier account write', () async {
      final first = subject.setUserInfo({'uuid': 'old'});
      await store.started.future;
      final next = switch (operation) {
        'replace' => subject.setUserInfo({'uuid': 'new'}),
        'logout' => subject.setUserInfo(null),
        'sensitive' => subject.clearSensitiveData(),
        _ => subject.clearAll(),
      };
      var completed = false;
      final observed = next.then((_) => completed = true);
      await pumpEventQueue();
      final completedBeforeFirst = completed;
      store.firstWrite.complete();
      await Future.wait([first, observed]);
      expect(completedBeforeFirst, isFalse);
      expect(
        await subject.getUserInfo(),
        operation == 'replace' ? {'uuid': 'new'} : isNull,
      );
    });
  }
  test('read waits for an earlier acknowledged account write', () async {
    final write = subject.setUserInfo({'uuid': 'new'});
    await store.started.future;
    final read = subject.getUserInfo();
    var completed = false;
    final observed = read.then((value) {
      completed = true;
      return value;
    });
    await pumpEventQueue();
    final completedBeforeWrite = completed;
    store.firstWrite.complete();
    await write;
    expect(await observed, {'uuid': 'new'});
    expect(completedBeforeWrite, isFalse);
  });
  test(
    'failed write reaches caller and does not block the next account',
    () async {
      store.failFirst = true;
      final first = subject.setUserInfo({'uuid': 'old'});
      final failure = expectLater(first, throwsStateError);
      await store.started.future;
      final next = subject.setUserInfo({'uuid': 'new'});
      store.firstWrite.complete();
      await failure;
      await next;
      expect(jsonDecode(store.values['userInfo']!), {'uuid': 'new'});
    },
  );
  test(
    'queued user data is captured before the caller changes its map',
    () async {
      final first = subject.setUserInfo({'uuid': 'old'});
      await store.started.future;
      final profile = <String, dynamic>{
        'uuid': 'new',
        'details': {'name': 'New'},
      };
      final next = subject.setUserInfo(profile);
      profile['uuid'] = 'changed';
      (profile['details'] as Map<String, dynamic>)['name'] = 'Changed';
      store.firstWrite.complete();
      await Future.wait([first, next]);
      expect(await subject.getUserInfo(), {
        'uuid': 'new',
        'details': {'name': 'New'},
      });
    },
  );

  for (final clear in ['logout', 'sensitive', 'all']) {
    test('$clear before init cannot resurrect legacy account data', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInfo', jsonEncode({'uuid': 'legacy'}));
      final storage = FakeSecureStore();
      final fresh = SecurePreferences.test(
        prefs: prefs,
        secureStorage: storage,
      );
      await switch (clear) {
        'logout' => fresh.setUserInfo(null),
        'sensitive' => fresh.clearSensitiveData(),
        _ => fresh.clearAll(),
      };
      await fresh.init();
      expect(await fresh.getUserInfo(), isNull);
      expect(prefs.getString('userInfo'), isNull);
    });
  }
  for (final clear in ['logout', 'sensitive']) {
    test('$clear removes legacy account after failed migration', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInfo', jsonEncode({'uuid': 'legacy'}));
      final storage = FakeSecureStore()..failingWrites.add('userInfo');
      final fresh = SecurePreferences.test(
        prefs: prefs,
        secureStorage: storage,
      );
      if (clear == 'logout') {
        await fresh.setUserInfo(null);
      } else {
        await fresh.clearSensitiveData();
      }
      storage.failingWrites.clear();
      final reopened = SecurePreferences.test(
        prefs: prefs,
        secureStorage: storage,
      );
      await reopened.init();
      expect(await reopened.getUserInfo(), isNull);
      expect(prefs.getString('userInfo'), isNull);
    });
  }
}
