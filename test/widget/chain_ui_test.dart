// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/utils/all_chain.dart';

// Alias for easier usage in tests
Map<String, dynamic> get all_chain => allChainUrlMap;

void main() {
  group('Chain Display Data Tests', () {
    test('all chains should have icon URLs', () {
      for (final entry in all_chain.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        final icon = baseInfo['icon'] as String?;

        expect(
          icon != null && icon.isNotEmpty,
          true,
          reason: '${entry.key} should have an icon URL',
        );
      }
    });

    test('all chains should have display names', () {
      for (final entry in all_chain.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        final name = baseInfo['name'] as String?;
        final miniName = baseInfo['miniName'] as String?;

        expect(name != null && name.isNotEmpty, true,
            reason: '${entry.key} should have a display name');
        expect(miniName != null && miniName.isNotEmpty, true,
            reason: '${entry.key} should have a mini name/symbol');
      }
    });

    test('new batch 1 chains should have proper display info', () {
      final batch1Chains = {
        'XLM': {'name': 'Stellar', 'miniName': 'XLM'},
        'VET': {'name': 'VeChain', 'miniName': 'VET'},
        'ONE': {'name': 'Harmony', 'miniName': 'ONE'},
        'IOTX': {'name': 'IoTeX', 'miniName': 'IOTX'},
      };

      for (final entry in batch1Chains.entries) {
        final config = all_chain[entry.key] as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;

        expect(baseInfo['name'], entry.value['name']);
        expect(baseInfo['miniName'], entry.value['miniName']);
      }
    });

    test('new batch 2 chains should have proper display info', () {
      final batch2Chains = {
        'NEAR': {'name': 'NEAR Protocol', 'miniName': 'NEAR'},
        'ZIL': {'name': 'Zilliqa', 'miniName': 'ZIL'},
        'THETA': {'name': 'Theta Network', 'miniName': 'THETA'},
      };

      for (final entry in batch2Chains.entries) {
        final config = all_chain[entry.key] as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;

        expect(baseInfo['name'], entry.value['name']);
        expect(baseInfo['miniName'], entry.value['miniName']);
      }
    });

    test('new batch 3 chains should have proper display info', () {
      final batch3Chains = {
        'ADA': {'name': 'Cardano', 'miniName': 'ADA'},
        'EGLD': {'name': 'MultiversX', 'miniName': 'EGLD'},
      };

      for (final entry in batch3Chains.entries) {
        final config = all_chain[entry.key] as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;

        expect(baseInfo['name'], entry.value['name']);
        expect(baseInfo['miniName'], entry.value['miniName']);
      }
    });
  });

  group('Balance Formatting Tests', () {
    test('should format balance with correct decimals for ETH', () {
      final balance = BigInt.parse('1500000000000000000'); // 1.5 ETH
      const decimals = 18;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format balance with correct decimals for BTC', () {
      final balance = BigInt.parse('150000000'); // 1.5 BTC
      const decimals = 8;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format balance with correct decimals for XLM', () {
      final balance = BigInt.parse('15000000'); // 1.5 XLM
      const decimals = 7;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format balance with correct decimals for ADA', () {
      final balance = BigInt.parse('1500000'); // 1.5 ADA
      const decimals = 6;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format balance with correct decimals for NEAR', () {
      final balance = BigInt.parse('1500000000000000000000000'); // 1.5 NEAR
      const decimals = 24;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format balance with correct decimals for ZIL', () {
      final balance = BigInt.parse('1500000000000'); // 1.5 ZIL
      const decimals = 12;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '1.5');
    });

    test('should format zero balance correctly', () {
      final balance = BigInt.zero;
      const decimals = 18;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '0');
    });

    test('should format small balance correctly', () {
      final balance = BigInt.parse('1000000000000'); // 0.000001 ETH
      const decimals = 18;

      final formatted = _formatBalance(balance, decimals);
      expect(formatted, '0.000001');
    });
  });

  group('Short Address Display Tests', () {
    test('should shorten Ethereum address correctly', () {
      const address = '0x1234567890abcdef1234567890abcdef12345678';
      final shortened = _shortenAddress(address);
      expect(shortened, '0x1234...5678');
    });

    test('should shorten Stellar address correctly', () {
      const address = 'GCEZWKCA5VLDNRLN3RPRJMRZOX3Z6G5CHCGSNFHEYVXM3XOJMDS674JZ';
      final shortened = _shortenAddress(address);
      expect(shortened, 'GCEZWK...74JZ');
    });

    test('should shorten Cardano address correctly', () {
      const address = 'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp';
      final shortened = _shortenAddress(address);
      expect(shortened, 'addr1q...tjqp');
    });

    test('should shorten MultiversX address correctly', () {
      const address = 'erd1qqqqqqqqqqqqqpgqhe8t5jewej70zupmh44jurgn29psua5l2jps3ntjj3';
      final shortened = _shortenAddress(address);
      expect(shortened, 'erd1qq...tjj3');
    });

    test('should not shorten short address', () {
      const address = '0x123456';
      final shortened = _shortenAddress(address);
      expect(shortened, address);
    });
  });

  group('Chain Icon URL Tests', () {
    test('all new chains should have valid icon URLs', () {
      final newChains = ['XLM', 'VET', 'ONE', 'IOTX', 'NEAR', 'ZIL', 'THETA', 'ADA', 'EGLD'];

      for (final chain in newChains) {
        final config = all_chain[chain] as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        final icon = baseInfo['icon'] as String;

        expect(icon.startsWith('http'), true,
            reason: '$chain icon URL should start with http');
        expect(icon.contains('.png') || icon.contains('.svg') || icon.contains('.jpg'), true,
            reason: '$chain icon should be an image file');
      }
    });
  });

  group('Price Display Tests', () {
    test('should format USD value correctly', () {
      final priceUsd = 1234.56789;
      final formatted = _formatUsd(priceUsd);
      expect(formatted, '\$1,234.57');
    });

    test('should format small USD value correctly', () {
      final priceUsd = 0.000123;
      final formatted = _formatUsd(priceUsd);
      expect(formatted, '\$0.00');
    });

    test('should format large USD value correctly', () {
      final priceUsd = 1000000.50;
      final formatted = _formatUsd(priceUsd);
      expect(formatted, '\$1,000,000.50');
    });
  });

  group('Chain Selector Widget Tests', () {
    testWidgets('should display chain name and symbol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestChainListItem(
              name: 'Stellar',
              symbol: 'XLM',
              icon: 'https://example.com/xlm.png',
            ),
          ),
        ),
      );

      expect(find.text('Stellar'), findsOneWidget);
      expect(find.text('XLM'), findsOneWidget);
    });

    testWidgets('should display all new batch 1 chains', (tester) async {
      final batch1 = ['Stellar', 'VeChain', 'Harmony', 'IoTeX'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: batch1
                  .map((name) => _TestChainListItem(
                        name: name,
                        symbol: name.substring(0, 3).toUpperCase(),
                        icon: '',
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      for (final name in batch1) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('should display all new batch 2 chains', (tester) async {
      final batch2 = ['NEAR Protocol', 'Zilliqa', 'Theta Network'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: batch2
                  .map((name) => _TestChainListItem(
                        name: name,
                        symbol: name.split(' ')[0].toUpperCase(),
                        icon: '',
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      for (final name in batch2) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('should display all new batch 3 chains', (tester) async {
      final batch3 = ['Cardano', 'MultiversX'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: batch3
                  .map((name) => _TestChainListItem(
                        name: name,
                        symbol: name == 'Cardano' ? 'ADA' : 'EGLD',
                        icon: '',
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      for (final name in batch3) {
        expect(find.text(name), findsOneWidget);
      }
    });
  });

  group('Balance Card Widget Tests', () {
    testWidgets('should display formatted balance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBalanceCard(
              chainName: 'Stellar',
              symbol: 'XLM',
              balance: '100.5',
              usdValue: '\$50.25',
            ),
          ),
        ),
      );

      expect(find.text('100.5 XLM'), findsOneWidget);
      expect(find.text('\$50.25'), findsOneWidget);
    });

    testWidgets('should display zero balance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBalanceCard(
              chainName: 'Cardano',
              symbol: 'ADA',
              balance: '0',
              usdValue: '\$0.00',
            ),
          ),
        ),
      );

      expect(find.text('0 ADA'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
    });
  });
}

// Helper functions for testing

String _formatBalance(BigInt balance, int decimals) {
  if (balance == BigInt.zero) return '0';

  final divisor = BigInt.from(10).pow(decimals);
  final whole = balance ~/ divisor;
  final fraction = balance.remainder(divisor);

  if (fraction == BigInt.zero) {
    return whole.toString();
  }

  final fractionStr = fraction.toString().padLeft(decimals, '0');
  final trimmedFraction = fractionStr.replaceAll(RegExp(r'0+$'), '');

  if (trimmedFraction.isEmpty) {
    return whole.toString();
  }

  return '$whole.$trimmedFraction';
}

String _shortenAddress(String address) {
  if (address.length <= 10) return address;
  return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}

String _formatUsd(double value) {
  final formatted = value.toStringAsFixed(2);
  final parts = formatted.split('.');
  final intPart = parts[0];
  final decPart = parts[1];

  // Add thousand separators
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(intPart[i]);
  }

  return '\$$buffer.$decPart';
}

// Test widgets

class _TestChainListItem extends StatelessWidget {
  final String name;
  final String symbol;
  final String icon;

  const _TestChainListItem({
    required this.name,
    required this.symbol,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon.isNotEmpty
          ? const CircleAvatar(child: Icon(Icons.currency_bitcoin))
          : const CircleAvatar(child: Icon(Icons.currency_bitcoin)),
      title: Text(name),
      subtitle: Text(symbol),
    );
  }
}

class _TestBalanceCard extends StatelessWidget {
  final String chainName;
  final String symbol;
  final String balance;
  final String usdValue;

  const _TestBalanceCard({
    required this.chainName,
    required this.symbol,
    required this.balance,
    required this.usdValue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chainName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('$balance $symbol',
                style: Theme.of(context).textTheme.headlineSmall),
            Text(usdValue, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
