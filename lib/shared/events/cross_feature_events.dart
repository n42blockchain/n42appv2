// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

/// Base class for all cross-feature events.
///
/// Events communicated across feature boundaries via EventBus
/// without direct dependencies.
abstract class CrossFeatureEvent {
  final DateTime timestamp;
  
  CrossFeatureEvent() : timestamp = DateTime.now();
}

// — Wallet Events —

class WalletSelectedEvent extends CrossFeatureEvent {
  final SharedWalletInfo wallet;
  
  WalletSelectedEvent(this.wallet);
}

class WalletCreatedEvent extends CrossFeatureEvent {
  final SharedWalletInfo wallet;
  
  WalletCreatedEvent(this.wallet);
}

class WalletDeletedEvent extends CrossFeatureEvent {
  final String walletAddress;
  
  WalletDeletedEvent(this.walletAddress);
}

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

// — Mining Events —

/// [status] is one of: 'started', 'stopped', 'paused'.
class MiningStatusChangedEvent extends CrossFeatureEvent {
  final String status;
  final String? walletAddress;
  
  MiningStatusChangedEvent({
    required this.status,
    this.walletAddress,
  });
}

class MiningRewardReceivedEvent extends CrossFeatureEvent {
  final String reward;
  final String walletAddress;
  
  MiningRewardReceivedEvent({
    required this.reward,
    required this.walletAddress,
  });
}

class MiningPlanChangedEvent extends CrossFeatureEvent {
  final String planId;
  final String planName;
  
  MiningPlanChangedEvent({
    required this.planId,
    required this.planName,
  });
}

// — Chat Events —

class UnreadMessageCountChangedEvent extends CrossFeatureEvent {
  final int count;
  
  UnreadMessageCountChangedEvent(this.count);
}

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

// — Auth Events —

class UserLoggedInEvent extends CrossFeatureEvent {
  final String userUuid;
  final String? email;
  
  UserLoggedInEvent({
    required this.userUuid,
    this.email,
  });
}

class UserLoggedOutEvent extends CrossFeatureEvent {}

// — App Lifecycle Events —

class AppBackgroundedEvent extends CrossFeatureEvent {}

class AppForegroundedEvent extends CrossFeatureEvent {}

