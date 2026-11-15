import 'dart:math';

import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';

/// The network accepts at most this many balance-withdraw reservations per
/// transaction, plus one for gas paid from the address balance.
const suiMaxWithdrawReservations = 10;

final _maxU64 = (BigInt.one << 64) - BigInt.one;

/// How a SUI payment is funded (SIP-58).
class SuiFundingPlan {
  /// MIST withdrawn from the sender's address balance; zero means none.
  final BigInt addressBalanceAmount;

  /// Gas is paid from the address balance (a `valid_during` window is then
  /// required) instead of the input coins.
  final bool gasFromAddressBalance;

  /// Withdraw reservations the transaction makes, gas included.
  final int reservations;

  const SuiFundingPlan({
    required this.addressBalanceAmount,
    required this.gasFromAddressBalance,
    required this.reservations,
  });

  /// Coins alone pay both the amount and the gas: today's transaction shape.
  bool get coinsOnly =>
      addressBalanceAmount == BigInt.zero && !gasFromAddressBalance;
}

/// Chooses the funding for a PaySui of [amount] to [recipients] recipients
/// (one amount each, summing to [amount]), or returns null when the funds
/// cannot cover it. Every path reserves the full [gasBudget]:
///
/// 1. Coins cover amount + budget: coins only, exactly as before SIP-58.
/// 2. Coins cover the budget: they stay the gas payment and the shortfall
///    (amount + budget - coins) is withdrawn from the address balance and
///    merged into the gas coin, so the budget is still there after paying.
/// 3. Otherwise gas comes from the address balance (`valid_during`); the
///    coins, if any, are spent as funds and the rest is withdrawn. Without
///    coins WalletCore needs the withdrawal to equal the amount exactly and
///    makes one reservation per recipient.
SuiFundingPlan? planSuiFunding({
  required BigInt amount,
  required BigInt gasBudget,
  required BigInt coinBalance,
  required bool hasCoins,
  required BigInt addressBalance,
  int recipients = 1,
}) {
  if (amount <= BigInt.zero ||
      gasBudget <= BigInt.zero ||
      coinBalance.isNegative ||
      addressBalance.isNegative ||
      recipients < 1 ||
      (!hasCoins && coinBalance != BigInt.zero)) {
    return null;
  }
  final need = amount + gasBudget;
  if (hasCoins && coinBalance >= need) {
    return SuiFundingPlan(
      addressBalanceAmount: BigInt.zero,
      gasFromAddressBalance: false,
      reservations: 0,
    );
  }
  if (hasCoins && coinBalance >= gasBudget) {
    final withdraw = need - coinBalance;
    if (withdraw > addressBalance) return null;
    return SuiFundingPlan(
      addressBalanceAmount: withdraw,
      gasFromAddressBalance: false,
      reservations: 1,
    );
  }
  final withdraw = hasCoins
      ? (amount > coinBalance ? amount - coinBalance : BigInt.zero)
      : amount;
  if (withdraw + gasBudget > addressBalance || withdraw > _maxU64) return null;
  final fundReservations = withdraw == BigInt.zero
      ? 0
      : (hasCoins ? 1 : recipients);
  if (fundReservations > suiMaxWithdrawReservations) return null;
  return SuiFundingPlan(
    addressBalanceAmount: withdraw,
    gasFromAddressBalance: true,
    reservations: fundReservations + 1,
  );
}

/// Result of [prepareSuiTransfer]: the native signing map or an error.
class SuiTransferRequest {
  final Map<String, dynamic>? signMap;
  final SuiFundingPlan? plan;
  final String? error;
  const SuiTransferRequest.ok(Map<String, dynamic> this.signMap, this.plan)
    : error = null;
  const SuiTransferRequest.fail(String this.error)
    : signMap = null,
      plan = null;
}

/// A fresh random nonce for each signed transaction (see [prepareSuiTransfer]).
int randomSuiNonce() => Random.secure().nextInt(1 << 32);

