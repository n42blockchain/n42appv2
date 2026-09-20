import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vodozemac/vodozemac.dart' as vod;
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_message_datasource.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/repositories/message_repository_impl.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_contact_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_message_sender.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';

// Explicit live acceptance only. N42_QA_STATE must point to a mode-0600 file
// containing disposable accounts and a rooms array, managed by the QA runner.
// Never supply user accounts. The runner must deactivate all test accounts.
// SQLite and crypto are real; secure storage/preferences remain mocked here.
void main() {
  test(
    'sequential accounts retain independent device identities and decrypt offline messages',
    () async {
      HttpOverrides.global = null;
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final pkg = (config['packages'] as List).firstWhere(
        (p) => p['name'] == 'flutter_vodozemac',
      );
      final root = configFile.uri
          .resolve(pkg['rootUri'] as String)
          .toFilePath();
      final dir = await Directory.systemTemp.createTemp('n42-live-crypto-');
      addTearDown(() => dir.delete(recursive: true));
      await Link('${dir.path}/libvodozemac_bindings_dart.dylib').create(
        '$root/macos/flutter_vodozemac/flutter_vodozemac.xcframework/macos-arm64_x86_64/flutter_vodozemac.framework/flutter_vodozemac',
      );
      await vod.init(libraryPath: '${dir.path}/');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final stateFile = File(Platform.environment['N42_QA_STATE']!);
      final state =
          jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
      final accounts = state['accounts'] as List;
      expect(stateFile.statSync().mode & 0x3f, 0);
      expect(accounts, hasLength(2));
      expect(
        accounts.every((a) => (a['user_id'] as String).startsWith('@n42qa_')),
        isTrue,
      );
      expect(state['rooms'], isEmpty);
      final manager = MatrixClientManager.instance;
      await manager.initialize(databasePath: dir.path);
      final auth = MatrixAuthDataSource(clientManager: manager);
      // Keep the same repository across accounts, as application DI does.
      final messages = MessageRepositoryImpl(
        MatrixMessageDataSource(manager),
        manager,
        PreferencesDataSource(),
      );
      Future<void> expectRepositoryReadable(
        String roomId,
        String eventId,
        String body,
      ) async {
        final visible = await messages
            .watchMessages(roomId)
            .firstWhere(
              (items) => items.any((m) => m.id == eventId && m.content == body),
            )
            .timeout(const Duration(seconds: 25));
        expect(visible.singleWhere((m) => m.id == eventId).content, body);
      }

      Future<void> signIn(int i) async {
        final result = await auth.loginWithPassword(
          homeserver: 'https://m.si46.world',
          username: accounts[i]['user_id'] as String,
          password: accounts[i]['password'] as String,
        );
        accounts[i]['access_token'] = result.accessToken;
        accounts[i]['device_id'] = result.deviceId;
        stateFile.writeAsStringSync(jsonEncode(state));
        await manager.client!.firstSyncReceived;
      }

      Future<void> switchTo(int i) async {
        await auth.loginWithToken(
          homeserver: 'https://m.si46.world',
          accessToken: accounts[i]['access_token'] as String,
          userId: accounts[i]['user_id'] as String,
          deviceId: accounts[i]['device_id'] as String,
        );
        await manager.client!.firstSyncReceived;
        expect(manager.userId, accounts[i]['user_id']);
      }

      Future<void> expectReadable(
        String roomId,
        String eventId,
        String body,
      ) async {
        final timeline = await manager.client!
            .getRoomById(roomId)!
            .getTimeline();
        try {
          if (!timeline.events.any((e) => e.eventId == eventId)) {
            await timeline.requestHistory(historyCount: 50);
          }
          for (var i = 0; i < 80; i++) {
            if (timeline.events.any(
              (e) => e.eventId == eventId && e.body == body,
            ))
              return;
            await Future<void>.delayed(const Duration(milliseconds: 250));
          }
          final matches = timeline.events.where((e) => e.eventId == eventId);
          fail(
            'Unreadable fixture: $body; matches=${matches.length}; '
            'types=${matches.map((e) => e.messageType).toList()}; '
            'errors=${matches.map((e) => e.body).toList()}',
          );
        } finally {
          timeline.cancelSubscriptions();
        }
      }

      try {
        await switchTo(
          0,
        ); // A fresh, server-issued token without prior device keys.
        final aDevice = manager.client!.deviceID;
        final aFingerprint = manager.client!.fingerprintKey;
        final contacts = MatrixContactDataSource(manager);
        final roomId = await contacts.startDirectChat(
          accounts[1]['user_id'] as String,
        );
        (state['rooms'] as List).add(roomId);
        stateFile.writeAsStringSync(jsonEncode(state));
        await signIn(1);
        final bDevice = manager.client!.deviceID;
        final bFingerprint = manager.client!.fingerprintKey;
        for (
          var i = 0;
          i < 80 && manager.client!.getRoomById(roomId) == null;
          i++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
        await contacts.acceptInvite(roomId);
        await switchTo(0);
        expect(manager.client!.deviceID, aDevice);
        expect(manager.client!.fingerprintKey, aFingerprint);
        final sender = MatrixMessageSender(
          manager,
          MatrixMediaUploader(manager),
        );
        final first = await sender.sendTextMessage(
          roomId,
          'N42 sequential retained A to B',
        );
        expect(first, isNotNull);
        await switchTo(1);
        await expectRepositoryReadable(
          roomId,
          first!,
          'N42 sequential retained A to B',
        );
        expect(manager.client!.deviceID, bDevice);
        expect(manager.client!.fingerprintKey, bFingerprint);
        await expectReadable(roomId, first, 'N42 sequential retained A to B');
        print(
          'QA real manager sequential A-to-B decryption passed; identity retained',
        );
        final second = await sender.sendTextMessage(
          roomId,
          'N42 sequential retained B to A',
        );
        expect(second, isNotNull);
        await switchTo(0);
        await expectRepositoryReadable(
          roomId,
          second!,
          'N42 sequential retained B to A',
        );
        await expectReadable(roomId, second, 'N42 sequential retained B to A');
        print(
          'QA real manager sequential B-to-A decryption passed; identity retained',
        );
        // Reuse the outbound session and cached repository after another switch.
        final third = await sender.sendTextMessage(
          roomId,
          'N42 retained session second message',
        );
        await switchTo(1);
        await expectRepositoryReadable(
          roomId,
          third!,
          'N42 retained session second message',
        );
        await switchTo(0);
        await manager.dispose();
        await manager.initialize(databasePath: dir.path);
        expect(manager.userId, accounts[0]['user_id']);
        expect(manager.client!.deviceID, aDevice);
        await expectReadable(roomId, second, 'N42 sequential retained B to A');
        await switchTo(1);
        await expectReadable(roomId, first, 'N42 sequential retained A to B');
        print(
          'QA manager restart and subsequent switch preserve both accounts',
        );
        try {
          await auth.loginWithPassword(
            homeserver: 'https://m.si46.world',
            username: accounts[0]['user_id'] as String,
            password: 'deliberately-invalid-fixture',
          );
          fail('Wrong password unexpectedly succeeded');
        } on matrix.MatrixException {
          expect(manager.userId, accounts[1]['user_id']);
          expect(manager.client!.deviceID, bDevice);
          expect(manager.client!.fingerprintKey, bFingerprint);
        }
        print(
          'QA failed new-account login restores previous device and identity',
        );
        await switchTo(0);
        await auth.logout();
        expect(manager.isLoggedIn, isFalse);
        await switchTo(1);
        await expectReadable(roomId, first, 'N42 sequential retained A to B');
        print(
          'QA explicit logout remains destructive only for its own session',
        );
        await signIn(0); // Refresh cleanup credentials after explicit logout.
        expect(manager.client!.deviceID, isNot(aDevice));
      } finally {
        messages.disposeAllTimelines();
        await manager.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
    skip: !Platform.isMacOS || Platform.environment['N42_QA_STATE'] == null,
  );
}
