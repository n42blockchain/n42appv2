import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_mining_platform_interface.dart';

/// An implementation of [FlutterMiningPlatform] that uses method channels.
class MethodChannelFlutterMining extends FlutterMiningPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_mining');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> emit(String params) async{
    final value = await methodChannel.invokeMethod<String>('emit',params);
    return value;
  }


  @override
  Future<String?> cryptographyMessage(String message) async{
    final value = await methodChannel.invokeMethod<String>('emit',message);
    return value;
  }

  @override
  Future<String?> dCodeMessage(String message) async{
    final value = await methodChannel.invokeMethod<String>('emit',message);
    return value;
  }
  @override
  Future<String?> generateBls12381Keypair() async{
    final value = await methodChannel.invokeMethod<String>('generateBls12381Keypair');
    return value;
  }
  @override
  Future<String?> createDepositUnsignedTx(Map<String,String> params) async{
    final value = await methodChannel.invokeMethod<String>('createDepositUnsignedTx',params);
    return value;
  }
  @override
  Future<String?> createGetExitFeeUnsignedTx() async{
    final value = await methodChannel.invokeMethod<String>('createGetExitFeeUnsignedTx');
    return value;
  }
  @override
  Future<String?> createExitUnsignedTx(Map<String,String> params) async{
    final value = await methodChannel.invokeMethod<String>('createExitUnsignedTx',params);
    return value;
  }
  @override
  Future<String?> runClient(Map<String,String> params) async{
    final value = await methodChannel.invokeMethod<String>('runClient',params);
    return value;
  }
}
