// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

/// Pins `WalletActionProvider.isWalletReady`, the gate that guards every
/// deferred read of `walletInfo` / `walletMap`.
///
/// Why it exists: `initWallet()` clears the wallet and coin lists synchronously
/// before its first `await` so the skeleton view can take over, but leaves
/// `walletIndex` pointing at the old slot. Anything that reads `walletInfo` in
/// that window throws
/// `Invalid walletIndex (0) for list of 0 wallets`.
///
/// T26 hit exactly this: `WalletPage.build` scheduled `_runTokenDiscovery` in a
/// post-frame callback while the wallet still looked loaded; `initWallet` — also
/// post-frame, registered earlier — then emptied the list before the discovery
/// callback ran. The fix re-checks `isWalletReady` inside the callback instead
/// of trusting the snapshot captured at schedule time.
void main() {
  late WalletActionProvider wap;

  setUp(() => wap = WalletActionProvider());

  group('isWalletReady', () {
    test('false before any wallet is loaded', () {
      expect(wap.walletInfoList, isEmpty);
      expect(wap.isWalletReady, isFalse);
    });

    test('false while a rebuild is in flight even with a loaded wallet', () {
      wap.walletInfoLsit.add(WalletInfo());
      wap.walletIndex = 0;
      expect(wap.isWalletReady, isTrue);

      wap.buildwallet = true;
      expect(
        wap.isWalletReady,
        isFalse,
        reason: 'a deferred consumer must not read walletInfo mid-rebuild',
      );
    });

    test('false for the transient "index kept, list emptied" state', () {
      wap.walletInfoLsit.add(WalletInfo());
      wap.walletIndex = 0;

      // Exactly what initWallet leaves behind before its first await.
      wap.walletInfoLsit.clear();

      expect(wap.walletIndex, 0);
      expect(wap.isWalletReady, isFalse);
      // And the gate is what stops the throw below from reaching a caller.
      expect(() => wap.walletInfo, throwsStateError);
    });

    test('false when no wallet is selected (walletIndex == -1)', () {
      wap.walletInfoLsit.add(WalletInfo());
      wap.walletIndex = -1;
      expect(wap.isWalletReady, isFalse);
    });

    test('false when walletIndex points past the end of the list', () {
      wap.walletInfoLsit.add(WalletInfo());
      wap.walletIndex = 5;
      expect(wap.isWalletReady, isFalse);
      expect(() => wap.walletInfo, throwsStateError);
    });

    test('true implies walletInfo is safe to read', () {
      wap.walletInfoLsit.add(WalletInfo());
      wap.walletIndex = 0;

      expect(wap.isWalletReady, isTrue);
      expect(() => wap.walletInfo, returnsNormally);
    });
  });
}
