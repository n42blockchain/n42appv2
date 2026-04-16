#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_event_mapper.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_text_message_content.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 真服消息能力 smoke。
///
/// 优先使用环境变量提供的现成账号：
///   N42_TEST_HOMESERVER=https://m.si46.world
///   N42_TEST_USERNAME=...
///   N42_TEST_PASSWORD=...
///
/// 如果未提供账号，则会尝试用邀请码注册临时账号：
///   N42_TEST_INVITE_CODE=...
///
/// 运行：
///   dart run tool/live_message_smoke.dart
void main() async {
  final env = Platform.environment;
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
    stderr.writeln(
      'Missing N42_TEST_INVITE_CODE. '
      'Provide an invite code or a reusable N42_TEST_USERNAME/N42_TEST_PASSWORD.',
    );
    exit(2);
  }

  print('Homeserver: $homeserver');
  print(
    'Mode: ${createdAccount ? "register-temp-user" : "login-existing-user"}',
  );
  print('Username: $username');

  sqfliteFfiInit();
  final sqfliteDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  final database = await matrix.MatrixSdkDatabase.init(
    'N42LiveMessageSmoke',
    database: sqfliteDb,
    sqfliteFactory: databaseFactoryFfi,
  );
  final client = matrix.Client('N42LiveMessageSmoke', database: database);
  final mapper = MatrixEventMapper(() => client);

  String? roomId;

  try {
    await _step('connect homeserver', () async {
      await client.checkHomeserver(Uri.parse(homeserver));
      _expect(client.homeserver != null, 'homeserver connection failed');
    });

    await _step('print login flows', () async {
      final flows = await client.getLoginFlows() ?? const [];
      _expect(flows.isNotEmpty, 'no login flows exposed by homeserver');
      print('Login flows: ${flows.map((flow) => flow.type).join(", ")}');
    });

    if (createdAccount) {
      await _step('register temp account', () async {
        await _registerWithToken(
          client: client,
          username: username,
          password: password,
          inviteCode: inviteCode!,
        );
        _expect(
          client.isLogged(),
          'registration did not leave client logged in',
        );
      });
    } else {
      await _step('login', () async {
        final result = await client.login(
          matrix.LoginType.mLoginPassword,
          identifier: matrix.AuthenticationUserIdentifier(user: username),
          password: password,
          initialDeviceDisplayName: 'N42 Live Smoke',
        );
        print('Logged in as ${result.userId} / ${result.deviceId}');
        _expect(client.isLogged(), 'login did not create a live session');
      });
    }

    await _sync(client, rounds: 2);

    await _step('create room', () async {
      roomId = await client.createRoom(
        name: 'N42 Smoke ${DateTime.now().toIso8601String()}',
        topic: 'live smoke for UTF-8/reply/edit/thread/reaction',
        preset: matrix.CreateRoomPreset.privateChat,
      );
      _expect(
        roomId != null && roomId!.isNotEmpty,
        'room creation returned null',
      );
    });

    await _sync(client, rounds: 2);
    final room = await _waitForRoom(client, roomId!);

    const rootText = 'Cafe\u0301\r\n中文 العربية हिन्दी emoji 🙂 <b>tag</b>';
    const replyText = '回复 Reply 🫡 café';
    const editedText = '已编辑 cafe\u0301 👩‍👩‍👧‍👦 <script>alert(1)</script>';
    const threadText = '线程 Thread 🧵 español';
    const pollQuestion = 'Lunch?';
    const pollOptions = ['Sushi', 'Pizza'];

    String? rootEventId;
    String? replyEventId;
    String? editEventId;
    String? reactionEventId;
    String? threadEventId;
    String? pollEventId;

    await _step('send UTF-8 root message', () async {
      rootEventId = await room.sendEvent(
        Map<String, dynamic>.from(buildTextMessageContent(rootText)),
      );
      _expect(rootEventId != null, 'root message send returned null');
      await _sync(client, rounds: 2);

      final rootEvent = await _waitForServerEvent(client, room, rootEventId!);
      _expect(
        rootEvent.content['body'] == normalizeMatrixText(rootText),
        'root body did not round-trip with normalization',
      );
      _expect(
        rootEvent.content['formatted_body'] ==
            buildMatrixFormattedBody(rootText),
        'root formatted_body mismatch',
      );

      final mapped = mapper.mapEventToMessage(rootEvent, room);
      _expect(
        mapped.content == normalizeMatrixText(rootText),
        'mapped root text mismatch',
      );
      _expect(
        mapped.formattedContent == buildMatrixFormattedBody(rootText),
        'mapped root formatted text mismatch',
      );
    });

    await _step('send reply', () async {
      final original = await _waitForServerEvent(client, room, rootEventId!);
      replyEventId = await room.sendEvent(
        Map<String, dynamic>.from(buildTextMessageContent(replyText)),
        inReplyTo: original,
      );
      _expect(replyEventId != null, 'reply send returned null');
      await _sync(client, rounds: 2);

      final replyEvent = await _waitForServerEvent(client, room, replyEventId!);
      final mapped = mapper.mapEventToMessage(replyEvent, room);
      _expect(
        replyEvent.inReplyToEventId() == rootEventId,
        'reply relation missing target event id',
      );
      _expect(mapped.replyToId == rootEventId, 'mapped reply target missing');
      _expect(
        mapped.content == normalizeMatrixText(replyText),
        'mapped reply body mismatch',
      );
      _expect(mapped.replyToSender != null, 'mapped reply sender missing');
      _expect(
        mapped.replyToContent != null && mapped.replyToContent!.isNotEmpty,
        'mapped reply preview missing',
      );
    });

    await _step('edit root message', () async {
      editEventId = await room.sendEvent(
        Map<String, dynamic>.from(buildTextMessageContent(editedText)),
        editEventId: rootEventId,
      );
      _expect(editEventId != null, 'edit send returned null');
      await _sync(client, rounds: 3);

      final aggregatedRoot = await _waitForEditedRootEvent(
        client,
        room,
        rootEventId!,
      );
      final mapped = mapper.mapEventToMessage(aggregatedRoot, room);
      _expect(mapped.isEdited, 'mapped root should be marked edited');
      _expect(
        mapped.content == normalizeMatrixText(editedText),
        'edited display body mismatch',
      );
      _expect(
        mapped.formattedContent == buildMatrixFormattedBody(editedText),
        'edited formatted display mismatch',
      );
    });

    await _step('send and redact reaction', () async {
      reactionEventId = await room.sendEvent(<String, dynamic>{
        'm.relates_to': <String, dynamic>{
          'rel_type': 'm.annotation',
          'event_id': rootEventId,
          'key': '🔥',
        },
      }, type: 'm.reaction');
      _expect(reactionEventId != null, 'reaction send returned null');
      await _sync(client, rounds: 2);

      final reactions = await _activeReactions(room, rootEventId!);
      _expect(
        reactions['🔥']?.contains(client.userID) == true,
        'active reaction not found before redaction',
      );

      await room.redactEvent(reactionEventId!, reason: 'live smoke cleanup');
      await _sync(client, rounds: 2);

      await _waitFor(() async {
        final after = await _activeReactions(room, rootEventId!);
        return after['🔥']?.contains(client.userID) != true;
      }, description: 'reaction redaction to propagate');
    });

    await _step('send thread reply', () async {
      threadEventId = await room.sendEvent(
        Map<String, dynamic>.from(buildTextMessageContent(threadText)),
        threadRootEventId: rootEventId,
        threadLastEventId: rootEventId,
      );
      _expect(threadEventId != null, 'thread send returned null');
      await _sync(client, rounds: 3);

      final threadEvents = await _waitForThreadEvents(
        client,
        room,
        rootEventId!,
      );
      final threadEvent = threadEvents.firstWhere(
        (event) => event.eventId == threadEventId,
        orElse: () =>
            throw StateError('thread event not returned from relations API'),
      );
      final mapped = mapper.mapEventToMessage(threadEvent, room);
      _expect(
        mapped.threadRootId == rootEventId,
        'thread root id missing in mapped event',
      );
      _expect(
        mapped.replyToId == null,
        'thread fallback should not be exposed as reply target',
      );
      _expect(
        mapped.content == normalizeMatrixText(threadText),
        'mapped thread body mismatch',
      );
    });

    await _step('send anonymous poll, vote, and end poll', () async {
      pollEventId = await room.sendEvent(
        _buildPollStartContent(
          question: pollQuestion,
          options: pollOptions,
          maxSelections: 1,
          isAnonymous: true,
        ),
        type: 'org.matrix.msc3381.poll.start',
      );
      _expect(pollEventId != null, 'poll send returned null');
      await _sync(client, rounds: 2);

      final pollEvent = await _waitForServerEvent(client, room, pollEventId!);
      final pollStart =
          pollEvent.content['org.matrix.msc3381.poll.start']
              as Map<String, dynamic>?;
      _expect(pollStart != null, 'poll.start content missing');
      _expect(
        pollStart?['kind'] == 'org.matrix.msc3381.poll.undisclosed',
        'poll kind did not preserve anonymous mode',
      );

      final answers =
          (pollStart?['answers'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .toList(growable: false) ??
          const [];
      _expect(answers.length == 2, 'poll answers count mismatch');
      final firstOptionId = answers.first['id'] as String?;
      _expect(
        firstOptionId != null && firstOptionId.isNotEmpty,
        'poll option id missing',
      );

      final mappedInitial = mapper.mapEventToMessage(pollEvent, room);
      _expect(
        mappedInitial.type == MessageType.poll,
        'mapped poll type mismatch',
      );
      _expect(
        mappedInitial.metadata?.pollQuestion == pollQuestion,
        'mapped poll question mismatch',
      );
      _expect(
        mappedInitial.metadata?.pollOptions?.length == 2,
        'mapped poll options missing',
      );
      _expect(
        mappedInitial.metadata?.isAnonymousPoll == true,
        'mapped poll anonymity missing',
      );

      final voted = await room.sendEvent(<String, dynamic>{
        'm.relates_to': <String, dynamic>{
          'rel_type': 'm.reference',
          'event_id': pollEventId,
        },
        'org.matrix.msc3381.poll.response': <String, dynamic>{
          'answers': [firstOptionId],
        },
      }, type: 'org.matrix.msc3381.poll.response');
      _expect(voted != null, 'poll vote send returned null');

      final ended = await room.sendEvent(<String, dynamic>{
        'm.relates_to': <String, dynamic>{
          'rel_type': 'm.reference',
          'event_id': pollEventId,
        },
        'org.matrix.msc3381.poll.end': <String, dynamic>{},
        'org.matrix.msc1767.text': 'Poll ended',
      }, type: 'org.matrix.msc3381.poll.end');
      _expect(ended != null, 'poll end send returned null');
      await _sync(client, rounds: 3);

      final bundledPoll = await _waitForBundledPollEvent(
        client,
        room,
        pollEventId!,
      );
      final mappedBundled = mapper.mapEventToMessage(bundledPoll, room);
      final metadata = mappedBundled.metadata;
      _expect(metadata != null, 'bundled poll metadata missing');
      _expect(metadata?.pollEnded == true, 'poll end aggregation missing');
      _expect(metadata?.totalVoters == 1, 'poll voter count mismatch');
      _expect(
        metadata?.voteCounts?[firstOptionId] == 1,
        'poll vote count mismatch',
      );
      _expect(
        metadata?.myVotes?.contains(firstOptionId) == true,
        'poll myVotes missing',
      );
      _expect(
        metadata?.isAnonymousPoll == true,
        'bundled poll anonymity mismatch',
      );
    });

    print('');
    print('Live smoke passed.');
    print('roomId=$roomId');
    print('rootEventId=$rootEventId');
    print('replyEventId=$replyEventId');
    print('editEventId=$editEventId');
    print('reactionEventId=$reactionEventId');
    print('threadEventId=$threadEventId');
    print('pollEventId=$pollEventId');
  } catch (error, stackTrace) {
    stderr.writeln('');
    stderr.writeln('Live smoke failed: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  } finally {
    try {
      if (createdAccount && client.isLogged()) {
        await client.logout();
      }
    } catch (_) {}
    await client.dispose();
  }
}

Future<void> _step(String name, Future<void> Function() body) async {
  stdout.write('[$name] ');
  await body();
  print('ok');
}

String _generateUsername() =>
    'n42live${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}';

void _expect(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

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
      initialDeviceDisplayName: 'N42 Live Smoke',
      auth: _RegistrationTokenAuthenticationData(token: inviteCode),
    );
    print('Registered ${response.userId}');
    return;
  } on matrix.MatrixException catch (error) {
    if (error.response?.statusCode != 401 || error.response?.body == null) {
      rethrow;
    }

    final responseBody = error.response!.body;
    final decoded = jsonDecode(responseBody);
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
      initialDeviceDisplayName: 'N42 Live Smoke',
      auth: _RegistrationTokenAuthenticationData(
        token: inviteCode,
        session: session,
      ),
    );
    print('Registered ${response.userId}');
  }
}

