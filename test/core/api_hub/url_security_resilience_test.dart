import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/aggregators/url_security_aggregator.dart';
import 'package:n42_wallet/core/api_hub/datasources/urlhaus_datasource.dart';
import 'package:n42_wallet/core/api_hub/models/url_threat.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';

void main() {
  group('UrlhausDatasource parsing', () {
    test('caches definitive safe no_results responses only', () {
      final safeParsed = UrlhausDatasource.parseUrlResponse(
        'https://example.com',
        {'query_status': 'no_results'},
      );
      final transientParsed = UrlhausDatasource.parseUrlResponse(
        'https://example.com',
        {'query_status': 'rate_limited'},
      );

      expect(safeParsed.threat.isMalicious, isFalse);
      expect(safeParsed.shouldCache, isTrue);
      expect(transientParsed.threat.isMalicious, isFalse);
      expect(transientParsed.shouldCache, isFalse);
    });

    test('parses malicious host responses from url_count', () {
      final parsed = UrlhausDatasource.parseHostResponse('malware.example', {
        'query_status': 'ok',
        'url_count': 3,
      });

      expect(parsed.shouldCache, isTrue);
      expect(parsed.threat.isMalicious, isTrue);
      expect(parsed.threat.threatType, 'malware_host');
      expect(parsed.threat.tags, contains('urls_count:3'));
    });
  });

  group('UrlSecurityAggregator remote fallback', () {
    test('uses host lookup when URL lookup is safe', () async {
      final result = await UrlSecurityAggregator.checkUrlWithLookups(
        'https://malware.example/path',
        phishingLookup: (_) => PhishingCheckResult.safe,
        remoteUrlLookup: (_) async =>
            const UrlThreat.safe('https://malware.example/path'),
        remoteHostLookup: (host) async => UrlThreat(
          url: host,
          isMalicious: true,
          threatType: 'malware_host',
          source: 'URLhaus',
        ),
      );

      expect(result.isMalicious, isTrue);
      expect(result.url, 'malware.example');
      expect(result.threatType, 'malware_host');
    });

    test(
      'short-circuits remote lookups when local phishing detection blocks',
      () async {
        var urlLookupCalls = 0;
        var hostLookupCalls = 0;

        final result = await UrlSecurityAggregator.checkUrlWithLookups(
          'https://phishing.example',
          phishingLookup: (_) => PhishingCheckResult.phishing,
          remoteUrlLookup: (_) async {
            urlLookupCalls++;
            return const UrlThreat.safe('https://phishing.example');
          },
          remoteHostLookup: (_) async {
            hostLookupCalls++;
            return const UrlThreat.safe('phishing.example');
          },
        );

        expect(result.isMalicious, isTrue);
        expect(result.threatType, 'phishing');
        expect(urlLookupCalls, 0);
        expect(hostLookupCalls, 0);
      },
    );

    test('fails closed when host lookup throws', () async {
      final result = await UrlSecurityAggregator.checkUrlWithLookups(
        'https://unknown.example/path',
        phishingLookup: (_) => PhishingCheckResult.safe,
        remoteUrlLookup: (_) async =>
            const UrlThreat.safe('https://unknown.example/path'),
        remoteHostLookup: (_) async => throw Exception('boom'),
      );

      expect(result.isMalicious, isTrue);
    });
  });
}
