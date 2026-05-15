// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei
//
// **Status: designed but not adopted.** None of the seven contracts in
// this file has an implementor in production code — they were drafted
// as a feature-module surface (alongside [FeatureInitializer]) for a
// dependency-aware bootstrap that was never wired up. The current
// architecture instead leans on Riverpod's natural provider graph,
// where cross-feature data and lifecycle are expressed through
// `ref.watch` / `ref.read` and `ref.onDispose`.
//
// Kept in tree as the canonical reference for the originally intended
// feature-module surface (in case the project ever revisits a Hilt /
// module-system style bootstrap). Do not extend without first reviving
// the FeatureInitializer integration.

/// Contract for features that handle in-feature navigation.
abstract class INavigatable {
  void navigateTo(String route, {Map<String, dynamic>? arguments});
  void pop({dynamic result});
  String get baseRoute;
}

/// Contract for features that support data refresh.
abstract class IRefreshable {
  Future<void> refresh();
  bool get isRefreshing;
}

/// Contract for features that require resource cleanup.
abstract class IDisposable {
  void dispose();
  bool get isDisposed;
}

/// Contract for features that require authentication guards.
abstract class IAuthenticatable {
  bool get isAuthenticated;
  void onAuthenticationRequired();
  void onAuthenticationSuccess();
  void onLogout();
}

/// Base contract for all feature modules.
abstract class IFeatureModule implements IDisposable {
  Future<void> initialize();
  String get featureId;
  String get featureName;
  bool get isInitialized;
  List<String> get dependencies;
}

/// Contract for features that expose reactive data to others.
abstract class IDataProvider<T> {
  T? get currentData;
  Stream<T?> get dataStream;
  Future<T?> fetchData();
}

/// Contract for features that subscribe to cross-feature events.
abstract class IEventListener {
  void subscribeToEvents();
  void unsubscribeFromEvents();
  bool get isSubscribed;
}

