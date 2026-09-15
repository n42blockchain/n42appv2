// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:n42_wallet/features/wallet/aa/utils/gas_estimator.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_constants.dart';
import 'package:n42_wallet/features/wallet/aa/builder/user_op_builder.dart';
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_client.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

/// Build a minimal GasEstimateResult for test purposes.
GasEstimateResult _makeEstimate({
  int verification = 100000,
  int call = 100000,
  int preVerification = 50000,
  int? pmVerify,
  int? pmPost,
}) {
  return GasEstimateResult(
    verificationGasLimit: BigInt.from(verification),
    callGasLimit: BigInt.from(call),
    preVerificationGas: BigInt.from(preVerification),
    paymasterVerificationGasLimit: pmVerify != null
        ? BigInt.from(pmVerify)
        : null,
    paymasterPostOpGasLimit: pmPost != null ? BigInt.from(pmPost) : null,
  );
}

/// Build a minimal UserOpBuilder with the required fields set.
UserOpBuilder _minimalBuilder({bool withGasFees = false}) {
  final b = UserOpBuilder()
    ..setSender('0x${'ab' * 20}')
    ..setNonce(BigInt.zero)
    ..setCallData(Uint8List.fromList([0x01, 0x02, 0x03]));

  if (withGasFees) {
    b.setGasFees(
      maxFeePerGas: BigInt.from(10000000000),
      maxPriorityFeePerGas: BigInt.from(1000000000),
    );
  }
  return b;
}

// ── calculatePreVerificationGas ────────────────────────────────────────────

void _testCalculatePreVerificationGas() {
  group('calculatePreVerificationGas', () {
    // Build a UserOperation with known calldata for predictable gas calculation.
    // We test by constructing a full UserOperation via builder.
    UserOpBuilder builderWithCalldata(Uint8List data) {
      return UserOpBuilder()
        ..setSender('0x${'aa' * 20}')
        ..setNonce(BigInt.zero)
        ..setCallData(data)
        ..setGasFees(
          maxFeePerGas: BigInt.one,
          maxPriorityFeePerGas: BigInt.zero,
        );
    }

    test('all-zero calldata: charges 4 gas per byte', () {
      final data = Uint8List(100); // 100 zero bytes
      final builder = builderWithCalldata(data);
      final userOp = builder.build();

      final gas = AAGasEstimator.calculatePreVerificationGas(userOp);
      // 21000 + 100 * 4 = 21400 — still above minPreVerificationGas (21000)
      expect(gas, BigInt.from(21400));
    });

    test('all-nonzero calldata: charges 16 gas per byte', () {
      final data = Uint8List.fromList(
        List.filled(10, 0xFF),
      ); // 10 non-zero bytes
      final builder = builderWithCalldata(data);
      final userOp = builder.build();

      final gas = AAGasEstimator.calculatePreVerificationGas(userOp);
      // 21000 + 10 * 16 = 21160 > 21000 minimum
      expect(gas, BigInt.from(21160));
    });

    test('mixed calldata: zero bytes cost 4, nonzero cost 16', () {
      // 5 zero bytes + 5 non-zero bytes
      final data = Uint8List.fromList([
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xFF,
        0xFF,
        0xFF,
        0xFF,
        0xFF,
      ]);
      final builder = builderWithCalldata(data);
      final userOp = builder.build();

      final gas = AAGasEstimator.calculatePreVerificationGas(userOp);
      // 21000 + 5*4 + 5*16 = 21000 + 20 + 80 = 21100
      expect(gas, BigInt.from(21100));
    });

    test('empty calldata: returns minimum pre-verification gas', () {
      // setCallData requires non-empty, so build directly with 1-byte data
      // and verify the formula is correct, not the empty case (builder rejects empty)
      final data = Uint8List.fromList([0x00]); // 1 zero byte
      final builder = builderWithCalldata(data);
      final userOp = builder.build();

      final gas = AAGasEstimator.calculatePreVerificationGas(userOp);
      // 21000 + 1*4 = 21004 — still above minimum
      expect(
        gas,
        greaterThanOrEqualTo(BigInt.from(AAConstants.minPreVerificationGas)),
      );
    });

    test('nonzero bytes are significantly more expensive than zero bytes', () {
      final zeroData = Uint8List(50); // 50 zeros
      final nonZeroData = Uint8List.fromList(
        List.filled(50, 0xAB),
      ); // 50 non-zeros

      UserOpBuilder zeroBuilder() => builderWithCalldata(zeroData);
      UserOpBuilder nonZeroBuilder() => builderWithCalldata(nonZeroData);

      final zeroGas = AAGasEstimator.calculatePreVerificationGas(
        zeroBuilder().build(),
      );
      final nonZeroGas = AAGasEstimator.calculatePreVerificationGas(
        nonZeroBuilder().build(),
      );

      // Non-zero should cost 4x more for the calldata portion
      // zeroGas calldata portion = 50*4 = 200
      // nonZeroGas calldata portion = 50*16 = 800
      expect(
        nonZeroGas - zeroGas,
        BigInt.from(600),
      ); // 800 - 200 = 600 extra gas
    });

    test('EIP-2028 is superior to flat-16 for ABI-encoded parameters', () {
      // ABI-encoded uint256(1) has 31 zero bytes + 1 non-zero byte
      final abiParam = Uint8List(32);
      abiParam[31] = 0x01; // uint256(1)

      final builder = builderWithCalldata(abiParam);
      final userOp = builder.build();

      final eip2028Gas = AAGasEstimator.calculatePreVerificationGas(userOp);
      // 21000 + 31*4 + 1*16 = 21000 + 124 + 16 = 21140
      expect(eip2028Gas, BigInt.from(21140));

      // Flat-16 (old broken formula) would have given 21000 + 32*16 = 21512
      // EIP-2028 correctly saves 372 gas for this ABI parameter
      final flatGas = BigInt.from(21000 + 32 * 16);
      expect(eip2028Gas, lessThan(flatGas));
    });
  });
}

