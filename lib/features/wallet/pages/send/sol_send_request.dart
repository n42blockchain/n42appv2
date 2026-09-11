import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// Preserve the confirmed amount, recipient and network at the UI/sender boundary.
SendParams solSendRequest(
  CoinModel account,
  TransationRecordModel confirmed, {
  CoinModel? parent,
}) {
  if (account.address.toString() != confirmed.from1 ||
      account.isTest != (confirmed.isTest == 1)) {
    throw StateError('The sending account or network changed; confirm again');
  }
  final decimals = (account.coin['decimals'] as num?)?.toInt() ?? 9;
  final basePath =
      account.config.pathForAddrType(account.addrType) ??
      parent?.config.pathForAddrType(account.addrType) ??
      "m/44'/501'/0'";
  final token = confirmed.contract.isNotEmpty;
  return SendParams(
    coinType: account.config.coinType,
    fromAddress: confirmed.from1,
    toAddress: confirmed.to1,
    amount: toEther(confirmed.price.toString(), decimals).toDouble(),
    decimals: decimals,
    path: getPathWithIndex(basePath, account.pathIndex),
    isTest: confirmed.isTest == 1,
    contractAddress: confirmed.contract,
    tokenDecimals: decimals,
    valueWeiOverride: token ? null : confirmed.price,
    tokenValueWeiOverride: token ? confirmed.price : null,
    memo: confirmed.message,
    privateKey: account.privateKey,
    chainConfig: account.coin,
  );
}
