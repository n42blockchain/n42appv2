import 'dart:convert';
import 'dart:async';

import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
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
    MpcLoginType.facebook: 'facebook',
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

  test(
    'transaction signs the raw EVM preimage without a message prefix',
    () async {
      await provider.login(MpcLoginType.google);
      // EIP-155 unsigned transfer preimage; public deterministic fixture.
      final preimage = hexToBytes(
        'ec098504a817c800825208943535353535353535353535353535353535353535'
        '880de0b6b3a764000080018080',
      );
      final result = await provider.signTransaction(preimage);
      expect(result.signature.length, 65);
      final signature = MsgSignature(
        bytesToUnsignedInt(result.signature.sublist(0, 32)),
        bytesToUnsignedInt(result.signature.sublist(32, 64)),
        result.signature[64],
      );
      final publicKey = ecRecover(keccak256(preimage), signature);
      final recovered = bytesToHex(keccak256(publicKey).sublist(12));
      expect(recovered.toLowerCase(), address.toLowerCase());
      final personal = await provider.signMessage(preimage);
      expect(result.signature, isNot(orderedEquals(personal.signature)));
      expect(result.signatureHex, '0x${bytesToHex(result.signature)}');
      await provider.logout();
      await expectLater(
        provider.signTransaction(preimage),
        throwsA(isA<MpcNotLoggedInException>()),
      );
    },
  );

  for (final chainId in [1, 8453]) {
    test(
      'typed ERC20 transaction binds chain $chainId and current signer',
      () async {
        await provider.login(MpcLoginType.google);
        final transaction = Transaction(
          to: EthereumAddress.fromHex('0x${'35' * 20}'),
          nonce: 7,
          maxGas: 65000,
          maxFeePerGas: EtherAmount.inWei(BigInt.from(3000000000)),
          maxPriorityFeePerGas: EtherAmount.inWei(BigInt.from(1000000000)),
          value: EtherAmount.zero(),
          data: hexToBytes('a9059cbb${'00' * 12}${'12' * 20}${'00' * 31}01'),
        );
        final preimage = transaction.getUnsignedSerialized(chainId: chainId);
        expect(preimage.first, 2);
        String recover(Uint8List payload, MpcSignResult signed) {
          final signature = MsgSignature(
            bytesToUnsignedInt(signed.signature.sublist(0, 32)),
            bytesToUnsignedInt(signed.signature.sublist(32, 64)),
            signed.signature[64],
          );
          return bytesToHex(
            keccak256(ecRecover(keccak256(payload), signature)).sublist(12),
          );
        }

        final initial = await provider.signTransaction(preimage);
        expect(recover(preimage, initial).toLowerCase(), address.toLowerCase());
        final otherChain = transaction.getUnsignedSerialized(
          chainId: chainId + 1,
        );
        expect(
          recover(otherChain, initial).toLowerCase(),
          isNot(address.toLowerCase()),
        );
        loginKey = '2'.padLeft(64, '0');
        final replacement = await provider.login(MpcLoginType.facebook);
        final next = await provider.signTransaction(preimage);
        expect(
          recover(preimage, next).toLowerCase(),
          replacement.address.toLowerCase(),
        );
        expect(next.signature, isNot(orderedEquals(initial.signature)));
      },
    );
  }

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
  test('switching social accounts replaces the cached signer', () async {
    await provider.login(MpcLoginType.google);
    loginKey = '2'.padLeft(64, '0');
    final next = await provider.login(MpcLoginType.facebook);
    expect(next.address, isNot(address));
    expect(provider.currentAddress, next.address);
    await provider.logout();
    final restored = await provider.login(MpcLoginType.apple);
    expect(restored.address, next.address);
  });

  for (final invalid in [
    '',
    '0',
    '0'.padLeft(64, '0'),
    'f'.padLeft(64, 'f'),
    'malformed',
  ]) {
    test(
      'invalid replacement key clears the old signing session: ${invalid.length}',
      () async {
        await provider.login(MpcLoginType.google);
        loginKey = invalid;
        await expectLater(
          provider.login(MpcLoginType.apple),
          throwsA(isA<MpcLoginException>()),
        );
        expect(provider.currentAddress, isNull);
        await expectLater(
          provider.signMessage(Uint8List(0)),
          throwsA(isA<MpcNotLoggedInException>()),
        );
      },
    );
  }

  for (final close in ['logout', 'dispose']) {
    test('$close invalidates an in-flight social authorization', () async {
      await provider.initialize();
      final pending = Completer<String>();
      final started = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'connectTo') {
              started.complete();
              return pending.future;
            }
            return null;
          });
      final login = provider.login(MpcLoginType.facebook);
      final rejected = expectLater(login, throwsA(isA<MpcLoginException>()));
      await started.future;
      await expectLater(
        provider.login(MpcLoginType.google),
        throwsA(isA<MpcLoginException>()),
      );
      if (close == 'logout') {
        await provider.logout();
      } else {
        provider.dispose();
      }
      pending.complete(jsonEncode({'privKey': key}));
      await rejected;
      expect(provider.currentAddress, isNull);
    });
  }
}
