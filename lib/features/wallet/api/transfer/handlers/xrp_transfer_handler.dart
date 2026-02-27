// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/models/message_model.dart';
import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for XRP Ledger chain
class XrpTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'XRP';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'XRP';

  @override
  // TODO: Migrate from transfer_api.dart transferXrp method
  Future<MessageModel> transfer(TransferParams params) => notYetMigrated();

  @override
  // TODO: Implement gas estimation
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      notImplementedGas();
}
