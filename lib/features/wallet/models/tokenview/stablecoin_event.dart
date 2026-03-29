import 'package:n42_wallet/features/wallet/models/tokenview/parse_helpers.dart';

/// Stablecoin mint/burn/freeze event from TokenView /stablecoin/events endpoint.
class StablecoinEvent {
  final String? txHash;
  final String? amount;
  final String? action; // issue, destroy, freeze
  final int? timestamp;
  final String? network;

  const StablecoinEvent({
    this.txHash,
    this.amount,
    this.action,
    this.timestamp,
    this.network,
  });

  factory StablecoinEvent.fromJson(Map<String, dynamic> json) {
    return StablecoinEvent(
      txHash: (json['txHash'] ?? json['hash'] ?? json['txid'])?.toString(),
      amount: (json['amount'] ?? json['value'])?.toString(),
      action: (json['action'] ?? json['type'])?.toString(),
      timestamp: toIntSafe(json['timestamp'] ?? json['time']),
      network: (json['network'] ?? json['chain'])?.toString(),
    );
  }
}
