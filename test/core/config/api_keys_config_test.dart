import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/api_keys_config.dart';

void main() {
  test('API key validation is safe when client keys are proxy managed', () {
    expect(ApiKeysConfig.validateInDebug, returnsNormally);
  });

  test('API key initialization delegates to safe debug validation', () {
    expect(initApiKeys, returnsNormally);
  });
}
