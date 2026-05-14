import 'package:flutter/services.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Dedicated MethodChannel wrapper for mining operations.
///
/// Separates BLS key generation, mining client management, and
/// iOS LiveActivity from the core wallet channel.
///
/// Currently uses the same 'trustdart' channel for backward compatibility
/// with native code. Phase 3-4 native refactoring will move these to
/// a dedicated 'trustdart_mining' channel.
class MiningChannel {
  final MethodChannel _channel = const MethodChannel('trustdart');

  // ---------------------------------------------------------------------------
  // BLS Key Management
  // ---------------------------------------------------------------------------

  Future<String?> generateBls12381Keypair() =>
      _invoke('MiningGenerateBls12381Keypair');

  // ---------------------------------------------------------------------------
  // Deposit / Exit Transactions
  // ---------------------------------------------------------------------------

  Future<String?> createDepositUnsignedTx(Map<String, dynamic> params) =>
      _invoke('MiningCreateDepositUnsignedTx', params);

  Future<String?> createGetExitFeeUnsignedTx() =>
      _invoke('MiningCreateGetExitFeeUnsignedTx');

  Future<String?> createExitUnsignedTx(Map<String, dynamic> params) =>
      _invoke('MiningCreateExitUnsignedTx', params);

  // ---------------------------------------------------------------------------
  // Mining Client Lifecycle
  // ---------------------------------------------------------------------------

  Future<String?> runClient(Map<String, dynamic> params) =>
      _invoke('MiningRunClient', params);

  Future<String?> stopClient() =>
      _invoke('MiningStopClient');

  // ---------------------------------------------------------------------------
  // iOS LiveActivity (mining background indicator)
  // ---------------------------------------------------------------------------

  Future<MessageModel> liveActivityStart() async {
    try {
      final int type = await globalProviderContainer
              .read(spUtilProvider)
              .getBackgroundMiningMusic() ??
          0;
      final String rData = await _channel.invokeMethod(
        'LiveActivityStart',
        <String, dynamic>{'type': type},
      );
      final MessageModel rmm = MessageModel();
      if (rData != 'true') rmm.data = rData;
      return rmm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> liveActivityUpdate(int value) =>
      _invokeLiveActivity('LiveActivityUpdate', value);

  Future<MessageModel> liveActivityEnd(int value) =>
      _invokeLiveActivity('LiveActivityEnd', value);

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<String?> _invoke(String method, [Map<String, dynamic>? params]) async {
    try {
      return await _channel.invokeMethod(method, params);
    } catch (e) {
      AppLogger.w('MiningChannel', '$method: $e');
      return null;
    }
  }

  Future<MessageModel> _invokeLiveActivity(String method, int value) async {
    try {
      final String rData = await _channel.invokeMethod(
        method,
        <String, dynamic>{'value': value},
      );
      final MessageModel rmm = MessageModel();
      if (rData != 'true') rmm.data = rData;
      return rmm;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
