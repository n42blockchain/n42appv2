// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

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

