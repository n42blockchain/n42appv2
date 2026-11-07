// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'wallet_form_cases.dart';
import 'wallet_import_fixture.dart';
import 'wallet_send_fixture.dart';

/// Device flows that require an isolated wallet fixture and a controllable RPC.
///
/// These cases used to contain unconditional placeholder assertions and were
/// reported as passing without launching the app. They remain explicitly
/// skipped until the integration harness can seed disposable wallet data
/// without exposing mnemonic phrases or broadcasting unintended transactions.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  registerWalletFormCases();
  registerWalletImportFixture();
  registerWalletSendFixture();

  for (final testCase in _pendingWalletCases) {
    final displayName = '${testCase.name} [BLOCKED: ${testCase.blocker}]';
    testWidgets(displayName, (tester) async {
      // The body is intentionally unreachable while the case is skipped.
    }, skip: true);
  }
}

const _pendingWalletCases = <_PendingDeviceCase>[
  _PendingDeviceCase(
    'WLT-01 creates and backs up a disposable wallet',
    'Requires an isolated secure-storage fixture and disposable mnemonic.',
  ),
  _PendingDeviceCase(
    'WLT-02 imports a disposable mnemonic wallet',
    'Requires complete address initialization and wallet-home acceptance.',
  ),
  _PendingDeviceCase(
    'WLT-03 imports a disposable private-key wallet',
    'Requires a secret-safe device fixture for a disposable private key.',
  ),
  _PendingDeviceCase(
    'WLT-14 displays progressively loaded wallet balances',
    'Requires a deterministic fake RPC connected to the device build.',
  ),
  _PendingDeviceCase(
    'WLT-14 refreshes balances without stale account data',
    'Requires a deterministic fake RPC connected to the device build.',
  ),
  _PendingDeviceCase(
    'TX-13 displays transaction history',
    'Requires seeded transaction history from a controllable RPC.',
  ),
  _PendingDeviceCase(
    'TX-06 sends a disposable testnet transaction',
    'Requires an approved funded testnet wallet and controllable RPC.',
  ),
];

class _PendingDeviceCase {
  const _PendingDeviceCase(this.name, this.blocker);

  final String name;
  final String blocker;
}
