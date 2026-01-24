// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

// Feature Contracts
//
// Defines the contracts/interfaces that features must implement
// to participate in cross-feature communication.

/// Navigation Contract
///
/// Features can implement this to receive navigation requests.
abstract class INavigatable {
  /// Navigate to a specific route within this feature
  void navigateTo(String route, {Map<String, dynamic>? arguments});
  
  /// Pop current route
  void pop({dynamic result});
  
  /// Get feature's base route
  String get baseRoute;
}

/// Refreshable Contract
///
/// Features that can refresh their data implement this.
abstract class IRefreshable {
  /// Refresh all data
  Future<void> refresh();
  
  /// Check if currently refreshing
  bool get isRefreshing;
}

/// Disposable Contract
///
/// Features that need cleanup implement this.
abstract class IDisposable {
  /// Dispose resources
  void dispose();
  
  /// Check if disposed
  bool get isDisposed;
}

/// Authenticatable Contract
///
/// Features that need authentication checks implement this.
abstract class IAuthenticatable {
  /// Check if authenticated
  bool get isAuthenticated;
  
  /// Handle authentication required
  void onAuthenticationRequired();
  
  /// Handle authentication success
  void onAuthenticationSuccess();
  
  /// Handle logout
  void onLogout();
}

/// Feature Module Contract
///
/// Base contract for all feature modules.
abstract class IFeatureModule implements IDisposable {
  /// Initialize the feature
  Future<void> initialize();
  
  /// Feature identifier
  String get featureId;
  
  /// Feature display name
  String get featureName;
  
  /// Check if feature is initialized
  bool get isInitialized;
  
  /// Dependencies on other features (by featureId)
  List<String> get dependencies;
}

/// Data Provider Contract
///
/// Features that provide data to other features implement this.
abstract class IDataProvider<T> {
  /// Get current data
  T? get currentData;
  
  /// Stream of data changes
  Stream<T?> get dataStream;
  
  /// Fetch fresh data
  Future<T?> fetchData();
}

/// Event Listener Contract
///
/// Features that listen for events implement this.
abstract class IEventListener {
  /// Subscribe to events
  void subscribeToEvents();
  
  /// Unsubscribe from events
  void unsubscribeFromEvents();
  
  /// Check if subscribed
  bool get isSubscribed;
}

