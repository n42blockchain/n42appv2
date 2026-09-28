import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.n42.android_native_smoke/vectors');

  testWidgets('MobileSdk loads in a strict 16 KB process', (tester) async {
    final loaded = await channel.invokeMethod<bool>('mobileSdkLoad');
    expect(loaded, isTrue);
  });

  testWidgets('MobileSdk initializes Android TLS verifier twice', (
    tester,
  ) async {
    final initialized = await channel.invokeMethod<bool>('mobileSdkTlsInit');
    expect(initialized, isTrue);
  });

  testWidgets('MobileSdk produces offline transaction vectors', (tester) async {
    final raw = await channel.invokeMapMethod<String, String>(
      'mobileSdkVectors',
    );
    expect(raw, isNotNull);
    // Frozen from the supplier's published v0.2.2 AAR with these dummy inputs.
    expect(
      raw!['depositSha256'],
      '8e1ea787eadbff10d62cc99456636dc61b3940e601c12fcd9d8743b14c951a2e',
    );
    expect(
      raw['exitSha256'],
      '3bfe7dc9710dbb2909a94c0a13a8f4b075ca69cb24fce378b0d8c6e473c143e5',
    );
    expect(
      raw['feeCallSha256'],
      '3f6579def870d65ab2b87cfba1708875dc6b0e98f3163c1e4e769f18ff027fa8',
    );
    final deposit = jsonDecode(raw['deposit']!) as Map<String, dynamic>;
    final exit = jsonDecode(raw['exit']!) as Map<String, dynamic>;
    final feeCall = jsonDecode(raw['feeCall']!) as Map<String, dynamic>;
    expect(
      (deposit['to'] as String).toLowerCase(),
      '0x5fbdb2315678afecb367f032d93f642f64180aa3',
    );
    expect(deposit['value'], '0x1bc16d674ec800000');
    expect(deposit['gas'], '0x493e0');
    final depositData = (deposit['data'] as String).substring(10);
    final pubkeyOffset = int.parse(depositData.substring(0, 64), radix: 16);
    final pubkeyStart = pubkeyOffset * 2;
    expect(
      int.parse(
        depositData.substring(pubkeyStart, pubkeyStart + 64),
        radix: 16,
      ),
      48,
    );
    expect(
      depositData.substring(pubkeyStart + 64, pubkeyStart + 160),
      '8a2470d8ccb2e43b3b5295cfee71508f8808e166e5f152d5af9fe022d95e300dc7c5814f2c9eb71e2da8412beb61c53a',
    );
    expect(
      (exit['to'] as String).toLowerCase(),
      '0x00000961ef480eb55e80d19ad83579a64c007002',
    );
    expect(
      exit['data'],
      '0x8a2470d8ccb2e43b3b5295cfee71508f8808e166e5f152d5af9fe022d95e300dc7c5814f2c9eb71e2da8412beb61c53a0000000000000000',
    );
    expect(exit['value'], '0x1');
    expect(
      (feeCall['to'] as String).toLowerCase(),
      '0x00000961ef480eb55e80d19ad83579a64c007002',
    );
    expect(feeCall['data'], '0x');
  });
}
