// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/features/wallet/aa/builder/signature_builder.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';

void main() {
  group('SignatureBuilder', () {
    // ── formatSignature ─────────────────────────────────────────────────────

    group('formatSignature', () {
      test('should accept 65-byte hex signature', () {
        // 32 bytes r + 32 bytes s + 1 byte v(27)
        final hexSig = 'a' * 128 + '1b'; // 65 bytes, v=27
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result.length, 65);
        expect(result[64], 27);
      });

      test('should accept 0x-prefixed signature', () {
        final hexSig = '0x${'a' * 128}1b';
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result.length, 65);
      });

      test('should adjust v < 27 to v + 27', () {
        // v = 0 should become 27
        final hexSig = '${'a' * 128}00';
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result[64], 27);
      });

      test('should adjust v = 1 to 28', () {
        final hexSig = '${'a' * 128}01';
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result[64], 28);
      });

      test('should keep v = 27 unchanged', () {
        final hexSig = '${'a' * 128}1b';
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result[64], 27);
      });

      test('should keep v = 28 unchanged', () {
        final hexSig = '${'a' * 128}1c';
        final result = SignatureBuilder.formatSignature(hexSig);
        expect(result[64], 28);
      });

      test('should throw SignatureError for wrong length', () {
        expect(
          () => SignatureBuilder.formatSignature('abcd'),
          throwsA(isA<SignatureError>()),
        );
      });
    });

    // ── parseSignature / combineSignature roundtrip ─────────────────────────

    group('parseSignature', () {
      test('should decompose 65-byte signature into r, s, v', () {
        final sig = Uint8List(65);
        sig.fillRange(0, 32, 0xAA); // r
        sig.fillRange(32, 64, 0xBB); // s
        sig[64] = 27; // v

        final comp = SignatureBuilder.parseSignature(sig);
        expect(comp.r.length, 64); // 32 bytes hex
        expect(comp.s.length, 64);
        expect(comp.v, 27);
      });

      test('should throw for non-65-byte input', () {
        expect(
          () => SignatureBuilder.parseSignature(Uint8List(32)),
          throwsA(isA<SignatureError>()),
        );
      });
    });

    group('combineSignature', () {
      test('should reconstruct 65-byte signature from components', () {
        final comp = SignatureComponents(r: 'aa' * 32, s: 'bb' * 32, v: 28);
        final result = SignatureBuilder.combineSignature(comp);
        expect(result.length, 65);
        expect(result[64], 28);
      });

      test('parse → combine roundtrip should be identity', () {
        final original = Uint8List(65);
        for (int i = 0; i < 32; i++) {
          original[i] = i;
        }
        for (int i = 32; i < 64; i++) {
          original[i] = i + 32;
        }
        original[64] = 27;

        final parsed = SignatureBuilder.parseSignature(original);
        final recombined = SignatureBuilder.combineSignature(parsed);
        expect(recombined, original);
      });
    });

    // ── recoverSignerAddress ────────────────────────────────────────────────

    group('recoverSignerAddress', () {
      test('should throw SignatureError for non-65-byte signature', () {
        expect(
          () => SignatureBuilder.recoverSignerAddress(
            hash: Uint8List(32),
            signature: Uint8List(10),
          ),
          throwsA(isA<SignatureError>()),
        );
      });

      test(
        'should recover a valid Ethereum address (0x-prefixed, 42 chars)',
        () {
          // signToUint8List internally does keccak256(payload) before signing.
          // So ecRecover needs keccak256(payload) as the hash input.
          final privKey = EthPrivateKey.fromHex(
            'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
          );
          final expectedAddress = privKey.address.with0x;

          // Raw payload (simulates a UserOp hash before wallet signing)
          final payload = Uint8List.fromList(
            utf8.encode('test message for signing'),
          );

          // signToUint8List signs keccak256(payload) internally
          final rawSig = privKey.signToUint8List(payload);

          // Recover using keccak256(payload) — the hash actually signed
          final recovered = SignatureBuilder.recoverSignerAddress(
            hash: keccak256(payload),
            signature: rawSig,
          );

          expect(recovered, startsWith('0x'));
          expect(recovered.length, 42);
          expect(recovered.toLowerCase(), expectedAddress.toLowerCase());
        },
      );

      test('should handle different key pairs consistently', () {
        final privKey = EthPrivateKey.fromHex(
          '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
        );

        final payload = Uint8List.fromList(utf8.encode('another test message'));
        final rawSig = privKey.signToUint8List(payload);

        final recovered = SignatureBuilder.recoverSignerAddress(
          hash: keccak256(payload),
          signature: rawSig,
        );

        final expectedAddress = privKey.address.with0x;
        expect(recovered, startsWith('0x'));
        expect(recovered.length, 42);
        expect(recovered.toLowerCase(), expectedAddress.toLowerCase());
      });
    });

    // ── createDummySignature ────────────────────────────────────────────────

    group('createDummySignature', () {
      test('should return 65 bytes of 0xFF', () {
        final dummy = SignatureBuilder.createDummySignature();
        expect(dummy.length, 65);
        expect(dummy.every((b) => b == 0xFF), true);
      });
    });

    // ── isValidSignatureFormat ───────────────────────────────────────────────

    group('isValidSignatureFormat', () {
      test('should accept v=27', () {
        final sig = Uint8List(65);
        sig[64] = 27;
        expect(SignatureBuilder.isValidSignatureFormat(sig), true);
      });

      test('should accept v=28', () {
        final sig = Uint8List(65);
        sig[64] = 28;
        expect(SignatureBuilder.isValidSignatureFormat(sig), true);
      });

      test('should accept v=0 (pre-adjustment)', () {
        final sig = Uint8List(65);
        sig[64] = 0;
        expect(SignatureBuilder.isValidSignatureFormat(sig), true);
      });

      test('should accept v=1 (pre-adjustment)', () {
        final sig = Uint8List(65);
        sig[64] = 1;
        expect(SignatureBuilder.isValidSignatureFormat(sig), true);
      });

      test('should reject v=2', () {
        final sig = Uint8List(65);
        sig[64] = 2;
        expect(SignatureBuilder.isValidSignatureFormat(sig), false);
      });

      test('should reject wrong length', () {
        expect(SignatureBuilder.isValidSignatureFormat(Uint8List(64)), false);
        expect(SignatureBuilder.isValidSignatureFormat(Uint8List(66)), false);
      });
    });
  });

  // ── SignatureComponents ─────────────────────────────────────────────────────

  group('SignatureComponents', () {
    test('toCompact produces 0x + 130 hex chars', () {
      final comp = SignatureComponents(r: 'aa' * 32, s: 'bb' * 32, v: 27);
      final compact = comp.toCompact();
      expect(compact, startsWith('0x'));
      expect(compact.length, 132); // 0x + 130
    });

    test('fromCompact parses correctly', () {
      final original = SignatureComponents(r: 'cc' * 32, s: 'dd' * 32, v: 28);
      final compact = original.toCompact();
      final parsed = SignatureComponents.fromCompact(compact);
      expect(parsed.r, original.r);
      expect(parsed.s, original.s);
      expect(parsed.v, original.v);
    });

    test('fromCompact throws on wrong length', () {
      expect(
        () => SignatureComponents.fromCompact('0xabcd'),
        throwsA(isA<SignatureError>()),
      );
    });
  });
}
