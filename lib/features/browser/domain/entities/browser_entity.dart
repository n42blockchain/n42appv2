// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Browser History Entity
class BrowserHistoryEntity extends Equatable {
  final String id;
  final String url;
  final String title;
  final String? favicon;
  final DateTime visitedAt;

  const BrowserHistoryEntity({
    required this.id,
    required this.url,
    required this.title,
    this.favicon,
    required this.visitedAt,
  });

  @override
  List<Object?> get props => [id, url, title, favicon, visitedAt];
}

/// Bookmark Entity
class BookmarkEntity extends Equatable {
  final String id;
  final String url;
  final String title;
  final String? favicon;
  final String? folderId;
  final DateTime createdAt;

  const BookmarkEntity({
    required this.id,
    required this.url,
    required this.title,
    this.favicon,
    this.folderId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, url, title, favicon, folderId, createdAt];
}

/// Bookmark Folder Entity
class BookmarkFolderEntity extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;

  const BookmarkFolderEntity({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, parentId, createdAt];
}

/// Browser Settings Entity
class BrowserSettingsEntity extends Equatable {
  final String searchEngine;
  final bool blockAds;
  final bool blockTrackers;
  final bool enableJavascript;
  final bool enableCookies;
  final bool saveHistory;
  final String defaultUserAgent;
  final bool desktopMode;

  const BrowserSettingsEntity({
    this.searchEngine = 'google',
    this.blockAds = false,
    this.blockTrackers = false,
    this.enableJavascript = true,
    this.enableCookies = true,
    this.saveHistory = true,
    this.defaultUserAgent = 'mobile',
    this.desktopMode = false,
  });

  BrowserSettingsEntity copyWith({
    String? searchEngine,
    bool? blockAds,
    bool? blockTrackers,
    bool? enableJavascript,
    bool? enableCookies,
    bool? saveHistory,
    String? defaultUserAgent,
    bool? desktopMode,
  }) {
    return BrowserSettingsEntity(
      searchEngine: searchEngine ?? this.searchEngine,
      blockAds: blockAds ?? this.blockAds,
      blockTrackers: blockTrackers ?? this.blockTrackers,
      enableJavascript: enableJavascript ?? this.enableJavascript,
      enableCookies: enableCookies ?? this.enableCookies,
      saveHistory: saveHistory ?? this.saveHistory,
      defaultUserAgent: defaultUserAgent ?? this.defaultUserAgent,
      desktopMode: desktopMode ?? this.desktopMode,
    );
  }

  @override
  List<Object?> get props => [
        searchEngine,
        blockAds,
        blockTrackers,
        enableJavascript,
        enableCookies,
        saveHistory,
        defaultUserAgent,
        desktopMode,
      ];
}

/// Tab Entity
class TabEntity extends Equatable {
  final String id;
  final String url;
  final String title;
  final String? favicon;
  final bool isActive;
  final DateTime createdAt;

  const TabEntity({
    required this.id,
    required this.url,
    required this.title,
    this.favicon,
    this.isActive = false,
    required this.createdAt,
  });

  TabEntity copyWith({
    String? id,
    String? url,
    String? title,
    String? favicon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TabEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      favicon: favicon ?? this.favicon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, url, title, favicon, isActive, createdAt];
}

