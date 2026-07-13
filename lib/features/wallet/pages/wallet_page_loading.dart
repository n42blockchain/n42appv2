// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

bool shouldShowWalletInitialLoading({
  required int walletIndex,
  required bool isBuilding,
  required bool hasCoins,
}) {
  return walletIndex == -1 || (isBuilding && !hasCoins);
}
