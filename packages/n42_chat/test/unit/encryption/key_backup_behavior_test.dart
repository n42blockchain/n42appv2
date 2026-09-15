import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/models/timeline_chunk.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/encryption/key_manager.dart';
import 'package:matrix/encryption/ssss.dart';
import 'package:matrix/encryption/utils/bootstrap.dart';
import 'package:matrix/encryption/utils/session_key.dart';
import 'package:n42_chat/src/core/encryption/room_key_backup_restore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/encryption/e2ee_manager.dart';
import 'package:n42_chat/src/core/encryption/key_backup_service.dart';

class _Client extends Mock implements Client {}

class _Encryption extends Mock implements Encryption {}

class _Keys extends Mock implements KeyManager {}

class _Secrets extends Mock implements SSSS {}

class _OpenSecrets extends Mock implements OpenSSSS {}

class _Bootstrap extends Mock implements Bootstrap {}

class _Session extends Mock implements SessionKey {}

class _Info extends Mock implements GetRoomKeysVersionCurrentResponse {}

class _Database extends Mock implements DatabaseApi {}

void main() {
  late _Client client;
  late _Encryption encryption;
  late _Keys keys;
  late _Secrets secrets;
  late _OpenSecrets open;
  setUpAll(() => registerFallbackValue(RoomKeys(rooms: {})));
  setUp(() {
    client = _Client();
    encryption = _Encryption();
    keys = _Keys();
    secrets = _Secrets();
    open = _OpenSecrets();
    when(() => client.encryption).thenReturn(encryption);
    when(() => encryption.keyManager).thenReturn(keys);
    when(() => encryption.ssss).thenReturn(secrets);
    when(() => secrets.open()).thenReturn(open);
    when(
      () => open.unlock(
        passphrase: any(named: 'passphrase'),
        recoveryKey: any(named: 'recoveryKey'),
      ),
    ).thenAnswer((_) async {});
    when(() => open.maybeCacheAll()).thenAnswer((_) async {});
    when(() => open.recoveryKey).thenReturn('fixture-recovery-key');
    when(() => keys.loadAllKeys()).thenAnswer((_) async {});
    when(() => keys.uploadInboundGroupSessions()).thenAnswer((_) async {});
    final info = _Info();
    when(() => info.version).thenReturn('v1');
    when(
      () => info.algorithm,
    ).thenReturn(BackupAlgorithm.mMegolmBackupV1Curve25519AesSha2);
    when(() => info.count).thenReturn(2);
    when(() => info.etag).thenReturn('etag');
    when(() => keys.getRoomKeysBackupInfo(any())).thenAnswer((_) async => info);
    when(
      () => client.getRoomKeys('v1'),
    ).thenAnswer((_) async => RoomKeys(rooms: {}));
    when(() => keys.loadFromResponse(any())).thenAnswer((_) async {});
    when(() => keys.isCached()).thenAnswer((_) async => true);
  });
  test(
    'server backup is discovered even without a local backup secret',
    () async {
      when(() => keys.enabled).thenReturn(false);
      final service = KeyBackupService(client);
      expect((await service.getBackupInfo())?.count, 2);
      expect(await service.hasKeyBackup(), isTrue);
      verify(() => keys.getRoomKeysBackupInfo(false)).called(2);
    },
  );
  for (final recovery in [false, true]) {
    test('E2EE unlock returns an empty restore count ($recovery)', () async {
      final manager = E2EEManager(client);
      final count = recovery
          ? await manager.unlockWithRecoveryKey('fixture')
          : await manager.unlockWithPassphrase('fixture');
      expect(count, 0);
      verify(() => client.getRoomKeys('v1')).called(1);
      verify(() => keys.getRoomKeysBackupInfo(false)).called(1);
    });
  }
  test(
    'restoring known sessions retries decryption in an existing SDK timeline',
    () async {
      final database = _Database();
      final streams = Client('recovery-fixture', database: database);
      when(() => client.onTimelineEvent).thenReturn(streams.onTimelineEvent);
      when(() => client.onHistoryEvent).thenReturn(streams.onHistoryEvent);
      when(() => client.onSync).thenReturn(streams.onSync);
      when(
        () => client.onCancelSendEvent,
      ).thenReturn(streams.onCancelSendEvent);
      when(() => client.database).thenReturn(database);
      when(() => client.encryptionEnabled).thenReturn(true);
      when(() => database.transaction(any())).thenAnswer(
        (invocation) =>
            (invocation.positionalArguments.single
                as Future<void> Function())(),
      );
      final room = Room(id: '!room:test', client: client);
      when(() => client.getRoomById(room.id)).thenReturn(room);
      Event encrypted(String id, String session) => Event.fromJson({
        'event_id': id,
        'type': EventTypes.Encrypted,
        'sender': '@alice:test',
        'origin_server_ts': 1,
        'content': {
          'msgtype': MessageTypes.BadEncrypted,
          'session_id': session,
        },
      }, room);
      final pending = encrypted(r'$pending', 'session');
      final missing = encrypted(r'$missing', 'not-backed-up');
      final clear = Event.fromJson({
        'event_id': r'$pending',
        'type': EventTypes.Message,
        'sender': '@alice:test',
        'origin_server_ts': 1,
        'content': {'msgtype': MessageTypes.Text, 'body': 'Recovered fixture'},
      }, room);
      when(
        () => encryption.decryptRoomEvent(
          pending,
          store: true,
          updateType: EventUpdateType.history,
        ),
      ).thenAnswer((_) async => clear);
      final updated = Completer<void>();
      final timeline = Timeline(
        room: room,
        chunk: TimelineChunk(events: [pending, missing]),
        onUpdate: () {
          if (!updated.isCompleted) updated.complete();
        },
      );
      addTearDown(timeline.cancelSubscriptions);
      addTearDown(room.onSessionKeyReceived.close);
      final backup = RoomKeys.fromJson({
        'rooms': {
          room.id: {
            'sessions': {
              'session': {
                'first_message_index': 0,
                'forwarded_count': 0,
                'is_verified': false,
                'session_data': <String, Object?>{},
              },
            },
          },
        },
      });
      when(() => client.getRoomKeys('v1')).thenAnswer((_) async => backup);
      final session = _Session();
      when(() => session.isValid).thenReturn(true);
      when(
        () => keys.loadInboundGroupSession(room.id, 'session'),
      ).thenAnswer((_) async => session);
      // loadFromResponse is a no-op, matching the SDK's already-known-key path.
      expect(await restoreRoomKeyBackup(client), 1);
      await updated.future.timeout(const Duration(seconds: 2));
      expect(timeline.events.first.body, 'Recovered fixture');
      expect(timeline.events.last.messageType, MessageTypes.BadEncrypted);
    },
  );
  for (final recovery in [false, true]) {
    test(
      'failed ${recovery ? 'recovery-key' : 'password'} download does not report restoration success',
      () async {
        when(
          () => client.getRoomKeys('v1'),
        ).thenThrow(StateError('backup unreachable'));
        final service = KeyBackupService(client);
        await expectLater(
          recovery
              ? service.restoreFromRecoveryKey('fixture')
              : service.restoreFromPassword('fixture'),
          throwsA(isA<KeyBackupException>()),
        );
        verifyNever(() => keys.startAutoUploadKeys());
      },
    );
  }
  test('password restore loads historical keys before completing', () async {
    expect(await KeyBackupService(client).restoreFromPassword('fixture'), 0);
    verifyInOrder([
      () => open.maybeCacheAll(),
      () => keys.loadFromResponse(any()),
      () => keys.startAutoUploadKeys(),
    ]);
  });
  test(
    'SDK silently skipping a session cannot report successful recovery',
    () async {
      final backup = RoomKeys.fromJson({
        'rooms': {
          '!room:test': {
            'sessions': {
              'session': {
                'first_message_index': 0,
                'forwarded_count': 0,
                'is_verified': false,
                'session_data': <String, Object?>{},
              },
            },
          },
        },
      });
      when(() => client.getRoomKeys('v1')).thenAnswer((_) async => backup);
      when(
        () => keys.loadInboundGroupSession('!room:test', 'session'),
      ).thenAnswer((_) async => null);
      await expectLater(restoreRoomKeyBackup(client), throwsStateError);
      final session = _Session();
      when(() => session.isValid).thenReturn(true);
      when(
        () => keys.loadInboundGroupSession('!room:test', 'session'),
      ).thenAnswer((_) async => session);
      expect(await restoreRoomKeyBackup(client), 1);
    },
  );
  test('locked backup cannot report an empty successful restore', () async {
    when(() => keys.isCached()).thenAnswer((_) async => false);
    await expectLater(restoreRoomKeyBackup(client), throwsStateError);
    verifyNever(() => client.getRoomKeys(any()));
  });
  test('creating a recovery key completes server backup setup', () async {
    final bootstrap = _Bootstrap();
    var state = BootstrapState.askNewSsss;
    when(() => encryption.bootstrap()).thenReturn(bootstrap);
    when(() => bootstrap.state).thenAnswer((_) => state);
    when(() => bootstrap.newSsssKey).thenReturn(open);
    when(
      () => bootstrap.newSsss(any()),
    ).thenAnswer((_) async => state = BootstrapState.askSetupCrossSigning);
    when(
      () => bootstrap.askSetupCrossSigning(),
    ).thenAnswer((_) async => state = BootstrapState.askSetupOnlineKeyBackup);
    when(
      () => bootstrap.askSetupOnlineKeyBackup(true),
    ).thenAnswer((_) async => state = BootstrapState.done);
    expect(
      await E2EEManager(client).createRecoveryKey(),
      'fixture-recovery-key',
    );
    verify(() => bootstrap.askSetupOnlineKeyBackup(true)).called(1);
    verify(() => keys.uploadInboundGroupSessions()).called(1);
    verify(() => keys.startAutoUploadKeys()).called(1);
  });
  test(
    'existing backup is preserved and locked secrets require recovery',
    () async {
      final bootstrap = _Bootstrap();
      var state = BootstrapState.askWipeSsss;
      when(() => encryption.bootstrap()).thenReturn(bootstrap);
      when(() => bootstrap.state).thenAnswer((_) => state);
      when(() => bootstrap.newSsssKey).thenReturn(open);
      when(() => open.isUnlocked).thenReturn(false);
      when(
        () => bootstrap.wipeSsss(false),
      ).thenAnswer((_) => state = BootstrapState.askUseExistingSsss);
      when(
        () => bootstrap.useExistingSsss(true),
      ).thenAnswer((_) => state = BootstrapState.openExistingSsss);
      await expectLater(
        E2EEManager(client).createRecoveryKey(),
        throwsA(isA<E2EEException>()),
      );
      verifyNever(() => bootstrap.wipeSsss(true));
      verifyNever(() => bootstrap.askSetupOnlineKeyBackup(true));
      verifyNever(() => keys.startAutoUploadKeys());
    },
  );
}
