import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../helpers/wallet_connect_client_fake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletKitFake client;
  late SessionPreviewProvider provider;
  setUp(() {
    client = WalletKitFake();
    provider = SessionPreviewProvider()
      ..signClient = client
      ..dAppTopic = 'selected';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (_) async => true,
        );
  });
  tearDown(() {
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          null,
        );
  });

  testWidgets(
    'failed reconnects use actual 2/4/8/16/30 second timers then stop',
    (tester) async {
      client.core.relayClient.onConnect = () async =>
          throw StateError('offline');
      provider.scheduleReconnect();
      var attempts = 0;
      for (final delay in [2, 4, 8, 16, 30]) {
        await tester.pump(Duration(milliseconds: delay * 1000 - 1));
        expect(client.core.relayClient.connects, attempts);
        await tester.pump(const Duration(milliseconds: 1));
        expect(client.core.relayClient.connects, ++attempts);
      }
      expect(provider.reconnectAttempts, 5);
      expect(provider.reconnectTimer, isNull);
      expect(provider.states, [WalletConnectState.disconnect]);
      await tester.pump(const Duration(minutes: 1));
      expect(client.core.relayClient.connects, 5);
    },
  );

  testWidgets(
    'successful retry resets the backoff and stops further attempts',
    (tester) async {
      provider.reconnectAttempts = 2;
      provider.scheduleReconnect();
      await tester.pump(const Duration(seconds: 8));
      expect(client.core.relayClient.connects, 1);
      expect(provider.reconnectAttempts, 0);
      expect(provider.states, isEmpty);
      await tester.pump(const Duration(minutes: 1));
      expect(client.core.relayClient.connects, 1);
    },
  );

  testWidgets('rescheduling cancels the previous retry deadline', (
    tester,
  ) async {
    provider.scheduleReconnect();
    await tester.pump(const Duration(seconds: 1));
    provider.scheduleReconnect();
    await tester.pump(const Duration(seconds: 1));
    expect(client.core.relayClient.connects, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(client.core.relayClient.connects, 1);
  });

  testWidgets('explicit cancellation prevents reconnecting', (tester) async {
    provider.scheduleReconnect();
    provider.cancelReconnectTimer();
    await tester.pump(const Duration(seconds: 30));
    expect(client.core.relayClient.connects, 0);
    expect(provider.reconnectTimer, isNull);
  });

  testWidgets('lost client while waiting does not contact the old relay', (
    tester,
  ) async {
    provider.scheduleReconnect();
    provider.signClient = null;
    await tester.pump(const Duration(seconds: 2));
    expect(client.core.relayClient.connects, 0);
    expect(provider.states, isEmpty);
  });

  testWidgets('relay connect event cancels pending retry and resets attempts', (
    tester,
  ) async {
    provider.setChainInfo();
    provider.reconnectAttempts = 3;
    provider.scheduleReconnect();
    client.core.relayClient.onRelayClientConnect.broadcast();
    expect(provider.reconnectTimer, isNull);
    expect(provider.reconnectAttempts, 0);
    await tester.pump(const Duration(seconds: 30));
    expect(client.core.relayClient.connects, 0);
  });

  for (final event in ['disconnect', 'error']) {
    testWidgets('relay $event schedules a retry only with an active session', (
      tester,
    ) async {
      provider.setChainInfo();
      void emit() {
        if (event == 'disconnect') {
          client.core.relayClient.onRelayClientDisconnect.broadcast();
        } else {
          client.core.relayClient.onRelayClientError.broadcast(
            wc.ErrorEvent('offline'),
          );
        }
      }

      provider.dAppTopic = null;
      emit();
      expect(provider.reconnectTimer, isNull);
      provider.dAppTopic = 'selected';
      emit();
      await tester.pump(const Duration(seconds: 2));
      expect(client.core.relayClient.connects, 1);
    });
  }

  testWidgets('foreground resume reconnects before pinging the active topic', (
    tester,
  ) async {
    final connection = Completer<void>();
    client.core.relayClient.onConnect = () => connection.future;
    provider.onAppResumed();
    expect(client.core.relayClient.connects, 1);
    expect(client.reOwnSign.pings, isEmpty);
    connection.complete();
    await tester.pump();
    expect(client.reOwnSign.pings, ['selected']);
    expect(provider.states, isEmpty);
  });

  testWidgets(
    'foreground reconnect failure schedules a retry without pinging',
    (tester) async {
      client.core.relayClient.onConnect = () async =>
          throw StateError('offline');
      provider.onAppResumed();
      await tester.pump();
      expect(provider.reconnectTimer?.isActive, isTrue);
      expect(client.reOwnSign.pings, isEmpty);
      provider.cancelReconnectTimer();
    },
  );

  testWidgets(
    'ping timeout disconnects only after the full ten-second deadline',
    (tester) async {
      final ping = Completer<void>();
      client.reOwnSign.onPing = () => ping.future;
      final action = provider.pingSession();
      await tester.pump(const Duration(milliseconds: 9999));
      expect(provider.states, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      await action;
      expect(provider.states, [WalletConnectState.disconnect]);
      ping.complete();
      await tester.pump(const Duration(seconds: 7));
      expect(provider.states, hasLength(1));
    },
  );

  testWidgets('successful ping cancels its timeout', (tester) async {
    await provider.pingSession();
    expect(client.reOwnSign.pings, ['selected']);
    await tester.pump(const Duration(seconds: 11));
    expect(provider.states, isEmpty);
  });
}