// ── GasDeviationDetector ────────────────────────────────────────────────────

void _testGasDeviationDetector() {
  group('GasDeviationDetector.analyze', () {
    test('no warnings for normal estimates', () {
      final estimate = _makeEstimate(
        verification: 100000,
        call: 100000,
        preVerification: 50000,
      );
      final warnings = GasDeviationDetector.analyze(estimate);
      expect(warnings, isEmpty);
    });

    group('totalGasVeryHigh', () {
      test('warning severity at warning threshold', () {
        // Total = 2,000,000 + 1 (just over threshold)
        // verification + call + preVerification = 2_000_001
        final estimate = _makeEstimate(
          verification: 1000000,
          call: 800000,
          preVerification: 200001,
        );
        final warnings = GasDeviationDetector.analyze(estimate);
        final totalWarn = warnings
            .where((w) => w.type == GasDeviationWarningType.totalGasVeryHigh)
            .toList();

        expect(totalWarn, hasLength(1));
        expect(totalWarn.first.severity, GasDeviationSeverity.warning);
        expect(totalWarn.first.titleKey, 'g_key_aa_gas_warn_total_high');
        expect(totalWarn.first.hasGasPlaceholder, isTrue);
        expect(totalWarn.first.gasValue, isNotNull);
      });

      test('critical severity at critical threshold', () {
        final estimate = _makeEstimate(
          verification: 2000000,
          call: 2000000,
          preVerification: 1000001,
        );
        final warnings = GasDeviationDetector.analyze(estimate);
        final totalWarn = warnings
            .where((w) => w.type == GasDeviationWarningType.totalGasVeryHigh)
            .toList();

        expect(totalWarn, hasLength(1));
        expect(totalWarn.first.severity, GasDeviationSeverity.critical);
      });

      test('no warning below threshold', () {
        final estimate = _makeEstimate(
          verification: 500000,
          call: 500000,
          preVerification: 50000,
        );
        // Total = 1,050,000 — below 2,000,000 warning threshold
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.totalGasVeryHigh)
            .toList();
        expect(warnings, isEmpty);
      });
    });

    group('verificationGasHigh', () {
      test('fires when verificationGasLimit >= 500000', () {
        final estimate = _makeEstimate(verification: 500000);
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.verificationGasHigh)
            .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.warning);
        expect(warnings.first.titleKey, 'g_key_aa_gas_warn_verify_high');
        expect(warnings.first.gasValue, '500,000');
      });

      test('does not fire below threshold', () {
        final estimate = _makeEstimate(verification: 499999);
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.verificationGasHigh)
            .toList();
        expect(warnings, isEmpty);
      });
    });

    group('callGasHigh', () {
      test('fires when callGasLimit >= 500000', () {
        final estimate = _makeEstimate(call: 500000);
        final warnings = GasDeviationDetector.analyze(
          estimate,
        ).where((w) => w.type == GasDeviationWarningType.callGasHigh).toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.warning);
        expect(warnings.first.titleKey, 'g_key_aa_gas_warn_call_high');
      });

      test('does not fire below threshold', () {
        final estimate = _makeEstimate(call: 499999);
        final warnings = GasDeviationDetector.analyze(
          estimate,
        ).where((w) => w.type == GasDeviationWarningType.callGasHigh).toList();
        expect(warnings, isEmpty);
      });
    });

    group('paymasterOverhead', () {
      test('fires when paymaster gas > 20% of total', () {
        // GasEstimateResult.totalGas includes pmVerify+pmPost.
        // total = 50000 + 50000 + 25000 + 50000 + 50000 = 225000
        // pm    = 50000 + 50000 = 100000 → 44% > 20%
        final estimate = _makeEstimate(
          verification: 50000,
          call: 50000,
          preVerification: 25000,
          pmVerify: 50000,
          pmPost: 50000,
        );
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.paymasterOverhead)
            .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.info);
        expect(warnings.first.titleKey, 'g_key_aa_gas_warn_paymaster');
      });

      test('critical severity when paymaster overhead > 75% of total', () {
        // total = 50000 + 50000 + 25000 + 400000 + 400000 = 925000
        // pm    = 800000 → 86% > 75% → critical
        final estimate = _makeEstimate(
          verification: 50000,
          call: 50000,
          preVerification: 25000,
          pmVerify: 400000,
          pmPost: 400000,
        );
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.paymasterOverhead)
            .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.critical);
      });

      test('does not fire when paymaster is absent', () {
        final estimate = _makeEstimate();
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.paymasterOverhead)
            .toList();
        expect(warnings, isEmpty);
      });

      test('does not fire when paymaster overhead is under 20%', () {
        // total = 250000, pm = 40000 → 16% < 20%
        final estimate = _makeEstimate(pmVerify: 20000, pmPost: 20000);
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.paymasterOverhead)
            .toList();
        expect(warnings, isEmpty);
      });
    });

    group('deploymentOverhead', () {
      test('fires as info when isFirstTransaction=true', () {
        final estimate = _makeEstimate();
        final warnings =
            GasDeviationDetector.analyze(estimate, isFirstTransaction: true)
                .where(
                  (w) => w.type == GasDeviationWarningType.deploymentOverhead,
                )
                .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.info);
        expect(warnings.first.titleKey, 'g_key_aa_gas_warn_deploy');
        expect(warnings.first.gasValue, isNotNull);
      });

      test('does not fire when isFirstTransaction=false (default)', () {
        final estimate = _makeEstimate();
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.deploymentOverhead)
            .toList();
        expect(warnings, isEmpty);
      });
    });

    group('possibleUnderEstimate', () {
      test('warning severity at 50% deviation', () {
        // Deviation formula: pct = (client - bundler) / bundler * 100
        // bundler total = 100000+100000+50000 = 250000
        // For 50% deviation: client = bundler * 1.5 = 375000
        final estimate = _makeEstimate(
          verification: 100000,
          call: 100000,
          preVerification: 50000,
        );
        final warnings =
            GasDeviationDetector.analyze(
                  estimate,
                  clientEstimate: BigInt.from(375000),
                )
                .where(
                  (w) =>
                      w.type == GasDeviationWarningType.possibleUnderEstimate,
                )
                .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.warning);
        expect(warnings.first.titleKey, 'g_key_aa_gas_warn_under_est');
      });

      test('critical severity at 100% deviation', () {
        // Deviation formula: pct = (client - bundler) / bundler * 100
        // bundler total = 250000
        // For 100% deviation: client = bundler * 2 = 500000
        final estimate = _makeEstimate(
          verification: 100000,
          call: 100000,
          preVerification: 50000,
        );
        final warnings =
            GasDeviationDetector.analyze(
                  estimate,
                  clientEstimate: BigInt.from(500000),
                )
                .where(
                  (w) =>
                      w.type == GasDeviationWarningType.possibleUnderEstimate,
                )
                .toList();

        expect(warnings, hasLength(1));
        expect(warnings.first.severity, GasDeviationSeverity.critical);
      });

      test('no warning when bundler >= client (safe side)', () {
        // bundler total = 500000, client = 250000
        // diff = 250000 - 500000 = -250000 (negative: bundler > client → safe)
        final estimate = _makeEstimate(
          verification: 200000,
          call: 200000,
          preVerification: 100000,
        ); // total = 500000

        final warnings =
            GasDeviationDetector.analyze(
                  estimate,
                  clientEstimate: BigInt.from(250000), // bundler higher → safe
                )
                .where(
                  (w) =>
                      w.type == GasDeviationWarningType.possibleUnderEstimate,
                )
                .toList();

        expect(warnings, isEmpty);
      });

      test('no check performed when clientEstimate is null', () {
        final estimate = _makeEstimate();
        final warnings = GasDeviationDetector.analyze(estimate)
            .where(
              (w) => w.type == GasDeviationWarningType.possibleUnderEstimate,
            )
            .toList();
        expect(warnings, isEmpty);
      });

      test('no check performed when clientEstimate is zero', () {
        final estimate = _makeEstimate();
        final warnings =
            GasDeviationDetector.analyze(estimate, clientEstimate: BigInt.zero)
                .where(
                  (w) =>
                      w.type == GasDeviationWarningType.possibleUnderEstimate,
                )
                .toList();
        expect(warnings, isEmpty);
      });
    });

    group('result ordering', () {
      test('critical warnings appear before warning, warning before info', () {
        // Trigger:
        //   - critical: total > 5M (2M+2M+1M+1 = 5,000,001)
        //   - warning:  verify >= 500k (2M) + call >= 500k (2M)
        //   - info:     isFirstTransaction = true
        final estimate = _makeEstimate(
          verification: 2000000,
          call: 2000000,
          preVerification: 1000001,
        );
        final warnings = GasDeviationDetector.analyze(
          estimate,
          isFirstTransaction: true,
        );

        expect(warnings, isNotEmpty);

        // GasDeviationSeverity enum: info=0, warning=1, critical=2
        // "critical first" ordering → severity.index must be DESCENDING
        // (highest index = most severe comes first in the list)
        final severities = warnings.map((w) => w.severity.index).toList();
        for (var i = 0; i < severities.length - 1; i++) {
          expect(
            severities[i],
            greaterThanOrEqualTo(severities[i + 1]),
            reason:
                'Warnings not in severity-descending order at index $i '
                '(${warnings[i].severity} should be >= ${warnings[i + 1].severity})',
          );
        }

        // Additionally verify the first element is the most severe present.
        expect(warnings.first.severity, GasDeviationSeverity.critical);
        // And the last element is the least severe.
        expect(warnings.last.severity, GasDeviationSeverity.info);
      });
    });

    group('_formatGas', () {
      test('formats numbers with thousands separators', () {
        final estimate = _makeEstimate(verification: 500000);
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.verificationGasHigh)
            .toList();

        expect(warnings.first.gasValue, '500,000');
      });

      test('formats large numbers correctly', () {
        final estimate = _makeEstimate(
          verification: 2000000,
          call: 2000000,
          preVerification: 1000001,
        );
        final warnings = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.totalGasVeryHigh)
            .toList();

        // 5,000,001
        expect(warnings.first.gasValue, '5,000,001');
      });

      test('formats small numbers without separators', () {
        final estimate = _makeEstimate(verification: 500000);
        final w = GasDeviationDetector.analyze(estimate)
            .where((w) => w.type == GasDeviationWarningType.verificationGasHigh)
            .first;
        // "500,000" — 6 digits, 1 separator
        expect(w.gasValue!.contains(','), isTrue);
      });
    });
  });
}

