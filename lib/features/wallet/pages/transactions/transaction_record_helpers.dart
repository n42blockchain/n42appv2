import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';

String resolveCoinContractForNetwork({
  required Map<String, dynamic> coin,
  required bool isTest,
}) {
  if (isTest) {
    final testContract = coin['contract_test'] as String?;
    if (testContract != null && testContract.isNotEmpty) {
      return testContract;
    }
  }
  return coin['contract'] as String? ?? '';
}

TransationRecordModel buildFallbackTransactionRecord(
  CoinModel coinModel, {
  int walletIndex = 0,
}) {
  final address = coinModel.address?.toString() ?? '';
  final coinIdRaw = coinModel.isTest
      ? coinModel.coin['chainId_test']
      : coinModel.coin['chainId'];

  return TransationRecordModel()
    ..address = address
    ..from1 = address
    ..addrType = coinModel.addrType
    ..coin = coinModel.coin
    ..coinMiniName = coinModel.config.coinType
    ..walletIndex = walletIndex
    ..contract = resolveCoinContractForNetwork(
      coin: coinModel.coin,
      isTest: coinModel.isTest,
    )
    ..isTest = coinModel.isTest ? 1 : 0
    ..gasPrice = BigInt.zero
    ..gasPriceValue = BigInt.zero
    ..coinId = switch (coinIdRaw) {
      final int value => value,
      final num value => value.toInt(),
      _ => int.tryParse(coinIdRaw?.toString() ?? '') ?? 0,
    };
}

void populateTrxTransactionRecordFromInfo({
  required TransationRecordModel record,
  required Map<String, dynamic> transactionInfo,
}) {
  final triggerInfo = transactionInfo['trigger_info'] as Map<String, dynamic>?;
  if (triggerInfo != null) {
    final parameter = triggerInfo['parameter'] as Map<String, dynamic>?;
    record.contract =
        triggerInfo['contract_address'] as String? ?? record.contract;
    record.to1 =
        parameter?['_to']?.toString() ??
        transactionInfo['toAddress']?.toString() ??
        record.to1;
    record.price = _parseBigInt(
      parameter?['_value'] ?? transactionInfo['amount'],
    );
    return;
  }

  record.to1 = transactionInfo['toAddress']?.toString() ?? record.to1;
  record.price = _parseBigInt(transactionInfo['amount']);
}

BigInt _parseBigInt(dynamic value) {
  return switch (value) {
    null => BigInt.zero,
    final BigInt v => v,
    final int v => BigInt.from(v),
    final num v => BigInt.from(v.toInt()),
    _ => BigInt.tryParse(value.toString()) ?? BigInt.zero,
  };
}
