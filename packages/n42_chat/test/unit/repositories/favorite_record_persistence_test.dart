import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_reaction_datasource.dart';
import 'package:n42_chat/src/data/repositories/message_action_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Reaction extends Mock implements MatrixReactionDataSource {}

class _Manager extends Mock implements MatrixClientManager {}

class _Store extends InMemorySharedPreferencesStore {
  _Store() : super.empty();
  int writes = 0;
  int? rejectWrite;
  bool throwOnReject = false;

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    writes++;
    if (writes == rejectWrite) {
      if (throwOnReject) throw StateError('write rejected');
      return false;
    }
    return super.setValue(type, key, value);
  }
}

class _DelayedStorage extends PreferencesDataSource {
  final started = Completer<void>();
  final release = Completer<void>();
  int reads = 0;

  @override
  Future<String?> getFavoriteRecord() async {
    reads++;
    final snapshot = await super.getFavoriteRecord();
    if (reads == 1) {
      started.complete();
      await release.future;
    }
    return snapshot;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Store platform;
  late PreferencesDataSource storage;
  late MessageActionRepositoryImpl repository;
  MessageActionRepositoryImpl fresh() => MessageActionRepositoryImpl(
    _Reaction(),
    _Manager(),
    PreferencesDataSource(),
  );
  const recordKey = 'n42_chat_favorite_record';
  MessageEntity message(String id) => MessageEntity(
    id: id,
    roomId: 'room',
    senderId: 'alice',
    senderName: 'Alice',
    content: id,
    type: MessageType.text,
    timestamp: DateTime.utc(2026),
  );
  Future<void> seedLegacy({
    String meta = '{"one":{"tags":["work"],"remark":"keep"}}',
  }) async {
    await storage.saveFavoriteMessages('[{"id":"one"},{"id":"two"}]');
    await storage.saveFavoriteMeta(meta);
    platform.writes = 0;
  }

  void restartPreferences() {
    // Discard the optimistic plugin cache and reload the fake platform's state.
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesStorePlatform.instance = platform;
  }

  Future<Map<String, dynamic>> record() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(recordKey)!) as Map<String, dynamic>;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    platform = _Store();
    SharedPreferencesStorePlatform.instance = platform;
    storage = PreferencesDataSource();
    repository = fresh();
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  test(
    'deletion commits the message and metadata in a single platform write',
    () async {
      await seedLegacy();
      platform.rejectWrite = 2;
      await repository.unsaveMessage('one');
      expect(platform.writes, 1);
      expect((await fresh().getSavedMessages()).map((m) => m.id), ['two']);
      expect((await record())['metadata'], isNot(contains('one')));
    },
  );

  test(
    'corrupt legacy metadata blocks deletion before any durable change',
    () async {
      await seedLegacy(meta: 'broken-json');
      await expectLater(repository.unsaveMessage('one'), throwsFormatException);
      expect(platform.writes, 0);
      expect(
        await storage.getFavoriteMessages(),
        '[{"id":"one"},{"id":"two"}]',
      );
      expect(await storage.getFavoriteMeta(), 'broken-json');
    },
  );

  for (final throwFailure in [false, true]) {
    for (final migrated in [false, true]) {
      test(
        'rejected deletion preserves both halves and can retry (throw=$throwFailure migrated=$migrated)',
        () async {
          await seedLegacy();
          if (migrated) await repository.editFavoriteRemark('one', 'keep');
          platform.rejectWrite = platform.writes + 1;
          platform.throwOnReject = throwFailure;
          await expectLater(repository.unsaveMessage('one'), throwsStateError);
          expect(await repository.isMessageSaved('one'), isTrue);
          restartPreferences();
          repository = fresh();
          storage = PreferencesDataSource();
          expect(await repository.isMessageSaved('one'), isTrue);
          if (migrated) {
            expect((await record())['metadata']['one']['remark'], 'keep');
          } else {
            expect(
              (await SharedPreferences.getInstance()).getString(recordKey),
              isNull,
            );
            expect(
              jsonDecode((await storage.getFavoriteMeta())!)['one']['remark'],
              'keep',
            );
          }
          platform.rejectWrite = null;
          await repository.unsaveMessage('one');
          expect(await fresh().isMessageSaved('one'), isFalse);
          expect((await record())['metadata'], isNot(contains('one')));
        },
      );
    }
  }