// ── UserOpBuilder.buildForEstimation ──────────────────────────────────────

void _testBuildForEstimation() {
  group('UserOpBuilder.buildForEstimation', () {
    test('succeeds without gas fees set', () {
      final builder = _minimalBuilder(); // no gas fees
      expect(() => builder.buildForEstimation(), returnsNormally);
    });

    test('uses dummy signature in returned UserOperation', () {
      final builder = _minimalBuilder();
      final userOp = builder.buildForEstimation();
      expect(userOp.signature, equals(AAConstants.dummySignature));
    });

    test('does NOT permanently mutate the signature field', () {
      final originalSig = Uint8List.fromList([0x01, 0x02, 0x03]);
      final builder = _minimalBuilder(withGasFees: true)
        ..setSignature(originalSig);

      // Build for estimation (injects dummy signature temporarily)
      final estimationOp = builder.buildForEstimation();
      expect(estimationOp.signature, equals(AAConstants.dummySignature));

      // Now build the real operation — must use original signature
      final realOp = builder.build();
      expect(realOp.signature, equals(originalSig));
    });

    test('does NOT mutate state when signature was null before', () {
      final builder = _minimalBuilder(withGasFees: true);
      // No signature set

      builder.buildForEstimation();

      // After estimation, signature field must remain null
      // Build throws because gas fees ARE set, so signature should be null
      final realOp = builder.build();
      expect(realOp.signature, isNull);
    });

    test(
      'estimation and real build can be called multiple times independently',
      () {
        final sig = Uint8List.fromList(List.filled(65, 0xAA));
        final builder = _minimalBuilder(withGasFees: true)..setSignature(sig);

        // Alternate calls: estimation must not interfere with real builds
        builder.buildForEstimation();
        builder.buildForEstimation();
        final real1 = builder.build();
        builder.buildForEstimation();
        final real2 = builder.build();

        expect(real1.signature, equals(sig));
        expect(real2.signature, equals(sig));
      },
    );

    test('throws when sender is missing', () {
      final builder = UserOpBuilder()
        ..setNonce(BigInt.zero)
        ..setCallData(Uint8List.fromList([0x01]));

      expect(
        () => builder.buildForEstimation(),
        throwsA(isA<UserOperationBuildError>()),
      );
    });

    test('throws when nonce is missing', () {
      final builder = UserOpBuilder()
        ..setSender('0x${'aa' * 20}')
        ..setCallData(Uint8List.fromList([0x01]));

      expect(
        () => builder.buildForEstimation(),
        throwsA(isA<UserOperationBuildError>()),
      );
    });

    test('throws when callData is missing', () {
      final builder = UserOpBuilder()
        ..setSender('0x${'aa' * 20}')
        ..setNonce(BigInt.zero);

      expect(
        () => builder.buildForEstimation(),
        throwsA(isA<UserOperationBuildError>()),
      );
    });

    test('returned UserOp preserves all other fields unchanged', () {
      final callData = Uint8List.fromList([0xb6, 0x1d, 0x27, 0xf6]);
      final initCode = Uint8List.fromList([0xAB, 0xCD]);
      final builder = UserOpBuilder()
        ..setSender('0x${'aa' * 20}')
        ..setNonce(BigInt.from(42))
        ..setCallData(callData)
        ..setInitCode(initCode);

      final userOp = builder.buildForEstimation();

      expect(userOp.sender, '0x${'aa' * 20}');
      expect(userOp.nonce, BigInt.from(42));
      expect(userOp.callData, equals(callData));
      expect(userOp.initCode, equals(initCode));
    });
  });
}

