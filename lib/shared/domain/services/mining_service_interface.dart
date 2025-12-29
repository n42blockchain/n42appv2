// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Mining Status
enum MiningStatus {
  idle,
  mining,
  paused,
  stopped,
  error,
}

/// Mining Info
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

/// Mining Service Interface
///
/// This interface allows other features (like Wallet) to access mining
/// status without direct dependency on the Mining feature.
abstract class IMiningService {
  /// Get current mining status
  MiningStatus get status;

  /// Check if mining is active
  bool get isMining;

  /// Get current mining wallet address
  String? get miningWalletAddress;

  /// Get mining info
  SharedMiningInfo get miningInfo;

  /// Stream of mining status changes
  Stream<MiningStatus> get statusStream;

  /// Notify mining feature of wallet change
  void onWalletChanged(String? newAddress);
}

