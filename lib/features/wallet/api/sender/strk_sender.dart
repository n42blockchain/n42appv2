// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'chain_sender.dart';

/// Starknet (STRK) — stub implementation.
/// Starknet uses the STARK curve which trustdart does not yet support.
/// Full support requires the StarkNet.dart SDK.
class StrkSender implements ChainSender {
  @override
  Future<SendResult> send(SendParams params) async => const SendResult.fail(
    'Starknet transfer: requires StarkNet.dart SDK, not yet implemented',
  );
}
