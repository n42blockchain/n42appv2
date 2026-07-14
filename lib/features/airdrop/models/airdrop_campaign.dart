// Copyright 2021-2026 N42 Inc. All rights reserved.

enum AirdropCampaignStatus { active, upcoming, ended, unknown }

class AirdropCampaign {
  const AirdropCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.sourceName,
    required this.status,
    this.symbol,
    this.chain,
    this.startDate,
    this.endDate,
    this.claimUrl,
    this.projectUrl,
    this.isEligible,
  });

  final String id;
  final String name;
  final String description;
  final String sourceName;
  final AirdropCampaignStatus status;
  final String? symbol;
  final String? chain;
  final DateTime? startDate;
  final DateTime? endDate;
  final Uri? claimUrl;
  final Uri? projectUrl;
  final bool? isEligible;

  bool get canOpenClaim => claimUrl != null;

  factory AirdropCampaign.fromJson(Map<String, dynamic> json) {
    final coin = json['coin'] is Map<String, dynamic>
        ? json['coin'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final id = _text(json['id']);
    final projectName = _text(
      json['project_name'] ?? json['projectName'] ?? json['name'],
    );
    final claimUrl = _httpsUri(
      json['claim_url'] ?? json['claimUrl'] ?? json['link'],
    );
    final projectUrl = _httpsUri(json['project_url'] ?? json['projectUrl']);

    return AirdropCampaign(
      id: id.isEmpty ? '${projectName.toLowerCase()}-${claimUrl ?? ''}' : id,
      name: projectName.isEmpty ? _text(coin['name']) : projectName,
      description: _text(json['description']),
      sourceName: _sourceName(json, claimUrl),
      status: _status(json['status']),
      symbol: _nullableText(json['token_symbol'] ?? coin['symbol']),
      chain: _nullableText(json['chain_symbol'] ?? json['chain']),
      startDate: _date(json['start_date'] ?? json['startDate']),
      endDate: _date(
        json['claim_deadline'] ?? json['end_date'] ?? json['endDate'],
      ),
      claimUrl: claimUrl,
      projectUrl: projectUrl,
      isEligible: json['is_eligible'] as bool?,
    );
  }

  static AirdropCampaignStatus _status(dynamic value) {
    return switch (_text(value).toLowerCase()) {
      'active' || 'ongoing' => AirdropCampaignStatus.active,
      'upcoming' => AirdropCampaignStatus.upcoming,
      'claimed' || 'expired' || 'ended' => AirdropCampaignStatus.ended,
      _ => AirdropCampaignStatus.unknown,
    };
  }

  static String _sourceName(Map<String, dynamic> json, Uri? claimUrl) {
    final explicit = _text(json['source_name'] ?? json['source']);
    if (explicit.isNotEmpty) return explicit;
    if (claimUrl?.host.endsWith('coinmarketcap.com') == true) {
      return 'CoinMarketCap';
    }
    return 'N42';
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static String? _nullableText(dynamic value) {
    final result = _text(value);
    return result.isEmpty ? null : result;
  }

  static DateTime? _date(dynamic value) {
    final raw = _text(value);
    return raw.isEmpty ? null : DateTime.tryParse(raw)?.toLocal();
  }

  static Uri? _httpsUri(dynamic value) {
    final uri = Uri.tryParse(_text(value));
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }
}

class AirdropSource {
  const AirdropSource({
    required this.name,
    required this.description,
    required this.url,
  });

  final String name;
  final String description;
  final Uri url;
}
