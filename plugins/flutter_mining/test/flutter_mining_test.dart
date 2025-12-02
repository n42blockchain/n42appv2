import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mining/flutter_mining.dart';
import 'package:flutter_mining/flutter_mining_platform_interface.dart';
import 'package:flutter_mining/flutter_mining_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterMiningPlatform
    with MockPlatformInterfaceMixin
    implements FlutterMiningPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> emit(String params) {
    throw UnimplementedError();
  }

  @override
  Future<String?> cryptographyMessage(String message) {
    throw UnimplementedError();
  }

  @override
  Future<String?> dCodeMessage(String message) {
    throw UnimplementedError();
  }
  @override
  Future<String?> runClient(Map<String,String> params) {
    throw UnimplementedError();
  }
  @override
  Future<String?> createExitUnsignedTx(Map<String,String> params) {
    throw UnimplementedError();
  }
  @override
  Future<String?> createDepositUnsignedTx(Map<String,String> params) {
    throw UnimplementedError();
  }
  Future<String?> createGetExitFeeUnsignedTx() {
    throw UnimplementedError();
  }
  Future<String?> generateBls12381Keypair() {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterMiningPlatform initialPlatform = FlutterMiningPlatform.instance;

  test('$MethodChannelFlutterMining is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterMining>());
  });

  test('getPlatformVersion', () async {
    FlutterMining flutterMiningPlugin = FlutterMining();
    MockFlutterMiningPlatform fakePlatform = MockFlutterMiningPlatform();
    FlutterMiningPlatform.instance = fakePlatform;

    expect(await flutterMiningPlugin.getPlatformVersion(), '42');
  });
}
