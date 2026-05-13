// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/event_bus.dart' as global_bus;
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'cross_feature_events.dart';

/// Centralized event manager for cross-feature communication.
///
/// Uses the global [eventBus] instance from `core/utils/event_bus.dart`
/// so that all event types (EventPublic and CrossFeatureEvent) flow
/// through a single bus. The types are distinct so listeners don't interfere.
class EventManager {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();
  final List<StreamSubscription> _subscriptions = [];

  void emit<T extends CrossFeatureEvent>(T event) {
    AppLogger.d('EventManager', 'emitting: ${event.runtimeType}');
    global_bus.eventBus.fire(event);
  }

  StreamSubscription<T> on<T extends CrossFeatureEvent>(
    void Function(T event) handler,
  ) {
    final subscription = global_bus.eventBus.on<T>().listen(handler);
    _subscriptions.add(subscription);
    return subscription;
  }

  void cancel(StreamSubscription subscription) {
    subscription.cancel();
    _subscriptions.remove(subscription);
  }

  void cancelAll() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void destroy() {
    cancelAll();
  }

  // — Convenience emitters —

  void emitWalletSelected(SharedWalletInfo wallet) {
    emit(WalletSelectedEvent(wallet));
  }

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

  void emitMiningStatusChanged({
    required String status,
    String? walletAddress,
  }) {
    emit(MiningStatusChangedEvent(
      status: status,
      walletAddress: walletAddress,
    ));
  }

  void emitUserLoggedIn({
    required String userUuid,
    String? email,
  }) {
    emit(UserLoggedInEvent(
      userUuid: userUuid,
      email: email,
    ));
  }

  void emitUserLoggedOut() {
    emit(UserLoggedOutEvent());
  }

  void emitAppBackgrounded() {
    emit(AppBackgroundedEvent());
  }

  void emitAppForegrounded() {
    emit(AppForegroundedEvent());
  }
}

final eventManager = EventManager();

/// Mixin providing event subscription lifecycle management.
mixin EventListenerMixin {
  final List<StreamSubscription> _eventSubscriptions = [];

  void subscribeToEvent<T extends CrossFeatureEvent>(
    void Function(T event) handler,
  ) {
    final sub = eventManager.on<T>(handler);
    _eventSubscriptions.add(sub);
  }

  void unsubscribeFromAllEvents() {
    for (final sub in _eventSubscriptions) {
      sub.cancel();
    }
    _eventSubscriptions.clear();
  }
}
