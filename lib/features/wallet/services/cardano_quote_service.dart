import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/signing_inputs.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/transfer_plan.dart';

/// Builds a public, unsigned ADA-only quote. Native-token inputs stay unspent.
class CardanoQuoteService {
  final AdaApi api;
  final Trustdart bridge;
  CardanoQuoteService({AdaApi? api, Trustdart? bridge})
    : api =
          api ??
          AdaApi(
            projectId: const String.fromEnvironment('BLOCKFROST_PROJECT_ID'),
          ),
      bridge = bridge ?? Trustdart();

  Future<CardanoTransferPlan> quote({
    required String sender,
    required String recipient,
    required BigInt amount,
    required bool isTest,
    required bool maximum,
    required bool Function() isCurrent,
  }) async {
    void check() {
      if (!isCurrent()) throw StateError('Cardano quote context changed');
    }

    check();
    if (api.projectId.trim().isEmpty ||
        sender.isEmpty ||
        recipient.isEmpty ||
        (!maximum && amount <= BigInt.zero)) {
      throw const FormatException('Cardano quote unavailable');
    }
    final response = await api.getAddressUtxos(sender, isTest: isTest);
    check();
    if (response.error) {
      throw const FormatException('Cardano inputs unavailable');
    }
    final inputs = CardanoSigningInputs.fromBlockfrost(response.data, sender);
    final block = await api.getLatestBlock(isTest: isTest);
    check();
    if (block.error) throw const FormatException('Cardano slot unavailable');
    final ttl = CardanoSigningInputs.ttl(block.data);
    final requested = maximum ? inputs.balance : amount;
    final result = await bridge.planCardanoTransaction({
      'utxos': inputs.utxos,
      'ttl': ttl,
      'toAddress': recipient,
      'changeAddress': sender,
      'amount': requested.toString(),
      'useMaxAmount': maximum,
    });
    check();
    return CardanoTransferPlan.parse(
      result,
      requested: requested,
      available: inputs.balance,
      sendMax: maximum,
    );
  }
}
