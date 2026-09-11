import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/pages/perps/hyperliquid_service.dart';
import 'package:n42_wallet/generated/l10n.dart';

Future<void> showPerpMarketDetails(BuildContext context, PerpMarket market) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final s = S.of(context);
      final rows = <(String, String)>[
        (s.g_audit_mark_price, '\$${market.markPrice}'),
        (s.g_audit_oracle_price, '\$${market.oraclePrice}'),
        (s.g_audit_volume, '\$${market.volume24h.toStringAsFixed(2)}'),
        (s.g_audit_open_interest, '${market.openInterest} ${market.symbol}'),
        (
          s.g_audit_funding,
          '${(market.fundingRate * 100).toStringAsFixed(6)}%',
        ),
        (s.g_audit_max_leverage, '${market.maxLeverage}×'),
      ];
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${market.symbol}-PERP',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(s.g_key_perps_read_only),
            const SizedBox(height: 16),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 4,
                  children: [Text(row.$1), SelectableText(row.$2)],
                ),
              ),
          ],
        ),
      );
    },
  );
}
