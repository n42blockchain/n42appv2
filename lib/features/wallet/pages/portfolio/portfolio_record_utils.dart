import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';

CoinRecord? portfolioRecordFromCoinModel(CoinModel item) {
  final hasBalance = item.balance > BigInt.zero || item.balanceDoubleAll() > 0;
  if (!hasBalance) return null;

  final symbol = (item.coin['miniName'] ?? item.coin['coinType'] ?? '')
      .toString();
  if (symbol.isEmpty) return null;

  return CoinRecord(
    symbol: symbol,
    name: (item.coin['name'] ?? symbol).toString(),
    icon: (item.coin['icon'] ?? '').toString(),
    value: item.value > 0 ? item.value : 0.0,
    percentage: item.percentage,
  );
}

List<CoinRecord> sortPortfolioRecordsByValue(Iterable<CoinRecord> records) {
  final list = records.toList();
  list.sort((a, b) => b.value.compareTo(a.value));
  return list;
}
