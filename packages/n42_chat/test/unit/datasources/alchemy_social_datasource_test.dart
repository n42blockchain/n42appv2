import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/data/datasources/social/alchemy_social_datasource.dart';

void main() {
  group('AlchemySocialDatasource', () {
    test('uses proxy endpoint with bearer auth for NFT lookups', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          contains('/v1/alchemy/eth-mainnet/getNFTsForOwner'),
        );
        expect(request.url.queryParameters['owner'], '0x123');
        expect(request.headers['Authorization'], 'Bearer proxy-token');
        return http.Response(
          jsonEncode({
            'ownedNfts': [
              {
                'contract': {'address': '0xabc'},
              },
            ],
          }),
          200,
        );
      });

      final datasource = AlchemySocialDatasource(
        apiKey: '',
        baseUrl: 'https://api.n42.ai/proxy/v1/alchemy/eth-mainnet',
        authToken: 'proxy-token',
        useProxyEndpoint: true,
        httpClient: client,
      );

      final nfts = await datasource.getUserNFTs('0x123');

      expect(nfts, hasLength(1));
      expect(
        (nfts.first['contract'] as Map<String, dynamic>)['address'],
        '0xabc',
      );
      datasource.dispose();
    });

    test('uses proxy endpoint with bearer auth for owner lookups', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          contains('/v1/alchemy/eth-mainnet/getOwnersForContract'),
        );
        expect(request.url.queryParameters['contractAddress'], '0xcollection');
        expect(request.headers['Authorization'], 'Bearer proxy-token');
        return http.Response(
          jsonEncode({
            'ownerAddresses': ['0x1', '0x2'],
          }),
          200,
        );
      });

      final datasource = AlchemySocialDatasource(
        apiKey: '',
        baseUrl: 'https://api.n42.ai/proxy/v1/alchemy/eth-mainnet',
        authToken: 'proxy-token',
        useProxyEndpoint: true,
        httpClient: client,
      );

      final owners = await datasource.getCollectionOwners('0xcollection');

      expect(owners, ['0x1', '0x2']);
      datasource.dispose();
    });
  });
}
