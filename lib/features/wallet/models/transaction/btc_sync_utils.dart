import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';

String parseBtcTimestamp(String? confirmed, {DateTime? fallbackTime}) {
  final parsed = confirmed == null ? null : DateTime.tryParse(confirmed);
  final resolved = parsed ?? fallbackTime ?? DateTime.now();
  return (resolved.millisecondsSinceEpoch ~/ 1000).toString();
}

bool syncBtcRecordFromDetail(
  BtcTransactionRecodeModel record,
  BtcTranDetail detail,
) {
  var changed = false;

  final confirmations = detail.confirmations;
  if (record.confirmations != confirmations) {
    record.confirmations = confirmations;
    changed = true;
  }

  final nextState = confirmations >= 6 ? 1 : 0;
  if (record.state != nextState) {
    record.state = nextState;
    changed = true;
  }

  final txTime = parseBtcTimestamp(
    detail.confirmed,
    fallbackTime: DateTime.fromMillisecondsSinceEpoch(
      _safeEpochSeconds(record.txTime) * 1000,
    ),
  );
  if (record.txTime != txTime) {
    record.txTime = txTime;
    changed = true;
  }

  if (record.gasPrice != detail.fees) {
    record.gasPrice = detail.fees;
    changed = true;
  }

  final nextInputs = buildBtcInputModels(detail.inputs);
  if (!_sameInputModels(record.inputModels, nextInputs)) {
    record.inputModels = nextInputs;
    record.inputsAddress = null;
    record.inputAddressStr = null;
    changed = true;
  }

  final nextOutputs = buildBtcOutputModels(detail.outputs);
  if (!_sameOutputModels(record.outputModels, nextOutputs)) {
    record.outputModels = nextOutputs;
    record.outputsAddress = null;
    record.outputAddressStr = null;
    changed = true;
  }

  final price = computeBtcDisplayPrice(record.address, detail);
  if (record.price != price) {
    record.price = price;
    changed = true;
  }

  return changed;
}

List<InputModel>? buildBtcInputModels(List<Input>? inputs) {
  if (inputs == null) return null;
  return [
    for (final input in inputs)
      InputModel()
        ..vout = input.outputValue
        ..txid = input.prevHash
        ..script = input.script ?? ''
        ..address = input.addresses,
  ];
}

List<OutputModel>? buildBtcOutputModels(List<Output>? outputs) {
  if (outputs == null) return null;
  return [
    for (final output in outputs)
      OutputModel()
        ..price = output.value
        ..script = output.script ?? ''
        ..address = output.addresses ?? [],
  ];
}

int computeBtcDisplayPrice(String walletAddress, BtcTranDetail detail) {
  final inputs = buildBtcInputModels(detail.inputs);
  final outputs = buildBtcOutputModels(detail.outputs);
  if (outputs == null) {
    return detail.total;
  }

  final normalizedWallet = walletAddress.toUpperCase();
  var isIncoming = false;
  if (inputs != null) {
    isIncoming = inputs.every(
      (input) => input.address.every(
        (address) => address.toUpperCase() != normalizedWallet,
      ),
    );
  }

  var outputPrice = 0;
  for (final output in outputs) {
    final hasWalletAddress = output.address.any(
      (address) => address.toUpperCase() == normalizedWallet,
    );
    if (isIncoming ? hasWalletAddress : !hasWalletAddress) {
      outputPrice += output.price;
    }
  }
  return outputPrice;
}

int _safeEpochSeconds(String rawValue) {
  final value = int.tryParse(rawValue);
  if (value == null || value <= 0) {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
  return rawValue.length == 13 ? value ~/ 1000 : value;
}

bool _sameInputModels(List<InputModel>? left, List<InputModel>? right) {
  if (left == null || right == null) return left == right;
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    final a = left[i];
    final b = right[i];
    if (a.value != b.value ||
        a.txid != b.txid ||
        a.vout != b.vout ||
        a.script != b.script ||
        a.witnessValue != b.witnessValue ||
        !_sameStrings(a.address, b.address)) {
      return false;
    }
  }
  return true;
}

bool _sameOutputModels(List<OutputModel>? left, List<OutputModel>? right) {
  if (left == null || right == null) return left == right;
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    final a = left[i];
    final b = right[i];
    if (a.price != b.price ||
        a.script != b.script ||
        !_sameStrings(a.address, b.address)) {
      return false;
    }
  }
  return true;
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}
