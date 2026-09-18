import 'dart:async';
import 'dart:typed_data';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_sender.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/encryption/key_manager.dart';
import 'package:matrix/encryption/olm_manager.dart';
import 'package:matrix/encryption/utils/olm_session.dart';
import 'package:matrix/encryption/utils/outbound_group_session.dart';
import 'package:vodozemac/vodozemac.dart' as vod;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/encrypted_send_guard.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/direct_chat_send_guard.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Uploader extends Mock implements MatrixMediaUploader {}

class _Client extends Mock implements Client {}

class _Room extends Mock implements Room {}

class _User extends Mock implements User {}

class _Device extends Mock implements DeviceKeys {}

class _Encryption extends Mock implements Encryption {}

class _Keys extends Mock implements KeyManager {}

class _Olm extends Mock implements OlmManager {}

class _OlmSession extends Mock implements OlmSession {}

class _Outbound extends Mock implements OutboundGroupSession {}

class _SignedDevice extends DeviceKeys {
  _SignedDevice(MatrixDeviceKeys keys, Client client)
    : super.fromMatrixDeviceKeys(keys, client);
  // This case isolates the sharing policy; signature verification belongs to SDK tests.
  @override
  bool get selfSigned => true;
}

void main() {
  if (!Platform.isMacOS &&
      Platform.environment['N42_VODOZEMAC_TEST_LIB'] == null) {
    test(
      'native encryption send guard',
      () {},
      skip:
          'Set N42_VODOZEMAC_TEST_LIB to the native vodozemac library on this host.',
    );
    return;
  }
  setUpAll(() async {
    final configFile = File('.dart_tool/package_config.json').absolute;
    final config =
        jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
    final package = (config['packages'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((p) => p['name'] == 'flutter_vodozemac');
    final packageRoot = configFile.uri
        .resolve(package['rootUri'] as String)
        .toFilePath();
    final override = Platform.environment['N42_VODOZEMAC_TEST_LIB'];
    final native =
        override ??
        '${packageRoot}/macos/flutter_vodozemac/flutter_vodozemac.xcframework/macos-arm64_x86_64/flutter_vodozemac.framework/flutter_vodozemac';
    final directory = await Directory.systemTemp.createTemp('n42-crypto-test-');
    addTearDown(() => directory.delete(recursive: true));
    final suffix = Platform.isMacOS ? 'dylib' : 'so';
    await Link(
      '${directory.path}/libvodozemac_bindings_dart.$suffix',
    ).create(native);
    await vod.init(libraryPath: '${directory.path}/');
  });
  late _Client client;
  late _Room room;
  late _Device peer;
  late _Keys keys;
  late _Olm olm;
  late Map<String, DeviceKeysList> lists;
  late Map<String, List<OlmSession>> sessions;
  late _Outbound outbound;
  setUp(() {
    client = _Client();
    room = _Room();
    keys = _Keys();
    olm = _Olm();
    outbound = _Outbound();
    final encryption = _Encryption();
    final group = vod.GroupSession();
    final self = _Device();
    peer = _Device();
    final devices = [self, peer];
    for (var i = 0; i < devices.length; i++) {
      final d = devices[i];
      when(() => d.userId).thenReturn(i == 0 ? '@me:hs' : '@peer:hs');
      when(() => d.deviceId).thenReturn(i == 0 ? 'ME' : 'PEER');
      when(() => d.curve25519Key).thenReturn(i == 0 ? 'self-key' : 'peer-key');
      when(() => d.blocked).thenReturn(false);
      when(() => d.isValid).thenReturn(true);
      when(() => d.encryptToDevice).thenReturn(true);
    }
    lists = {
      for (final id in ['@me:hs', '@peer:hs']) id: DeviceKeysList(id, client),
    };
    sessions = {
      'peer-key': [_OlmSession()],
    };
    when(() => client.userID).thenReturn('@me:hs');
    when(() => client.deviceID).thenReturn('ME');
    when(() => client.isLogged()).thenReturn(true);
    when(() => client.encryptionEnabled).thenReturn(true);
    when(() => client.encryption).thenReturn(encryption);
    when(() => client.firstSyncReceived).thenAnswer((_) async {});
    when(() => client.userDeviceKeys).thenReturn(lists);
    when(
      () => client.updateUserDeviceKeys(
        additionalUsers: any(named: 'additionalUsers'),
      ),
    ).thenAnswer((_) async {
      for (final list in lists.values) {
        list.outdated = false;
      }
    });
    when(
      () => client.sendToDeviceEncrypted(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(() => client.getRoomById('!room:hs')).thenReturn(room);
    when(() => room.client).thenReturn(client);
    when(() => room.encrypted).thenReturn(true);
    when(() => room.id).thenReturn('!room:hs');
    when(() => room.membership).thenReturn(Membership.join);
    final members = <User>[];
    for (final id in lists.keys) {
      final user = _User();
      when(() => user.id).thenReturn(id);
      when(() => user.membership).thenReturn(Membership.join);
      members.add(user);
    }
    when(() => room.requestParticipants()).thenAnswer((_) async => members);
    when(() => room.getUserDeviceKeys()).thenAnswer((_) async => devices);
    when(() => encryption.keyManager).thenReturn(keys);
    when(() => encryption.olmManager).thenReturn(olm);
    when(() => olm.olmSessions).thenReturn(sessions);
    when(
      () => olm.getOlmSessionsForDevicesFromDatabase(any()),
    ).thenAnswer((_) async {});
    when(() => olm.startOutgoingOlmSessions(any())).thenAnswer((_) async {});
    when(() => keys.loadOutboundGroupSession(any())).thenAnswer((_) async {});
    when(() => keys.getOutboundGroupSession(any())).thenReturn(outbound);
    when(
      () => keys.prepareOutboundGroupSession(any()),
    ).thenAnswer((_) async {});
    when(
      () => keys.clearOrUseOutboundGroupSession(any(), wipe: true, use: false),
    ).thenAnswer((_) async => true);
    when(() => outbound.devices).thenReturn({
      '@me:hs': {'ME': false},
      '@peer:hs': {'PEER': false},
    });
    when(() => outbound.outboundGroupSession).thenReturn(group);
  });
  for (final source in ['path', 'stream']) {
    test(
      'encrypted picker $source reaches SDK without plaintext upload',
      () async {
        final manager = _Manager();
        final uploader = _Uploader();
        when(() => manager.client).thenReturn(client);
        when(() => client.fileEncryptionEnabled).thenReturn(true);
        final payload = Uint8List.fromList([1, 2, 3, 4]);
        registerFallbackValue(
          MatrixFile(bytes: Uint8List(0), name: 'fallback'),
        );
        when(
          () => room.sendFileEvent(
            any(),
            extraContent: any(named: 'extraContent'),
          ),
        ).thenAnswer((call) async {
          final file = call.positionalArguments.first as MatrixFile;
          expect(file.bytes, payload);
          expect(file.name, 'video.bin');
          return 'event';
        });
        final directory = await Directory.systemTemp.createTemp(
          'n42-attachment-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final file = File('${directory.path}/video.bin');
        await file.writeAsBytes(payload);
        final sender = MatrixMediaSender(manager, uploader);
        expect(
          await sender.sendFileMessage(
            '!room:hs',
            filename: 'video.bin',
            filePath: source == 'path' ? file.path : null,
            fileStream: source == 'stream' ? Stream.value(payload) : null,
            fileSize: payload.length,
          ),
          'event',
        );
        verifyZeroInteractions(uploader);
        // A failed encrypted upload must never retry via plaintext media upload.
        when(
          () => room.sendFileEvent(
            any(),
            extraContent: any(named: 'extraContent'),
          ),
        ).thenThrow(StateError('upload failed'));
        await expectLater(
          sender.sendFileMessage(
            '!room:hs',
            filename: 'video.bin',
            filePath: file.path,
          ),
          throwsStateError,
        );
        verifyZeroInteractions(uploader);
      },
    );
  }
  test(
    'delivered Megolm key decrypts the next message on a fresh receiver',
    () async {
      Map<String, dynamic>? delivered;
      when(() => client.sendToDeviceEncrypted(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        delivered = invocation.positionalArguments[2] as Map<String, dynamic>;
      });
      await EncryptedSendGuard.prepare(room);
      final receiver = vod.InboundGroupSession(
        delivered!['session_key'] as String,
      );
      final ciphertext = outbound.outboundGroupSession!.encrypt('new message');
      expect(receiver.decrypt(ciphertext).plaintext, 'new message');
    },
  );
  test('plaintext rooms keep their existing send path', () async {
    when(() => room.encrypted).thenReturn(false);
    expect(await prepareRoomForSending(client, '!room:hs'), room);
    verifyNever(
      () => client.updateUserDeviceKeys(
        additionalUsers: any(named: 'additionalUsers'),
      ),
    );
  });
  test(
    'key delivery is awaited before allowing encrypted publication',
    () async {
      final sent = Completer<void>();
      when(
        () => client.sendToDeviceEncrypted(any(), any(), any()),
      ).thenAnswer((_) => sent.future);
      var ready = false;
      final result = EncryptedSendGuard.prepare(room).then((_) => ready = true);
      await Future<void>.delayed(Duration.zero);
      expect(ready, isFalse);
      sent.complete();
      await result;
      expect(ready, isTrue);
      await EncryptedSendGuard.prepare(room);
      verify(
        () => client.sendToDeviceEncrypted(any(), EventTypes.RoomKey, any()),
      ).called(1);
    },
  );
  test(
    'unverified recipient device stops new ciphertext from being sent',
    () async {
      when(() => peer.encryptToDevice).thenReturn(false);
      await expectLater(
        prepareRoomForSending(client, '!room:hs'),
        throwsA(isA<EncryptedSendNotReady>()),
      );
      verifyNever(() => keys.prepareOutboundGroupSession(any()));
    },
  );
  test(
    'missing one-time keys do not become a silent partial key distribution',
    () async {
      sessions.clear();
      await expectLater(
        EncryptedSendGuard.prepare(room),
        throwsA(isA<EncryptedSendNotReady>()),
      );
      verify(() => olm.startOutgoingOlmSessions(any())).called(1);
      verifyNever(() => keys.prepareOutboundGroupSession(any()));
    },
  );
  test(
    'new peer devices rotate the old session instead of SDK best-effort re-sharing',
    () async {
      when(() => outbound.devices).thenReturn({
        '@me:hs': {'ME': false},
        '@peer:hs': {'OLD': false},
      });
      await EncryptedSendGuard.prepare(room);
      verifyInOrder([
        () => keys.clearOrUseOutboundGroupSession(
          '!room:hs',
          wipe: true,
          use: false,
        ),
        () => keys.prepareOutboundGroupSession('!room:hs'),
        () => client.sendToDeviceEncrypted(any(), EventTypes.RoomKey, any()),
      ]);
    },
  );
  test(
    'network failure does not mark session delivered and retry re-sends keys',
    () async {
      when(
        () => client.sendToDeviceEncrypted(any(), any(), any()),
      ).thenThrow(StateError('Network down'));
      await expectLater(
        EncryptedSendGuard.prepare(room),
        throwsA(isA<EncryptedSendNotReady>()),
      );
      when(
        () => client.sendToDeviceEncrypted(any(), any(), any()),
      ).thenAnswer((_) async {});
      await EncryptedSendGuard.prepare(room);
      verify(
        () => client.sendToDeviceEncrypted(any(), EventTypes.RoomKey, any()),
      ).called(2);
    },
  );
  test(
    'stale device query cannot approve delivery using an old device list',
    () async {
      when(
        () => client.updateUserDeviceKeys(
          additionalUsers: any(named: 'additionalUsers'),
        ),
      ).thenAnswer((_) async {});
      await expectLater(
        EncryptedSendGuard.prepare(room),
        throwsA(isA<EncryptedSendNotReady>()),
      );
      verifyNever(() => keys.prepareOutboundGroupSession(any()));
    },
  );
  test(
    'SDK standard policy supports accounts without cross-signing but still rejects blocked devices',
    () {
      final device = _SignedDevice(
        MatrixDeviceKeys.fromJson({
          'user_id': '@peer:hs',
          'device_id': 'PEER',
          'algorithms': <String>[],
          'keys': {'ed25519:PEER': 'test-public-key'},
        }),
        client,
      );
      when(() => client.shareKeysWith).thenReturn(ShareKeysWith.crossVerified);
      expect(device.encryptToDevice, isFalse);
      when(
        () => client.shareKeysWith,
      ).thenReturn(ShareKeysWith.crossVerifiedIfEnabled);
      expect(device.encryptToDevice, isTrue);
      device.blocked = true;
      expect(device.encryptToDevice, isFalse);
    },
  );
}