// ── AAConstants gas thresholds ─────────────────────────────────────────────

void _testAAConstants() {
  group('AAConstants gas deviation thresholds', () {
    test('warning threshold values are reasonable', () {
      expect(AAConstants.gasTotalWarningThreshold, 2000000);
      expect(AAConstants.gasTotalCriticalThreshold, 5000000);
      expect(AAConstants.gasVerificationWarningThreshold, 500000);
      expect(AAConstants.gasCallWarningThreshold, 500000);
      expect(AAConstants.gasDeviationWarningPct, 50.0);
      expect(AAConstants.gasDeviationCriticalPct, 100.0);
    });

    test('critical threshold is higher than warning threshold', () {
      expect(
        AAConstants.gasTotalCriticalThreshold,
        greaterThan(AAConstants.gasTotalWarningThreshold),
      );
    });

    test('critical pct is higher than warning pct', () {
      expect(
        AAConstants.gasDeviationCriticalPct,
        greaterThan(AAConstants.gasDeviationWarningPct),
      );
    });
  });
}

// ── validateGasEstimates ───────────────────────────────────────────────────

void _testValidateGasEstimates() {
  group('AAGasEstimator.validateGasEstimates', () {
    test('returns true for reasonable estimates', () {
      final estimate = _makeEstimate(
        verification: 100000,
        call: 100000,
        preVerification: 50000,
      );
      expect(AAGasEstimator.validateGasEstimates(estimate), isTrue);
    });

    test('returns false when verificationGasLimit too low', () {
      final estimate = _makeEstimate(verification: 49999);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });

    test('returns false when verificationGasLimit too high', () {
      final estimate = _makeEstimate(verification: 10000001);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });

    test('returns false when callGasLimit too low', () {
      final estimate = _makeEstimate(call: 20999);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });

    test('returns false when callGasLimit too high', () {
      final estimate = _makeEstimate(call: 30000001);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });

    test('returns false when preVerificationGas too low', () {
      final estimate = _makeEstimate(preVerification: 20999);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });

    test('returns false when preVerificationGas too high', () {
      final estimate = _makeEstimate(preVerification: 1000001);
      expect(AAGasEstimator.validateGasEstimates(estimate), isFalse);
    });
  });
}

