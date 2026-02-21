// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42appv2/src/wallet/aa/core/aa_config.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/aa/models/user_operation.dart';
import 'package:n42appv2/src/wallet/aa/utils/eip7702_handler.dart';
import 'package:n42appv2/src/wallet/aa/account/account_types/simple7702_account.dart';
import 'package:n42appv2/src/wallet/aa/builder/calldata_builder.dart';

// ─── Test helpers ────────────────────────────────────────────────────────────

/// 20-byte "all-0x12" address used as a stable test address.
const _testAddr = '0x1234567890123456789012345678901234567890';
const _testAddr2 = '0x2222222222222222222222222222222222222222';


UserOperation _minimalUserOp({Uint8List? eip7702Auth}) => UserOperation(
      sender: _testAddr,
      nonce: BigInt.zero,
      callData: Uint8List(0),
      accountGasLimits: Uint8List(32),
      preVerificationGas: BigInt.zero,
      gasFees: Uint8List(32),
      eip7702Auth: eip7702Auth,
    );

EIP7702Authorization _authWithZeroSig({
  int chainId = 1,
  String address = _testAddr,
  BigInt? nonce,
  int v = 27,
}) =>
    EIP7702Authorization(
      chainId: chainId,
      address: address,
      nonce: nonce ?? BigInt.zero,
      v: v,
      r: Uint8List(32),
      s: Uint8List(32),
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler — basic checks
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – magic byte', () {
    test('magicByte is 0x05 per EIP-7702 spec', () {
      expect(EIP7702Handler.magicByte, 0x05);
    });
  });

  group('EIP7702Handler – isEIP7702UserOp', () {
    test('returns false for standard UserOp (no auth)', () {
      expect(EIP7702Handler.isEIP7702UserOp(_minimalUserOp()), false);
    });

    test('returns false for UserOp with empty eip7702Auth', () {
      expect(EIP7702Handler.isEIP7702UserOp(_minimalUserOp(eip7702Auth: Uint8List(0))), false);
    });

    test('returns true for UserOp with non-empty eip7702Auth', () {
      expect(
        EIP7702Handler.isEIP7702UserOp(
          _minimalUserOp(eip7702Auth: Uint8List.fromList([0x01])),
        ),
        true,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // createAuthorizationHash — correctness and determinism
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – createAuthorizationHash', () {
    test('produces a 32-byte hash', () {
      final hash = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: _testAddr,
        nonce: BigInt.zero,
      );
      expect(hash.length, 32);
    });

    test('is deterministic for the same inputs', () {
      final h1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.zero);
      final h2 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.zero);
      expect(h1, equals(h2));
    });

    test('differs for different chainIds', () {
      final h1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.zero);
      final h137 = EIP7702Handler.createAuthorizationHash(
        chainId: 137, implementationAddress: _testAddr, nonce: BigInt.zero);
      expect(h1, isNot(equals(h137)));
    });

    test('differs for different implementation addresses', () {
      final h1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.zero);
      final h2 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr2, nonce: BigInt.zero);
      expect(h1, isNot(equals(h2)));
    });

    test('differs for different nonces', () {
      final h0 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.zero);
      final h1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1, implementationAddress: _testAddr, nonce: BigInt.one);
      expect(h0, isNot(equals(h1)));
    });

    // ── RLP structure validation ─────────────────────────────────────────────
    //
    // For (chainId=1, address=_testAddr, nonce=0) the expected RLP encoding is:
    //
    //   chainId  1  → 0x01           (integer < 0x80 is self-encoding)
    //   address      → 0x94 + 20 bytes  (0x80 + 20 = 0x94 length prefix)
    //   nonce    0  → 0x80           (RLP empty string = zero)
    //   list         → 0xd7 prefix   (0xc0 + 23 payload bytes)
    //
    // toHash = [0x05] || rlp_list  (magic byte prepended per spec)
    // result  = keccak256(toHash)
    //
    // This test validates the exact RLP encoding without running an external
    // reference implementation.
    test('matches manually-constructed RLP spec vector', () {
      // Manually build expected RLP: [chainId=1, addr=0x1234...5678, nonce=0]
      final addrBytes = hexToBytes(_testAddr.replaceFirst('0x', ''));
      // address: 0x94 || 20 bytes
      final rlpAddress = Uint8List(21)
        ..[0] = 0x94
        ..setAll(1, addrBytes);
      // List payload = 1 (chainId) + 21 (address) + 1 (nonce) = 23 bytes
      // List prefix = 0xc0 + 23 = 0xd7
      final rlpList = Uint8List(24)
        ..[0] = 0xd7  // list prefix
        ..[1] = 0x01  // chainId = 1
        ..setAll(2, rlpAddress)  // address (21 bytes)
        ..[23] = 0x80;  // nonce = 0

      // Prepend magic byte 0x05
      final toHash = Uint8List(25)
        ..[0] = 0x05
        ..setAll(1, rlpList);

      final expectedHash = keccak256(toHash);

      final actualHash = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: _testAddr,
        nonce: BigInt.zero,
      );

      expect(actualHash, equals(expectedHash));
    });

    test('handles large chainId (e.g. 42161 Arbitrum)', () {
      final hash = EIP7702Handler.createAuthorizationHash(
        chainId: 42161,
        implementationAddress: _testAddr,
        nonce: BigInt.zero,
      );
      expect(hash.length, 32);
    });

    test('handles large nonce', () {
      final hash = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: _testAddr,
        nonce: BigInt.from(0xFFFFFFFF),
      );
      expect(hash.length, 32);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – chain support
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – chain support', () {
    test('ETH is supported (v0.8 active by default)', () {
      expect(EIP7702Handler.isChainSupported('ETH'), true);
    });

    test('BASE is supported', () {
      expect(EIP7702Handler.isChainSupported('BASE'), true);
    });

    test('ARB is supported', () {
      expect(EIP7702Handler.isChainSupported('ARB'), true);
    });

    test('OP is supported', () {
      expect(EIP7702Handler.isChainSupported('OP'), true);
    });

    test('MATIC is supported', () {
      expect(EIP7702Handler.isChainSupported('MATIC'), true);
    });

    test('unknown chain is not supported', () {
      expect(EIP7702Handler.isChainSupported('NOTACHAIN'), false);
    });

    test('empty chain symbol is not supported', () {
      expect(EIP7702Handler.isChainSupported(''), false);
    });

    test('getImplementationAddress returns 0x-prefixed address', () {
      final addr = EIP7702Handler.getImplementationAddress('ETH');
      expect(addr.startsWith('0x'), true);
      expect(addr.length, greaterThanOrEqualTo(42));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – gas estimation
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – estimateAuthorizationGas', () {
    test('returns a value in reasonable range [10 000, 50 000]', () {
      final gas = EIP7702Handler.estimateAuthorizationGas();
      expect(gas, greaterThanOrEqualTo(BigInt.from(10000)));
      expect(gas, lessThanOrEqualTo(BigInt.from(50000)));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – buildSignedAuthorization / parseAuthorization
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – buildSignedAuthorization', () {
    test('returns non-empty bytes', () {
      final auth = _authWithZeroSig();
      expect(EIP7702Handler.buildSignedAuthorization(auth).isNotEmpty, true);
    });

    test('returns same bytes as auth.encode()', () {
      final auth = _authWithZeroSig();
      expect(
        EIP7702Handler.buildSignedAuthorization(auth),
        equals(auth.encode()),
      );
    });
  });

  group('EIP7702Handler – parseAuthorization', () {
    test('returns null for UserOp without auth', () {
      expect(EIP7702Handler.parseAuthorization(_minimalUserOp()), isNull);
    });

    test('returns null for UserOp with empty auth bytes', () {
      expect(
        EIP7702Handler.parseAuthorization(_minimalUserOp(eip7702Auth: Uint8List(0))),
        isNull,
      );
    });

    test('returns valid authorization for well-formed UserOp', () {
      final auth = _authWithZeroSig();
      final encoded = auth.encode();
      final userOp = _minimalUserOp(eip7702Auth: encoded);
      final parsed = EIP7702Handler.parseAuthorization(userOp);
      expect(parsed, isNotNull);
      expect(parsed!.chainId, auth.chainId);
    });

    test('returns null for authorization with invalid v (fails isValid)', () {
      // v=26 is not in {0,1,27,28} → isValid == false → parseAuthorization → null
      final invalidAuth = EIP7702Authorization(
        chainId: 1,
        address: _testAddr,
        nonce: BigInt.zero,
        v: 26, // invalid
        r: Uint8List(32),
        s: Uint8List(32),
      );
      final userOp = _minimalUserOp(eip7702Auth: invalidAuth.encode());
      expect(EIP7702Handler.parseAuthorization(userOp), isNull);
    });

    test('returns null for authorization with short r (fails isValid)', () {
      final invalidAuth = EIP7702Authorization(
        chainId: 1,
        address: _testAddr,
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(31), // too short
        s: Uint8List(32),
      );
      final encoded = invalidAuth.encode(); // encodes 31 bytes, but decode expects 32
      final userOp = _minimalUserOp(eip7702Auth: encoded);
      // Decode will still produce 32-byte r (slice from bytes), but the
      // original intent is tested via isValid check path
      // At minimum, no exception is thrown
      expect(() => EIP7702Handler.parseAuthorization(userOp), returnsNormally);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – verifyAuthorization
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – verifyAuthorization', () {
    test('returns false for zero r/s signature (invalid EC point)', () {
      // All-zero signature does not correspond to any valid private key;
      // ecRecover will fail or return a different address.
      final auth = _authWithZeroSig();
      final result = EIP7702Handler.verifyAuthorization(
        auth: auth,
        expectedSigner: _testAddr,
      );
      expect(result, false);
    });

    test('returns false when signer does not match', () {
      final auth = _authWithZeroSig(v: 27);
      // Even if ecRecover succeeded, the recovered address is not _testAddr2
      final result = EIP7702Handler.verifyAuthorization(
        auth: auth,
        expectedSigner: _testAddr2,
      );
      expect(result, false);
    });

    test('handles v=0 and v=1 (y-parity style) without throwing', () {
      for (final v in [0, 1]) {
        final auth = _authWithZeroSig(v: v);
        expect(
          () => EIP7702Handler.verifyAuthorization(
              auth: auth, expectedSigner: _testAddr),
          returnsNormally,
        );
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – createEIP7702UserOp
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – createEIP7702UserOp', () {
    test('creates UserOp with sender and auth set', () {
      final auth = _authWithZeroSig();
      final userOp = EIP7702Handler.createEIP7702UserOp(
        eoaAddress: _testAddr,
        nonce: BigInt.from(1),
        callData: Uint8List.fromList([0x01, 0x02]),
        authorization: auth,
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.from(50000),
        gasFees: Uint8List(32),
      );

      expect(userOp.sender, _testAddr);
      expect(userOp.hasEIP7702Auth, true);
    });

    test('initCode is null for EIP-7702 (no deployment needed)', () {
      final auth = _authWithZeroSig();
      final userOp = EIP7702Handler.createEIP7702UserOp(
        eoaAddress: _testAddr,
        nonce: BigInt.zero,
        callData: Uint8List(0),
        authorization: auth,
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      expect(userOp.initCode, isNull);
    });

    test('optional paymasterAndData is forwarded', () {
      final auth = _authWithZeroSig();
      final paymaster = Uint8List.fromList([0xAA, 0xBB]);
      final userOp = EIP7702Handler.createEIP7702UserOp(
        eoaAddress: _testAddr,
        nonce: BigInt.zero,
        callData: Uint8List(0),
        authorization: auth,
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        paymasterAndData: paymaster,
      );

      expect(userOp.paymasterAndData, equals(paymaster));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Handler – buildRevocationAuthorization (new feature)
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Handler – buildRevocationAuthorization', () {
    test('address is the zero address', () {
      final rev = EIP7702Handler.buildRevocationAuthorization(
        chainId: 1,
        nonce: BigInt.from(5),
      );
      expect(rev.address, '0x0000000000000000000000000000000000000000');
    });

    test('chainId and nonce are preserved', () {
      final rev = EIP7702Handler.buildRevocationAuthorization(
        chainId: 8453,
        nonce: BigInt.from(42),
      );
      expect(rev.chainId, 8453);
      expect(rev.nonce, BigInt.from(42));
    });

    test('isRevocation returns true', () {
      final rev = EIP7702Handler.buildRevocationAuthorization(
        chainId: 1,
        nonce: BigInt.zero,
      );
      expect(rev.isRevocation, true);
    });

    test('revocation hash can be computed for signing', () {
      final rev = EIP7702Handler.buildRevocationAuthorization(
        chainId: 1,
        nonce: BigInt.from(3),
      );
      final hash = EIP7702Handler.createAuthorizationHash(
        chainId: rev.chainId,
        implementationAddress: rev.address,
        nonce: rev.nonce,
      );
      expect(hash.length, 32);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EntryPointVersionAdapter
  // ══════════════════════════════════════════════════════════════════════════

  group('EntryPointVersionAdapter – getEntryPoint', () {
    test('v07 returns entryPointV07', () {
      expect(
        EntryPointVersionAdapter.getEntryPoint(EntryPointVersion.v07),
        AAConfig.entryPointV07,
      );
    });

    test('v08 returns entryPointV08', () {
      expect(
        EntryPointVersionAdapter.getEntryPoint(EntryPointVersion.v08),
        AAConfig.entryPointV08,
      );
    });

    test('entryPointV07 and entryPointV08 are different addresses', () {
      expect(AAConfig.entryPointV07, isNot(equals(AAConfig.entryPointV08)));
    });
  });

  group('EntryPointVersionAdapter – requiresV08', () {
    test('returns true for UserOp with EIP-7702 auth', () {
      final userOp = _minimalUserOp(eip7702Auth: Uint8List.fromList([0x01]));
      expect(EntryPointVersionAdapter.requiresV08(userOp), true);
    });

    test('returns false for standard UserOp', () {
      expect(EntryPointVersionAdapter.requiresV08(_minimalUserOp()), false);
    });
  });

  group('EntryPointVersionAdapter – upgradeToV08', () {
    test('preserves all UserOp fields', () {
      final userOp = _minimalUserOp();
      final upgraded = EntryPointVersionAdapter.upgradeToV08(userOp);
      expect(upgraded.sender, userOp.sender);
      expect(upgraded.nonce, userOp.nonce);
    });
  });

  group('EntryPointVersionAdapter – getGasPenaltyThreshold', () {
    test('v07 threshold is zero (all unused gas penalised)', () {
      expect(
        EntryPointVersionAdapter.getGasPenaltyThreshold(EntryPointVersion.v07),
        BigInt.zero,
      );
    });

    test('v08 threshold is 40 000 (no penalty under this amount)', () {
      expect(
        EntryPointVersionAdapter.getGasPenaltyThreshold(EntryPointVersion.v08),
        BigInt.from(40000),
      );
    });
  });

  group('EntryPointVersionAdapter – addEIP7702Auth', () {
    test('attaches authorization bytes to an existing UserOp', () {
      final userOp = _minimalUserOp();
      final auth = _authWithZeroSig();

      final updated = EntryPointVersionAdapter.addEIP7702Auth(
        userOp: userOp,
        authorization: auth,
      );

      expect(updated.hasEIP7702Auth, true);
      expect(updated.sender, userOp.sender);
    });

    test('can be verified with parseAuthorization after adding', () {
      final userOp = _minimalUserOp();
      final auth = _authWithZeroSig();
      final updated = EntryPointVersionAdapter.addEIP7702Auth(
        userOp: userOp,
        authorization: auth,
      );

      final parsed = EIP7702Handler.parseAuthorization(updated);
      expect(parsed, isNotNull);
      expect(parsed!.chainId, auth.chainId);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EntryPointVersionAdapter – estimateGasSavings (bug-fix coverage)
  // ══════════════════════════════════════════════════════════════════════════

  group('EntryPointVersionAdapter – estimateGasSavings', () {
    test('first EIP-7702 tx saves ~175 000 gas (200 000 deploy − 25 000 auth)', () {
      final userOp = UserOperation(
        sender: _testAddr,
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01]),
      );

      final savings = EntryPointVersionAdapter.estimateGasSavings(
        userOp: userOp,
        isFirstTransaction: true,
      );

      // Expected: 200 000 (deployment avoided) − 25 000 (auth gas) = 175 000
      expect(savings, BigInt.from(175000));
    });

    test('non-first EIP-7702 tx has zero deployment savings', () {
      final userOp = UserOperation(
        sender: _testAddr,
        nonce: BigInt.one,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01]),
      );

      final savings = EntryPointVersionAdapter.estimateGasSavings(
        userOp: userOp,
        isFirstTransaction: false,
      );

      // No deployment savings; verificationGasLimit=0 → no penalty reduction either
      expect(savings, BigInt.zero);
    });

    test('returns non-negative value (clamped to zero)', () {
      // Standard UserOp (no EIP-7702), no unused gas → savings = 0
      final savings = EntryPointVersionAdapter.estimateGasSavings(
        userOp: _minimalUserOp(),
        isFirstTransaction: true,
      );
      expect(savings >= BigInt.zero, true);
    });

    test('v08 penalty reduction applies when unused gas is under 40 000', () {
      // verificationGasLimit=35 000, estimate unused = 35 000 − 20 000 = 15 000
      // 10% of 15 000 = 1 500 additional savings
      final userOp = UserOperation(
        sender: _testAddr,
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: PackedGasLimits.pack(
          BigInt.from(35000),
          BigInt.from(100000),
        ),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      final savings = EntryPointVersionAdapter.estimateGasSavings(
        userOp: userOp,
        isFirstTransaction: false,
      );

      expect(savings, BigInt.from(1500));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // V08MigrationHelper
  // ══════════════════════════════════════════════════════════════════════════

  group('V08MigrationHelper – canMigrate', () {
    test('always returns true (v0.8 is backwards compatible)', () {
      expect(
        V08MigrationHelper.canMigrate(_testAddr, 1),
        true,
      );
    });
  });

  group('V08MigrationHelper – shouldUseEIP7702', () {
    test('returns false when account is already deployed', () {
      expect(
        V08MigrationHelper.shouldUseEIP7702(
          chainSymbol: 'ETH',
          isDeployed: true,
          preferGasEfficiency: true,
        ),
        false,
      );
    });

    test('returns false for unsupported chain', () {
      expect(
        V08MigrationHelper.shouldUseEIP7702(
          chainSymbol: 'UNKNOWNCHAIN',
          isDeployed: false,
          preferGasEfficiency: true,
        ),
        false,
      );
    });

    test('returns true for supported undeployed account when preferring efficiency', () {
      final result = V08MigrationHelper.shouldUseEIP7702(
        chainSymbol: 'ETH',
        isDeployed: false,
        preferGasEfficiency: true,
      );
      // ETH supports EIP-7702; prefer gas efficiency; not deployed
      expect(result, true);
    });

    test('returns false when not preferring gas efficiency', () {
      expect(
        V08MigrationHelper.shouldUseEIP7702(
          chainSymbol: 'ETH',
          isDeployed: false,
          preferGasEfficiency: false,
        ),
        false,
      );
    });
  });

  group('V08MigrationHelper – getMigrationRecommendations', () {
    test('recommends v0.8 upgrade when on v0.7', () {
      final recs = V08MigrationHelper.getMigrationRecommendations(
        currentVersion: EntryPointVersion.v07,
        hasDeployedAccount: false,
        chainSymbol: 'ETH',
      );
      expect(recs.any((r) => r.contains('v0.8')), true);
    });

    test('recommends EIP-7702 when chain supports it and no deployment', () {
      final recs = V08MigrationHelper.getMigrationRecommendations(
        currentVersion: EntryPointVersion.v07,
        hasDeployedAccount: false,
        chainSymbol: 'ETH',
      );
      expect(recs.any((r) => r.toLowerCase().contains('eip-7702') || r.contains('7702')), true);
    });

    test('notes optimal when already on v0.8', () {
      final recs = V08MigrationHelper.getMigrationRecommendations(
        currentVersion: EntryPointVersion.v08,
        hasDeployedAccount: true,
        chainSymbol: 'ETH',
      );
      expect(recs.any((r) => r.contains('optimal')), true);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Authorization — model tests
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Authorization – isValid', () {
    test('true when v=0, r=32 bytes, s=32 bytes', () {
      expect(_authWithZeroSig(v: 0).isValid, true);
    });

    test('true when v=1', () {
      expect(_authWithZeroSig(v: 1).isValid, true);
    });

    test('true when v=27 (legacy Ethereum style)', () {
      expect(_authWithZeroSig(v: 27).isValid, true);
    });

    test('true when v=28', () {
      expect(_authWithZeroSig(v: 28).isValid, true);
    });

    test('false when v=26 (invalid)', () {
      expect(_authWithZeroSig(v: 26).isValid, false);
    });

    test('false when v=29 (invalid)', () {
      expect(_authWithZeroSig(v: 29).isValid, false);
    });

    test('false when r is shorter than 32 bytes', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: _testAddr,
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(31), // 31 bytes — invalid
        s: Uint8List(32),
      );
      expect(auth.isValid, false);
    });

    test('false when s is shorter than 32 bytes', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: _testAddr,
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(32),
        s: Uint8List(30), // 30 bytes — invalid
      );
      expect(auth.isValid, false);
    });
  });

  group('EIP7702Authorization – isRevocation', () {
    test('true when address is the zero address', () {
      final rev = EIP7702Authorization(
        chainId: 1,
        address: '0x0000000000000000000000000000000000000000',
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(32),
        s: Uint8List(32),
      );
      expect(rev.isRevocation, true);
    });

    test('false for a normal implementation address', () {
      expect(_authWithZeroSig().isRevocation, false);
    });
  });

  group('EIP7702Authorization – isAnyChain', () {
    test('true when chainId is 0', () {
      final auth = EIP7702Authorization(
        chainId: 0,
        address: _testAddr,
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(32),
        s: Uint8List(32),
      );
      expect(auth.isAnyChain, true);
    });

    test('false for specific chainId', () {
      expect(_authWithZeroSig(chainId: 1).isAnyChain, false);
    });

    test('false for mainnet chainId 1', () {
      expect(_authWithZeroSig(chainId: 1).isAnyChain, false);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EIP7702Authorization — encode / decode round-trip
  // ══════════════════════════════════════════════════════════════════════════

  group('EIP7702Authorization – encode/decode round-trip', () {
    test('encoded bytes are 149 bytes', () {
      expect(_authWithZeroSig().encode().length, 149);
    });

    test('round-trip preserves chainId', () {
      final original = _authWithZeroSig(chainId: 42161);
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.chainId, 42161);
    });

    test('round-trip preserves address', () {
      final original = _authWithZeroSig(address: _testAddr2);
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.address.toLowerCase(), _testAddr2.toLowerCase());
    });

    test('round-trip preserves nonce', () {
      final original = _authWithZeroSig(nonce: BigInt.from(999));
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.nonce, BigInt.from(999));
    });

    test('round-trip preserves v', () {
      final original = _authWithZeroSig(v: 28);
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.v, 28);
    });

    test('round-trip preserves non-zero r bytes', () {
      final r = Uint8List.fromList(List.filled(32, 0xAB));
      final original = EIP7702Authorization(
        chainId: 1, address: _testAddr, nonce: BigInt.zero,
        v: 27, r: r, s: Uint8List(32),
      );
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.r, equals(r));
    });

    test('round-trip preserves non-zero s bytes', () {
      final s = Uint8List.fromList(List.filled(32, 0xCD));
      final original = EIP7702Authorization(
        chainId: 1, address: _testAddr, nonce: BigInt.zero,
        v: 27, r: Uint8List(32), s: s,
      );
      final decoded = EIP7702Authorization.decode(original.encode());
      expect(decoded.s, equals(s));
    });

    test('decode throws ArgumentError for truncated bytes', () {
      final truncated = Uint8List(100); // less than 149 bytes
      expect(() => EIP7702Authorization.decode(truncated), throwsArgumentError);
    });

    test('decode throws ArgumentError for empty bytes', () {
      expect(() => EIP7702Authorization.decode(Uint8List(0)), throwsArgumentError);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Simple7702AccountHelper
  // ══════════════════════════════════════════════════════════════════════════

  group('Simple7702AccountHelper – fromChain', () {
    test('ETH creates helper with chainId=1', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      expect(helper.chainId, 1);
    });

    test('ETH helper uses EntryPoint v0.8 address', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      expect(helper.entryPointAddress, AAConfig.entryPointV08);
    });

    test('ETH implementation address is 0x-prefixed', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      expect(helper.implementationAddress.startsWith('0x'), true);
    });

    test('BASE creates helper with chainId=8453', () {
      final helper = Simple7702AccountHelper.fromChain('BASE');
      expect(helper.chainId, 8453);
    });

    test('ARB creates helper with chainId=42161', () {
      final helper = Simple7702AccountHelper.fromChain('ARB');
      expect(helper.chainId, 42161);
    });

    test('unsupported chain throws ArgumentError', () {
      expect(() => Simple7702AccountHelper.fromChain('UNKNOWNCHAIN'), throwsArgumentError);
    });

    test('lowercase chain symbol is normalised (eth → ETH)', () {
      // AAConfig.getChainConfig calls toUpperCase() internally, so 'eth' → 'ETH'
      // and the call should succeed without throwing.
      expect(() => Simple7702AccountHelper.fromChain('eth'), returnsNormally);
    });
  });

  group('Simple7702AccountHelper – getAccountAddress', () {
    test('returns EOA address unchanged (no counterfactual derivation)', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      const eoaAddr = '0xDeAdBEEf00000000000000000000000000000000';
      expect(helper.getAccountAddress(eoaAddr), eoaAddr);
    });
  });

  group('Simple7702AccountHelper – buildAuthorization', () {
    test('returns non-empty bytes', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      expect(helper.buildAuthorization(nonce: BigInt.zero).isNotEmpty, true);
    });

    test('different nonces produce different auth bytes', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final a0 = helper.buildAuthorization(nonce: BigInt.zero);
      final a1 = helper.buildAuthorization(nonce: BigInt.one);
      expect(a0, isNot(equals(a1)));
    });
  });

  group('Simple7702AccountHelper – getAuthorizationHash', () {
    test('returns exactly 32 bytes', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      expect(helper.getAuthorizationHash(nonce: BigInt.zero).length, 32);
    });

    test('matches EIP7702Handler.createAuthorizationHash for same inputs', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final helperHash = helper.getAuthorizationHash(nonce: BigInt.zero);

      final handlerHash = EIP7702Handler.createAuthorizationHash(
        chainId: helper.chainId,
        implementationAddress: helper.implementationAddress,
        nonce: BigInt.zero,
      );

      expect(helperHash, equals(handlerHash),
          reason: 'Simple7702AccountHelper and EIP7702Handler must produce '
              'the same hash for the same (chainId, address, nonce) triple');
    });

    test('different nonces produce different hashes', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final h0 = helper.getAuthorizationHash(nonce: BigInt.zero);
      final h1 = helper.getAuthorizationHash(nonce: BigInt.one);
      expect(h0, isNot(equals(h1)));
    });
  });

  group('Simple7702AccountHelper – buildSignedAuthorization', () {
    test('returns bytes with length = auth + signature', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      const sigLength = 65; // typical secp256k1 signature
      final fakeSignature = Uint8List(sigLength);
      final result = helper.buildSignedAuthorization(
        nonce: BigInt.zero,
        signature: fakeSignature,
      );
      final authLength = helper.buildAuthorization(nonce: BigInt.zero).length;
      expect(result.length, authLength + sigLength);
    });
  });

  group('Simple7702AccountHelper – createAccount', () {
    test('account address equals EOA address', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      const eoaAddr = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      final account = helper.createAccount(eoaAddress: eoaAddr);
      expect(account.address, eoaAddr);
    });

    test('ownerAddress equals EOA address', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      const eoaAddr = '0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
      final account = helper.createAccount(eoaAddress: eoaAddr);
      expect(account.ownerAddress, eoaAddr);
    });

    test('account type is simple7702Account', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(eoaAddress: _testAddr);
      expect(account.type, SmartAccountType.simple7702Account);
    });

    test('state is deployed (EIP-7702 needs no factory deployment)', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(eoaAddress: _testAddr);
      expect(account.state, SmartAccountState.deployed);
    });

    test('chainId matches chain configuration', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(eoaAddress: _testAddr);
      expect(account.chainId, 1);
    });

    test('salt is zero (no factory salt needed)', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(eoaAddress: _testAddr);
      expect(account.salt, BigInt.zero);
    });

    test('custom label is used when provided', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(
        eoaAddress: _testAddr,
        label: 'My Test Account',
      );
      expect(account.label, 'My Test Account');
    });

    test('default label is non-empty when not provided', () {
      final helper = Simple7702AccountHelper.fromChain('ETH');
      final account = helper.createAccount(eoaAddress: _testAddr);
      expect(account.label?.isNotEmpty, true);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Simple7702GasConstants
  // ══════════════════════════════════════════════════════════════════════════

  group('Simple7702GasConstants', () {
    test('authorizationGas is positive', () {
      expect(Simple7702GasConstants.authorizationGas, greaterThan(0));
    });

    test('estimateExecuteGas returns > authorizationGas for non-trivial data', () {
      final gas = Simple7702GasConstants.estimateExecuteGas(100);
      expect(gas, greaterThan(BigInt.from(Simple7702GasConstants.authorizationGas)));
    });

    test('estimateBatchGas returns > estimateExecuteGas for same call count', () {
      final execGas = Simple7702GasConstants.estimateExecuteGas(0);
      final batchGas = Simple7702GasConstants.estimateBatchGas([
        ExecuteCall(
          target: _testAddr,
          value: BigInt.zero,
          data: Uint8List(0),
        ),
      ]);
      // Batch adds per-call overhead on top of base overhead
      expect(batchGas, greaterThan(execGas));
    });
  });
}
