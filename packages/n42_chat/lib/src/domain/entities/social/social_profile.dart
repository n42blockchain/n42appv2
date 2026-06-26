import 'package:equatable/equatable.dart';

/// On-chain social profile representing a user's Web3 identity and holdings.
class SocialProfile extends Equatable {
  /// The wallet address of this profile.
  final String address;

  /// ENS name if resolved (e.g. "vitalik.eth").
  final String? ensName;

  /// Lens Protocol handle (e.g. "stani").
  final String? lensHandle;

  /// Farcaster username (e.g. "dwr").
  final String? farcasterUsername;

  /// Avatar URL from on-chain identity or gravatar.
  final String? avatarUrl;

  /// List of chain IDs this address has been active on.
  final List<String> chains;

  /// Number of distinct token holdings.
  final int tokenCount;

  /// Number of NFTs owned.
  final int nftCount;

  /// Number of DAOs participated in.
  final int daoCount;

  /// Estimated total portfolio value in USD.
  final double portfolioValueUsd;

  const SocialProfile({
    required this.address,
    this.ensName,
    this.lensHandle,
    this.farcasterUsername,
    this.avatarUrl,
    this.chains = const [],
    this.tokenCount = 0,
    this.nftCount = 0,
    this.daoCount = 0,
    this.portfolioValueUsd = 0,
  });

  /// Human-readable display name, preferring ENS > Lens > Farcaster > short address.
  String get displayName =>
      ensName ?? lensHandle ?? farcasterUsername ?? _shortenAddress(address);

  String _shortenAddress(String addr) {
    if (addr.length <= 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  @override
  List<Object?> get props => [
        address,
        ensName,
        lensHandle,
        farcasterUsername,
        avatarUrl,
        chains,
        tokenCount,
        nftCount,
        daoCount,
        portfolioValueUsd,
      ];
}
