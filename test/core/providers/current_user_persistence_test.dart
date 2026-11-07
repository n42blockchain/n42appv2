import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

class _Storage extends SPUtil {
  final saved = Completer<void>();
  int writes = 0;
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;
  @override
  Future<void> saveUserInfoJson(Map<String, dynamic> info) {
    writes++;
    return saved.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const user = SharedUserInfo(uuid: 'user', email: 'user@example.com');
  test('setUser completion waits for persistence acknowledgement', () async {
    final storage = _Storage();
    final notifier = CurrentUserNotifier(storage);
    addTearDown(notifier.dispose);
    var completed = false;
    final write = notifier.setUser(user).then((_) => completed = true);
    await pumpEventQueue();
    expect(notifier.state, user);
    expect(completed, isFalse);
    storage.saved.complete();
    await write;
    expect(completed, isTrue);
    expect(storage.writes, 1);
  });
  test('persistence failure reaches the awaiting caller', () async {
    final storage = _Storage();
    final notifier = CurrentUserNotifier(storage);
    addTearDown(notifier.dispose);
    final write = notifier.setUser(user);
    final failure = expectLater(write, throwsStateError);
    storage.saved.completeError(StateError('storage unavailable'));
    await failure;
    expect(notifier.state, user);
  });
  test('late acknowledgement does not restore a cleared account', () async {
    final storage = _Storage();
    final notifier = CurrentUserNotifier(storage);
    addTearDown(notifier.dispose);
    final write = notifier.setUser(user);
    notifier.clearUser();
    storage.saved.complete();
    await write;
    expect(notifier.state, isNull);
  });
  test('disposed notifier returns without writing', () async {
    final storage = _Storage();
    final notifier = CurrentUserNotifier(storage)..dispose();
    await notifier.setUser(user);
    expect(storage.writes, 0);
  });
}
