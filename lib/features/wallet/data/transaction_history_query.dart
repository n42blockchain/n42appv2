import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_record_helpers.dart';

class TransactionHistoryScope {
  final String userId;
  final String address;
  final String coinType;
  final String contract;
  final String blockchainType;
  final bool isTest;

  const TransactionHistoryScope({
    required this.userId,
    required this.address,
    required this.coinType,
    required this.blockchainType,
    this.contract = '',
    this.isTest = false,
  });

  factory TransactionHistoryScope.fromCoin(String userId, CoinModel coin) =>
      TransactionHistoryScope(
        userId: userId,
        address: coin.address?.toString() ?? '',
        coinType: coin.config.coinType,
        contract: resolveCoinContractForNetwork(
          coin: coin.coin,
          isTest: coin.isTest,
        ),
        blockchainType: coin.config.blockchainType,
        isTest: coin.isTest,
      );

  bool get isBtc => blockchainType == 'Bitcoin';
  bool get isEvm => blockchainType == 'Ethereum';
  bool get isValid =>
      userId.isNotEmpty && address.isNotEmpty && coinType.isNotEmpty;
  Object get key =>
      (userId, address, coinType, contract, blockchainType, isTest);

  bool matchesAddress(String other) {
    // Base58 addresses (BTC legacy, Solana, Tron) are case-sensitive.
    final bech32 =
        isBtc &&
        RegExp(
          r'^(bc1|tb1|bcrt1|ltc1|tltc1)',
          caseSensitive: false,
        ).hasMatch(address);
    return isEvm || bech32
        ? other.toLowerCase() == address.toLowerCase()
        : other == address;
  }
}

const _unchanged = Object();

class TransactionHistoryFilter {
  final String? direction;
  final int? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  const TransactionHistoryFilter({
    this.direction,
    this.status,
    this.dateFrom,
    this.dateTo,
  });

  bool get isActive => activeCount > 0;
  int get activeCount =>
      [direction, status, dateFrom, dateTo].where((e) => e != null).length;

  TransactionHistoryFilter copyWith({
    Object? direction = _unchanged,
    Object? status = _unchanged,
    Object? dateFrom = _unchanged,
    Object? dateTo = _unchanged,
  }) => TransactionHistoryFilter(
    direction: direction == _unchanged ? this.direction : direction as String?,
    status: status == _unchanged ? this.status : status as int?,
    dateFrom: dateFrom == _unchanged ? this.dateFrom : dateFrom as DateTime?,
    dateTo: dateTo == _unchanged ? this.dateTo : dateTo as DateTime?,
  );

  TransactionHistoryFilter clear() => const TransactionHistoryFilter();

  int? get fromMs =>
      dateFrom == null ? null : _midnight(dateFrom!).millisecondsSinceEpoch;
  // Calendar next day, not +24h: daylight-saving days may have 23 or 25 hours.
  int? get untilMs => dateTo == null
      ? null
      : DateTime(
          dateTo!.year,
          dateTo!.month,
          dateTo!.day + 1,
        ).millisecondsSinceEpoch;
  static DateTime _midnight(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
