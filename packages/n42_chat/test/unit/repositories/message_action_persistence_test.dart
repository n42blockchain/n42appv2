import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_reaction_datasource.dart';
import 'package:n42_chat/src/data/repositories/message_action_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockReaction extends Mock implements MatrixReactionDataSource {}

class MockManager extends Mock implements MatrixClientManager {}

class MockClient extends Mock implements matrix.Client {}

final fixtureScope = sha256
    .convert(utf8.encode(jsonEncode(['https://test', '@alice:test'])))
    .toString();

class FaultStorage extends PreferencesDataSource {
  bool rejectReads = false;
  @override
  Future<String?> getFavoriteRecord({String? scope}) async {
    if (rejectReads) throw StateError('read unavailable');
    return super.getFavoriteRecord(scope: scope ?? fixtureScope);
  }

  bool rejectMessages = false;
  bool rejectMeta = false;
  Completer<void>? pending;
  @override
  Future<void> saveFavoriteRecord(String json, {String? scope}) async {
    if (pending != null) await pending!.future;
    if (rejectMessages || rejectMeta) throw StateError('storage full');
    await super.saveFavoriteRecord(json, scope: scope ?? fixtureScope);
  }
}

void main() {
  late MockReaction reaction;
  late MockManager manager;
  late FaultStorage storage;
  late MessageActionRepositoryImpl repository;
  MessageActionRepositoryImpl fresh() =>
      MessageActionRepositoryImpl(reaction, manager, storage);
  MessageEntity message(String id, {MessageMetadata? metadata}) =>
      MessageEntity(
        id: id,
        roomId: 'room',
        senderId: '@alice:test',
        senderName: 'Alice',
        content: 'Saved $id',
        formattedContent: '<b>Saved</b>',
        senderAvatarUrl: 'https://example.org/avatar',
        timestamp: DateTime.utc(2026, 9, 13),
        type: MessageType.text,
        status: MessageStatus.read,
        isFromMe: true,
        isEdited: true,
        editedAt: DateTime.utc(2026, 9, 13, 1),
        replyToId: 'parent',
        replyToContent: 'original',
        replyToSender: 'Bob',
        threadRootId: 'thread',
        threadReplyCount: 2,
        threadLatestReply: 'latest',
        threadLatestReplySender: 'Carol',
        threadLatestReplyTimestamp: DateTime.utc(2026, 9, 13, 2),
        metadata: metadata,
      );
  Future<void> seedMessages(String raw) async {
    await storage.saveFavoriteMessages(raw);
    await storage.saveFavoriteRecord(
      '{"version":1,"messages":${raw.isEmpty ? '[]' : raw},"metadata":{}}',
    );
  }

  Future<void> seedMeta(String raw) async {
    await storage.saveFavoriteMeta(raw);
    await storage.saveFavoriteRecord(
      '{"version":1,"messages":[],"metadata":$raw}',
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    reaction = MockReaction();
    manager = MockManager();
    storage = FaultStorage();
    final client = MockClient();
    when(() => client.userID).thenReturn('@alice:test');
    when(() => client.homeserver).thenReturn(Uri.parse('https://test'));
    when(() => manager.client).thenReturn(client);
    repository = fresh();
  });

  test(
    'failed read cannot be cached as empty or overwrite existing favorites',
    () async {
      await seedMessages(
        jsonEncode([
          {'id': 'existing'},
        ]),
      );
      storage.rejectReads = true;
      await expectLater(
        repository.saveMessage(message('new')),
        throwsStateError,
      );
      storage.rejectReads = false;
      expect((await repository.getSavedMessages()).map((m) => m.id), [
        'existing',
      ]);
      await repository.saveMessage(message('new'));
      expect((await fresh().getSavedMessages()).map((m) => m.id), [
        'existing',
        'new',
      ]);
    },
  );
  test(
    'corrupt favorite payload remains intact and can recover after storage repair',
    () async {
      await seedMessages('broken-json');
      await expectLater(
        repository.saveMessage(message('new')),
        throwsFormatException,
      );
      expect(await storage.getFavoriteMessages(), 'broken-json');
      await seedMessages('[]');
      await repository.saveMessage(message('new'));
      expect((await fresh().getSavedMessages()).single.id, 'new');
    },
  );
  test(
    'corrupt metadata is not silently discarded by a subsequent edit',
    () async {
      await seedMeta('broken-json');
      await expectLater(
        repository.editFavoriteTags('one', ['tag']),
        throwsFormatException,
      );
      expect(await storage.getFavoriteMeta(), 'broken-json');
      await seedMeta('{}');
      await repository.editFavoriteRemark('one', 'recovered');
      expect(
        jsonDecode(
          (await storage.getFavoriteRecord())!,
        )['metadata']['one']['remark'],
        'recovered',
      );
    },
  );
  test(
    'saved messages survive repository recreation with reply and thread context',
    () async {
      final original = message('one');
      await repository.saveMessage(original);
      expect((await fresh().getSavedMessages()).single, original);
      expect(await repository.isMessageSaved('one'), isTrue);
      expect(await repository.isMessageSaved('absent'), isFalse);
    },
  );
  test(
    'media, poll, payment and call details round-trip through durable storage',
    () async {
      final original = message(
        'rich',
        metadata: MessageMetadata(
          mediaUrl: 'mxc://test/media',
          httpUrl: 'https://example.org/media',
          thumbnailUrl: 'mxc://test/thumb',
          mimeType: 'audio/ogg',
          size: 1024,
          width: 640,
          height: 480,
          duration: 12000,
          fileName: 'voice.ogg',
          isPlayed: true,
          waveform: const [1, 5, 2],
          transcription: 'hello',
          transcriptionStatus: TranscriptionStatus.success,
          latitude: 45.5,
          longitude: -73.5,
          locationName: 'Park',
          amount: '1.25',
          token: 'TEST',
          transferStatus: 'completed',
          txHash: 'test-transaction',
          paymentRequestId: 'request',
          paymentReceiverAddress: 'receiver',
          paymentRequestExpiresAt: DateTime.utc(2027),
          redPacketId: 'packet',
          pollQuestion: 'Lunch?',
          pollOptions: const ['A', 'B'],
          pollOptionIds: const ['a', 'b'],
          myVotes: const ['b'],
          voteCounts: const {'a': 1, 'b': 2},
          totalVoters: 3,
          maxSelections: 1,
          pollEnded: true,
          isAnonymousPoll: true,
          musicTitle: 'Music',
          musicArtist: 'Artist',
          musicUrl: 'mxc://test/music',
          musicCover: 'mxc://test/cover',
          callDuration: 60,
          callEnded: true,
          isMissedCall: false,
          callEndReason: 'hangup',
          callRoomId: 'call-room',
          callPeerId: '@bob:test',
        ),
      );
      await repository.saveMessage(original);
      expect((await fresh().getSavedMessages()).single, original);
    },
  );
  test(
    'repeated save is idempotent and returned lists cannot mutate cache',
    () async {
      await repository.saveMessage(message('one'));
      await repository.saveMessage(message('one'));
      final list = await repository.getSavedMessages();
      expect(list, hasLength(1));
      expect(() => list.clear(), throwsUnsupportedError);
      expect(await fresh().isMessageSaved('one'), isTrue);
    },
  );
  test('unsave removes the stored message and its tags and remark', () async {
    await repository.saveMessage(message('one'));
    await repository.saveMessage(message('two'));
    await repository.editFavoriteTags('one', ['work']);
    await repository.editFavoriteRemark('one', 'important');
    await repository.unsaveMessage('one');
    expect((await fresh().getSavedMessages()).map((m) => m.id), ['two']);
    expect(
      jsonDecode((await storage.getFavoriteRecord())!)['metadata'],
      isNot(contains('one')),
    );
  });
  test(
    'tags and remarks preserve one another across repository recreation',
    () async {
      await repository.editFavoriteTags('one', ['work', 'todo']);
      await fresh().editFavoriteRemark('one', 'review');
      final data =
          jsonDecode((await storage.getFavoriteRecord())!)['metadata']
              as Map<String, dynamic>;
      expect(data['one'], {
        'tags': ['work', 'todo'],
        'remark': 'review',
      });
    },
  );
  test(
    'failed save is reported and does not become a cached favorite',
    () async {
      storage.rejectMessages = true;
      await expectLater(
        repository.saveMessage(message('one')),
        throwsStateError,
      );
      expect(await repository.isMessageSaved('one'), isFalse);
      storage.rejectMessages = false;
      await repository.saveMessage(message('one'));
      expect(await fresh().isMessageSaved('one'), isTrue);
    },
  );
  test('failed unsave preserves the previously saved message', () async {
    await repository.saveMessage(message('one'));
    storage.rejectMessages = true;
    await expectLater(repository.unsaveMessage('one'), throwsStateError);
    expect(await repository.isMessageSaved('one'), isTrue);
    expect(await fresh().isMessageSaved('one'), isTrue);
  });
  test(
    'failed metadata edits cannot leak into a later successful edit',
    () async {
      await repository.editFavoriteTags('one', ['original']);
      storage.rejectMeta = true;
      await expectLater(
        repository.editFavoriteTags('one', ['unsaved']),
        throwsStateError,
      );
      storage.rejectMeta = false;
      await repository.editFavoriteRemark('one', 'remark');
      final data =
          jsonDecode((await storage.getFavoriteRecord())!)['metadata']
              as Map<String, dynamic>;
      expect(data['one'], {
        'tags': ['original'],
        'remark': 'remark',
      });
    },
  );
  test(
    'caller mutation of tags cannot silently change persisted metadata',
    () async {
      final tags = ['original'];
      await repository.editFavoriteTags('one', tags);
      tags.add('external');
      await repository.editFavoriteRemark('one', 'remark');
      expect(
        (jsonDecode((await storage.getFavoriteRecord())!)['metadata']
            as Map)['one']['tags'],
        ['original'],
      );
    },
  );
  test('concurrent first saves retain both messages after reopening', () async {
    storage.pending = Completer<void>();
    final a = repository.saveMessage(message('one'));
    final b = repository.saveMessage(message('two'));
    await Future<void>.delayed(Duration.zero);
    storage.pending!.complete();
    await Future.wait([a, b]);
    expect((await fresh().getSavedMessages()).map((m) => m.id).toSet(), {
      'one',
      'two',
    });
  });
  test(
    'unknown persisted enum values fall back without dropping the message',
    () async {
      await seedMessages(
        jsonEncode([
          {'id': 'legacy', 'type': 999, 'status': 999, 'timestamp': 'invalid'},
        ]),
      );
      final saved = (await repository.getSavedMessages()).single;
      expect(saved.id, 'legacy');
      expect(saved.type, MessageType.text);
      expect(saved.status, MessageStatus.sent);
    },
  );
  test('empty persisted favorites return an empty list', () async {
    await seedMessages('');
    expect(await repository.getSavedMessages(), isEmpty);
  });
  test(
    'fan-out forwarding reports null and thrown sends as failures',
    () async {
      when(
        () => reaction.forwardMessage('room', 'one', 'good'),
      ).thenAnswer((_) async => 'new-event');
      when(
        () => reaction.forwardMessage('room', 'one', 'null'),
      ).thenAnswer((_) async => null);
      when(
        () => reaction.forwardMessage('room', 'one', 'error'),
      ).thenThrow(StateError('denied'));
      expect(
        await repository.forwardToMultipleRooms('room', 'one', [
          'good',
          'null',
          'error',
        ]),
        {'good': true, 'null': false, 'error': false},
      );
    },
  );
  test(
    'forward result carries the destination room and current sender',
    () async {
      final client = MockClient();
      when(() => client.userID).thenReturn('@me:test');
      when(() => manager.client).thenReturn(client);
      when(
        () => reaction.forwardMessage('room', 'one', 'destination'),
      ).thenAnswer((_) async => 'forwarded');
      final sent = (await repository.forwardMessage(
        'room',
        'one',
        'destination',
      ))!;
      expect(sent.id, 'forwarded');
      expect(sent.roomId, 'destination');
      expect(sent.senderId, '@me:test');
      expect(sent.status, MessageStatus.sending);
    },
  );
  test(
    'reply and edit return pending messages only after a server event id',
    () async {
      when(
        () => reaction.sendReply('room', 'original', 'reply'),
      ).thenAnswer((_) async => 'reply-id');
      when(
        () => reaction.editMessage('room', 'original', 'edited'),
      ).thenAnswer((_) async => 'edit-id');
      final reply = (await repository.replyToMessage(
        'room',
        'original',
        'reply',
      ))!;
      expect(reply.replyToId, 'original');
      expect(reply.content, 'reply');
      expect(reply.id, 'reply-id');
      final edit = (await repository.editMessage(
        'room',
        'original',
        'edited',
      ))!;
      expect(edit.isEdited, isTrue);
      expect(edit.content, 'edited');
      when(
        () => reaction.sendReply('room', 'original', 'reply'),
      ).thenAnswer((_) async => null);
      when(
        () => reaction.editMessage('room', 'original', 'edited'),
      ).thenAnswer((_) async => null);
      expect(
        await repository.replyToMessage('room', 'original', 'reply'),
        isNull,
      );
      expect(
        await repository.editMessage('room', 'original', 'edited'),
        isNull,
      );
    },
  );
  for (final reacted in [true, false]) {
    test(
      'reaction toggle changes only the current user reaction (existing=$reacted)',
      () async {
        final client = MockClient();
        when(() => client.userID).thenReturn('@me:test');
        when(() => manager.client).thenReturn(client);
        when(() => reaction.getReactions('room', 'one')).thenAnswer(
          (_) async => {
            '👍': reacted ? ['@me:test', '@other:test'] : ['@other:test'],
          },
        );
        when(
          () => reaction.addReaction('room', 'one', '👍'),
        ).thenAnswer((_) async {});
        when(
          () => reaction.removeReaction('room', 'one', '👍'),
        ).thenAnswer((_) async {});
        await repository.toggleReaction('room', 'one', '👍');
        if (reacted) {
          verify(() => reaction.removeReaction('room', 'one', '👍')).called(1);
          verifyNever(() => reaction.addReaction('room', 'one', '👍'));
        } else {
          verify(() => reaction.addReaction('room', 'one', '👍')).called(1);
          verifyNever(() => reaction.removeReaction('room', 'one', '👍'));
        }
      },
    );
  }
  test(
    'reaction lookup preserves user ids without a room or active account',
    () async {
      when(() => manager.client).thenReturn(null);
      when(() => reaction.getReactions('room', 'one')).thenAnswer(
        (_) async => {
          '👍': ['@alice:test'],
        },
      );
      await repository.toggleReaction('room', 'one', '👍');
      final results = await repository.getReactions('room', 'one');
      expect(results.single.userNames, ['@alice:test']);
      expect(results.single.count, 1);
      verifyNever(() => reaction.addReaction('room', 'one', '👍'));
    },
  );
  test(
    'redaction permissions and reason pass through to the Matrix adapter',
    () async {
      when(() => reaction.canEdit('room', '@me:test')).thenReturn(true);
      when(() => reaction.canRedact('room', '@other:test')).thenReturn(false);
      when(
        () => reaction.redactMessage('room', 'one', reason: 'remove'),
      ).thenAnswer((_) async {});
      expect(repository.canEdit('room', '@me:test'), isTrue);
      expect(repository.canRedact('room', '@other:test'), isFalse);
      await repository.redactMessage('room', 'one', reason: 'remove');
      verify(
        () => reaction.redactMessage('room', 'one', reason: 'remove'),
      ).called(1);
    },
  );
}
