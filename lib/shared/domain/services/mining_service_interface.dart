// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

enum MiningStatus {
  idle,
  mining,
  paused,
  stopped,
  error,
}

class SharedMiningInfo {
  final MiningStatus status;
  final String? currentReward;
  final String? totalReward;
  final DateTime? startTime;
  final String? walletAddress;

  const SharedMiningInfo({
    required this.status,
    this.currentReward,
    this.totalReward,
    this.startTime,
    this.walletAddress,
  });

  bool get isActive => status == MiningStatus.mining;
}

/// Allows other features to access mining status without direct dependency.
abstract class IMiningService {
  MiningStatus get status;
  bool get isMining;
  String? get miningWalletAddress;
  SharedMiningInfo get miningInfo;
  Stream<MiningStatus> get statusStream;
  void onWalletChanged(String? newAddress);
}