  test(
    'read-only legacy access does not migrate or require writable storage',
    () async {
      await seedLegacy();
      platform.rejectWrite = 1;
      expect((await repository.getSavedMessages()).map((m) => m.id), [
        'one',
        'two',
      ]);
      expect(platform.writes, 0);
    },
  );

  test(
    'first edit migrates both halves and preserves untouched legacy data',
    () async {
      await seedLegacy();
      await repository.editFavoriteTags('one', ['updated']);
      final saved = await record();
      expect(saved['version'], 1);
      expect((saved['messages'] as List).map((m) => m['id']), ['one', 'two']);
      expect(saved['metadata']['one'], {
        'tags': ['updated'],
        'remark': 'keep',
      });
      expect(
        await storage.getFavoriteMessages(),
        '[{"id":"one"},{"id":"two"}]',
      );
      expect(jsonDecode((await storage.getFavoriteMeta())!)['one']['tags'], [
        'work',
      ]);
    },
  );

  test(
    'reopening after commit never resurrects retained legacy favorites',
    () async {
      await seedLegacy();
      await repository.unsaveMessage('one');
      await storage.saveFavoriteMeta('broken-json');
      await storage.saveFavoriteMessages('broken-json');
      restartPreferences();
      expect((await fresh().getSavedMessages()).map((m) => m.id), ['two']);
      await fresh().saveMessage(message('three'));
      expect((await fresh().getSavedMessages()).map((m) => m.id), [
        'two',
        'three',
      ]);
      expect((await record())['metadata'], isNot(contains('one')));
    },
  );

  test(
    'favorite page state retains a rejected deletion and clears its error on retry',
    () async {
      await seedLegacy();
      final bloc = FavoriteBloc(repository: repository);
      addTearDown(bloc.close);
      final loaded = bloc.stream.firstWhere(
        (s) => !s.isLoading && s.favorites.length == 2,
      );
      bloc.add(const LoadFavorites());
      await loaded.timeout(const Duration(seconds: 5));
      platform.rejectWrite = platform.writes + 1;
      final failed = bloc.stream.firstWhere((s) => s.error != null);
      bloc.add(const DeleteFavorite('one'));
      final failure = await failed.timeout(const Duration(seconds: 5));
      expect(failure.favorites.map((m) => m.id), ['one', 'two']);
      restartPreferences();
      expect(await fresh().isMessageSaved('one'), isTrue);
      platform.rejectWrite = null;
      final retried = bloc.stream.firstWhere((s) => s.favorites.length == 1);
      bloc.add(const DeleteFavorite('one'));
      final success = await retried.timeout(const Duration(seconds: 5));
      expect(success.error, isNull);
      expect(success.favorites.single.id, 'two');
      restartPreferences();
      expect(await fresh().isMessageSaved('one'), isFalse);
    },
  );

  test(
    'concurrent initial read and edit share a snapshot without overwriting a committed cache',
    () async {
      final delayed = _DelayedStorage();
      final repo = MessageActionRepositoryImpl(
        _Reaction(),
        _Manager(),
        delayed,
      );
      final reading = repo.getSavedMessages();
      await delayed.started.future;
      final saving = repo.saveMessage(message('new'));
      await Future<void>.delayed(Duration.zero);
      final readCount = delayed.reads;
      delayed.release.complete();
      await reading;
      await saving;
      expect(readCount, 1);
      expect(await repo.isMessageSaved('new'), isTrue);
      restartPreferences();
      expect(await fresh().isMessageSaved('new'), isTrue);
    },
  );

  for (final invalid in [
    'broken-json',
    '{"version":2,"messages":[],"metadata":{}}',
    '{"version":1,"messages":[],"metadata":null}',
    '{"version":1,"messages":{},"metadata":{}}',
    '{"version":1,"messages":[],"metadata":{"one":null}}',
    '{"version":1,"messages":[null],"metadata":{}}',
    '',
  ]) {
    test(
      'invalid committed record cannot fall back to legacy or be overwritten: $invalid',
      () async {
        await seedLegacy();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(recordKey, invalid);
        platform.writes = 0;
        await expectLater(
          repository.saveMessage(message('new')),
          throwsFormatException,
        );
        expect(platform.writes, 0);
        expect(prefs.getString(recordKey), invalid);
        await prefs.setString(
          recordKey,
          '{"version":1,"messages":[],"metadata":{}}',
        );
        await repository.saveMessage(message('new'));
        expect((await fresh().getSavedMessages()).single.id, 'new');
      },
    );
  }
}
