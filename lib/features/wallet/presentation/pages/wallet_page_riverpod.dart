// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

/// Example: Wallet Page using Riverpod
///
/// This demonstrates how to use the new Riverpod providers
/// with proper loading/error handling.
class WalletPageRiverpod extends ConsumerWidget {
  const WalletPageRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(walletListProvider),
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) => _buildContent(context, ref, wallets),
        loading: () => const _WalletLoadingSkeleton(),
        error: (error, stack) => _WalletErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(walletListProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<WalletInfoData> wallets,
  ) {
    if (wallets.isEmpty) {
      return const _EmptyWalletWidget();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(walletListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Balance Card
          SliverToBoxAdapter(
            child: _BalanceCard(ref: ref),
          ),

          // Coin List
          SliverToBoxAdapter(
            child: _CoinListSection(ref: ref),
          ),
        ],
      ),
    );
  }
}

/// Balance Card Widget
class _BalanceCard extends StatelessWidget {
  final WidgetRef ref;

  const _BalanceCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(walletBalanceProvider);
    final currentWallet = ref.watch(currentWalletProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Name
            Text(
              currentWallet?.name ?? 'No Wallet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Balance
            balanceAsync.when(
              data: (balance) => Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Text(
                '\$0.00',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coin List Section
class _CoinListSection extends StatelessWidget {
  final WidgetRef ref;

  const _CoinListSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final coinsAsync = ref.watch(coinListProvider);

    return coinsAsync.when(
      data: (coins) {
        if (coins.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No coins yet'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coins.length,
          itemBuilder: (context, index) {
            final coin = coins[index];
            return _CoinListItem(coin: coin);
          },
        );
      },
      loading: () => const _CoinListSkeleton(),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load coins: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(coinListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coin List Item
class _CoinListItem extends StatelessWidget {
  final CoinBalanceData coin;

  const _CoinListItem({required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChange24h >= 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(coin.iconUrl),
      ),
      title: Text(coin.symbol),
      subtitle: Text(coin.name),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${coin.balance.toStringAsFixed(4)} ${coin.symbol}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${coin.balanceUsd.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading Skeleton
class _WalletLoadingSkeleton extends StatelessWidget {
  const _WalletLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading wallet...'),
        ],
      ),
    );
  }
}

/// Coin List Skeleton
class _CoinListSkeleton extends StatelessWidget {
  const _CoinListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
          ),
          title: Container(
            height: 16,
            width: 80,
            color: Colors.grey[300],
          ),
          subtitle: Container(
            height: 12,
            width: 120,
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}

/// Error Widget
class _WalletErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _WalletErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty Wallet Widget
class _EmptyWalletWidget extends StatelessWidget {
  const _EmptyWalletWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Wallet Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create or import a wallet to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create wallet
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Wallet'),
          ),
        ],
      ),
    );
  }
}

