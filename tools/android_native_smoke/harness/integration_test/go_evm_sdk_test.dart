import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.n42.android_native_smoke/vectors');

  testWidgets('Go V1 SDK offline Emit protocol with synthetic keys', (
    tester,
  ) async {
    const requireInvalidErrors = bool.fromEnvironment(
      'N42_GO_REQUIRE_INVALID_ERRORS',
      defaultValue: true,
    );
    final vectors = await channel.invokeMapMethod<String, String>(
      'goEvmVectors',
    );
    expect(vectors, isNotNull);
    final results = vectors!;
    print('GO_EVM_VECTOR_JSON:${jsonEncode(results)}');
    for (final name in <String>[
      'setting',
      'state',
      'stop',
      'repeatStop',
      'partialSetting',
      'lowPubkey',
      'lowSignature',
      'highPubkey',
      'highSignature',
      'invalidJson',
      'invalidKeyLength',
      'invalidKeyHex',
      'invalidMessageHex',
    ]) {
      expect(results.containsKey(name), isTrue, reason: name);
      expect(results[name], isNotEmpty, reason: name);
      final response = jsonDecode(results[name]!) as Map<String, dynamic>;
      expect(response.keys, containsAll(<String>['code', 'message', 'data']));
      final success = !name.startsWith('invalid');
      if (success || requireInvalidErrors) {
        expect(response['code'] == 0, success, reason: name);
      }
      if (name.endsWith('Pubkey')) {
        expect((response['data'] as String).length, 96, reason: name);
      }
      if (name.endsWith('Signature')) {
        expect((response['data'] as String).length, 192, reason: name);
      }
    }
    expect(jsonDecode(results['state']!)['data'], 'stopped');
  });
}
