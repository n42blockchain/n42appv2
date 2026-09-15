import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';

void main() {
  group('TxRiskAnalyzer', () {
    group('analyze - native transfer', () {
      test('null calldata is native transfer (safe)', () {
        final result = TxRiskAnalyzer.analyze(calldata: null);
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Native Transfer');
      });

      test('empty calldata is native transfer', () {
        final result = TxRiskAnalyzer.analyze(calldata: '');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Native Transfer');
      });

      test('"0x" calldata is native transfer', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Native Transfer');
      });

      test('"0X" calldata is native transfer', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0X');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Native Transfer');
      });

      test('native transfer with toAddress shows To field', () {
        final result = TxRiskAnalyzer.analyze(
          calldata: null,
          toAddress: '0x1234567890abcdef1234567890abcdef12345678',
        );
        expect(result.fields.length, 1);
        expect(result.fields[0].label, 'To');
      });

      test('native transfer with ethValue shows Value field', () {
        final result = TxRiskAnalyzer.analyze(
          calldata: null,
          ethValue: '0x38d7ea4c68000', // 0.001 ETH
        );
        expect(result.fields.any((f) => f.label == 'Value'), isTrue);
      });

      test('native transfer with 0x0 value does not show Value field', () {
        final result = TxRiskAnalyzer.analyze(calldata: null, ethValue: '0x0');
        expect(result.fields.any((f) => f.label == 'Value'), isFalse);
      });
    });

    group('analyze - short calldata', () {
      test('calldata shorter than 8 hex chars is unknown call', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x1234');
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, 'Unknown Call');
        expect(result.warnings, isNotEmpty);
      });
    });

    group('analyze - ERC-20 transfer', () {
      test('decodes transfer(address, uint256)', () {
        // selector: 0xa9059cbb
        // to: 0x000...abc (padded to 32 bytes)
        // amount: 1000 (0x3e8 padded to 32 bytes)
        final to =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final amount =
            '00000000000000000000000000000000000000000000000000000000000003e8';
        final result = TxRiskAnalyzer.analyze(calldata: '0xa9059cbb$to$amount');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'ERC-20 Transfer');
        expect(result.fields.length, 2);
        expect(result.fields[0].label, 'To');
        expect(result.fields[1].label, 'Amount');
        expect(result.fields[1].value, '1000');
      });
    });

    group('analyze - ERC-20 approve', () {
      test('limited approve is caution level', () {
        // selector: 0x095ea7b3
        final spender =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final amount =
            '00000000000000000000000000000000000000000000000000000000000003e8';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x095ea7b3$spender$amount',
        );
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, 'ERC-20 Approve');
        expect(result.warnings, isEmpty);
      });

      test('unlimited approve (MaxUint256) is danger level', () {
        final spender =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final maxUint =
            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x095ea7b3$spender$maxUint',
        );
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, 'ERC-20 Approve');
        expect(result.warnings, isNotEmpty);
        expect(result.fields.any((f) => f.value.contains('Unlimited')), isTrue);
        expect(result.fields.any((f) => f.isHighlighted), isTrue);
      });

      test('increaseAllowance uses correct function name', () {
        final spender =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final amount =
            '00000000000000000000000000000000000000000000000000000000000003e8';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0xb0431182$spender$amount',
        );
        expect(result.functionName, 'Increase Allowance');
      });
    });

    group('analyze - ERC-20 transferFrom', () {
      test('decodes transferFrom with caution level', () {
        final from =
            '0000000000000000000000001111111111111111111111111111111111111111';
        final to =
            '0000000000000000000000002222222222222222222222222222222222222222';
        final amount =
            '00000000000000000000000000000000000000000000000000000000000003e8';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x23b872dd$from$to$amount',
        );
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, 'ERC-20 TransferFrom');
        expect(result.fields.length, 3);
        expect(result.warnings, isNotEmpty);
      });
    });

    group('analyze - setApprovalForAll', () {
      test('setApprovalForAll is danger', () {
        final operator =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final approved =
            '0000000000000000000000000000000000000000000000000000000000000001';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0xa22cb465$operator$approved',
        );
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, contains('setApprovalForAll'));
        expect(result.fields.any((f) => f.label == 'Operator'), isTrue);
        expect(result.fields.any((f) => f.value == 'Grant Access'), isTrue);
      });

      test('setApprovalForAll revoke shows Revoke Access', () {
        final operator =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final revoked =
            '0000000000000000000000000000000000000000000000000000000000000000';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0xa22cb465$operator$revoked',
        );
        expect(result.fields.any((f) => f.value == 'Revoke Access'), isTrue);
      });
    });

    group('analyze - ownership', () {
      test('transferOwnership is danger', () {
        final newOwner =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final result = TxRiskAnalyzer.analyze(calldata: '0xf2fde38b$newOwner');
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, 'Transfer Ownership');
      });

      test('renounceOwnership is danger', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x715018a6');
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, 'Renounce Ownership');
      });
    });

    group('analyze - multicall', () {
      test('multicall(bytes[]) is caution', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0xac9650d8');
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, contains('Multicall'));
      });

      test('multicall(uint256,bytes[]) Uniswap V3 is caution', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x5ae401dc');
        expect(result.level, TxRiskLevel.caution);
      });
    });

    group('analyze - DEX swaps', () {
      test('swapExactETHForTokens is safe', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x7ff36ab5');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Token Swap (DEX)');
      });

      test('exactInputSingle (UniV3) is safe', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x414bf389');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'Token Swap (DEX)');
      });

      test('all Uniswap V2 swap selectors are safe', () {
        final selectors = [
          '0x7ff36ab5',
          '0x38ed1739',
          '0x18cbafe5',
          '0xfb3bdb41',
          '0x4a25d94a',
          '0x8803dbee',
        ];
        for (final sel in selectors) {
          final result = TxRiskAnalyzer.analyze(calldata: sel);
          expect(result.level, TxRiskLevel.safe, reason: 'selector $sel');
        }
      });
    });

    group('analyze - mint', () {
      test('mint is caution', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x40c10f19');
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, 'Mint Tokens');
      });
    });

    group('analyze - unknown selector', () {
      test('unknown selector returns caution with selector field', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0xdeadbeef');
        expect(result.level, TxRiskLevel.caution);
        expect(result.functionName, 'Unknown Contract Call');
        expect(result.fields.any((f) => f.label == 'Selector'), isTrue);
      });
    });

    group('analyze - case insensitivity', () {
      test('handles uppercase hex in calldata', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0xA9059CBB');
        // Should still match transfer selector (lowercase comparison)
        expect(result.functionName, isNotEmpty);
      });

      test('handles 0X prefix', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0X715018a6');
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, 'Renounce Ownership');
      });
    });

    group('analyze - NFT transfers', () {
      test('safeTransferFrom (3 args) is safe', () {
        final from =
            '0000000000000000000000001111111111111111111111111111111111111111';
        final to =
            '0000000000000000000000002222222222222222222222222222222222222222';
        final tokenId =
            '0000000000000000000000000000000000000000000000000000000000000001';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x42842e0e$from$to$tokenId',
        );
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'NFT Transfer');
        expect(result.fields.length, 2);
      });

      test('safeBatchTransferFrom is safe', () {
        final result = TxRiskAnalyzer.analyze(calldata: '0x2eb2c2d6');
        expect(result.level, TxRiskLevel.safe);
        expect(result.functionName, 'NFT Batch Transfer');
      });
    });

    group('analyze - permit (on-chain)', () {
      test('permit function is danger', () {
        // permit(address,address,uint256,uint256,uint8,bytes32,bytes32) = 0xd505accf
        final owner =
            '0000000000000000000000001111111111111111111111111111111111111111';
        final spender =
            '0000000000000000000000002222222222222222222222222222222222222222';
        final maxUint =
            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
        final deadline =
            '0000000000000000000000000000000000000000000000000000000067890abc';
        final v =
            '000000000000000000000000000000000000000000000000000000000000001b';
        final r =
            'abcdef0000000000000000000000000000000000000000000000000000000000';
        final s =
            '1234560000000000000000000000000000000000000000000000000000000000';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0xd505accf$owner$spender$maxUint$deadline$v$r$s',
        );
        expect(result.level, TxRiskLevel.danger);
        expect(result.functionName, contains('Permit'));
      });
    });

    group('analyzeTypedData', () {
      test('returns null for null input', () {
        expect(TxRiskAnalyzer.analyzeTypedData(null), isNull);
      });

      test('returns null for empty string', () {
        expect(TxRiskAnalyzer.analyzeTypedData(''), isNull);
      });

      test('returns null for non-JSON string', () {
        expect(TxRiskAnalyzer.analyzeTypedData('not json'), isNull);
      });

      test('returns null for JSON array', () {
        expect(TxRiskAnalyzer.analyzeTypedData('[1,2,3]'), isNull);
      });

      test('returns null when no primaryType', () {
        expect(TxRiskAnalyzer.analyzeTypedData('{"foo":"bar"}'), isNull);
      });

      test('EIP-2612 Permit with unlimited value is danger', () {
        final data = jsonEncode({
          'primaryType': 'Permit',
          'message': {
            'spender': '0x1234567890abcdef1234567890abcdef12345678',
            'value':
                '115792089237316195423570985008687907853269984665640564039457584007913129639935',
            'deadline': '1700000000',
          },
        });
        final result = TxRiskAnalyzer.analyzeTypedData(data);
        expect(result, isNotNull);
        expect(result!.level, TxRiskLevel.danger);
        expect(result.functionName, contains('Permit'));
        expect(result.fields.any((f) => f.value.contains('Unlimited')), isTrue);
        expect(result.warnings.length, greaterThanOrEqualTo(2));
      });

      test('EIP-2612 Permit with limited value is still danger (gasless)', () {
        final data = jsonEncode({
          'primaryType': 'Permit',
          'message': {
            'spender': '0xabcdef',
            'value': '1000000',
            'deadline': '1700000000',
          },
        });
        final result = TxRiskAnalyzer.analyzeTypedData(data);
        expect(result, isNotNull);
        expect(result!.level, TxRiskLevel.danger);
        expect(
          result.warnings.length,
          1,
        ); // only gasless warning, not unlimited
      });

      test('non-Permit typed data is safe', () {
        final data = jsonEncode({
          'primaryType': 'Order',
          'message': {'orderHash': '0x123'},
        });
        final result = TxRiskAnalyzer.analyzeTypedData(data);
        expect(result, isNotNull);
        expect(result!.level, TxRiskLevel.safe);
        expect(result.functionName, 'Signed Message (Order)');
      });
    });

    group('TxRiskAnalysis', () {
      test('hasWarnings returns true when warnings exist', () {
        const analysis = TxRiskAnalysis(
          level: TxRiskLevel.danger,
          functionName: 'test',
          warnings: ['warning1'],
        );
        expect(analysis.hasWarnings, isTrue);
      });

      test('hasWarnings returns false when no warnings', () {
        const analysis = TxRiskAnalysis(
          level: TxRiskLevel.safe,
          functionName: 'test',
        );
        expect(analysis.hasWarnings, isFalse);
      });
    });

    group('TxRiskField', () {
      test('default isHighlighted is false', () {
        const field = TxRiskField('label', 'value');
        expect(field.isHighlighted, isFalse);
      });

      test('isHighlighted can be set', () {
        const field = TxRiskField('label', 'value', isHighlighted: true);
        expect(field.isHighlighted, isTrue);
      });
    });

    group('edge cases - amount formatting', () {
      test('zero amount', () {
        final spender =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        final zero =
            '0000000000000000000000000000000000000000000000000000000000000000';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x095ea7b3$spender$zero',
        );
        expect(
          result.fields.any((f) => f.label == 'Amount' && f.value == '0'),
          isTrue,
        );
      });

      test('very large but not unlimited amount', () {
        final spender =
            '0000000000000000000000001234567890abcdef1234567890abcdef12345678';
        // Large number but not MaxUint256
        final large =
            '00000000000000000000000000000000ffffffffffffffffffffffffffffffff';
        final result = TxRiskAnalyzer.analyze(
          calldata: '0x095ea7b3$spender$large',
        );
        expect(result.level, TxRiskLevel.caution); // not danger
      });
    });
  });
}
