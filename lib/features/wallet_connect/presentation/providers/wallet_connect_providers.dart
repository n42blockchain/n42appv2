// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

/// Global WCP instance shared between legacy code and Riverpod.
/// Initialized in main() before runApp().
late final WalletConnectProvider globalWcpInstance;

/// Riverpod bridge provider for WalletConnectProvider.
///
/// Usage:
/// - `ref.read(wcpBridgeProvider)` replaces `Provider.of<WCP>(context, listen: false)`
/// - `ref.watch(wcpBridgeProvider)` replaces `Consumer<WCP>`
final wcpBridgeProvider = ChangeNotifierProvider<WalletConnectProvider>((ref) {
  return globalWcpInstance;
});
