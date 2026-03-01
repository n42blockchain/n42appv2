// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// URL threat detection result.
class UrlThreat {
  /// The URL that was checked.
  final String url;

  /// Whether the URL is considered malicious.
  final bool isMalicious;

  /// Threat type (e.g. 'phishing', 'malware_download', 'unknown').
  final String? threatType;

  /// Which detection layer flagged this URL.
  final String source;

  /// Additional context or tags from the detection source.
  final List<String> tags;

  const UrlThreat({
    required this.url,
    required this.isMalicious,
    this.threatType,
    required this.source,
    this.tags = const [],
  });

  /// Safe result — no threat detected.
  const UrlThreat.safe(this.url)
      : isMalicious = false,
        threatType = null,
        source = 'none',
        tags = const [];
}
