import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_wallet/features/wallet_connect/security/reown_core_factory.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/security/reown_secure_store.dart';
import 'package:n42_wallet/features/wallet_connect/security/reown_keychain.dart';
import 'package:n42_wallet/features/wallet_connect/security/reown_pairing_recovery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reown_core/core_impl.dart';
import 'package:reown_core/models/basic_models.dart';
import 'package:reown_core/relay_client/i_relay_client.dart';
import 'package:reown_core/utils/utils.dart';
import 'package:reown_walletkit/reown_walletkit.dart'
    show Event, PairingMetadata, ReownWalletKit;
import 'package:package_info_plus/package_info_plus.dart';

class _Relay extends Mock implements IRelayClient {}

class _FailureBindingProvider extends WalletConnectProvider {
  void bindFailureCallback(ReownWalletKit client) =>
      bindReownKeyFailureCallback(client);
}

class _Platform extends TestFlutterSecureStoragePlatform {
  _Platform(super.data);

  bool failRead = false;
  bool failWrite = false;
  bool failDelete = false;
  bool writeThenThrowKeychain = false;

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    if (failRead) throw StateError('secure storage read failed');
    return Map.of(data);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (failWrite) throw StateError('secure storage write failed');
    await super.write(key: key, value: value, options: options);
    if (writeThenThrowKeychain && key == 'wc@2:core:0.3//keychain') {
      throw StateError('write committed but response failed');
    }
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    if (failDelete) throw StateError('secure storage delete failed');
    await super.delete(key: key, options: options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Platform platform;
  late N42ReownSecureStore storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    platform = _Platform({});
    FlutterSecureStoragePlatform.instance = platform;
    storage = N42ReownSecureStore();
  });

  test('read failure fails closed without plaintext fallback', () async {
    platform.failRead = true;
    await expectLater(storage.init(), throwsStateError);
    expect(() => storage.get('keychain'), throwsStateError);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  test(
    'malformed keychain and other Reown JSON fail before deletion',
    () async {
      for (final value in ['{broken', '[]', '{"topic":42}']) {
        platform.data['wc@2:core:0.3//keychain'] = value;
        await expectLater(N42ReownSecureStore().init(), throwsStateError);
        expect(platform.data['wc@2:core:0.3//keychain'], value);
      }
      platform.data['wc@2:core:0.3//keychain'] = '{}';
      platform.data['wc@2:core:other'] = '[]';
      await expectLater(N42ReownSecureStore().init(), throwsStateError);
      expect(platform.data['wc@2:core:other'], '[]');
    },
  );

  test('write persists before publishing and poisons on error', () async {
    await storage.init();
    platform.failWrite = true;
    await expectLater(
      storage.set('0.3//keychain', {'topic': 'secret'}),
      throwsStateError,
    );
    expect(platform.data, isEmpty);
    expect(() => storage.has('0.3//keychain'), throwsStateError);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  test(
    'restart restores keys and deleteAll preserves other secure values',
    () async {
      platform.data['auth_token'] = 'host-secret';
      await storage.init();
      await storage.set('keychain', {'version': '0.3'});
      await storage.set('0.3//keychain', {'topic': 'sym-key'});
      final restart = N42ReownSecureStore();
      await restart.init();
      expect(restart.get('0.3//keychain'), {'topic': 'sym-key'});
      await restart.deleteAll();
      expect(platform.data, {'auth_token': 'host-secret'});
    },
  );

  test('delete failure leaves no usable in-memory state', () async {
    await storage.init();
    await storage.set('keychain', {'version': '0.3'});
    platform.failDelete = true;
    await expectLater(storage.delete('keychain'), throwsStateError);
    expect(() => storage.get('keychain'), throwsStateError);
    expect(platform.data['wc@2:core:keychain'], jsonEncode({'version': '0.3'}));
  });

  test(
    'keychain restores client and topic secrets on a fresh instance',
    () async {
      final keychain = N42ReownKeychain(storage: storage);
      await keychain.init();
      await keychain.set('CLIENT_SEED', 'seed');
      await keychain.set('topic', 'sym-key');
      final restart = N42ReownKeychain(storage: N42ReownSecureStore());
      await restart.init();
      expect(restart.get('CLIENT_SEED'), 'seed');
      expect(restart.get('topic'), 'sym-key');
      expect(restart.getAll(), containsAll(['seed', 'sym-key']));
    },
  );

  test(
    'keychain failed write emits no create and requires a fresh instance',
    () async {
      final keychain = N42ReownKeychain(storage: storage);
      await keychain.init();
      var creates = 0;
      keychain.onCreate.subscribe((_) => creates++);
      platform.failWrite = true;
      await expectLater(keychain.set('topic', 'sym-key'), throwsStateError);
      expect(creates, 0);
      expect(() => keychain.get('topic'), throwsStateError);
      platform.failWrite = false;
      final fresh = N42ReownKeychain(storage: N42ReownSecureStore());
      await fresh.init();
      expect(fresh.get('topic'), isNull);
      await fresh.set('topic', 'sym-key');
      expect(fresh.get('topic'), 'sym-key');
    },
  );

  test('failed topic write retains the durable client seed', () async {
    final keychain = N42ReownKeychain(storage: storage);
    await keychain.init();
    await keychain.set('CLIENT_SEED', 'stable-seed');
    platform.failWrite = true;
    await expectLater(keychain.set('topic', 'failed-key'), throwsStateError);
    expect(jsonDecode(platform.data['wc@2:core:0.3//keychain']!), {
      'CLIENT_SEED': 'stable-seed',
    });
    platform.failWrite = false;
    final fresh = N42ReownKeychain(storage: N42ReownSecureStore());
    await fresh.init();
    expect(fresh.get('CLIENT_SEED'), 'stable-seed');
    expect(fresh.get('topic'), isNull);
  });

  test('failure callback cannot mask the original persistence error', () async {
    var callbacks = 0;
    final keychain = N42ReownKeychain(
      storage: storage,
      onPersistenceFailure: (_) async {
        callbacks++;
        throw StateError('callback failed');
      },
    );
    await keychain.init();
    platform.failWrite = true;
    await expectLater(
      keychain.set('topic', 'sym-key'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'secure storage write failed',
        ),
      ),
    );
    expect(callbacks, 1);
    expect(() => keychain.get('topic'), throwsStateError);
  });

  test('core injects both secure fields before SDK initialization', () async {
    final upstream = ReownCore(projectId: 'test-project');
    final oldSecureStore = upstream.secureStorage;
    final oldKeychain = upstream.crypto.keyChain;
    final core = configureN42ReownCore(upstream);
    expect(core.secureStorage, isA<N42ReownSecureStore>());
    expect(core.crypto.keyChain, isA<N42ReownKeychain>());
    expect(core.crypto.keyChain.storage, same(core.secureStorage));
    final relay = _Relay();
    core.relayClient = relay;
    platform.failRead = true;
    await expectLater(core.start(), throwsStateError);
    verifyNever(() => relay.init());
    expect(() => oldSecureStore.get('keychain'), throwsA(anything));
    expect(() => oldKeychain.has('CLIENT_SEED'), throwsA(anything));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  test('failed startup does not publish a WalletKit client', () async {
    platform.failRead = true;
    final provider = WalletConnectProvider();
    addTearDown(provider.dispose);
    await provider.connectInit();
    expect(provider.signClient, isNull);
    expect(provider.walletConnectState, WalletConnectState.error);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
  });

  testWidgets(
    'active key failure stops old heartbeat and permits fresh recovery',
    (tester) async {
      final provider = _FailureBindingProvider();
      addTearDown(provider.dispose);
      Future<(ReownWalletKit, _Relay)> client() async {
        final core = createN42ReownCore(projectId: 'test-project');
        final relay = _Relay();
        when(() => relay.disconnect()).thenAnswer((_) async {});
        core.relayClient = relay;
        final kit = ReownWalletKit(
          core: core,
          metadata: PairingMetadata(
            name: 'N42',
            description: 'N42',
            url: 'https://n42.ai',
            icons: const ['https://n42.ai/icon.png'],
          ),
        );
        provider.bindFailureCallback(kit);
        await (core.crypto.keyChain as N42ReownKeychain).init();
        return (kit, relay);
      }

      final (oldClient, oldRelay) = await client();
      provider.signClient = oldClient;
      provider.dAppTopic = 'old-session';
      provider.eventsRegistered = true;
      var oldPulses = 0;
      oldClient.core.heartbeat.interval = 1;
      oldClient.core.heartbeat.onPulse.subscribe((_) => oldPulses++);
      oldClient.core.heartbeat.init();

      platform.failWrite = true;
      await expectLater(
        oldClient.core.crypto.keyChain.set('failed-topic', 'sym-key'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'secure storage write failed',
          ),
        ),
      );
      expect(provider.signClient, isNull);
      expect(provider.dAppTopic, isNull);
      expect(provider.eventsRegistered, isFalse);
      verify(() => oldRelay.disconnect()).called(1);
      await tester.pump(const Duration(seconds: 2));
      expect(oldPulses, 0);

      platform.failWrite = false;
      final (freshClient, _) = await client();
      provider.signClient = freshClient;
      await freshClient.core.crypto.keyChain.set('recovered-topic', 'new-key');
      expect(
        freshClient.core.crypto.keyChain.get('recovered-topic'),
        'new-key',
      );
      expect(provider.signClient, same(freshClient));
      oldClient.core.heartbeat.stop();
      freshClient.core.heartbeat.stop();
    },
  );

  testWidgets('stale key failure retires only its owning heartbeat', (
    tester,
  ) async {
    final provider = _FailureBindingProvider();
    addTearDown(provider.dispose);
    final oldCore = createN42ReownCore(projectId: 'test-project');
    final newCore = createN42ReownCore(projectId: 'test-project');
    final oldRelay = _Relay();
    final newRelay = _Relay();
    when(() => oldRelay.disconnect()).thenAnswer((_) async {});
    when(() => newRelay.disconnect()).thenAnswer((_) async {});
    oldCore.relayClient = oldRelay;
    newCore.relayClient = newRelay;
    ReownWalletKit kit(ReownCore core) => ReownWalletKit(
      core: core,
      metadata: PairingMetadata(
        name: 'N42',
        description: 'N42',
        url: 'https://n42.ai',
        icons: const ['https://n42.ai/icon.png'],
      ),
    );
    final oldClient = kit(oldCore);
    final newClient = kit(newCore);
    provider.bindFailureCallback(oldClient);
    provider.bindFailureCallback(newClient);
    await (oldCore.crypto.keyChain as N42ReownKeychain).init();
    await (newCore.crypto.keyChain as N42ReownKeychain).init();
    provider.signClient = newClient;
    provider.dAppTopic = 'new-session';
    provider.eventsRegistered = true;
    var oldPulses = 0;
    var newPulses = 0;
    oldCore.heartbeat.interval = 1;
    newCore.heartbeat.interval = 1;
    oldCore.heartbeat.onPulse.subscribe((_) => oldPulses++);
    newCore.heartbeat.onPulse.subscribe((_) => newPulses++);
    oldCore.heartbeat.init();
    newCore.heartbeat.init();

    platform.failWrite = true;
    await expectLater(
      oldCore.crypto.keyChain.set('failed-topic', 'sym-key'),
      throwsStateError,
    );
    expect(provider.signClient, same(newClient));
    expect(provider.dAppTopic, 'new-session');
    expect(provider.eventsRegistered, isTrue);
    verify(() => oldRelay.disconnect()).called(1);
    verifyNever(() => newRelay.disconnect());
    await tester.pump(const Duration(seconds: 2));
    expect(oldPulses, 0);
    expect(newPulses, greaterThan(0));
    oldCore.heartbeat.stop();
    newCore.heartbeat.stop();
  });

  testWidgets('provider disposal stops the active Reown heartbeat', (
    tester,
  ) async {
    final provider = WalletConnectProvider();
    final core = createN42ReownCore(projectId: 'test-project');
    final relay = _Relay();
    when(() => relay.disconnect()).thenAnswer((_) async {});
    core.relayClient = relay;
    final client = ReownWalletKit(
      core: core,
      metadata: PairingMetadata(
        name: 'N42',
        description: 'N42',
        url: 'https://n42.ai',
        icons: const ['https://n42.ai/icon.png'],
      ),
    );
    provider.signClient = client;
    var pulses = 0;
    core.heartbeat.interval = 1;
    core.heartbeat.onPulse.subscribe((_) => pulses++);
    core.heartbeat.init();

    provider.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(pulses, 0);
    verify(() => relay.disconnect()).called(1);
    core.heartbeat.stop();
  });

  test('actual SDK client identity and symkey survive restart', () async {
    Future<ReownCore> startCrypto() async {
      final core = createN42ReownCore(projectId: 'test-project');
      await core.crypto.init();
      return core;
    }

    final first = await startCrypto();
    final clientId = await first.crypto.getClientId();
    await first.crypto.setSymKey('fixture-symkey', overrideTopic: 'topic');
    final second = await startCrypto();
    expect(await second.crypto.getClientId(), clientId);
    expect(second.crypto.keyChain.get('topic'), 'fixture-symkey');
  });

  test('Reown package identity call works with package_info_plus 10', () async {
    PackageInfo.setMockInitialValues(
      appName: 'N42',
      packageName: 'com.n42.test',
      version: '1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    expect(await ReownCoreUtils.getPackageName(), 'com.n42.test');
  });

  test(
    'keychain rejects unknown version without deleting credentials',
    () async {
      platform.data['wc@2:core:keychain'] = '{"version":"0.2"}';
      platform.data['wc@2:core:0.2//keychain'] = '{"topic":"old-secret"}';
      final keychain = N42ReownKeychain(storage: storage);
      await expectLater(keychain.init(), throwsStateError);
      expect(
        platform.data['wc@2:core:0.2//keychain'],
        '{"topic":"old-secret"}',
      );
    },
  );

  test('recovery deletes only a newly inserted orphan pairing', () async {
    var deleted = '';
    Future<void> delete(String topic) async => deleted = topic;
    await reconcileFailedNewPairing(
      topic: 'new-topic',
      existedBefore: false,
      deletePairing: delete,
    );
    expect(deleted, 'new-topic');
    deleted = '';
    await reconcileFailedNewPairing(
      topic: 'existing-topic',
      existedBefore: true,
      deletePairing: delete,
    );
    expect(deleted, isEmpty);
  });

  test('recovery retains pairing after uncertain durable write', () async {
    platform.data['wc@2:core:0.3//keychain'] = '{"topic":"sym-key"}';
    var deleted = false;
    await reconcileFailedNewPairing(
      topic: 'topic',
      existedBefore: false,
      deletePairing: (_) async => deleted = true,
    );
    expect(deleted, isFalse);
  });

  test('recovery preserves metadata when durable read fails', () async {
    platform.failRead = true;
    var deleted = false;
    await expectLater(
      reconcileFailedNewPairing(
        topic: 'topic',
        existedBefore: false,
        deletePairing: (_) async => deleted = true,
      ),
      throwsStateError,
    );
    expect(deleted, isFalse);
  });

  test(
    'actual Reown pairing retries same URI after failed secure key write',
    () async {
      registerFallbackValue(SubscribeOptions(topic: 'fallback'));
      Future<(ReownCore, _Relay)> createCore() async {
        final core = ReownCore(projectId: 'test-project');
        final relay = _Relay();
        when(() => relay.onRelayClientConnect).thenReturn(Event());
        when(() => relay.onRelayClientMessage).thenReturn(Event());
        when(() => relay.onLinkModeMessage).thenReturn(Event());
        when(() => relay.isConnected).thenReturn(false);
        when(() => relay.subscribe(options: any(named: 'options')))
            .thenAnswer((_) async => 'subscription');
        core.relayClient = relay;
        final secure = N42ReownSecureStore();
        core.secureStorage = secure;
        core.crypto.keyChain = N42ReownKeychain(storage: secure);
        await core.storage.init();
        await secure.init();
        await core.crypto.init();
        await core.pairing.init();
        return (core, relay);
      }

      final topic = 'b' * 64;
      final symKey = 'a' * 64;
      final uri = Uri.parse('wc:$topic@2?relay-protocol=irn&symKey=$symKey');
      final (firstCore, firstRelay) = await createCore();
      expect(firstCore.pairing.getStore().has(topic), isFalse);
      platform.failWrite = true;
      await expectLater(firstCore.pairing.pair(uri: uri), throwsStateError);
      verifyNever(() => firstRelay.subscribe(options: any(named: 'options')));
      expect(firstCore.pairing.getStore().has(topic), isTrue);
      await reconcileFailedNewPairing(
        topic: topic,
        existedBefore: false,
        deletePairing: firstCore.pairing.getStore().delete,
      );
      expect(firstCore.pairing.getStore().has(topic), isFalse);
      platform.failWrite = false;
      final (retryCore, retryRelay) = await createCore();
      final pairing = await retryCore.pairing.pair(uri: uri);
      expect(pairing.topic, topic);
      expect(retryCore.crypto.keyChain.get(topic), symKey);
      verify(() => retryRelay.subscribe(options: any(named: 'options')))
          .called(1);

      final uncertainTopic = 'c' * 64;
      final uncertainUri = Uri.parse(
        'wc:$uncertainTopic@2?relay-protocol=irn&symKey=$symKey',
      );
      final (uncertainCore, uncertainRelay) = await createCore();
      platform.writeThenThrowKeychain = true;
      await expectLater(
        uncertainCore.pairing.pair(uri: uncertainUri),
        throwsStateError,
      );
      verifyNever(
        () => uncertainRelay.subscribe(options: any(named: 'options')),
      );
      await reconcileFailedNewPairing(
        topic: uncertainTopic,
        existedBefore: false,
        deletePairing: uncertainCore.pairing.getStore().delete,
      );
      expect(uncertainCore.pairing.getStore().has(uncertainTopic), isTrue);
      platform.writeThenThrowKeychain = false;
      final (uncertainRetryCore, uncertainRetryRelay) = await createCore();
      expect(uncertainRetryCore.crypto.keyChain.get(uncertainTopic), symKey);
      await uncertainRetryCore.pairing.pair(uri: uncertainUri);
      verify(
        () => uncertainRetryRelay.subscribe(options: any(named: 'options')),
      ).called(1);
    },
  );
}