/// Builds the native signing map for a SUI transfer of [amount] MIST.
///
/// Coin-only transfers produce exactly the map used before SIP-58 support
/// (and no extra requests); the address balance and the network state are
/// only read when the coins fall short.
///
/// A transaction whose gas comes from the address balance has no owned gas
/// object, so its uniqueness comes from `valid_during`: the current and the
/// next epoch, the chain identifier and a nonce. The network executes one
/// digest at most once and rejects it after `max_epoch`, so resending the
/// same signed bytes can never pay twice. The nonce is random per signing so
/// that two intended, identical payments stay two transactions; the caller
/// must therefore never re-sign after an unknown outcome (the pending send
/// gate enforces that).
Future<SuiTransferRequest> prepareSuiTransfer({
  required SuiApi api,
  required String fromAddress,
  required String toAddress,
  required BigInt amount,
  required BigInt gasBudget,
  required BigInt referenceGasPrice,
  int Function() nonce = randomSuiNonce,
}) async {
  final objects = await api.getOwnedObjects(fromAddress);
  final coins = <Map<String, String>>[];
  var coinBalance = BigInt.zero;
  for (final object in objects) {
    final data = object is Map ? object['data'] : null;
    final balance = SuiApi.amount(
      SuiApi.field(data, ['content', 'fields', 'balance']),
    );
    if (data is! Map || balance == null) {
      return const SuiTransferRequest.fail('Invalid Sui coin data');
    }
    coins.add({
      'objectId': data['objectId'] as String,
      'version': data['version'] as String,
      'objectDigest': data['digest'] as String,
    });
    coinBalance += balance;
  }
  final signMap = <String, dynamic>{
    'type': 'SUI_TRANSFER',
    'amount': amount.toString(),
    'toAddress': toAddress,
    'fromAddress': fromAddress,
    'gasBudget': gasBudget.toString(),
    'referenceGasPrice': referenceGasPrice.toString(),
    'utxo': coins,
  };
  if (coins.isNotEmpty && coinBalance >= amount + gasBudget) {
    return SuiTransferRequest.ok(
      signMap,
      planSuiFunding(
        amount: amount,
        gasBudget: gasBudget,
        coinBalance: coinBalance,
        hasCoins: true,
        addressBalance: BigInt.zero,
      ),
    );
  }

  final balances = await api.getBalancesSui(fromAddress);
  if (balances.error) {
    return SuiTransferRequest.fail(balances.data?.toString() ?? 'Sui balance');
  }
  final plan = planSuiFunding(
    amount: amount,
    gasBudget: gasBudget,
    coinBalance: coinBalance,
    hasCoins: coins.isNotEmpty,
    addressBalance: (balances.data as SuiBalances).address,
  );
  if (plan == null) {
    return const SuiTransferRequest.fail('Insufficient Sui balance');
  }
  if (plan.addressBalanceAmount > BigInt.zero) {
    signMap['addressBalanceAmount'] = plan.addressBalanceAmount.toString();
  }
  if (plan.gasFromAddressBalance) {
    final network = await api.getNetworkSui();
    if (network.error) {
      return SuiTransferRequest.fail(network.data?.toString() ?? 'Sui epoch');
    }
    final state = network.data as SuiNetworkState;
    // Price and window come from the same read, so they belong to one epoch.
    signMap['referenceGasPrice'] = state.referenceGasPrice.toString();
    final value = nonce();
    if (value < 0 || value >= (1 << 32)) {
      return const SuiTransferRequest.fail('Invalid Sui nonce');
    }
    signMap['validDuring'] = <String, String>{
      'minEpoch': state.epoch.toString(),
      'maxEpoch': (state.epoch + BigInt.one).toString(),
      'chain': state.chainIdentifier,
      'nonce': value.toString(),
    };
  }
  return SuiTransferRequest.ok(signMap, plan);
}
