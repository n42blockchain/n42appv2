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

/// Controls whether to use V2 (beacon-chain staking, default) or V1 (APOS mining) UI.
/// true = V2, false = V1
final miningUseV2Provider = StateNotifierProvider<MiningUiVersionNotifier, bool>((ref) {
  return MiningUiVersionNotifier(ref.read(spUtilProvider));
});

class MiningUiVersionNotifier extends StateNotifier<bool> {
  final SPUtil _sp;

  MiningUiVersionNotifier(this._sp) : super(true) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final useV2 = await _sp.getMiningUseV2();
    if (mounted) state = useV2;
  }

  Future<void> setUseV2(bool useV2) async {
    await _sp.setMiningUseV2(useV2);
    state = useV2;
  }
}
