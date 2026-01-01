// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:n42appv2/shared/domain/services/mining_service_interface.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/shared/events/event_manager.dart';
import 'package:n42appv2/shared/events/cross_feature_events.dart';

/// Mining Service Implementation
///
/// Implements IMiningService to provide mining status to other features.
/// Uses IWalletService interface to access wallet data (not the Wallet feature directly).
class MiningServiceImpl implements IMiningService {
  final StreamController<MiningStatus> _statusStreamController =
      StreamController<MiningStatus>.broadcast();

  MiningStatus _status = MiningStatus.idle;
  String? _miningWalletAddress;
  SharedMiningInfo _miningInfo = const SharedMiningInfo(status: MiningStatus.idle);

  StreamSubscription? _walletEventSubscription;

  MiningServiceImpl() {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    // Listen for wallet changes from the shared event bus
    _walletEventSubscription = eventManager.on<WalletSelectedEvent>((event) {
      onWalletChanged(event.wallet.address);
    });
  }

  @override
  MiningStatus get status => _status;

  @override
  bool get isMining => _status == MiningStatus.mining;

  @override
  String? get miningWalletAddress => _miningWalletAddress;

  @override
  SharedMiningInfo get miningInfo => _miningInfo;

  @override
  Stream<MiningStatus> get statusStream => _statusStreamController.stream;

  @override
  void onWalletChanged(String? newAddress) {
    // Handle wallet change - mining might need to update its state
    if (_miningWalletAddress != newAddress) {
      _miningWalletAddress = newAddress;
      
      // If mining was active, we might need to update
      if (isMining && newAddress != null) {
        _updateMiningInfo();
      }
    }
  }

  // ============ Internal Update Methods ============

  /// Update mining status
  void updateStatus(MiningStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusStreamController.add(newStatus);

      // Emit cross-feature event
      eventManager.emitMiningStatusChanged(
        status: newStatus.name,
        walletAddress: _miningWalletAddress,
      );
    }
  }

  /// Update mining info
  void updateMiningInfo({
    MiningStatus? status,
    String? currentReward,
    String? totalReward,
    DateTime? startTime,
    String? walletAddress,
  }) {
    _miningInfo = SharedMiningInfo(
      status: status ?? _miningInfo.status,
      currentReward: currentReward ?? _miningInfo.currentReward,
      totalReward: totalReward ?? _miningInfo.totalReward,
      startTime: startTime ?? _miningInfo.startTime,
      walletAddress: walletAddress ?? _miningInfo.walletAddress,
    );
  }

  void _updateMiningInfo() {
    updateMiningInfo(walletAddress: _miningWalletAddress);
  }

  /// Get wallet service (through shared interface, not direct dependency)
  IWalletService? get _walletService => ServiceLocatorSetup.walletService;

  /// Get current wallet balance for mining rewards
  Future<String?> getCurrentRewardBalance() async {
    final walletService = _walletService;
    if (walletService == null || _miningWalletAddress == null) {
      return null;
    }

    final balanceInfo = await walletService.getBalance(
      _miningWalletAddress!,
      'N', // Mining reward coin
    );
    return balanceInfo?.balance.toString();
  }

  /// Dispose resources
  void dispose() {
    _walletEventSubscription?.cancel();
    _statusStreamController.close();
  }
}

