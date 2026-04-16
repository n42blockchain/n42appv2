import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/data/datasources/social/debank_datasource.dart';

void main() {
  group('DeBankDatasource', () {
    test(
      'uses proxy endpoints with bearer auth for portfolio lookups',
      () async {
        final client = MockClient((request) async {
          expect(request.url.toString(), contains('/v1/debank/total_balance'));
          expect(request.url.queryParameters['address'], '0x123');
          expect(request.headers['Authorization'], 'Bearer proxy-token');
          return http.Response(
            jsonEncode({
              'total_usd_value': 42.5,
              'chain_list': [
                {'id': 'eth', 'usd_value': 42.5},
              ],
            }),
            200,
          );
        });

        final datasource = DeBankDatasource(
          baseUrl: 'https://api.n42.ai/proxy/v1/debank',
          authToken: 'proxy-token',
          useProxyEndpoint: true,
          httpClient: client,
        );

        final portfolio = await datasource.getUserPortfolio('0x123');

        expect(portfolio.totalUsdValue, 42.5);
        expect(portfolio.chainBalances['eth'], 42.5);
        datasource.dispose();
      },
    );

    test('uses proxy used_chain_list route and parses chain ids', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), contains('/v1/debank/used_chain_list'));
        expect(request.url.queryParameters['address'], '0xabc');
        expect(request.headers['Authorization'], 'Bearer proxy-token');
        return http.Response(
          jsonEncode([
            {'id': 'eth'},
            {'id': 'base'},
          ]),
          200,
        );
      });

      final datasource = DeBankDatasource(
        baseUrl: 'https://api.n42.ai/proxy/v1/debank',
        authToken: 'proxy-token',
        useProxyEndpoint: true,
        httpClient: client,
      );

      final chains = await datasource.getUsedChains('0xabc');

      expect(chains, ['eth', 'base']);
      datasource.dispose();
    });
  });
}
