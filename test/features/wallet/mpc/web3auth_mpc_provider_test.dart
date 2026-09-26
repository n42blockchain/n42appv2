import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';
import 'package:n42_wallet/features/wallet/mpc/web3auth_mpc_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('web3auth_flutter');
  // Public secp256k1 test vector, never a funded wallet or a login credential.
  final key = '1'.padLeft(64, '0');
  const address = '7E5F4552091A69125d5DfCb7b8C2659029395Bdf';
  late Web3AuthMpcProvider provider;
  late List<MethodCall> calls;
  var sessionKey = '';
  var loginKey = '';

  setUp(() {
    calls = [];
    sessionKey = '';
    loginKey = key;
    provider = Web3AuthMpcProvider(
      clientId: 'test-client',
      redirectUrl: Uri.parse('n42://auth'),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'init':
            case 'initialize':
            case 'logout':
              return null;
            case 'getPrivateKey':
              return sessionKey;
            case 'connectTo':
              return jsonEncode({
                'privKey': loginKey,
                'userInfo': {
                  'userId': 'user-123',
                  'email': 'user@example.test',
                  'name': 'User',
                  'authConnection': 'google',
                },
              });
            default:
              throw MissingPluginException(call.method);
          }
        });
  });

  tearDown(() {
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('restores an existing session before reading its key', () async {
    sessionKey = key;
    await provider.initialize();
    expect(provider.currentAddress, address);
    expect(calls.map((call) => call.method), [
      'init',
      'initialize',
      'getPrivateKey',
    ]);
    final options = jsonDecode(calls.first.arguments as String) as Map;
    expect(options['network'], 'sapphire_mainnet');
    expect(options['redirectUrl'], 'n42://auth');
    await provider.initialize();
    expect(calls.length, 3);
  });

  for (final entry in {
    MpcLoginType.google: 'google',
    MpcLoginType.apple: 'apple',
    MpcLoginType.email: 'email_passwordless',
    MpcLoginType.phone: 'sms_passwordless',
    MpcLoginType.twitter: 'twitter',
    MpcLoginType.discord: 'discord',
    MpcLoginType.github: 'github',
  }.entries) {
    test('maps ${entry.key.name} login and preserves key identity', () async {
      final result = await provider.login(entry.key, hint: 'user@example.test');
      expect(result.address, address);
      expect(result.userId, 'user-123');
      expect(
        result.publicKey,
        '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483'
        'ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
      );
      final login = calls.singleWhere((call) => call.method == 'connectTo');
      final params = jsonDecode(login.arguments as String) as Map;
      expect(params['authConnection'], entry.value);
      expect(params['extraLoginOptions']['login_hint'], 'user@example.test');
      expect(await provider.getRecoveryFactors(), contains('google: User'));
    });
  }

  test('empty login key fails without exposing a logged in wallet', () async {
    loginKey = '';
    await expectLater(
      provider.login(MpcLoginType.google),
      throwsA(isA<MpcLoginException>()),
    );
    expect(provider.isLoggedIn, isFalse);
  });

  test('logout clears signing access', () async {
    await provider.login(MpcLoginType.google);
    final signature = await provider.signMessage(Uint8List.fromList([1, 2, 3]));
    expect(signature.signature.length, 65);
    await provider.logout();
    expect(provider.currentAddress, isNull);
    await expectLater(
      provider.signMessage(Uint8List(0)),
      throwsA(isA<MpcNotLoggedInException>()),
    );
  });
}
