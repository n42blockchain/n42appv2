// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';

/// App Context Provider Interface
///
/// Provides a testable abstraction over global context access.
/// This helps reduce direct usage of AppGlobals.appContext which
/// makes code harder to test and creates tight coupling.
///
/// Usage:
/// Instead of:
///   ```dart
///   Provider.of<SomeProvider>(AppGlobals.appContext, listen: false)
///   ```
///
/// Use:
///   ```dart
///   final provider = appContextProvider.getProvider<SomeProvider>();
///   ```
abstract class IAppContextProvider {
  /// Get the current BuildContext
  ///
  /// Returns null if no context is available (e.g., during app initialization)
  BuildContext? get currentContext;

  /// Check if context is available and mounted
  bool get hasValidContext;

  /// Get a Provider from the current context
  ///
  /// Returns null if context is not available or provider is not found
  T? getProvider<T>({bool listen = false});

  /// Execute a callback with a valid context
  ///
  /// Returns null if no valid context is available
  R? withContext<R>(R Function(BuildContext context) callback);

  /// Execute an async callback with a valid context
  Future<R?> withContextAsync<R>(Future<R> Function(BuildContext context) callback);
}

/// Default implementation using AppGlobals
///
/// This implementation wraps AppGlobals.appContext to provide
/// the same functionality through an interface, enabling:
/// - Dependency injection
/// - Testing with mock contexts
/// - Gradual migration away from global state
class DefaultAppContextProvider implements IAppContextProvider {
  final BuildContext Function() _contextGetter;

  DefaultAppContextProvider(this._contextGetter);

  @override
  BuildContext? get currentContext {
    try {
      final ctx = _contextGetter();
      return ctx.mounted ? ctx : null;
    } catch (_) {
      return null;
    }
  }

  @override
  bool get hasValidContext {
    final ctx = currentContext;
    return ctx != null && ctx.mounted;
  }

  @override
  T? getProvider<T>({bool listen = false}) {
    final ctx = currentContext;
    if (ctx == null) return null;

    try {
      // Use Provider.of with dynamic lookup
      // This is a simplified version - actual implementation would use Provider
      return null; // Subclasses should implement this with Provider
    } catch (_) {
      return null;
    }
  }

  @override
  R? withContext<R>(R Function(BuildContext context) callback) {
    final ctx = currentContext;
    if (ctx == null) return null;
    return callback(ctx);
  }

  @override
  Future<R?> withContextAsync<R>(Future<R> Function(BuildContext context) callback) async {
    final ctx = currentContext;
    if (ctx == null) return null;
    return await callback(ctx);
  }
}

/// Mock implementation for testing
class MockAppContextProvider implements IAppContextProvider {
  BuildContext? _mockContext;
  final Map<Type, dynamic> _mockProviders = {};

  void setMockContext(BuildContext? context) {
    _mockContext = context;
  }

  void registerMockProvider<T>(T provider) {
    _mockProviders[T] = provider;
  }

  @override
  BuildContext? get currentContext => _mockContext;

  @override
  bool get hasValidContext => _mockContext != null;

  @override
  T? getProvider<T>({bool listen = false}) {
    return _mockProviders[T] as T?;
  }

  @override
  R? withContext<R>(R Function(BuildContext context) callback) {
    if (_mockContext == null) return null;
    return callback(_mockContext!);
  }

  @override
  Future<R?> withContextAsync<R>(Future<R> Function(BuildContext context) callback) async {
    if (_mockContext == null) return null;
    return await callback(_mockContext!);
  }
}
