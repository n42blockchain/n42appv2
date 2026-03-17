import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/data/repositories/browser_repository_impl.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/models/browser_history_model.dart';

class FakeBrowserApi extends BrowserApi {
  Completer<int>? insertHistoryCompleter;
  Object? insertHistoryError;
  Object? insertCollectionError;
  List<BrowserCollectionModel> collectionByUrl = [];

  @override
  Future<int> insertBrowserHistory(String url, {String? title}) async {
    if (insertHistoryError != null) throw insertHistoryError!;
    final completer = insertHistoryCompleter;
    if (completer != null) return completer.future;
    return 1;
  }

  @override
  Future<void> insertBrowserCollection(
    String name,
    String url, {
    String desc = "",
    String? favicon,
  }) async {
    if (insertCollectionError != null) throw insertCollectionError!;
    collectionByUrl.add(
      BrowserCollectionModel(url, name, desc, faviconStr: favicon)..id = 1,
    );
  }

  @override
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async {
    return collectionByUrl.where((item) => item.url == url).toList();
  }

  @override
  Future<List<BrowserHistoryModel>> selectBrowserHistory({
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    return [];
  }
}

void main() {
  group('BrowserRepositoryImpl async persistence', () {
    test('addHistory waits for BrowserApi insert to finish', () async {
      final api = FakeBrowserApi()..insertHistoryCompleter = Completer<int>();
      final repo = BrowserRepositoryImpl(api: api);

      var completed = false;
      final future = repo.addHistory(url: 'https://n42.world', title: 'N42')
        ..then((_) => completed = true);

      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      api.insertHistoryCompleter!.complete(1);
      final result = await future;

      expect(completed, isTrue);
      expect(result, const Right(null));
    });

    test('addHistory returns CacheFailure when insert throws', () async {
      final api = FakeBrowserApi()
        ..insertHistoryError = StateError('insert failed');
      final repo = BrowserRepositoryImpl(api: api);

      final result = await repo.addHistory(
        url: 'https://n42.world',
        title: 'N42',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(
          failure,
          const CacheFailure(message: 'Bad state: insert failed'),
        ),
        (_) => fail('expected CacheFailure'),
      );
    });

    test('addBookmark returns CacheFailure when insert throws', () async {
      final api = FakeBrowserApi()
        ..insertCollectionError = StateError('bookmark insert failed');
      final repo = BrowserRepositoryImpl(api: api);

      final result = await repo.addBookmark(
        url: 'https://n42.world',
        title: 'N42',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(
          failure,
          const CacheFailure(message: 'Bad state: bookmark insert failed'),
        ),
        (_) => fail('expected CacheFailure'),
      );
    });
  });
}
