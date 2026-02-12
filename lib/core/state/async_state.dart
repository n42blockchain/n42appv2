// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unified async state type alias
typedef AsyncState<T> = AsyncValue<T>;

/// Extension methods for AsyncValue
extension AsyncStateX<T> on AsyncValue<T> {
  /// Whether the state is refreshing (has old data but loading new data)
  bool get isRefreshing => isLoading && hasValue;
  
  /// Get data or return default value
  T dataOr(T defaultValue) => value ?? defaultValue;
  
  /// Map data while preserving loading/error states
  AsyncValue<R> mapData<R>(R Function(T data) mapper) {
    return when(
      data: (data) => AsyncValue.data(mapper(data)),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }
  
  /// Execute action when has data
  void whenHasData(void Function(T data) action) {
    if (hasValue && value != null) {
      action(value as T);
    }
  }
}

/// Loading state enum for legacy compatibility
enum LoadState {
  initial,
  loading,
  success,
  error,
}

/// Extension to convert between AsyncValue and LoadState
extension AsyncValueToLoadState<T> on AsyncValue<T> {
  LoadState get loadState {
    if (isLoading) return LoadState.loading;
    if (hasError) return LoadState.error;
    if (hasValue) return LoadState.success;
    return LoadState.initial;
  }
}

