import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_campaign.dart';
import 'package:n42_wallet/features/airdrop/services/airdrop_service.dart';

void main() {
  group('AirdropCampaign', () {
    test('parses N42 and CoinMarketCap-compatible fields', () {
      final campaign = AirdropCampaign.fromJson({
        'id': 'campaign-1',
        'project_name': 'Project One',
        'description': 'Verified campaign',
        'status': 'ONGOING',
        'coin': {'symbol': 'ONE'},
        'link': 'https://coinmarketcap.com/currencies/one/airdrop/',
      });

      expect(campaign.name, 'Project One');
      expect(campaign.status, AirdropCampaignStatus.active);
      expect(campaign.symbol, 'ONE');
      expect(campaign.sourceName, 'CoinMarketCap');
      expect(campaign.claimUrl?.scheme, 'https');
    });

    test('rejects insecure and credential-bearing claim links', () {
      expect(
        AirdropCampaign.fromJson({
          'name': 'HTTP',
          'claim_url': 'http://example.com/claim',
        }).claimUrl,
        isNull,
      );
      expect(
        AirdropCampaign.fromJson({
          'name': 'Credentials',
          'claim_url': 'https://user:password@example.com/claim',
        }).claimUrl,
        isNull,
      );
    });

    test('source label is not spoofable by a lookalike suffix domain', () {
      // 裸 endsWith 会让钓鱼域名顶着 CoinMarketCap 的来源标签展示。
      expect(
        AirdropCampaign.fromJson({
          'name': 'Lookalike',
          'claim_url': 'https://evilcoinmarketcap.com/claim',
        }).sourceName,
        'N42',
      );
      expect(
        AirdropCampaign.fromJson({
          'name': 'Subdomain',
          'claim_url': 'https://airdrop.coinmarketcap.com/claim',
        }).sourceName,
        'CoinMarketCap',
      );
      expect(
        AirdropCampaign.fromJson({
          'name': 'Apex',
          'claim_url': 'https://coinmarketcap.com/claim',
        }).sourceName,
        'CoinMarketCap',
      );
    });
  });

  group('AirdropService', () {
    test('loads only named campaigns from configured aggregator', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/airdrop/v1/airdrops');
        expect(request.url.queryParameters['wallet'], '0xabc');
        return http.Response(
          '{"data":[{"id":"1","name":"Alpha","status":"active"},{"id":"2"}]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = AirdropService(
        client: client,
        baseUrl: 'https://api.example/airdrop/v1/',
      );

      final campaigns = await service.getCampaigns(walletAddress: '0xabc');

      expect(campaigns, hasLength(1));
      expect(campaigns.single.name, 'Alpha');
      service.dispose();
    });

    test(
      'does not replace an unavailable source with mock campaigns',
      () async {
        final service = AirdropService(
          client: MockClient((_) async => http.Response('not found', 404)),
          baseUrl: 'https://api.example/airdrop/v1',
        );

        await expectLater(
          service.getCampaigns(),
          throwsA(isA<AirdropServiceException>()),
        );
        service.dispose();
      },
    );

    test('returns an empty list for a valid empty response', () async {
      final service = AirdropService(
        client: MockClient((_) async => http.Response('{"data":[]}', 200)),
        baseUrl: 'https://api.example/airdrop/v1',
      );

      await expectLater(service.getCampaigns(), completion(isEmpty));
      service.dispose();
    });

    test('rejects malformed JSON without inventing campaigns', () async {
      final service = AirdropService(
        client: MockClient((_) async => http.Response('{broken', 200)),
        baseUrl: 'https://api.example/airdrop/v1',
      );

      await expectLater(
        service.getCampaigns(),
        throwsA(isA<FormatException>()),
      );
      service.dispose();
    });

    test('surfaces aggregator timeouts', () async {
      final service = AirdropService(
        client: MockClient((_) async => throw TimeoutException('offline')),
        baseUrl: 'https://api.example/airdrop/v1',
      );

      await expectLater(
        service.getCampaigns(),
        throwsA(isA<TimeoutException>()),
      );
      service.dispose();
    });
  });
}
