import 'package:equatable/equatable.dart';

/// Type of social connection between two addresses.
enum ConnectionType {
  /// Share common token holdings.
  commonTokens,

  /// Share common NFT collections.
  commonNfts,

  /// Have direct transaction history.
  transactionHistory,

  /// Members of the same DAOs.
  commonDaos,

  /// Use the same chains.
  commonChains,
}

/// Represents a social connection between two on-chain addresses.
///
/// The [strength] field ranges from 0.0 (no overlap) to 1.0 (identical).
class SocialConnection extends Equatable {
  /// Source address of the connection.
  final String fromAddress;

  /// Target address of the connection.
  final String toAddress;

  /// The type of on-chain relationship.
  final ConnectionType type;

  /// Connection strength from 0.0 to 1.0 (Jaccard similarity).
  final double strength;

  /// Shared item identifiers (token symbols, contract addresses, chain IDs).
  final List<String> sharedItems;

  /// Timestamp of the most recent on-chain interaction.
  final DateTime? lastInteraction;

  const SocialConnection({
    required this.fromAddress,
    required this.toAddress,
    required this.type,
    this.strength = 0,
    this.sharedItems = const [],
    this.lastInteraction,
  });

  @override
  List<Object?> get props => [fromAddress, toAddress, type, strength];
}
