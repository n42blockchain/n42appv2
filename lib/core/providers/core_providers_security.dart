// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

part of 'core_providers.dart';

// ============================================
// Mining UI Version Provider
// ============================================

/// The mining engine the mining tab runs: v1 (APOS), v2 (beacon-chain
/// staking, default) or v3 (mobileverify). See [MiningEngineKind].
final miningEngineKindProvider =
    StateNotifierProvider<MiningEngineKindNotifier, MiningEngineKind>((ref) {
      return MiningEngineKindNotifier(ref.read(spUtilProvider));
    });

class MiningEngineKindNotifier extends StateNotifier<MiningEngineKind> {
  MiningEngineKindNotifier(this._sp, {this.v3Available = miningV3Available})
    : super(MiningEngineKind.v2) {
    _loadInitial();
  }

  final SPUtil _sp;

  /// Whether v3 may be selected; a stored v3 reads as v2 otherwise.
  final bool v3Available;

  MiningEngineKind _allowed(MiningEngineKind kind) =>
      kind == MiningEngineKind.v3 && !v3Available ? MiningEngineKind.v2 : kind;

  Future<void> _loadInitial() async {
    final kind = _allowed(await _sp.getMiningEngine());
    if (mounted) state = kind;
  }

  Future<void> select(MiningEngineKind kind) async {
    kind = _allowed(kind);
    await _sp.setMiningEngine(kind);
    state = kind;
  }
}
