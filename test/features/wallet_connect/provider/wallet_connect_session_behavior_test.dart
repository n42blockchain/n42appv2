import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wallet_connect;

import '../../../helpers/wallet_connect_client_fake.dart';

class _UnavailableSessionStoreClient extends WalletKitFake {
  @override
  Map<String, wallet_connect.SessionData> getActiveSessions() =>
      throw StateError('session store unavailable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletKitFake client;
  late WalletConnectProvider provider;

  setUp(() {
    client = WalletKitFake();
    provider = WalletConnectProvider()
      ..signClient = client
      ..dAppTopic = 'selected-topic'
      ..walletConnectState = WalletConnectState.connect;
    provider.setChainInfo();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (_) async => true,
        );
  });

  tearDown(() {
    provider.signClient = null;
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          null,
        );
  });

  test('remote deletion of the selected session clears the active context', () {
    provider.errorMessage = 'stale session error';
    var notifications = 0;
    provider.addListener(() => notifications++);

    client.onSessionDelete.broadcast(
      wallet_connect.SessionDelete('selected-topic'),
    );

    expect(provider.dAppTopic, isNull);
    expect(provider.walletConnectState, WalletConnectState.disconnect);
    expect(provider.errorMessage, isEmpty);
    expect(notifications, 1);
  });

  test('deletion from another topic keeps the selected session connected', () {
    var notifications = 0;
    provider.addListener(() => notifications++);

    client.onSessionDelete.broadcast(
      wallet_connect.SessionDelete('other-topic'),
    );

    expect(provider.dAppTopic, 'selected-topic');
    expect(provider.walletConnectState, WalletConnectState.connect);
    expect(notifications, 1);
  });

  test('session-store read failure returns an empty session list', () {
    provider.signClient = _UnavailableSessionStoreClient();

    expect(provider.getActiveSessions(), isEmpty);
  });
}
