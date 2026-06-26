import 'package:equatable/equatable.dart';

/// A Snapshot governance space configuration
class GovernanceSpace extends Equatable {
  final String id;
  final String name;
  final String? about;
  final String? avatar;
  final String? website;
  final String network;
  final List<String> admins;
  final List<String> members;
  final int proposalsCount;
  final int followersCount;
  final List<Map<String, dynamic>> strategies;
  final Map<String, dynamic>? filters;

  const GovernanceSpace({
    required this.id,
    required this.name,
    this.about,
    this.avatar,
    this.website,
    this.network = '1',
    this.admins = const [],
    this.members = const [],
    this.proposalsCount = 0,
    this.followersCount = 0,
    this.strategies = const [],
    this.filters,
  });

  GovernanceSpace copyWith({
    String? id,
    String? name,
    String? about,
    String? avatar,
    String? website,
    String? network,
    List<String>? admins,
    List<String>? members,
    int? proposalsCount,
    int? followersCount,
    List<Map<String, dynamic>>? strategies,
    Map<String, dynamic>? filters,
  }) {
    return GovernanceSpace(
      id: id ?? this.id,
      name: name ?? this.name,
      about: about ?? this.about,
      avatar: avatar ?? this.avatar,
      website: website ?? this.website,
      network: network ?? this.network,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      proposalsCount: proposalsCount ?? this.proposalsCount,
      followersCount: followersCount ?? this.followersCount,
      strategies: strategies ?? this.strategies,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [id, name, network, proposalsCount];
}
