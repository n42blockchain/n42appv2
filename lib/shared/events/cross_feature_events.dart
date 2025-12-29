// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/shared/domain/entities/wallet_info.dart';

/// Cross-Feature Event Types
///
/// Events that need to be communicated across feature boundaries.
/// Features emit and listen for these events through the EventBus
/// without direct dependencies.

// ============ Base Event ============

/// Base class for all cross-feature events
abstract class CrossFeatureEvent {
  final DateTime timestamp;
  
  CrossFeatureEvent() : timestamp = DateTime.now();
}

// ============ Wallet Events ============

/// Emitted when a wallet is selected/changed
class WalletSelectedEvent extends CrossFeatureEvent {
  final SharedWalletInfo wallet;
  
  WalletSelectedEvent(this.wallet);
}

/// Emitted when a wallet is created
class WalletCreatedEvent extends CrossFeatureEvent {
  final SharedWalletInfo wallet;
  
  WalletCreatedEvent(this.wallet);
}

/// Emitted when a wallet is deleted
class WalletDeletedEvent extends CrossFeatureEvent {
  final String walletAddress;
  
  WalletDeletedEvent(this.walletAddress);
}

/// Emitted when wallet balance is updated
class WalletBalanceUpdatedEvent extends CrossFeatureEvent {
  final String walletAddress;
  final String coinSymbol;
  final String newBalance;
  
  WalletBalanceUpdatedEvent({
    required this.walletAddress,
    required this.coinSymbol,
    required this.newBalance,
  });
}

/// Emitted when a transaction is completed
class TransactionCompletedEvent extends CrossFeatureEvent {
  final String walletAddress;
  final String txHash;
  final String amount;
  final String coinSymbol;
  final bool isSuccess;
  
  TransactionCompletedEvent({
    required this.walletAddress,
    required this.txHash,
    required this.amount,
    required this.coinSymbol,
    required this.isSuccess,
  });
}

// ============ Mining Events ============

/// Emitted when mining status changes
class MiningStatusChangedEvent extends CrossFeatureEvent {
  final String status; // 'started', 'stopped', 'paused'
  final String? walletAddress;
  
  MiningStatusChangedEvent({
    required this.status,
    this.walletAddress,
  });
}

/// Emitted when mining reward is received
class MiningRewardReceivedEvent extends CrossFeatureEvent {
  final String reward;
  final String walletAddress;
  
  MiningRewardReceivedEvent({
    required this.reward,
    required this.walletAddress,
  });
}

/// Emitted when mining plan is changed
class MiningPlanChangedEvent extends CrossFeatureEvent {
  final String planId;
  final String planName;
  
  MiningPlanChangedEvent({
    required this.planId,
    required this.planName,
  });
}

// ============ Chat Events ============

/// Emitted when unread message count changes
class UnreadMessageCountChangedEvent extends CrossFeatureEvent {
  final int count;
  
  UnreadMessageCountChangedEvent(this.count);
}

/// Emitted when new message is received
class NewMessageReceivedEvent extends CrossFeatureEvent {
  final String conversationId;
  final String messageId;
  final String senderUid;
  
  NewMessageReceivedEvent({
    required this.conversationId,
    required this.messageId,
    required this.senderUid,
  });
}

// ============ Auth Events ============

/// Emitted when user logs in
class UserLoggedInEvent extends CrossFeatureEvent {
  final String userUuid;
  final String? email;
  
  UserLoggedInEvent({
    required this.userUuid,
    this.email,
  });
}

/// Emitted when user logs out
class UserLoggedOutEvent extends CrossFeatureEvent {}

// ============ App Lifecycle Events ============

/// Emitted when app goes to background
class AppBackgroundedEvent extends CrossFeatureEvent {}

/// Emitted when app comes to foreground
class AppForegroundedEvent extends CrossFeatureEvent {}

/// Emitted when screen is locked
class ScreenLockedEvent extends CrossFeatureEvent {}

/// Emitted when screen is unlocked
class ScreenUnlockedEvent extends CrossFeatureEvent {}

