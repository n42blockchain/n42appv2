// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';

void main() {
  group('GasEstimateModel Tests', () {
    group('GasSpeed enum', () {
      test('should have correct values', () {
        expect(GasSpeed.values.length, 3);
        expect(GasSpeed.values.contains(GasSpeed.slow), true);
        expect(GasSpeed.values.contains(GasSpeed.standard), true);
        expect(GasSpeed.values.contains(GasSpeed.fast), true);
      });
    });

    group('EIP1559GasFee', () {
      test('should create from JSON correctly', () {
        final json = {
          'maxPriorityFeePerGas': '2000000000',
          'maxFeePerGas': '25000000000',
          'baseFee': '15000000000',
          'estimatedSeconds': 30,
        };

        final fee = EIP1559GasFee.fromJson(json);

        expect(fee.maxPriorityFeePerGas, BigInt.parse('2000000000'));
        expect(fee.maxFeePerGas, BigInt.parse('25000000000'));
        expect(fee.baseFee, BigInt.parse('15000000000'));
        expect(fee.estimatedSeconds, 30);
      });

      test('should convert to JSON correctly', () {
        final fee = EIP1559GasFee(
          maxPriorityFeePerGas: BigInt.parse('2000000000'),
          maxFeePerGas: BigInt.parse('25000000000'),
          baseFee: BigInt.parse('15000000000'),
          estimatedSeconds: 30,
        );

        final json = fee.toJson();

        expect(json['maxPriorityFeePerGas'], '2000000000');
        expect(json['maxFeePerGas'], '25000000000');
        expect(json['baseFee'], '15000000000');
        expect(json['estimatedSeconds'], 30);
      });

      test('should calculate total fee correctly', () {
        final fee = EIP1559GasFee(
          maxPriorityFeePerGas: BigInt.parse('2000000000'),
          maxFeePerGas: BigInt.parse('25000000000'),
          baseFee: BigInt.parse('15000000000'),
          estimatedSeconds: 30,
        );

        final gasLimit = BigInt.from(21000);
        final totalFee = fee.totalFee(gasLimit);

        // 25 Gwei * 21000 = 525000 Gwei
        expect(totalFee, BigInt.parse('525000000000000'));
      });
    });

    group('LegacyGasFee', () {
      test('should create from JSON correctly', () {
        final json = {
          'gasPrice': '20000000000',
          'estimatedSeconds': 60,
        };

        final fee = LegacyGasFee.fromJson(json);

        expect(fee.gasPrice, BigInt.parse('20000000000'));
        expect(fee.estimatedSeconds, 60);
      });

      test('should convert to JSON correctly', () {
        final fee = LegacyGasFee(
          gasPrice: BigInt.parse('20000000000'),
          estimatedSeconds: 60,
        );

        final json = fee.toJson();

        expect(json['gasPrice'], '20000000000');
        expect(json['estimatedSeconds'], 60);
      });

      test('should calculate total fee correctly', () {
        final fee = LegacyGasFee(
          gasPrice: BigInt.parse('20000000000'), // 20 Gwei
          estimatedSeconds: 60,
        );

        final gasLimit = BigInt.from(21000);
        final totalFee = fee.totalFee(gasLimit);

        // 20 Gwei * 21000 = 420000 Gwei = 0.00042 ETH
        expect(totalFee, BigInt.parse('420000000000000'));
      });
    });

    group('GasOption', () {
      test('should create EIP1559 option', () {
        final option = GasOption.eip1559(
          maxPriorityFeePerGas: BigInt.parse('2000000000'),
          maxFeePerGas: BigInt.parse('25000000000'),
          baseFee: BigInt.parse('15000000000'),
          estimatedSeconds: 30,
        );

        expect(option.isEIP1559, true);
        expect(option.estimatedSeconds, 30);
      });

      test('should create Legacy option', () {
        final option = GasOption.legacy(
          gasPrice: BigInt.parse('20000000000'),
          estimatedSeconds: 60,
        );

        expect(option.isEIP1559, false);
        expect(option.estimatedSeconds, 60);
      });
    });
  });

  group('Gas Calculation Tests', () {
    test('should calculate transaction cost correctly', () {
      final gasPrice = BigInt.parse('20000000000'); // 20 Gwei
      const gasLimit = 21000;

      final costWei = gasPrice * BigInt.from(gasLimit);

      // 20 Gwei * 21000 = 420000 Gwei = 0.00042 ETH
      expect(costWei.toString(), '420000000000000');
    });

    test('should convert gwei to wei correctly', () {
      const gweiValue = 20.0;
      final weiValue = BigInt.from((gweiValue * 1e9).toInt());
      expect(weiValue.toString(), '20000000000');
    });

    test('should calculate EIP-1559 max cost correctly', () {
      final maxFeePerGas = BigInt.parse('30000000000'); // 30 Gwei
      const gasLimit = 21000;

      final maxCostWei = maxFeePerGas * BigInt.from(gasLimit);

      // 30 Gwei * 21000 = 630000 Gwei
      expect(maxCostWei.toString(), '630000000000000');
    });

    test('should convert wei to gwei', () {
      final weiValue = BigInt.parse('20000000000'); // 20 Gwei in Wei
      final gweiValue = weiValue / BigInt.from(1000000000);
      expect(gweiValue.toInt(), 20);
    });

    test('should convert wei to eth', () {
      final weiValue = BigInt.parse('1000000000000000000'); // 1 ETH
      final ethValue = weiValue / BigInt.from(10).pow(18);
      expect(ethValue.toInt(), 1);
    });
  });
}