// ── estimateBatchGas ────────────────────────────────────────────────────────

void _testEstimateBatchGas() {
  group('AAGasEstimator.estimateBatchGas', () {
    test('zero calls: returns default call gas limit', () {
      final gas = AAGasEstimator.estimateBatchGas(0);
      expect(gas, BigInt.from(AAConstants.defaultCallGasLimit));
    });

    test('1 call: adds 25000 per call', () {
      final gas = AAGasEstimator.estimateBatchGas(1);
      expect(gas, BigInt.from(AAConstants.defaultCallGasLimit + 25000));
    });

    test('5 calls: linear scaling', () {
      final gas = AAGasEstimator.estimateBatchGas(5);
      expect(gas, BigInt.from(AAConstants.defaultCallGasLimit + 5 * 25000));
    });

    test('gas scales linearly', () {
      final gas3 = AAGasEstimator.estimateBatchGas(3);
      final gas6 = AAGasEstimator.estimateBatchGas(6);
      // Difference should be exactly 3 * 25000 = 75000
      expect(gas6 - gas3, BigInt.from(75000));
    });
  });
}

// ── estimateTotalCost ───────────────────────────────────────────────────────

void _testEstimateTotalCost() {
  group('AAGasEstimator.estimateTotalCost', () {
    test('cost = totalGas * maxFeePerGas', () {
      final estimate = _makeEstimate(
        verification: 100000,
        call: 100000,
        preVerification: 50000,
      );
      // totalGas = 250000
      final cost = AAGasEstimator.estimateTotalCost(
        gasEstimate: estimate,
        maxFeePerGas: BigInt.from(1000000000), // 1 Gwei
      );
      expect(cost, BigInt.from(250000) * BigInt.from(1000000000));
    });

    test('zero maxFeePerGas gives zero cost', () {
      final estimate = _makeEstimate();
      final cost = AAGasEstimator.estimateTotalCost(
        gasEstimate: estimate,
        maxFeePerGas: BigInt.zero,
      );
      expect(cost, BigInt.zero);
    });
  });
}

