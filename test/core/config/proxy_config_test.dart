import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';

void main() {
  group('ProxyConfig route builders', () {
    final base = ProxyConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final routes = <String, ({String Function() build, String path})>{
      'marketBase': (build: () => ProxyConfig.marketBase, path: '/v1/market'),
      'marketOhlcv': (
        build: () => ProxyConfig.marketOhlcv,
        path: '/v1/market/ohlcv',
      ),
      'marketChart': (
        build: () => ProxyConfig.marketChart,
        path: '/v1/market/chart',
      ),
      'marketSimplePrice': (
        build: () => ProxyConfig.marketSimplePrice,
        path: '/v1/market/simple_price',
      ),
      'marketTrending': (
        build: () => ProxyConfig.marketTrending,
        path: '/v1/market/trending',
      ),
      'marketSearch': (
        build: () => ProxyConfig.marketSearch,
        path: '/v1/market/search',
      ),
      'tokenviewGasNextBlock': (
        build: () => ProxyConfig.tokenviewGasNextBlock,
        path: '/v1/tokenview/gas/nextblock',
      ),
      'tokenviewPendingStat': (
        build: () => ProxyConfig.tokenviewPendingStat,
        path: '/v1/tokenview/pendingstat',
      ),
      'tokenviewPendingTx': (
        build: () => ProxyConfig.tokenviewPendingTx,
        path: '/v1/tokenview/pending/tx',
      ),
      'tokenviewContractCreator': (
        build: () => ProxyConfig.tokenviewContractCreator,
        path: '/v1/tokenview/contract/creator',
      ),
      'tokenviewChainHeights': (
        build: () => ProxyConfig.tokenviewChainHeights,
        path: '/v1/tokenview/chain/heights',
      ),
      'tokenviewChainInfo': (
        build: () => ProxyConfig.tokenviewChainInfo,
        path: '/v1/tokenview/chain/info',
      ),
      'tokenviewTokenInfo': (
        build: () => ProxyConfig.tokenviewTokenInfo,
        path: '/v1/tokenview/token/info',
      ),
      'tokenviewTokenSupply': (
        build: () => ProxyConfig.tokenviewTokenSupply,
        path: '/v1/tokenview/token/supply',
      ),
      'tokenviewMarketInfo': (
        build: () => ProxyConfig.tokenviewMarketInfo,
        path: '/v1/tokenview/market/info',
      ),
      'tokenviewStablecoinEvents': (
        build: () => ProxyConfig.tokenviewStablecoinEvents,
        path: '/v1/tokenview/stablecoin/events',
      ),
      'bundler': (
        build: () => ProxyConfig.bundler('8453'),
        path: '/v1/bundler/8453',
      ),
      'explorerTxlist': (
        build: () => ProxyConfig.explorerTxlist('base'),
        path: '/v1/explorer/base/txlist',
      ),
      'explorerTokentx': (
        build: () => ProxyConfig.explorerTokentx('base'),
        path: '/v1/explorer/base/tokentx',
      ),
      'explorerSonic': (
        build: () => ProxyConfig.explorerSonic,
        path: '/v1/explorer/sonic',
      ),
      'nftBase': (build: () => ProxyConfig.nftBase, path: '/v1/nft'),
      'ethRpc': (build: () => ProxyConfig.ethRpc, path: '/v1/rpc/eth'),
      'tonRpc': (build: () => ProxyConfig.tonRpc, path: '/v1/rpc/ton'),
      'alchemyChain': (
        build: () => ProxyConfig.alchemyChain('base'),
        path: '/v1/alchemy/base',
      ),
    };

    for (final entry in routes.entries) {
      test('${entry.key} route uses its configured path', () {
        expect(entry.value.build(), '$base${entry.value.path}');
      });
    }

    test('normalizes a trailing slash in the configured base URL', () {
      final normalizedBase = ProxyConfig.baseUrl.replaceFirst(
        RegExp(r'/+$'),
        '',
      );
      expect(ProxyConfig.marketBase, '$normalizedBase/v1/market');
    });
  });

  group('ProxyConfig.isProxyUrl', () {
    test('matches routes under the configured proxy base URL', () {
      expect(
        ProxyConfig.isProxyUrl('${ProxyConfig.baseUrl}/v1/market/chart'),
        isTrue,
      );
    });

    test('host-only base matches only URLs on that exact origin', () {
      final base = Uri.parse(ProxyConfig.baseUrl);
      final basePath = base.path.replaceFirst(RegExp(r'/+$'), '');
      final routePath = basePath.isEmpty ? '/v1/market' : '$basePath/v1/market';
      final proxyRoute = base.replace(path: routePath).toString();
      final otherHost = base
          .replace(host: 'other.example', path: routePath)
          .toString();

      expect(ProxyConfig.isProxyUrl(proxyRoute), isTrue);
      expect(ProxyConfig.isProxyUrl(otherHost), isFalse);
    });

    test('rejects non-proxy URLs', () {
      expect(ProxyConfig.isProxyUrl('https://example.com/api'), isFalse);
    });

    test('rejects a URL whose path only shares the proxy prefix', () {
      final base = Uri.parse(ProxyConfig.baseUrl);
      final siblingPath = '${base.path}-evil/private';
      expect(
        ProxyConfig.isProxyUrl(base.replace(path: siblingPath).toString()),
        isFalse,
      );
    });

    test('rejects malformed and relative URLs', () {
      expect(ProxyConfig.isProxyUrl('https://[invalid'), isFalse);
      expect(ProxyConfig.isProxyUrl('/v1/market/chart'), isFalse);
    });
  });

  group('ProxyConfig.mergeAuthHeaders', () {
    test('adds bearer token for proxy requests when token is provided', () {
      final headers = ProxyConfig.mergeAuthHeaders(ProxyConfig.marketBase, {
        'Content-Type': 'application/json',
      }, 'proxy-token');

      expect(headers['Authorization'], 'Bearer proxy-token');
      expect(headers['Content-Type'], 'application/json');
    });

    test('does not add bearer token for non-proxy requests', () {
      final headers = ProxyConfig.mergeAuthHeaders('https://example.com/api', {
        'Content-Type': 'application/json',
      }, 'proxy-token');

      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('does not add an empty bearer token to proxy requests', () {
      final headers = ProxyConfig.mergeAuthHeaders(
        ProxyConfig.marketBase,
        const {'Content-Type': 'application/json'},
        '',
      );
      expect(headers, {'Content-Type': 'application/json'});
    });

    test('preserves an existing authorization header', () {
      final headers = ProxyConfig.mergeAuthHeaders(ProxyConfig.bundler('1'), {
        'authorization': 'Bearer existing-token',
      }, 'proxy-token');

      expect(headers['authorization'], 'Bearer existing-token');
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('ProxyConfig.trxPath', () {
    test('builds mainnet and testnet TRX proxy routes', () {
      expect(
        ProxyConfig.trxPath('jsonrpc'),
        '${ProxyConfig.baseUrl}/v1/trx/main/jsonrpc',
      );
      expect(
        ProxyConfig.trxPath('wallet/getnowblock', isTest: true),
        '${ProxyConfig.baseUrl}/v1/trx/test/wallet/getnowblock',
      );
    });

    test('normalizes a leading slash in TRX proxy paths', () {
      expect(
        ProxyConfig.trxPath('/wallet/getnowblock'),
        '${ProxyConfig.baseUrl}/v1/trx/main/wallet/getnowblock',
      );
    });
  });
}
