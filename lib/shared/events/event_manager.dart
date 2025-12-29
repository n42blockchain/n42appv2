// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'cross_feature_events.dart';

/// Cross-Feature Event Manager
///
/// Provides a centralized way to emit and listen for cross-feature events.
/// This enables loose coupling between features.
class EventManager {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();

  final EventBus _eventBus = EventBus();
  final List<StreamSubscription> _subscriptions = [];

  /// Emit an event
  void emit<T extends CrossFeatureEvent>(T event) {
    if (kDebugMode) {
      debugPrint('[EventManager] Emitting: ${event.runtimeType}');
    }
    _eventBus.fire(event);
  }

  /// Listen for events of a specific type
  StreamSubscription<T> on<T extends CrossFeatureEvent>(
    void Function(T event) handler,
  ) {
    final subscription = _eventBus.on<T>().listen(handler);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Cancel a specific subscription
  void cancel(StreamSubscription subscription) {
    subscription.cancel();
    _subscriptions.remove(subscription);
  }

  /// Cancel all subscriptions
  void cancelAll() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Destroy the event manager
  void destroy() {
    cancelAll();
    _eventBus.destroy();
  }

  // ============ Convenience Methods ============

  /// Emit wallet selected event
  void emitWalletSelected(SharedWalletInfo wallet) {
    emit(WalletSelectedEvent(wallet));
  }

  /// Emit wallet balance updated event
  void emitWalletBalanceUpdated({
    required String walletAddress,
    required String coinSymbol,
    required String newBalance,
  }) {
    emit(WalletBalanceUpdatedEvent(
      walletAddress: walletAddress,
      coinSymbol: coinSymbol,
      newBalance: newBalance,
    ));
  }

  /// Emit transaction completed event
  void emitTransactionCompleted({
    required String walletAddress,
    required String txHash,
    required String amount,
    required String coinSymbol,
    required bool isSuccess,
  }) {
    emit(TransactionCompletedEvent(
      walletAddress: walletAddress,
      txHash: txHash,
      amount: amount,
      coinSymbol: coinSymbol,
      isSuccess: isSuccess,
    ));
  }

  /// Emit mining status changed event
  void emitMiningStatusChanged({
    required String status,
    String? walletAddress,
  }) {
    emit(MiningStatusChangedEvent(
      status: status,
      walletAddress: walletAddress,
    ));
  }

  /// Emit user logged in event
  void emitUserLoggedIn({
    required String userUuid,
    String? email,
  }) {
    emit(UserLoggedInEvent(
      userUuid: userUuid,
      email: email,
    ));
  }

  /// Emit user logged out event
  void emitUserLoggedOut() {
    emit(UserLoggedOutEvent());
  }

  /// Emit app backgrounded event
  void emitAppBackgrounded() {
    emit(AppBackgroundedEvent());
  }

  /// Emit app foregrounded event
  void emitAppForegrounded() {
    emit(AppForegroundedEvent());
  }
}

/// Import SharedWalletInfo for event types
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';

/// Global event manager instance
final eventManager = EventManager();

/// Mixin for features that need to listen for events
mixin EventListenerMixin {
  final List<StreamSubscription> _eventSubscriptions = [];

  /// Subscribe to an event type
  void subscribeToEvent<T extends CrossFeatureEvent>(
    void Function(T event) handler,
  ) {
    final sub = eventManager.on<T>(handler);
    _eventSubscriptions.add(sub);
  }

  /// Unsubscribe from all events
  void unsubscribeFromAllEvents() {
    for (final sub in _eventSubscriptions) {
      sub.cancel();
    }
    _eventSubscriptions.clear();
  }
}

