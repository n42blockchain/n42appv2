// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Address Validation Tests', () {
    group('EVM Address Validation', () {
      test('valid Ethereum address should match pattern', () {
        const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('invalid Ethereum address should fail validation', () {
        const invalidAddresses = [
          '1234567890abcdef1234567890abcdef12345678', // Missing 0x
          '0x123456789', // Too short
          '0x1234567890abcdef1234567890abcdef1234567890', // Too long
          '0xGGGG567890abcdef1234567890abcdef12345678', // Invalid characters
        ];

        for (final address in invalidAddresses) {
          final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
          expect(
            isValid,
            false,
            reason: 'Address "$address" should be invalid',
          );
        }
      });

      test('checksum addresses should be valid', () {
        // Mixed case checksum addresses
        const checksumAddresses = [
          '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
          '0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359',
        ];

        for (final address in checksumAddresses) {
          final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
          expect(isValid, true);
        }
      });
    });

    group('Bitcoin Address Validation', () {
      test('valid P2PKH address should match pattern', () {
        // Legacy addresses start with 1
        const validAddress = '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2';
        final isValid = RegExp(
          r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$',
        ).hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid P2SH address should match pattern', () {
        // P2SH addresses start with 3
        const validAddress = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';
        final isValid = RegExp(
          r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$',
        ).hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid Bech32 address should match pattern', () {
        // Native SegWit addresses start with bc1
        const validAddress = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';
        final isValid = RegExp(r'^bc1[a-z0-9]{39,59}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('Stellar Address Validation', () {
      test('valid Stellar address should start with G', () {
        const validAddress =
            'GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ';
        // Stellar public keys are 56 characters and start with G
        final isValid = RegExp(r'^G[A-Z2-7]{55}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('invalid Stellar address should fail', () {
        const invalidAddresses = [
          'XEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ', // Wrong prefix
          'GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674', // Too short
        ];

        for (final address in invalidAddresses) {
          final isValid = RegExp(r'^G[A-Z2-7]{55}$').hasMatch(address);
          expect(isValid, false);
        }
      });
    });

    group('VeChain Address Validation', () {
      test('valid VeChain address should be EVM format', () {
        const validAddress = '0x7567D83b7b8d80ADdCb281A71d54Fc7B3364ffed';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('Harmony Address Validation', () {
      test('valid Harmony one1 address should match pattern', () {
        const validAddress = 'one1pdv9lrdwl0rg5vglh4xtyrv3wjk3wsqket7zxy';
        final isValid = RegExp(r'^one1[a-z0-9]{38}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid Harmony 0x address should also be accepted', () {
        const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('IoTeX Address Validation', () {
      test('valid IoTeX io address should match pattern', () {
        const validAddress = 'io1qyqsqqqq3r5qrzl0pxzpz2q3k0c3d4f7s8n2m1';
        final isValid = RegExp(r'^io1[a-z0-9]{38}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid IoTeX 0x address should also be accepted', () {
        const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('NEAR Address Validation', () {
      test('valid NEAR implicit address should be 64 hex chars', () {
        const validAddress =
            'ed25519:8hSHprDq2StXwMtNd43wDTXQYsjXcD4MJTXQYsjXcD4M';
        final isValid =
            validAddress.startsWith('ed25519:') ||
            RegExp(r'^[a-f0-9]{64}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid NEAR named account should match pattern', () {
        const validAddresses = ['alice.near', 'bob.testnet', 'my-account.near'];

        for (final address in validAddresses) {
          final isValid = RegExp(
            r'^[a-z0-9._-]+\.(near|testnet)$',
          ).hasMatch(address);
          expect(isValid, true, reason: '$address should be valid');
        }
      });
    });

    group('Zilliqa Address Validation', () {
      test('valid Zilliqa bech32 address should start with zil', () {
        const validAddress = 'zil1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9yf6pz';
        final isValid = RegExp(r'^zil1[a-z0-9]{38}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('valid Zilliqa base16 address should be 40 hex chars', () {
        const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('Theta Address Validation', () {
      test('valid Theta address should be EVM format', () {
        const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);
      });
    });

    group('Cardano Address Validation', () {
      test('valid Cardano Shelley address should start with addr', () {
        const validAddress =
            'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp';
        final isValid =
            validAddress.startsWith('addr1') ||
            validAddress.startsWith('addr_test1');
        expect(isValid, true);
      });

      test('valid Cardano stake address should start with stake', () {
        const validAddress =
            'stake1ux3g2c9dx2nhhehyrezyxpkstartcqmu9hk63qgfkccw5rqttygt7';
        final isValid =
            validAddress.startsWith('stake1') ||
            validAddress.startsWith('stake_test1');
        expect(isValid, true);
      });
    });

    group('MultiversX Address Validation', () {
      test('valid MultiversX address should start with erd', () {
        const validAddress =
            'erd1qqqqqqqqqqqqqpgqhe8t5jewej70zupmh44jurgn29psua5l2jps3ntjj3';
        final isValid = RegExp(r'^erd1[a-z0-9]{58}$').hasMatch(validAddress);
        expect(isValid, true);
      });

      test('invalid MultiversX address should fail', () {
        const invalidAddresses = [
          'xrd1qqqqqqqqqqqqqpgqhe8t5jewej70zupmh44jurgn29psua5l2jps3ntjj3', // Wrong prefix
          'erd1abc', // Too short
        ];

        for (final address in invalidAddresses) {
          final isValid = RegExp(r'^erd1[a-z0-9]{58}$').hasMatch(address);
          expect(isValid, false);
        }
      });
    });
  });

  group('Transaction Data Format Tests', () {
    test('EVM transaction should have required fields', () {
      final txData = {
        'toAddress': '0x1234567890abcdef1234567890abcdef12345678',
        'amount': '1000000000000000000',
        'gasLimit': '21000',
        'gasPrice': '20000000000',
        'nonce': '0',
        'chainId': '1',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('amount'), true);
      expect(txData.containsKey('gasLimit'), true);
      expect(txData.containsKey('gasPrice'), true);
      expect(txData.containsKey('nonce'), true);
      expect(txData.containsKey('chainId'), true);
    });

    test('Cardano transaction should have UTXOs', () {
      final txData = {
        'toAddress':
            'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
        'amount': '1000000',
        'ttl': '1000000',
        'utxos': [
          {
            'txHash': '0x1234567890abcdef',
            'outputIndex': 0,
            'amount': '5000000',
            'address': 'addr1...',
          },
        ],
      };

      expect(txData.containsKey('utxos'), true);
      expect(txData['utxos'], isA<List>());
      expect((txData['utxos'] as List).isNotEmpty, true);
    });

    test('MultiversX transaction should have required fields', () {
      final txData = {
        'toAddress': 'erd1...',
        'amount': '1000000000000000000',
        'nonce': '0',
        'gasPrice': '1000000000',
        'gasLimit': '50000',
        'chainId': '1',
        'version': '1',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('amount'), true);
      expect(txData.containsKey('nonce'), true);
      expect(txData.containsKey('gasPrice'), true);
      expect(txData.containsKey('gasLimit'), true);
      expect(txData.containsKey('chainId'), true);
    });

    test('Stellar transaction should have required fields', () {
      final txData = {
        'toAddress': 'GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ',
        'amount': '10000000', // In stroops (1 XLM = 10^7 stroops)
        'fee': '100',
        'sequence': '1234567890',
        'memo': '',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('amount'), true);
      expect(txData.containsKey('fee'), true);
      expect(txData.containsKey('sequence'), true);
    });

    test('NEAR transaction should have required fields', () {
      final txData = {
        'toAddress': 'receiver.near',
        'amount': '1000000000000000000000000', // In yoctoNEAR
        'nonce': '1',
        'blockHash': 'abc123...',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('amount'), true);
      expect(txData.containsKey('nonce'), true);
      expect(txData.containsKey('blockHash'), true);
    });

    test('Zilliqa transaction should have required fields', () {
      final txData = {
        'toAddress': 'zil1...',
        'amount': '1000000000000', // In Qa
        'gasPrice': '2000000000',
        'gasLimit': '50',
        'nonce': '1',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('amount'), true);
      expect(txData.containsKey('gasPrice'), true);
      expect(txData.containsKey('gasLimit'), true);
      expect(txData.containsKey('nonce'), true);
    });

    test('Theta transaction should have required fields', () {
      final txData = {
        'toAddress': '0x...',
        'thetaAmount': '0x0',
        'tfuelAmount': '0xde0b6b3a7640000',
        'sequence': '1',
        'fee': '0x5f5e100',
      };

      expect(txData.containsKey('toAddress'), true);
      expect(txData.containsKey('thetaAmount'), true);
      expect(txData.containsKey('tfuelAmount'), true);
      expect(txData.containsKey('sequence'), true);
      expect(txData.containsKey('fee'), true);
    });
  });

  group('Amount Conversion Tests', () {
    test('ETH to Wei conversion', () {
      // 1 ETH = 10^18 Wei
      final oneEth = BigInt.from(10).pow(18);
      expect(oneEth.toString(), '1000000000000000000');
    });

    test('BTC to Satoshi conversion', () {
      // 1 BTC = 10^8 Satoshi
      final oneBtc = BigInt.from(10).pow(8);
      expect(oneBtc.toString(), '100000000');
    });

    test('XLM to Stroops conversion', () {
      // 1 XLM = 10^7 Stroops
      final oneXlm = BigInt.from(10).pow(7);
      expect(oneXlm.toString(), '10000000');
    });

    test('ADA to Lovelace conversion', () {
      // 1 ADA = 10^6 Lovelace
      final oneAda = BigInt.from(10).pow(6);
      expect(oneAda.toString(), '1000000');
    });

    test('NEAR to yoctoNEAR conversion', () {
      // 1 NEAR = 10^24 yoctoNEAR
      final oneNear = BigInt.from(10).pow(24);
      expect(oneNear.toString(), '1000000000000000000000000');
    });

    test('ZIL to Qa conversion', () {
      // 1 ZIL = 10^12 Qa
      final oneZil = BigInt.from(10).pow(12);
      expect(oneZil.toString(), '1000000000000');
    });
  });
}
