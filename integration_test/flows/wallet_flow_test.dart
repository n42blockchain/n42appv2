// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:integration_test/integration_test.dart';

import '../../test/core/storage/chat_sqlcipher_runtime_test.dart'
    as chat_crypto;

import 'wallet_form_cases.dart';
import 'wallet_import_fixture.dart';
import 'wallet_send_fixture.dart';
import 'wallet_history_fixture.dart';
import 'wallet_login_fixture.dart';
import 'wallet_funded_transfer_fixture.dart';

/// Native wallet flows use isolated fixtures. Funded transfers additionally
/// require explicit opt-in, an owned loopback chain and disposable signing data.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  chat_crypto.main();
  registerWalletFormCases();
  registerWalletImportFixture();
  registerWalletSendFixture();
  registerWalletHistoryFixture();
  registerWalletLoginFixture();

  registerWalletFundedTransferFixture();
}
