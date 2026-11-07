import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

class _DelayedStorage extends SPUtil {
  final read = Completer<Map<String, dynamic>?>();
  final writes = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>?> getUserInfo() => read.future;
  @override
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {
    writes.add(Map.of(info));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const oldUser = SharedUserInfo(uuid: 'old', email: 'old@example.com');
  const newUser = SharedUserInfo(uuid: 'new', email: 'new@example.com');

  test('late startup restore cannot replace an explicit login', () async {
    final storage = _DelayedStorage();
    final notifier = CurrentUserNotifier(storage);
    addTearDown(notifier.dispose);
    notifier.setUser(newUser);
    storage.read.complete(oldUser.toJson());
    await pumpEventQueue();
    expect(notifier.state, newUser);
    expect(storage.writes, [newUser.toJson()]);
  });

  test(
    'late startup restore cannot undo logout from initial null state',
    () async {
      final storage = _DelayedStorage();
      final notifier = CurrentUserNotifier(storage);
      addTearDown(notifier.dispose);
      notifier.clearUser();
      storage.read.complete(oldUser.toJson());
      await pumpEventQueue();
      expect(notifier.state, isNull);
      expect(notifier.isLoggedIn, isFalse);
      expect(storage.writes, isEmpty);
    },
  );

  test('uncontested startup still restores the stored account', () async {
    final storage = _DelayedStorage();
    final notifier = CurrentUserNotifier(storage);
    addTearDown(notifier.dispose);
    storage.read.complete(oldUser.toJson());
    await pumpEventQueue();
    expect(notifier.state, oldUser);
    expect(storage.writes, isEmpty);
  });

  test(
    'disposed notifier ignores late restore and account callbacks',
    () async {
      final storage = _DelayedStorage();
      final notifier = CurrentUserNotifier(storage)..dispose();
      expect(() => notifier.clearUser(), returnsNormally);
      notifier.setUser(newUser);
      storage.read.complete(oldUser.toJson());
      await pumpEventQueue();
      expect(storage.writes, isEmpty);
    },
  );
  for (final logout in [false, true]) {
    test(
      'app startup cannot undo explicit ${logout ? "logout" : "login"}',
      () async {
        final storage = _DelayedStorage();
        final previousGlobalUser = AppGlobals.userInfo;
        final container = ProviderContainer(
          overrides: [spUtilProvider.overrideWithValue(storage)],
        );
        addTearDown(() {
          container.dispose();
          AppGlobals.userInfo = previousGlobalUser;
        });
        final notifier = container.read(currentUserProvider.notifier);
        final startup = container.read(appInitProvider.future);
        await pumpEventQueue();
        if (logout) {
          notifier.clearUser();
        } else {
          notifier.setUser(newUser);
        }
        storage.read.complete(oldUser.toJson());
        await startup;
        expect(notifier.state, logout ? isNull : newUser);
        expect(AppGlobals.userInfo, same(previousGlobalUser));
        expect(storage.writes.length, logout ? 0 : 1);
      },
    );
  }
}
