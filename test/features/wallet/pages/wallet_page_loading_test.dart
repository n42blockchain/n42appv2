// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_loading.dart';

void main() {
  group('shouldShowWalletInitialLoading', () {
    test('waits until the wallet index is available', () {
      expect(
        shouldShowWalletInitialLoading(
          walletIndex: -1,
          isBuilding: false,
          hasCoins: false,
        ),
        isTrue,
      );
    });

    test('shows wallet content after the first coin is built', () {
      expect(
        shouldShowWalletInitialLoading(
          walletIndex: 0,
          isBuilding: true,
          hasCoins: true,
        ),
        isFalse,
      );
    });

    test('keeps loading while a wallet switch has no coin data', () {
      expect(
        shouldShowWalletInitialLoading(
          walletIndex: 1,
          isBuilding: true,
          hasCoins: false,
        ),
        isTrue,
      );
    });
  });
}
