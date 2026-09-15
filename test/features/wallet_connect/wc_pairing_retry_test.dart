import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../helpers/wallet_connect_client_fake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletKitFake client;
  late SessionPreviewProvider provider;
  const uri = 'wc:fixture-topic@2?relay-protocol=irn&symKey=fixture-key';

  setUp(() {
    client = WalletKitFake();
    provider = SessionPreviewProvider()..signClient = client;
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

  test('valid pairing passes the URI to the SDK and notifies once', () async {
    var notifications = 0;
    provider.addListener(() => notifications++);
    expect(await provider.pair(uri), isTrue);
    expect(client.pairingRequests, [Uri.parse(uri)]);
    expect(notifications, 1);
    expect(provider.states, isEmpty);
  });

  for (final invalid in [
    '',
    'https://example.test',
    'wc:missing-parameters@2',
  ]) {
    test(
      'invalid URI $invalid is rejected before contacting the SDK',
      () async {
        expect(await provider.pair(invalid), isFalse);
        expect(client.pairingRequests, isEmpty);
        expect(provider.states, [WalletConnectState.error]);
      },
    );
  }

  for (final message in ['Pairing already exists', 'Already connected']) {
    test('$message permits a retry of the same active pairing', () async {
      client.pairingError = StateError(message);
      client.core.pairing.activePairings.add(pairingInfo('fixture-topic'));
      var notifications = 0;
      provider.addListener(() => notifications++);
      expect(await provider.pair(uri), isTrue);
      expect(notifications, 1);
      expect(provider.states, isEmpty);
    });
  }

  for (final (topic, active) in [
    ('other-topic', true),
    ('fixture-topic', false),
  ]) {
    test(
      'duplicate pairing does not succeed for $topic active=$active',
      () async {
        client.pairingError = StateError('Pairing already exists');
        client.core.pairing.activePairings.add(
          pairingInfo(topic, active: active),
        );
        var notifications = 0;
        provider.addListener(() => notifications++);
        expect(await provider.pair(uri), isFalse);
        expect(notifications, 0);
      },
    );
  }

  test(
    'SDK failure is surfaced and a later explicit retry can succeed',
    () async {
      client.pairingError = StateError('relay offline');
      expect(await provider.pair(uri), isFalse);
      expect(provider.errorMessage, contains('relay offline'));
      expect(provider.states, [WalletConnectState.error]);
      client.pairingError = null;
      expect(await provider.pair(uri), isTrue);
      expect(client.pairingRequests, hasLength(2));
    },
  );
}