Future<void> _sync(matrix.Client client, {int rounds = 1}) async {
  for (var i = 0; i < rounds; i++) {
    await client.oneShotSync();
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

Future<matrix.Room> _waitForRoom(matrix.Client client, String roomId) async {
  await _waitFor(
    () async => client.getRoomById(roomId) != null,
    description: 'room $roomId to appear locally',
  );
  return client.getRoomById(roomId)!;
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

Future<matrix.Event> _waitForEditedRootEvent(
  matrix.Client client,
  matrix.Room room,
  String rootEventId,
) async {
  matrix.Event? event;
  await _waitFor(() async {
    final base = await _fetchServerEvent(client, room, rootEventId);
    if (base == null) {
      return false;
    }
    final aggregated = await _attachLatestEditAggregation(client, room, base);
    final replace =
        (aggregated.unsigned?['m.relations']
            as Map<String, dynamic>?)?['m.replace'];
    if (replace is Map<String, dynamic> && replace['content'] != null) {
      event = aggregated;
      return true;
    }
    return false;
  }, description: 'bundled edit aggregation for $rootEventId');
  return event!;
}

Future<matrix.Event> _attachLatestEditAggregation(
  matrix.Client client,
  matrix.Room room,
  matrix.Event base,
) async {
  final response = await client.request(
    matrix.RequestType.GET,
    '/client/v1/rooms/${Uri.encodeComponent(room.id)}/relations/${Uri.encodeComponent(base.eventId)}/m.replace',
    query: <String, String>{'limit': '20'},
  );

  final chunk = (response['chunk'] as List<dynamic>? ?? const [])
      .whereType<Map<Object?, Object?>>()
      .map((event) => Map<String, dynamic>.from(event.cast<String, dynamic>()))
      .toList();

  if (chunk.isEmpty) {
    return base;
  }

  chunk.sort((left, right) {
    final leftTs = (left['origin_server_ts'] as int?) ?? 0;
    final rightTs = (right['origin_server_ts'] as int?) ?? 0;
    return rightTs.compareTo(leftTs);
  });

  final latestReplacement = chunk.first;
  final unsigned = Map<String, dynamic>.from(base.unsigned ?? const {});
  final relations = Map<String, dynamic>.from(
    (unsigned['m.relations'] as Map<String, dynamic>?) ?? const {},
  );
  relations['m.replace'] = latestReplacement;
  unsigned['m.relations'] = relations;

  final baseJson = Map<String, dynamic>.from(base.toJson());
  baseJson['unsigned'] = unsigned;
  return matrix.Event.fromJson(baseJson, room);
}

Future<matrix.Event> _waitForBundledPollEvent(
  matrix.Client client,
  matrix.Room room,
  String pollEventId,
) async {
  matrix.Event? event;
  await _waitFor(() async {
    final base = await _fetchServerEvent(client, room, pollEventId);
    if (base == null) {
      return false;
    }

    final aggregated = await _attachReferenceAggregation(client, room, base);
    final mapped = MatrixEventMapper(
      () => client,
    ).mapEventToMessage(aggregated, room);
    final metadata = mapped.metadata;
    final hasVoteCount =
        metadata?.voteCounts?.values.any((count) => count > 0) == true;
    if (metadata?.pollEnded == true && hasVoteCount) {
      event = aggregated;
      return true;
    }
    return false;
  }, description: 'bundled poll aggregation for $pollEventId');
  return event!;
}

Future<matrix.Event> _attachReferenceAggregation(
  matrix.Client client,
  matrix.Room room,
  matrix.Event base,
) async {
  final response = await client.request(
    matrix.RequestType.GET,
    '/client/v1/rooms/${Uri.encodeComponent(room.id)}/relations/${Uri.encodeComponent(base.eventId)}/m.reference',
    query: <String, String>{'limit': '50'},
  );

  final chunk = (response['chunk'] as List<dynamic>? ?? const [])
      .whereType<Map<Object?, Object?>>()
      .map((event) => Map<String, dynamic>.from(event.cast<String, dynamic>()))
      .toList(growable: false);

  final unsigned = Map<String, dynamic>.from(base.unsigned ?? const {});
  final relations = Map<String, dynamic>.from(
    (unsigned['m.relations'] as Map<String, dynamic>?) ?? const {},
  );
  relations['m.reference'] = <String, dynamic>{'chunk': chunk};
  unsigned['m.relations'] = relations;

  final baseJson = Map<String, dynamic>.from(base.toJson());
  baseJson['unsigned'] = unsigned;
  return matrix.Event.fromJson(baseJson, room);
}

Future<Map<String, Set<String>>> _activeReactions(
  matrix.Room room,
  String eventId,
) async {
  final timeline = await room.getTimeline();
  final reactions = <String, Set<String>>{};
  for (final event in timeline.events) {
    if (event.redactedBecause != null || event.type != 'm.reaction') {
      continue;
    }
    final relatesTo = event.content['m.relates_to'] as Map<String, dynamic>?;
    if (relatesTo == null || relatesTo['event_id'] != eventId) {
      continue;
    }
    final key = relatesTo['key'] as String?;
    if (key == null || key.isEmpty) {
      continue;
    }
    reactions.putIfAbsent(key, () => <String>{}).add(event.senderId);
  }
  return reactions;
}

Future<List<matrix.Event>> _waitForThreadEvents(
  matrix.Client client,
  matrix.Room room,
  String threadRootEventId,
) async {
  List<matrix.Event> events = const [];
  await _waitFor(() async {
    final response = await client.request(
      matrix.RequestType.GET,
      '/client/v1/rooms/${Uri.encodeComponent(room.id)}/relations/${Uri.encodeComponent(threadRootEventId)}/m.thread',
      query: <String, String>{'limit': '50'},
    );
    final chunk = (response['chunk'] as List<dynamic>? ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(
          (event) => matrix.Event.fromJson(
            Map<String, dynamic>.from(event.cast<String, dynamic>()),
            room,
          ),
        )
        .toList();
    events = chunk;
    return chunk.isNotEmpty;
  }, description: 'thread relations for $threadRootEventId');
  return events;
}

Map<String, dynamic> _buildPollStartContent({
  required String question,
  required List<String> options,
  required int maxSelections,
  required bool isAnonymous,
}) {
  final pollOptions = options
      .asMap()
      .entries
      .map((entry) {
        return <String, dynamic>{
          'id': '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          'org.matrix.msc1767.text': entry.value,
        };
      })
      .toList(growable: false);

  return <String, dynamic>{
    'org.matrix.msc3381.poll.start': <String, dynamic>{
      'question': <String, dynamic>{'org.matrix.msc1767.text': question},
      'kind': isAnonymous
          ? 'org.matrix.msc3381.poll.undisclosed'
          : 'org.matrix.msc3381.poll.disclosed',
      'max_selections': maxSelections,
      'answers': pollOptions,
    },
    'org.matrix.msc1767.text':
        '$question\n${options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}',
  };
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
