import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/data/wallet_activity_repository.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/generated/l10n.dart';

class WalletActivityPage extends ConsumerWidget {
  const WalletActivityPage({super.key, this.repository});
  final WalletActivityRepository? repository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.uuid ?? '';
    return _ActivityView(
      key: ValueKey(userId),
      userId: userId,
      repository: repository,
    );
  }
}

class _ActivityView extends StatefulWidget {
  const _ActivityView({super.key, required this.userId, this.repository});
  final String userId;
  final WalletActivityRepository? repository;

  @override
  State<_ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<_ActivityView> {
  late final _repository = widget.repository ?? WalletActivityRepository();
  final _items = <WalletActivity>[];
  bool _loading = false;
  bool _failed = false;
  bool _hasMore = true;
  int? _status;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
      if (reset) {
        _items.clear();
        _hasMore = true;
      }
    });
    try {
      final items = await _repository.load(
        userId: widget.userId,
        offset: _items.length,
        status: _status,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _items.addAll(items);
        _hasMore = items.length == 50;
      });
    } catch (_) {
      if (mounted && generation == _generation) setState(() => _failed = true);
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.g_coin_key_1)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.g_audit_activity_local,
                style: AppTypography.caption,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final item in <(int?, String)>[
                    (null, s.g_audit_all),
                    (0, s.g_key_t_2),
                    (1, s.g_key_t_1),
                    (2, s.g_key_t_3),
                  ])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(item.$2),
                        selected: _status == item.$1,
                        onSelected: (_) {
                          _status = item.$1;
                          _load(reset: true);
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(reset: true),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      if (_loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_failed) {
                        return Column(
                          children: [
                            Text(s.g_audit_activity_error),
                            TextButton(
                              onPressed: () => _load(),
                              child: Text(s.g_key_retry),
                            ),
                          ],
                        );
                      }
                      if (_items.isEmpty) {
                        return Center(child: Text(s.g_key_132));
                      }
                      if (!_hasMore) return const SizedBox.shrink();
                      return TextButton(
                        onPressed: () => _load(),
                        child: Text(s.g_audit_load_more),
                      );
                    }
                    final item = _items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.coin.coin['coinType'] ?? ''} · ${item.coin.isTest ? s.g_audit_testnet : s.g_audit_mainnet}',
                          style: AppTypography.caption,
                        ),
                        WalletChainInfoTransactionsItem(
                          type: item.isBtc ? 0 : 1,
                          transactionModel: item.record,
                          coinModel: item.coin,
                          readOnly: true,
                          onBack: () => _load(reset: true),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