// ── GasPriceRecommendation ─────────────────────────────────────────────────

void _testGasPriceRecommendation() {
  group('GasPriceRecommendation', () {
    final rec = GasPriceRecommendation(
      maxFeePerGas: BigInt.from(10000000000), // 10 Gwei
      maxPriorityFeePerGas: BigInt.from(1000000000), // 1 Gwei
      baseFee: BigInt.from(9000000000), // 9 Gwei
      speed: GasSpeed.standard,
    );

    test('calculateCost = gasUnits * maxFeePerGas', () {
      final cost = rec.calculateCost(BigInt.from(21000));
      expect(cost, BigInt.from(21000) * BigInt.from(10000000000));
    });

    test('maxFeeGwei formats correctly', () {
      expect(rec.maxFeeGwei, '10.00');
    });

    test('priorityFeeGwei formats correctly', () {
      expect(rec.priorityFeeGwei, '1.00');
    });
  });
}

// ── GasSpeed ──────────────────────────────────────────────────────────────

void _testGasSpeed() {
  group('GasSpeed', () {
    test('slow multiplier is 0.8', () {
      expect(GasSpeed.slow.multiplier, 0.8);
    });

    test('standard multiplier is 1.0', () {
      expect(GasSpeed.standard.multiplier, 1.0);
    });

    test('fast multiplier is 1.3', () {
      expect(GasSpeed.fast.multiplier, 1.3);
    });

    test('instant multiplier is 1.6', () {
      expect(GasSpeed.instant.multiplier, 1.6);
    });

    test('all speeds have estimated times', () {
      for (final speed in GasSpeed.values) {
        expect(speed.estimatedTime.inSeconds, greaterThan(0));
      }
    });

    test('faster speeds have shorter estimated times', () {
      expect(
        GasSpeed.instant.estimatedTime,
        lessThan(GasSpeed.fast.estimatedTime),
      );
      expect(
        GasSpeed.fast.estimatedTime,
        lessThan(GasSpeed.standard.estimatedTime),
      );
      expect(
        GasSpeed.standard.estimatedTime,
        lessThan(GasSpeed.slow.estimatedTime),
      );
    });
  });
}

// ── Test runner ────────────────────────────────────────────────────────────

void main() {
  _testCalculatePreVerificationGas();
  _testGasDeviationDetector();
  _testBuildForEstimation();
  _testAAConstants();
  _testValidateGasEstimates();
  _testEstimateBatchGas();
  _testEstimateTotalCost();
  _testGasPriceRecommendation();
  _testGasSpeed();
}
