// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

