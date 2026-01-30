// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:event_bus/event_bus.dart';

/// Global Event Bus instance
///
/// Used for decoupled inter-component communication.
/// Prefer using this for cross-feature events to avoid direct dependencies.
final EventBus eventBus = EventBus();

/// Generic Event for cross-feature communication
///
/// This event type enables loose coupling between features.
/// Each feature can emit and listen for events without direct dependencies.
class EventPublic {
  /// The type of event
  final EventPublicType type;

  /// Optional integer value
  final int? intValue;

  /// Optional string value
  final String? stringValue;

  /// Optional additional parameter
  final Object? param;

  const EventPublic(
    this.type, {
    this.intValue,
    this.stringValue,
    this.param,
  });

  @override
  String toString() {
    return 'EventPublic(type: $type, intValue: $intValue, stringValue: $stringValue)';
  }
}

/// Event Types for inter-feature communication
///
/// Organized by feature domain to maintain clarity about event ownership.
enum EventPublicType {
  // === General Events ===
  /// Close pages listening to this event
  finishPage,
  /// Refresh page data
  refreshData,

  // === Authentication Events ===
  /// Token expired, user needs to re-login
  tokenExpired,

  // === Chat Feature Events ===
  /// New chat message received
  chatMessage,
  /// Chat message content updated
  chatMessageRefresh,
  /// Single message deleted
  deleteChatItem,
  /// Message reply action
  chatItemReply,
  /// Conversation list updated
  updateChatConversationList,
  /// Group info updated
  updateGroupInfo,

  // === Mining Feature Events ===
  /// Mining data needs refresh
  refreshMiningData,
  /// Mining plan page pop
  selectMiningplansPop,
  /// Full node mining fee paid
  miningFullNode,

  // === Wallet Feature Events ===
  /// Wallet selection changed
  selectWallet,
  /// Mining wallet selection changed
  selectMiningWallet,
  /// Transfer completed successfully
  transferOk,
  /// WalletConnect event
  walletConnect,
  /// Backup reminder
  backup,

  // === Browser Feature Events ===
  /// Browser URL blocked
  blockUri,
}

/// Typed event for Feature-specific communication
///
/// Use this base class to create feature-specific events.
abstract class FeatureEvent {
  const FeatureEvent();
}

/// Wallet Feature Events
class WalletEvent extends FeatureEvent {
  final WalletEventType type;
  final dynamic data;

  const WalletEvent(this.type, {this.data});
}

enum WalletEventType {
  walletCreated,
  walletImported,
  walletDeleted,
  walletSelected,
  balanceUpdated,
  transactionCompleted,
}

/// Chat Feature Events
class ChatEvent extends FeatureEvent {
  final ChatEventType type;
  final dynamic data;

  const ChatEvent(this.type, {this.data});
}

enum ChatEventType {
  messageReceived,
  messageSent,
  conversationUpdated,
  contactAdded,
  groupCreated,
  groupUpdated,
}

/// Mining Feature Events
class MiningEvent extends FeatureEvent {
  final MiningEventType type;
  final dynamic data;

  const MiningEvent(this.type, {this.data});
}

enum MiningEventType {
  miningStarted,
  miningStopped,
  rewardReceived,
  planChanged,
  statusUpdated,
}

