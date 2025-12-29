// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Navigation Service Interface
///
/// Shared interface for navigation operations that can be used across features.
/// Enables navigation without direct route dependencies.
abstract class INavigationService {
  /// Navigate to a named route
  void navigateTo(String routeName, {Map<String, dynamic>? arguments});

  /// Navigate and replace current route
  void navigateAndReplace(String routeName, {Map<String, dynamic>? arguments});

  /// Navigate and remove all previous routes
  void navigateAndRemoveUntil(String routeName, {Map<String, dynamic>? arguments});

  /// Pop current route
  void pop<T>({T? result});

  /// Pop until a specific route
  void popUntil(String routeName);

  /// Check if can pop
  bool canPop();

  /// Navigate to home
  void goHome();

  /// Navigate to login
  void goLogin();

  /// Navigate to wallet detail
  void goWalletDetail({required String address});

  /// Navigate to transaction detail
  void goTransactionDetail({
    required String txHash,
    required String chainType,
  });

  /// Navigate to send screen
  void goSend({
    required String walletAddress,
    String? toAddress,
    String? amount,
    String? tokenAddress,
  });

  /// Navigate to receive screen
  void goReceive({required String walletAddress});

  /// Navigate to chat detail
  void goChatDetail({required String conversationId});
}

