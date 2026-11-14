import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';

/// A failed or stuck secure-storage write during login must never skip the
/// account isolation step (provider invalidation, wallet reload and
/// WalletConnect cleanup) that separates the new user from the previous one.
void main() {
  tearDown(() => AppGlobals.userInfo = null);
  UserInfo user() => UserInfo.fromJson({'uuid': 'bob', 'email': 'b@x.y'});

  test('successful persistence publishes then isolates', () async {
    final steps = <String>[];
    await AppGlobals.switchUser(
      user(),
      persist: () async => steps.add('persist'),
      publish: () async => steps.add('publish'),
      isolate: () => steps.add('isolate'),
    );
    expect(steps, ['persist', 'publish', 'isolate']);
    expect(AppGlobals.userInfo?.uuid, 'bob');
  });

  test('storage failure still isolates, then reports the error', () async {
    final steps = <String>[];
    await expectLater(
      AppGlobals.switchUser(
        user(),
        persist: () async => throw StateError('keystore unavailable'),
        publish: () async => steps.add('publish'),
        isolate: () => steps.add('isolate'),
      ),
      throwsA(isA<StateError>()),
    );
    expect(steps, ['publish', 'isolate']);
    expect(AppGlobals.userInfo?.uuid, 'bob');
  });

  test('publish failure still isolates', () async {
    final steps = <String>[];
    await expectLater(
      AppGlobals.switchUser(
        user(),
        persist: () async {},
        publish: () async => throw StateError('prefs unavailable'),
        isolate: () => steps.add('isolate'),
      ),
      throwsStateError,
    );
    expect(steps, ['isolate']);
  });

  test('stuck storage times out and isolates', () async {
    final steps = <String>[];
    final never = Completer<void>();
    await AppGlobals.switchUser(
      user(),
      persist: () => never.future,
      publish: () => never.future,
      isolate: () => steps.add('isolate'),
      timeout: const Duration(milliseconds: 10),
    );
    expect(steps, ['isolate']);
  });
}
