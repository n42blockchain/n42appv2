import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/browser/domain/entities/browser_entity.dart';
import 'package:n42_wallet/features/browser/domain/repositories/browser_repository.dart';
import 'package:n42_wallet/src/browser/api/browser_api.dart';
import 'package:n42_wallet/src/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/src/browser/models/browser_history_model.dart';

/// Concrete implementation of [BrowserRepository] backed by SQLite
/// via [BrowserApi].
class BrowserRepositoryImpl implements BrowserRepository {
  final BrowserApi _api;

  BrowserRepositoryImpl({BrowserApi? api}) : _api = api ?? BrowserApi();

  // ── History ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<BrowserHistoryEntity>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await _api.selectBrowserHistory(
        pageSize: limit,
        pageNum: page,
      );
      return Right(models.map(_historyFromModel).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHistory({
    required String url,
    required String title,
    String? favicon,
  }) async {
    try {
      _api.insertBrowserHistory(url, title: title);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistory(String id) async {
    try {
      await _api.deleteBrowserHistoryById(int.parse(id));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await _api.clearBrowserHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrowserHistoryEntity>>> searchHistory(
      String query) async {
    try {
      final models = await _api.selectBrowserHistoryLike(query);
      return Right(models.map(_historyFromModel).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  // ── Bookmarks ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<BookmarkEntity>>> getBookmarks({
    String? folderId,
  }) async {
    try {
      // folderId is not supported in the current schema; return all
      final models = await _api.selectBrowserCollection(pageSize: 1000);
      return Right(models.map(_bookmarkFromModel).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkEntity>> addBookmark({
    required String url,
    required String title,
    String? folderId,
    String? favicon,
  }) async {
    try {
      await _api.insertBrowserCollection(title, url, favicon: favicon);
      // Read back the newly inserted bookmark
      final list = await _api.selectBrowserCollectionUrl(url);
      if (list.isEmpty) {
        return Left(CacheFailure(message: 'Insert failed'));
      }
      return Right(_bookmarkFromModel(list.last));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkEntity>> updateBookmark({
    required String id,
    String? title,
    String? url,
    String? folderId,
  }) async {
    try {
      // Fetch existing
      final db = _api.db;
      final rows = await db.selectBrowserCollection(pageSize: 1000);
      final existing = rows.firstWhere(
        (m) => m.id.toString() == id,
        orElse: () => throw 'Bookmark not found',
      );
      if (title != null) existing.name = title;
      if (url != null) existing.url = url;
      await _api.updateBrowsercollection(existing);
      return Right(_bookmarkFromModel(existing));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookmark(String id) async {
    try {
      await _api.deleteBrowserCollection(int.parse(id));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked(String url) async {
    try {
      final list = await _api.selectBrowserCollectionUrl(url);
      return Right(list.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookmarkEntity?>> getBookmarkByUrl(String url) async {
    try {
      final list = await _api.selectBrowserCollectionUrl(url);
      if (list.isEmpty) return const Right(null);
      return Right(_bookmarkFromModel(list.first));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  // ── Settings ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, BrowserSettingsEntity>> getSettings() async {
    // Settings are stored in SharedPreferences via SPUtil, not here
    return const Right(BrowserSettingsEntity());
  }

  @override
  Future<Either<Failure, void>> updateSettings(
      BrowserSettingsEntity settings) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
      String query) async {
    try {
      final models = await _api.selectBrowserHistoryLike(query);
      return Right(models.map((m) => m.url ?? '').toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  // ── Mappers ──────────────────────────────────────────────────────────

  static BrowserHistoryEntity _historyFromModel(BrowserHistoryModel m) {
    return BrowserHistoryEntity(
      id: m.id?.toString() ?? '',
      url: m.url ?? '',
      title: m.title ?? m.url ?? '',
      visitedAt: m.time != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(m.time!) ?? 0,
            )
          : DateTime.now(),
    );
  }

  static BookmarkEntity _bookmarkFromModel(BrowserCollectionModel m) {
    return BookmarkEntity(
      id: m.id?.toString() ?? '',
      url: m.url ?? '',
      title: m.name ?? '',
      favicon: m.favicon,
      createdAt: m.createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(m.createdAt!)
          : DateTime.now(),
    );
  }
}
