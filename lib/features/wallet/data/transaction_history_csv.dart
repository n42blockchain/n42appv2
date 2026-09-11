import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart'
    show toEther;
import 'transaction_history_query.dart';

bool historyIsOutgoing(Object record, TransactionHistoryScope scope) =>
    switch (record) {
      BtcTransactionRecodeModel tx => tx.inputsAddressList.any(
        scope.matchesAddress,
      ),
      TransationRecordModel tx => scope.matchesAddress(tx.from1),
      _ => throw ArgumentError('Unsupported transaction record'),
    };

/// Quote every cell and neutralize spreadsheet formulas, including after spaces.
String historyCsvCell(String value) {
  final trimmed = value.trimLeft();
  if (RegExp(r'^[=+@\-]').hasMatch(trimmed) ||
      RegExp(r'^[\t\r\n]').hasMatch(value)) {
    value = "'$value";
  }
  return '"${value.replaceAll('"', '""')}"';
}

class TransactionHistoryCsv {
  static const header =
      '\uFEFFNo,Time,Direction,Status,Amount,Token,From,To,TxHash,Network,Chain\r\n';
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String row(int number, Object record, TransactionHistoryScope scope) {
    final (rawTime, state, amount, coin, from, to, hash) = switch (record) {
      BtcTransactionRecodeModel tx => (
        tx.txTime,
        tx.state,
        tx.price.toString(),
        tx.coin,
        tx.inputsAddressList.join('; '),
        tx.outputsAddressList.isEmpty
            ? tx.to1
            : tx.outputsAddressList.join('; '),
        tx.txHash,
      ),
      TransationRecordModel tx => (
        tx.txTime,
        tx.state,
        tx.price.toString(),
        tx.coin,
        tx.from1,
        tx.to1,
        tx.txHash,
      ),
      _ => throw ArgumentError('Unsupported transaction record'),
    };
    final timestamp = int.parse(rawTime);
    final ms = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
    final status = switch (state) {
      0 => 'Pending',
      1 => 'Success',
      2 => 'Failed',
      _ => 'Unknown',
    };
    final cells = [
      '$number',
      _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(ms)),
      historyIsOutgoing(record, scope) ? 'Send' : 'Receive',
      status,
      toEther(amount, coin['decimals'] ?? 0).toString(),
      (coin['unit']?.toString() ?? scope.coinType).toUpperCase(),
      from,
      to,
      hash,
      scope.isTest ? 'Testnet' : 'Mainnet',
      scope.coinType,
    ].map(historyCsvCell).join(',');
    return '$cells\r\n';
  }
}
