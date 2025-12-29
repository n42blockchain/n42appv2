// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42appv2/core/error/failures.dart';
import 'package:n42appv2/features/browser/domain/entities/browser_entity.dart';

/// Browser Repository Interface
///
/// Defines the contract for browser data operations.
abstract class BrowserRepository {
  /// Get browser history
  Future<Either<Failure, List<BrowserHistoryEntity>>> getHistory({
    int page = 1,
    int limit = 20,
  });

  /// Add history entry
  Future<Either<Failure, void>> addHistory({
    required String url,
    required String title,
    String? favicon,
  });

  /// Delete history entry
  Future<Either<Failure, void>> deleteHistory(String id);

  /// Clear all history
  Future<Either<Failure, void>> clearHistory();

  /// Search history
  Future<Either<Failure, List<BrowserHistoryEntity>>> searchHistory(String query);

  /// Get bookmarks
  Future<Either<Failure, List<BookmarkEntity>>> getBookmarks({
    String? folderId,
  });

  /// Add bookmark
  Future<Either<Failure, BookmarkEntity>> addBookmark({
    required String url,
    required String title,
    String? folderId,
    String? favicon,
  });

  /// Update bookmark
  Future<Either<Failure, BookmarkEntity>> updateBookmark({
    required String id,
    String? title,
    String? url,
    String? folderId,
  });

  /// Delete bookmark
  Future<Either<Failure, void>> deleteBookmark(String id);

  /// Check if URL is bookmarked
  Future<Either<Failure, bool>> isBookmarked(String url);

  /// Get bookmark by URL
  Future<Either<Failure, BookmarkEntity?>> getBookmarkByUrl(String url);

  /// Get browser settings
  Future<Either<Failure, BrowserSettingsEntity>> getSettings();

  /// Update browser settings
  Future<Either<Failure, void>> updateSettings(BrowserSettingsEntity settings);

  /// Get search suggestions
  Future<Either<Failure, List<String>>> getSearchSuggestions(String query);
}

