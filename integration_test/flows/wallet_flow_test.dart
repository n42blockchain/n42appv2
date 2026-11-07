// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../test/core/storage/chat_sqlcipher_runtime_test.dart'
    as chat_crypto;

import 'wallet_form_cases.dart';
import 'wallet_import_fixture.dart';
import 'wallet_send_fixture.dart';
import 'wallet_history_fixture.dart';
import 'wallet_login_fixture.dart';

/// Device flows that require an isolated wallet fixture and a controllable RPC.
///
/// These cases used to contain unconditional placeholder assertions and were
/// reported as passing without launching the app. They remain explicitly
/// skipped until the integration harness can seed disposable wallet data
/// without exposing mnemonic phrases or broadcasting unintended transactions.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  chat_crypto.main();
  registerWalletFormCases();
  registerWalletImportFixture();
  registerWalletSendFixture();
  registerWalletHistoryFixture();
  registerWalletLoginFixture();

  for (final testCase in _pendingWalletCases) {
    final displayName = '${testCase.name} [BLOCKED: ${testCase.blocker}]';
    testWidgets(displayName, (tester) async {
      // The body is intentionally unreachable while the case is skipped.
    }, skip: true);
  }
}

const _pendingWalletCases = <_PendingDeviceCase>[
  _PendingDeviceCase(
    'TX-06 sends a disposable testnet transaction',
    'Requires verified N42 test RPC/client provenance and an approved disposable funded account.',
  ),
];

class _PendingDeviceCase {
  const _PendingDeviceCase(this.name, this.blocker);

  final String name;
  final String blocker;
}
