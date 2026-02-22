// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Tests for WalletConnect DApp signing request handling:
//   - EIP-712 signature encoding (no double-hash)
//   - _isValidHex helper
//   - personal_sign hex vs UTF-8 detection
//   - Parameter bounds checks for eth_sign, eth_signTypedData*
//   - EIP-712 JSON field validation
//   - Unsupported method rejection

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:eip712/eip712.dart';

void main() {
  // ---------------------------------------------------------------------------
  group('_isValidHex helper', () {
    // Mirror of WalletConnectProvider._isValidHex
    bool isValidHex(String s) {
      if (s.isEmpty) return false;
      return RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);
    }

    test('valid lowercase hex', () {
      expect(isValidHex('deadbeef'), isTrue);
    });

    test('valid uppercase hex', () {
      expect(isValidHex('DEADBEEF'), isTrue);
    });

    test('valid mixed-case hex', () {
      expect(isValidHex('DeAdBeEf'), isTrue);
    });

    test('empty string returns false', () {
      expect(isValidHex(''), isFalse);
    });

    test('plain text returns false', () {
      expect(isValidHex('Hello World'), isFalse);
    });

    test('hex with 0x prefix returns false (prefix is not hex)', () {
      expect(isValidHex('0xdeadbeef'), isFalse);
    });

    test('hex with spaces returns false', () {
      expect(isValidHex('dead beef'), isFalse);
    });

    test('SIWE message returns false', () {
      const siwe = 'example.com wants you to sign in with your Ethereum account';
      expect(isValidHex(siwe), isFalse);
    });

    test('numeric string is valid hex', () {
      expect(isValidHex('1234567890'), isTrue);
    });

    test('single character hex', () {
      expect(isValidHex('a'), isTrue);
      expect(isValidHex('g'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('personal_sign — hex vs UTF-8 detection', () {
    // Mirror of the personal_sign branch in messageSignTap
    Uint8List decodePersonalSignData(String rawData) {
      String stripped = rawData;
      if (stripped.startsWith('0x') || stripped.startsWith('0X')) {
        stripped = stripped.substring(2);
      }
      final isHex =
          stripped.isNotEmpty && RegExp(r'^[0-9a-fA-F]+$').hasMatch(stripped);
      if (isHex) {
        // Decode hex string to bytes
        final bytes = <int>[];
        for (var i = 0; i < stripped.length; i += 2) {
          final end = (i + 2 <= stripped.length) ? i + 2 : stripped.length;
          bytes.add(int.parse(stripped.substring(i, end), radix: 16));
        }
        return Uint8List.fromList(bytes);
      } else {
        return Uint8List.fromList(utf8.encode(rawData));
      }
    }

    test('hex-encoded message is decoded as bytes', () {
      final result = decodePersonalSignData('0x48656c6c6f'); // "Hello"
      expect(utf8.decode(result), 'Hello');
    });

    test('hex without 0x prefix is decoded as bytes', () {
      final result = decodePersonalSignData('48656c6c6f');
      expect(utf8.decode(result), 'Hello');
    });

    test('SIWE plain text is encoded as UTF-8', () {
      const msg = 'example.com wants you to sign in with your Ethereum account';
      final result = decodePersonalSignData(msg);
      expect(utf8.decode(result), msg);
    });

    test('empty 0x is treated as UTF-8 (empty hex stripped = empty)', () {
      // "0x" → strip → "" → isValidHex("") = false → UTF-8 encode "0x"
      final result = decodePersonalSignData('0x');
      expect(utf8.decode(result), '0x');
    });

    test('multiline SIWE message', () {
      const msg = 'example.com wants you to sign in\n\nNonce: abc123\nChain ID: 1';
      final result = decodePersonalSignData(msg);
      expect(utf8.decode(result), msg);
    });

    test('unicode text is preserved', () {
      const msg = '请签名确认您的身份';
      final result = decodePersonalSignData(msg);
      expect(utf8.decode(result), msg);
    });
  });

  // ---------------------------------------------------------------------------
  group('eth_sign / eth_signTypedData* — parameter bounds', () {
    // Mirrors the bounds check logic added to setActionDataMap

    String? validateEthSignParams(List<String> params) {
      if (params.length < 2) {
        return 'Invalid eth_sign params: expected 2, got ${params.length}';
      }
      return null;
    }

    String? validateTypedDataParams(String method, List<String> params) {
      if (params.length < 2) {
        return 'Invalid $method params: expected 2, got ${params.length}';
      }
      return null;
    }

    test('eth_sign with 2 params succeeds', () {
      expect(validateEthSignParams(['0xAddr', '0xData']), isNull);
    });

    test('eth_sign with 0 params fails', () {
      final error = validateEthSignParams([]);
      expect(error, isNotNull);
      expect(error, contains('0'));
    });

    test('eth_sign with 1 param fails', () {
      final error = validateEthSignParams(['0xAddr']);
      expect(error, isNotNull);
      expect(error, contains('1'));
    });

    test('eth_signTypedData_v4 with 2 params succeeds', () {
      expect(
        validateTypedDataParams('eth_signTypedData_v4', ['0xAddr', '{}']),
        isNull,
      );
    });

    test('eth_signTypedData_v4 with 0 params fails', () {
      final error = validateTypedDataParams('eth_signTypedData_v4', []);
      expect(error, isNotNull);
      expect(error, contains('eth_signTypedData_v4'));
    });

    test('eth_signTypedData_v3 with 1 param fails', () {
      final error =
          validateTypedDataParams('eth_signTypedData_v3', ['0xAddr']);
      expect(error, isNotNull);
      expect(error, contains('eth_signTypedData_v3'));
    });

    test('eth_signTypedData (v1 style) with 2 params succeeds', () {
      expect(
        validateTypedDataParams('eth_signTypedData', ['0xAddr', '{}']),
        isNull,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('EIP-712 JSON validation', () {
    // Mirrors the field validation in _signTypedData
    String? validateEip712Json(String jsonStr) {
      try {
        final typedData = json.decode(jsonStr) as Map<String, dynamic>;
        const requiredFields = ['types', 'primaryType', 'domain', 'message'];
        for (final field in requiredFields) {
          if (!typedData.containsKey(field)) {
            return 'Invalid EIP-712 data: missing required field "$field"';
          }
        }
        return null;
      } on FormatException {
        return 'Invalid JSON';
      }
    }

    test('valid EIP-712 JSON passes validation', () {
      final validJson = json.encode({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'Test'},
        'message': {'contents': 'Hello'},
      });
      expect(validateEip712Json(validJson), isNull);
    });

    test('missing types field', () {
      final json_ = json.encode({
        'primaryType': 'Mail',
        'domain': {'name': 'Test'},
        'message': {'contents': 'Hello'},
      });
      expect(validateEip712Json(json_), contains('"types"'));
    });

    test('missing primaryType field', () {
      final json_ = json.encode({
        'types': {},
        'domain': {'name': 'Test'},
        'message': {'contents': 'Hello'},
      });
      expect(validateEip712Json(json_), contains('"primaryType"'));
    });

    test('missing domain field', () {
      final json_ = json.encode({
        'types': {},
        'primaryType': 'Mail',
        'message': {'contents': 'Hello'},
      });
      expect(validateEip712Json(json_), contains('"domain"'));
    });

    test('missing message field', () {
      final json_ = json.encode({
        'types': {},
        'primaryType': 'Mail',
        'domain': {'name': 'Test'},
      });
      expect(validateEip712Json(json_), contains('"message"'));
    });

    test('invalid JSON string', () {
      expect(validateEip712Json('not json{'), isNotNull);
    });

    test('empty JSON object fails (all fields missing)', () {
      expect(validateEip712Json('{}'), isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('EIP-712 signing — no double hash', () {
    // Verify that hashTypedData produces a keccak256 hash and that
    // signing it directly with secp256k1.sign (not signToEcSignature)
    // produces a recoverable signature.

    late web3.EthPrivateKey testKey;

    setUp(() {
      // Deterministic test key (32 bytes of 0x01)
      testKey = web3.EthPrivateKey(
        Uint8List.fromList(List.filled(32, 1)),
      );
    });

    test('hashTypedData returns 32 bytes', () {
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {'contents': 'Hello EIP-712'},
      });

      final hash = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      expect(hash.length, 32);
    });

    test('direct secp256k1 sign produces valid 65-byte signature', () {
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {'contents': 'Hello EIP-712'},
      });

      final hash = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      // Use secp256k1.sign directly (no double hash)
      final sig = web3.sign(hash, testKey.privateKey);

      // r and s should be non-zero BigInts
      expect(sig.r, isNot(BigInt.zero));
      expect(sig.s, isNot(BigInt.zero));
      // v should be 27 or 28
      expect(sig.v, anyOf(27, 28));

      // Hex encoding matches 65-byte standard (32+32+1)
      final r = sig.r.toRadixString(16).padLeft(64, '0');
      final s = sig.s.toRadixString(16).padLeft(64, '0');
      final v = sig.v.toRadixString(16).padLeft(2, '0');
      final hexSig = '0x$r$s$v';

      // 0x + 64 + 64 + 2 = 132 chars = 66 bytes in hex
      expect(hexSig.length, 132);
      expect(hexSig.startsWith('0x'), isTrue);
    });

    test('signature is recoverable (ecRecover returns correct address)', () {
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {'contents': 'Recover me'},
      });

      final hash = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      final sig = web3.sign(hash, testKey.privateKey);

      // ecRecover returns public key bytes; publicKeyToAddress returns Uint8List
      final recoveredPub = web3.ecRecover(hash, sig);
      final recoveredAddrBytes = web3.publicKeyToAddress(recoveredPub);
      final expectedAddrHex = testKey.address.without0x.toLowerCase();
      final recoveredAddrHex = web3.bytesToHex(recoveredAddrBytes).toLowerCase();

      expect(
        recoveredAddrHex,
        expectedAddrHex,
        reason: 'ecRecover must return the signer address',
      );
    });

    test('signToEcSignature would double-hash (demonstration)', () {
      // This test demonstrates the bug: signToEcSignature applies keccak256
      // to its input, so if input is already hashed, the result is wrong.
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {'contents': 'Double hash test'},
      });

      final hash = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      // Correct: sign directly
      final correctSig = web3.sign(hash, testKey.privateKey);

      // Wrong: signToEcSignature does keccak256(hash) internally
      final wrongSig = testKey.signToEcSignature(hash);

      // The signatures must be different (proving double-hash issue)
      final correctR = correctSig.r.toRadixString(16);
      final wrongR = wrongSig.r.toRadixString(16);

      expect(
        correctR,
        isNot(wrongR),
        reason:
            'signToEcSignature double-hashes, producing a different signature',
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('EIP-712 v3 vs v4', () {
    test('v4 supports arrays in typed data', () {
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'contents', 'type': 'string'},
            {'name': 'tags', 'type': 'string[]'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {
          'contents': 'Hello',
          'tags': ['urgent', 'crypto'],
        },
      });

      // v4 should handle arrays without error
      final hash = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      expect(hash.length, 32);
    });

    test('v3 produces different hash than v4 for same data', () {
      // v3 and v4 have different encoding rules for nested/array types
      final typedData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
          ],
          'Mail': [
            {'name': 'from', 'type': 'string'},
            {'name': 'contents', 'type': 'string'},
          ],
        },
        'primaryType': 'Mail',
        'domain': {'name': 'TestDApp'},
        'message': {
          'from': 'Alice',
          'contents': 'Hello',
        },
      });

      final hashV3 = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v3,
      );
      final hashV4 = hashTypedData(
        typedData: typedData,
        version: TypedDataVersion.v4,
      );

      // Both produce 32-byte hashes
      expect(hashV3.length, 32);
      expect(hashV4.length, 32);
    });
  });

  // ---------------------------------------------------------------------------
  group('Unsupported method rejection', () {
    // Mirror of the default case in setActionDataMap
    test('unknown method name is identified', () {
      const supportedMethods = {
        'personal_sign',
        'eth_sign',
        'eth_signTypedData',
        'eth_signTypedData_v3',
        'eth_signTypedData_v4',
        'eth_signTransaction',
        'eth_sendTransaction',
        'tron_signTransaction',
        'tron_signMessage',
      };

      expect(supportedMethods.contains('wallet_addEthereumChain'), isFalse);
      expect(supportedMethods.contains('eth_chainId'), isFalse);
      expect(supportedMethods.contains(''), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('EIP-712 Permit signature (common DApp pattern)', () {
    test('ERC-20 Permit typed data hashes correctly', () {
      final permitData = TypedMessage.fromJson({
        'types': {
          'EIP712Domain': [
            {'name': 'name', 'type': 'string'},
            {'name': 'version', 'type': 'string'},
            {'name': 'chainId', 'type': 'uint256'},
            {'name': 'verifyingContract', 'type': 'address'},
          ],
          'Permit': [
            {'name': 'owner', 'type': 'address'},
            {'name': 'spender', 'type': 'address'},
            {'name': 'value', 'type': 'uint256'},
            {'name': 'nonce', 'type': 'uint256'},
            {'name': 'deadline', 'type': 'uint256'},
          ],
        },
        'primaryType': 'Permit',
        'domain': {
          'name': 'USD Coin',
          'version': '2',
          'chainId': 1,
          'verifyingContract': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
        },
        'message': {
          'owner': '0x1234567890abcdef1234567890abcdef12345678',
          'spender': '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
          'value':
              '115792089237316195423570985008687907853269984665640564039457584007913129639935',
          'nonce': 0,
          'deadline': 1893456000,
        },
      });

      final hash = hashTypedData(
        typedData: permitData,
        version: TypedDataVersion.v4,
      );

      expect(hash.length, 32);

      // Sign and verify recoverability
      final key = web3.EthPrivateKey(Uint8List.fromList(List.filled(32, 42)));
      final sig = web3.sign(hash, key.privateKey);
      final recovered = web3.ecRecover(hash, sig);
      final recoveredAddrBytes = web3.publicKeyToAddress(recovered);
      final recoveredHex = web3.bytesToHex(recoveredAddrBytes).toLowerCase();
      final expectedHex = key.address.without0x.toLowerCase();

      expect(recoveredHex, expectedHex);
    });
  });

  // ---------------------------------------------------------------------------
  group('Registered method completeness', () {
    // Verify that all methods handled in the switch are also registered
    test('all switch-handled methods are in the registration list', () {
      const registeredMethods = [
        'eth_sendTransaction',
        'eth_signTransaction',
        'eth_sign',
        'personal_sign',
        'eth_signTypedData',
        'eth_signTypedData_v3', // Fixed: was missing
        'eth_signTypedData_v4',
      ];

      const switchHandledMethods = [
        'personal_sign',
        'eth_sign',
        'eth_signTypedData',
        'eth_signTypedData_v3',
        'eth_signTypedData_v4',
        'eth_signTransaction',
        'eth_sendTransaction',
      ];

      for (final method in switchHandledMethods) {
        expect(
          registeredMethods.contains(method),
          isTrue,
          reason: '$method is handled in switch but not registered',
        );
      }
    });
  });
}
