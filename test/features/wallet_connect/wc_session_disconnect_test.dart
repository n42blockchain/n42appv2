import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../helpers/wallet_connect_session_fixture.dart';

class _Client extends Fake implements wc.ReownWalletKit {
  final activeSessions = <String, wc.SessionData>{};
  final requests = <(String, wc.ReownSignError)>[];
  Future<void> Function(String) disconnect = (_) async {};
  Object? readError;

  @override
  Map<String, wc.SessionData> getActiveSessions() {
    if (readError != null) throw readError!;
    return Map.of(activeSessions);
  }

  @override
  Future<void> disconnectSession({
    required String topic,
    required wc.ReownSignError reason,
  }) async {
    requests.add((topic, reason));
    await disconnect(topic);
    activeSessions.remove(topic);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Client client;
  late WalletConnectProvider provider;
  var notifications = 0;
  setUp(() {
    client = _Client()
      ..activeSessions.addAll({'one': session('one'), 'two': session('two')});
    provider = WalletConnectProvider()..signClient = client;
    provider.setActiveSession(client.activeSessions['one']!);
    notifications = 0;
    provider.addListener(() => notifications++);
  });
  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  test(
    'missing client is harmless and does not clear an active context',
    () async {
      provider.signClient = null;
      await provider.disconnectSessionByTopic('one');
      await provider.disconnectAllSessions();
      expect(provider.dAppTopic, 'one');
      expect(notifications, 0);
    },
  );

  test(
    'disconnect uses the selected topic and standard reason, retaining other sessions',
    () async {
      await provider.disconnectSessionByTopic('one');
      expect(client.requests.single.$1, 'one');
      expect(
        client.requests.single.$2.code,
        wc.Errors.getSdkError(wc.Errors.USER_DISCONNECTED).toSignError().code,
      );
      expect(provider.getActiveSessions().keys, ['two']);
      expect(provider.dAppTopic, isNull);
      expect(notifications, 1);
    },
  );

  test(
    'disconnecting another session preserves the selected session',
    () async {
      await provider.disconnectSessionByTopic('two');
      expect(provider.dAppTopic, 'one');
      expect(provider.walletConnectState, WalletConnectState.connect);
      expect(provider.getActiveSessions().keys, ['one']);
    },
  );

  test(
    'SDK failure is propagated without falsely clearing the active session',
    () async {
      final error = StateError('relay offline');
      client.disconnect = (_) async => throw error;
      await expectLater(
        provider.disconnectSessionByTopic('one'),
        throwsA(same(error)),
      );
      expect(provider.dAppTopic, 'one');
      expect(provider.walletConnectState, WalletConnectState.connect);
      expect(provider.getActiveSessions(), hasLength(2));
      expect(notifications, 1);
      client.disconnect = (_) async {};
      await provider.disconnectSessionByTopic('one');
      expect(provider.getActiveSessions().keys, ['two']);
    },
  );

  test(
    'disconnect-all attempts every session, reports partial failure and permits retry',
    () async {
      client.disconnect = (topic) async {
        if (topic == 'one') throw StateError('relay offline');
      };
      await expectLater(provider.disconnectAllSessions(), throwsStateError);
      expect(client.requests.map((r) => r.$1), ['one', 'two']);
      expect(provider.dAppTopic, 'one');
      expect(provider.getActiveSessions().keys, ['one']);
      client.disconnect = (_) async {};
      await provider.disconnectAllSessions();
      expect(provider.getActiveSessions(), isEmpty);
      expect(provider.dAppTopic, isNull);
    },
  );

  test(
    'disconnect-all retains sessions established while its snapshot is in flight',
    () async {
      final pending = Completer<void>();
      client.disconnect = (_) => pending.future;
      final action = provider.disconnectAllSessions();
      client.activeSessions['new'] = session('new');
      provider.setActiveSession(client.activeSessions['new']!);
      pending.complete();
      await action;
      expect(client.requests.map((r) => r.$1), ['one', 'two']);
      expect(provider.getActiveSessions().keys, ['new']);
      expect(provider.dAppTopic, 'new');
      expect(provider.walletConnectState, WalletConnectState.connect);
    },
  );

  test(
    'disconnect-all reports session-store failure instead of claiming success',
    () async {
      client.readError = StateError('store offline');
      await expectLater(provider.disconnectAllSessions(), throwsStateError);
      expect(client.requests, isEmpty);
      expect(provider.dAppTopic, 'one');
    },
  );

  test(
    'a changed client cannot redirect the rest of a disconnect-all request',
    () async {
      final replacement = _Client()..activeSessions['new'] = session('new');
      client.disconnect = (_) async {
        provider.signClient = replacement;
        provider.setActiveSession(replacement.activeSessions['new']!);
      };
      await provider.disconnectAllSessions();
      expect(client.requests.map((r) => r.$1), ['one', 'two']);
      expect(replacement.requests, isEmpty);
      expect(provider.getActiveSessions().keys, ['new']);
      expect(provider.dAppTopic, 'new');
    },
  );
}
