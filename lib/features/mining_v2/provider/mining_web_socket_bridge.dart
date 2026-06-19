import 'dart:async';
import 'package:flutter/services.dart';

class NativeWebSocketBridge {
  final MethodChannel _methodChannel = const MethodChannel('trustdart_mining');

  final EventChannel _eventChannel = const EventChannel('trustdart_ws_events');

  Stream<String>? _stream;

  Stream<String> get messages {
    _stream ??= _eventChannel.receiveBroadcastStream().map((e) => e.toString());
    return _stream!;
  }

  Future<void> connect({
    required String wsUrl,
    required String validatorPubkey,
    required String validatorPrivateKey,
  }) {
    return _methodChannel.invokeMethod('connectWebSocket', {
      'wsUrl': wsUrl,
      'validatorPubkey': validatorPubkey,
      'validatorPrivateKey': validatorPrivateKey,
    });
  }

  Future<void> disconnect() {
    return _methodChannel.invokeMethod('disconnectWebSocket');
  }
}
