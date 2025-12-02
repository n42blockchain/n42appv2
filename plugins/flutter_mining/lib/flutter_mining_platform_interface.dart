import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_mining_method_channel.dart';

abstract class FlutterMiningPlatform extends PlatformInterface {
  /// Constructs a FlutterMiningPlatform.
  FlutterMiningPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMiningPlatform _instance = MethodChannelFlutterMining();

  /// The default instance of [FlutterMiningPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMining].
  static FlutterMiningPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMiningPlatform] when
  /// they register themselves.
  static set instance(FlutterMiningPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // emit
  Future<String?> emit(String params) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }


  /// 解密
  Future<String?> cryptographyMessage(String message) async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 解密
  Future<String?> dCodeMessage(String message) async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> generateBls12381Keypair() async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> createDepositUnsignedTx(Map<String,String> params) async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> createGetExitFeeUnsignedTx() async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> createExitUnsignedTx(Map<String,String> params) async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> runClient(Map<String,String> params) async{
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}