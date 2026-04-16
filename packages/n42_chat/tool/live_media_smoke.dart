#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/core/services/download_service.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_message_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_event_mapper.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_sender.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_media_uploader.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  try {
    await runLiveMediaSmoke();
  } catch (error, stackTrace) {
    stderr.writeln('');
    stderr.writeln('Live media smoke failed: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  }
}

Future<void> runLiveMediaSmoke({Map<String, String>? environment}) async {
  final env = environment ?? Platform.environment;
  final homeserver = env['N42_TEST_HOMESERVER']?.trim().isNotEmpty == true
      ? env['N42_TEST_HOMESERVER']!.trim()
      : 'https://m.si46.world';
  final configuredUsername = env['N42_TEST_USERNAME']?.trim();
  final configuredPassword = env['N42_TEST_PASSWORD']?.trim();
  final inviteCode = env['N42_TEST_INVITE_CODE']?.trim();

  final createdAccount =
      configuredUsername == null || configuredUsername.isEmpty;
  late final String username;
  if (createdAccount) {
    username = _generateUsername();
  } else {
    username = configuredUsername;
  }
  final password =
      (createdAccount ? env['N42_TEST_PASSWORD'] : configuredPassword) ??
      'N42LivePass123!@#';

  if (createdAccount && (inviteCode == null || inviteCode.isEmpty)) {
    throw StateError(
      'Missing N42_TEST_INVITE_CODE. '
      'Provide an invite code or a reusable N42_TEST_USERNAME/N42_TEST_PASSWORD.',
    );
  }

  print('Homeserver: $homeserver');
  print(
    'Mode: ${createdAccount ? "register-temp-user" : "login-existing-user"}',
  );
  print('Username: $username');

  sqfliteFfiInit();
  final sqfliteDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  final database = await matrix.MatrixSdkDatabase.init(
    'N42LiveMediaSmoke',
    database: sqfliteDb,
    sqfliteFactory: databaseFactoryFfi,
  );
  final client = matrix.Client('N42LiveMediaSmoke', database: database);
  final clientManager = _LiveClientManager(client);
  final uploader = MatrixMediaUploader(clientManager);
  final sender = MatrixMediaSender(clientManager, uploader);
  final messageDataSource = MatrixMessageDataSource(clientManager);
  final mapper = MatrixEventMapper(() => client);
  final downloadService = DownloadService();

  String? roomId;
  Directory? tempDir;

  try {
    await _step('connect homeserver', () async {
      await client.checkHomeserver(Uri.parse(homeserver));
      _expect(client.homeserver != null, 'homeserver connection failed');
    });

    if (createdAccount) {
      await _step('register temp account', () async {
        await _registerWithToken(
          client: client,
          username: username,
          password: password,
          inviteCode: inviteCode!,
        );
        _expect(client.isLogged(), 'registration did not leave client logged in');
      });
    } else {
      await _step('login', () async {
        final result = await client.login(
          matrix.LoginType.mLoginPassword,
          identifier: matrix.AuthenticationUserIdentifier(user: username),
          password: password,
          initialDeviceDisplayName: 'N42 Live Media Smoke',
        );
        print('Logged in as ${result.userId} / ${result.deviceId}');
        _expect(client.isLogged(), 'login did not create a live session');
      });
    }

    await client.abortSync();
    client.backgroundSync = false;

    tempDir = await Directory.systemTemp.createTemp('n42_live_media_smoke');

    await _step('create room', () async {
      roomId = await client.createRoom(
        name: 'N42 Media Smoke ${DateTime.now().toIso8601String()}',
        topic: 'live smoke for media upload/download/location',
        preset: matrix.CreateRoomPreset.privateChat,
      );
      _expect(roomId != null && roomId!.isNotEmpty, 'room creation returned null');
    });

    final room = (() {
      final existingRoom = client.getRoomById(roomId!);
      if (existingRoom != null) {
        return existingRoom;
      }
      final createdRoom = matrix.Room(id: roomId!, client: client);
      client.rooms = [...client.rooms, createdRoom];
      return createdRoom;
    })();

    final imageBytes = _tinyPngBytes();
    String? imageEventId;
    String? imageMxcUrl;

    await _step('send image via app sender', () async {
      imageEventId = await sender.sendImageMessage(
        room.id,
        imageBytes: imageBytes,
        filename: 'pixel.png',
        mimeType: 'image/png',
      );
      _expect(imageEventId != null, 'image send returned null');

      final imageEvent = await _waitForServerEvent(client, room, imageEventId!);
      _expect(imageEvent.content['msgtype'] == 'm.image', 'image msgtype mismatch');
      _expect(
        (imageEvent.content['info'] as Map<String, dynamic>?)?['mimetype'] ==
            'image/png',
        'image mimetype mismatch',
      );
      _expect(
        (imageEvent.content['info'] as Map<String, dynamic>?)?['size'] ==
            imageBytes.length,
        'image size mismatch',
      );
      imageMxcUrl = imageEvent.content['url'] as String?;
      _expect(imageMxcUrl != null && imageMxcUrl!.startsWith('mxc://'), 'image MXC missing');
    });

    final filePath = '${tempDir.path}/payload.bin';
    final fileBytes = Uint8List.fromList(
      List<int>.generate(4096, (index) => index % 251),
    );
    await File(filePath).writeAsBytes(fileBytes, flush: true);

    String? fileEventId;
    String? fileMxcUrl;

    await _step('send file via streaming path', () async {
      fileEventId = await sender.sendFileMessage(
        room.id,
        filename: 'payload.bin',
        mimeType: 'application/octet-stream',
        filePath: filePath,
        fileSize: fileBytes.length,
      );
      _expect(fileEventId != null, 'file send returned null');

      final fileEvent = await _waitForServerEvent(client, room, fileEventId!);
      _expect(fileEvent.content['msgtype'] == 'm.file', 'file msgtype mismatch');
      _expect(
        (fileEvent.content['info'] as Map<String, dynamic>?)?['size'] ==
            fileBytes.length,
        'file size mismatch',
      );
      fileMxcUrl = fileEvent.content['url'] as String?;
      _expect(fileMxcUrl != null && fileMxcUrl!.startsWith('mxc://'), 'file MXC missing');
    });

    await _step('download protected file via app download service', () async {
      final mediaUrl = fileMxcUrl;
      if (mediaUrl == null || !mediaUrl.startsWith('mxc://')) {
        throw StateError('file MXC missing');
      }

      final downloadUrl = mapper.getMediaUrl(mediaUrl)?.toString();
      if (downloadUrl == null || !downloadUrl.startsWith('http')) {
        throw StateError('download url missing');
      }

      final workingTempDir = tempDir;
      if (workingTempDir == null) {
        throw StateError('temp dir missing');
      }

      final savePath = '${workingTempDir.path}/downloaded_payload.bin';
      final accessToken = client.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw StateError('access token missing');
      }

      final taskId = await downloadService.download(
        url: downloadUrl,
        savePath: savePath,
        fileName: 'downloaded_payload.bin',
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      final task = await downloadService.waitForTaskCompletion(taskId);
      _expect(
        task.status == DownloadStatus.completed,
        'download task failed: ${task.error ?? task.status.name}',
      );

      final downloadedBytes = await File(savePath).readAsBytes();
      _expect(
        base64Encode(downloadedBytes) == base64Encode(fileBytes),
        'downloaded file content mismatch',
      );
    });

    await _step('receive live location from room state', () async {
      await messageDataSource.startLiveLocation(room.id, 60);
      await messageDataSource.updateLiveLocation(room.id, 43.6532, -79.3832, 5.0);

      final currentUserId = client.userID;
      _expect(currentUserId != null && currentUserId.isNotEmpty, 'current user missing');

      room.setState(
        await _waitForRoomStateEvent(
          client,
          room,
          'n42.live_location',
          currentUserId!,
        ),
      );
      room.setState(
        await _waitForRoomStateEvent(
          client,
          room,
          'n42.live_location.update',
          currentUserId,
        ),
      );
      final memberEvent = await _fetchRoomStateEvent(
        client,
        room,
        matrix.EventTypes.RoomMember,
        currentUserId,
      );
      if (memberEvent != null) {
        room.setState(memberEvent);
      }

      final locations = messageDataSource.getActiveLiveLocations(room.id);
      final mine = locations.where((location) => location.userId == client.userID).toList();
      _expect(mine.isNotEmpty, 'current user live location missing');
      _expect((mine.first.latitude - 43.6532).abs() < 0.0001, 'latitude mismatch');
      _expect((mine.first.longitude + 79.3832).abs() < 0.0001, 'longitude mismatch');
    });

    print('');
    print('Live media smoke passed.');
    print('roomId=$roomId');
    print('imageEventId=$imageEventId');
    print('fileEventId=$fileEventId');
    print('imageMxcUrl=$imageMxcUrl');
    print('fileMxcUrl=$fileMxcUrl');
  } finally {
    try {
      if (createdAccount && client.isLogged()) {
        await client.logout();
      }
    } catch (_) {}
    if (tempDir != null && await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await client.dispose();
  }
}

class _LiveClientManager implements MatrixClientManager {
  final matrix.Client _client;

  _LiveClientManager(this._client);

  @override
  matrix.Client? get client => _client;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _step(String name, Future<void> Function() body) async {
  stdout.write('[$name] ');
  await body();
  print('ok');
}

String _generateUsername() =>
    'n42media${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';

void _expect(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

Uint8List _tinyPngBytes() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+nmS8AAAAASUVORK5CYII=',
);

Future<void> _registerWithToken({
  required matrix.Client client,
  required String username,
  required String password,
  required String inviteCode,
}) async {
  try {
    final response = await client.register(
      username: username,
      password: password,
      initialDeviceDisplayName: 'N42 Live Media Smoke',
      auth: _RegistrationTokenAuthenticationData(token: inviteCode),
    );
    print('Registered ${response.userId}');
    return;
  } on matrix.MatrixException catch (error) {
    if (error.response?.statusCode != 401 || error.response?.body == null) {
      rethrow;
    }

    final decoded = jsonDecode(error.response!.body);
    if (decoded is! Map<String, dynamic>) {
      rethrow;
    }
    final session = decoded['session']?.toString();
    if (session == null || session.isEmpty) {
      rethrow;
    }

    final response = await client.register(
      username: username,
      password: password,
      initialDeviceDisplayName: 'N42 Live Media Smoke',
      auth: _RegistrationTokenAuthenticationData(
        token: inviteCode,
        session: session,
      ),
    );
    print('Registered ${response.userId}');
  }
}

Future<matrix.Event> _waitForServerEvent(
  matrix.Client client,
  matrix.Room room,
  String eventId,
) async {
  matrix.Event? event;
  await _waitFor(() async {
    event = await _fetchServerEvent(client, room, eventId);
    return event != null;
  }, description: 'event $eventId to be fetchable from server');
  return event!;
}

Future<matrix.Event> _waitForRoomStateEvent(
  matrix.Client client,
  matrix.Room room,
  String eventType,
  String stateKey,
) async {
  matrix.Event? event;
  await _waitFor(() async {
    event = await _fetchRoomStateEvent(client, room, eventType, stateKey);
    return event != null;
  }, description: 'room state $eventType/$stateKey to be fetchable from server');
  return event!;
}

Future<matrix.Event?> _fetchServerEvent(
  matrix.Client client,
  matrix.Room room,
  String eventId,
) async {
  try {
    final json = await client.request(
      matrix.RequestType.GET,
      '/client/v3/rooms/${Uri.encodeComponent(room.id)}/event/${Uri.encodeComponent(eventId)}',
    );
    return matrix.Event.fromJson(Map<String, dynamic>.from(json), room);
  } catch (_) {
    return await room.getEventById(eventId);
  }
}

Future<matrix.Event?> _fetchRoomStateEvent(
  matrix.Client client,
  matrix.Room room,
  String eventType,
  String stateKey,
) async {
  try {
    final json = Map<String, dynamic>.from(
      await client.request(
      matrix.RequestType.GET,
      '/client/v3/rooms/${Uri.encodeComponent(room.id)}/state/${Uri.encodeComponent(eventType)}/${Uri.encodeComponent(stateKey)}',
      ),
    );
    return matrix.Event(
      eventId: 'state_${eventType}_$stateKey',
      stateKey: stateKey,
      type: eventType,
      content: json,
      room: room,
      senderId: stateKey,
      originServerTs: DateTime.now(),
    );
  } catch (_) {
    final stripped = room.states[eventType]?[stateKey];
    if (stripped == null) {
      return null;
    }
    return matrix.Event(
      eventId: 'state_${eventType}_$stateKey',
      stateKey: stripped.stateKey ?? stateKey,
      type: stripped.type,
      content: Map<String, dynamic>.from(stripped.content),
      room: room,
      senderId: stripped.senderId,
      originServerTs: DateTime.now(),
    );
  }
}

Future<void> _waitFor(
  Future<bool> Function() predicate, {
  required String description,
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 750),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await predicate()) {
      return;
    }
    await Future<void>.delayed(step);
  }
  throw TimeoutException('Timed out waiting for $description');
}

class _RegistrationTokenAuthenticationData extends matrix.AuthenticationData {
  final String token;

  _RegistrationTokenAuthenticationData({required this.token, super.session})
    : super(type: 'm.login.registration_token');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['token'] = token;
    return json;
  }
}
