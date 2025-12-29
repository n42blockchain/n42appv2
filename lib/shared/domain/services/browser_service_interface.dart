// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Browser Service Interface
///
/// Shared interface for browser operations that can be used across features.
/// Enables opening URLs without direct dependency on Browser feature.
abstract class IBrowserService {
  /// Open URL in in-app browser
  Future<void> openUrl(String url);

  /// Open URL in external browser
  Future<void> openUrlExternal(String url);

  /// Open blockchain explorer for transaction
  Future<void> openTransactionInExplorer({
    required String txHash,
    required String chainType,
  });

  /// Open blockchain explorer for address
  Future<void> openAddressInExplorer({
    required String address,
    required String chainType,
  });

  /// Open blockchain explorer for token
  Future<void> openTokenInExplorer({
    required String tokenAddress,
    required String chainType,
  });
}

