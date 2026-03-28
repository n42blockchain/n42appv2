// Tests for pure-Dart classes in bundler_config.dart:
//   BundlerConfig, BundlerProviders, BundlerStrategy, MultiBundlerConfig,
//   BundlerHealthCheck — no network, platform, or native dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/bundler/bundler_config.dart';

void main() {
  // ─────────────────────────────────────────────────
  // BundlerStrategy enum
  // ─────────────────────────────────────────────────

  group('BundlerStrategy enum', () {
    test('has 4 values', () {
      expect(BundlerStrategy.values.length, 4);
    });

    test('contains all expected values', () {
      expect(BundlerStrategy.values, containsAll([
        BundlerStrategy.primary,
        BundlerStrategy.fallback,
        BundlerStrategy.race,
        BundlerStrategy.roundRobin,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerConfig — constructor
  // ─────────────────────────────────────────────────

  group('BundlerConfig constructor', () {
    const cfg = BundlerConfig(
      name: 'TestProvider',
      urlTemplate: 'https://example.com/{chainId}/rpc',
      supportedChainIds: {1, 137},
    );

    test('stores name', () {
      expect(cfg.name, 'TestProvider');
    });

    test('stores urlTemplate', () {
      expect(cfg.urlTemplate, 'https://example.com/{chainId}/rpc');
    });

    test('requiresApiKey defaults to true', () {
      expect(cfg.requiresApiKey, isTrue);
    });

    test('supportsSponsorship defaults to false', () {
      expect(cfg.supportsSponsorship, isFalse);
    });

    test('rateLimit defaults to null', () {
      expect(cfg.rateLimit, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerConfig.getUrl
  // ─────────────────────────────────────────────────

  group('BundlerConfig.getUrl', () {
    const pimlico = BundlerConfig(
      name: 'Pimlico',
      urlTemplate: 'https://api.pimlico.io/v2/{chainId}/rpc',
      requiresApiKey: true,
      supportedChainIds: {1},
    );

    test('replaces {chainId} with actual chain ID', () {
      final url = pimlico.getUrl(1);
      expect(url, 'https://api.pimlico.io/v2/1/rpc');
    });

    test('uses different chain IDs correctly', () {
      expect(pimlico.getUrl(137), 'https://api.pimlico.io/v2/137/rpc');
    });

    test('appends apikey when requiresApiKey=true and apiKey provided', () {
      final url = pimlico.getUrl(1, apiKey: 'mykey123');
      expect(url, 'https://api.pimlico.io/v2/1/rpc?apikey=mykey123');
    });

    test('no apiKey param → URL has no query string', () {
      final url = pimlico.getUrl(1);
      expect(url, isNot(contains('?apikey')));
    });

    test('apiKey ignored when requiresApiKey=false', () {
      const noKeyConfig = BundlerConfig(
        name: 'NoKey',
        urlTemplate: 'https://public.rpc/{chainId}',
        requiresApiKey: false,
        supportedChainIds: {1},
      );
      final url = noKeyConfig.getUrl(1, apiKey: 'ignored');
      expect(url, isNot(contains('?apikey')));
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerConfig.supportsChain
  // ─────────────────────────────────────────────────

  group('BundlerConfig.supportsChain', () {
    const cfg = BundlerConfig(
      name: 'Test',
      urlTemplate: 'https://rpc/{chainId}',
      supportedChainIds: {1, 137, 8453},
    );

    test('chainId in set → true', () {
      expect(cfg.supportsChain(1), isTrue);
      expect(cfg.supportsChain(137), isTrue);
    });

    test('chainId not in set → false', () {
      expect(cfg.supportsChain(999), isFalse);
      expect(cfg.supportsChain(0), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerProviders — pre-configured instances
  // ─────────────────────────────────────────────────

  group('BundlerProviders.pimlico', () {
    test('name is Pimlico', () {
      expect(BundlerProviders.pimlico.name, 'Pimlico');
    });

    test('supports Ethereum mainnet (1)', () {
      expect(BundlerProviders.pimlico.supportsChain(1), isTrue);
    });

    test('supports Sepolia testnet (11155111)', () {
      expect(BundlerProviders.pimlico.supportsChain(11155111), isTrue);
    });

    test('supportsSponsorship is true', () {
      expect(BundlerProviders.pimlico.supportsSponsorship, isTrue);
    });

    test('rateLimit is 10', () {
      expect(BundlerProviders.pimlico.rateLimit, 10);
    });
  });

  group('BundlerProviders.stackup', () {
    test('name is StackUp', () {
      expect(BundlerProviders.stackup.name, 'StackUp');
    });

    test('supports Ethereum mainnet (1)', () {
      expect(BundlerProviders.stackup.supportsChain(1), isTrue);
    });

    test('does NOT support Sepolia (11155111)', () {
      expect(BundlerProviders.stackup.supportsChain(11155111), isFalse);
    });

    test('supportsSponsorship is false', () {
      expect(BundlerProviders.stackup.supportsSponsorship, isFalse);
    });
  });

  group('BundlerProviders.alchemy', () {
    test('name is Alchemy', () {
      expect(BundlerProviders.alchemy.name, 'Alchemy');
    });

    test('rateLimit is 30', () {
      expect(BundlerProviders.alchemy.rateLimit, 30);
    });

    test('supportsSponsorship is true', () {
      expect(BundlerProviders.alchemy.supportsSponsorship, isTrue);
    });
  });

  group('BundlerProviders.all', () {
    test('contains 3 providers', () {
      expect(BundlerProviders.all.length, 3);
    });

    test('contains pimlico, stackup and alchemy', () {
      final names = BundlerProviders.all.map((p) => p.name).toList();
      expect(names, containsAll(['Pimlico', 'StackUp', 'Alchemy']));
    });
  });

  group('BundlerProviders.getByName', () {
    // getByName return type is BundlerConfig? but firstWhere without
    // orElse throws StateError when not found. Use ! for found cases.
    test('exact case match returns correct provider', () {
      final p = BundlerProviders.getByName('Pimlico')!;
      expect(p.name, 'Pimlico');
    });

    test('case-insensitive match works (lowercase query)', () {
      final p = BundlerProviders.getByName('pimlico')!;
      expect(p.name, 'Pimlico');
    });

    test('finds StackUp', () {
      final p = BundlerProviders.getByName('StackUp')!;
      expect(p.name, 'StackUp');
    });

    test('finds Alchemy', () {
      final p = BundlerProviders.getByName('alchemy')!;
      expect(p.name, 'Alchemy');
    });

    test('unknown name returns null', () {
      expect(BundlerProviders.getByName('unknown'), isNull);
    });
  });

  group('BundlerProviders.getForChain', () {
    test('Ethereum (chainId 1) supported by all 3 providers', () {
      final result = BundlerProviders.getForChain(1);
      expect(result.length, 3);
    });

    test('chainId not in any provider → empty list', () {
      final result = BundlerProviders.getForChain(99999);
      expect(result, isEmpty);
    });

    test('Sepolia (11155111) supported by pimlico and base sepolia', () {
      final result = BundlerProviders.getForChain(11155111);
      // Only pimlico supports Sepolia
      expect(result.length, 1);
      expect(result.first.name, 'Pimlico');
    });
  });

  // ─────────────────────────────────────────────────
  // MultiBundlerConfig — constructor
  // ─────────────────────────────────────────────────

  group('MultiBundlerConfig constructor', () {
    test('stores primaryUrl and entryPoint', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://primary.rpc',
        entryPoint: '0xEntryPoint',
      );
      expect(cfg.primaryUrl, 'https://primary.rpc');
      expect(cfg.entryPoint, '0xEntryPoint');
    });

    test('backupUrls defaults to empty list', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://rpc',
        entryPoint: '0xEP',
      );
      expect(cfg.backupUrls, isEmpty);
    });

    test('strategy defaults to fallback', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://rpc',
        entryPoint: '0xEP',
      );
      expect(cfg.strategy, BundlerStrategy.fallback);
    });

    test('apiKeys defaults to null', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://rpc',
        entryPoint: '0xEP',
      );
      expect(cfg.apiKeys, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // MultiBundlerConfig.allUrls
  // ─────────────────────────────────────────────────

  group('MultiBundlerConfig.allUrls', () {
    test('no backupUrls → only primary', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://primary',
        entryPoint: '0xEP',
      );
      expect(cfg.allUrls, ['https://primary']);
    });

    test('with backupUrls → primary then backups in order', () {
      const cfg = MultiBundlerConfig(
        primaryUrl: 'https://primary',
        backupUrls: ['https://backup1', 'https://backup2'],
        entryPoint: '0xEP',
      );
      expect(cfg.allUrls, [
        'https://primary',
        'https://backup1',
        'https://backup2',
      ]);
    });
  });

  // ─────────────────────────────────────────────────
  // MultiBundlerConfig.applyApiKey
  // ─────────────────────────────────────────────────

  group('MultiBundlerConfig.applyApiKey', () {
    const cfg = MultiBundlerConfig(
      primaryUrl: 'https://primary',
      entryPoint: '0xEP',
      apiKeys: {'Pimlico': 'secret123'},
    );

    test('known provider name → appends ?apikey=', () {
      final url = cfg.applyApiKey('https://api.pimlico.io/v2/1/rpc', 'Pimlico');
      expect(url, 'https://api.pimlico.io/v2/1/rpc?apikey=secret123');
    });

    test('unknown provider name → URL unchanged', () {
      final url = cfg.applyApiKey('https://other.rpc', 'Unknown');
      expect(url, 'https://other.rpc');
    });

    test('null apiKeys → URL unchanged', () {
      const noKeys = MultiBundlerConfig(
        primaryUrl: 'https://rpc',
        entryPoint: '0xEP',
      );
      final url = noKeys.applyApiKey('https://rpc', 'Pimlico');
      expect(url, 'https://rpc');
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerHealthCheck — factories
  // ─────────────────────────────────────────────────

  group('BundlerHealthCheck.healthy factory', () {
    test('isHealthy is true', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 120,
      );
      expect(hc.isHealthy, isTrue);
    });

    test('stores url and responseTimeMs', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 85,
      );
      expect(hc.url, 'https://bundler.rpc');
      expect(hc.responseTimeMs, 85);
    });

    test('error is null', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 100,
      );
      expect(hc.error, isNull);
    });

    test('entryPoints can be set', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 100,
        entryPoints: ['0xEP1'],
      );
      expect(hc.entryPoints, ['0xEP1']);
    });

    test('timestamp is set (not null)', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 0,
      );
      expect(hc.timestamp, isNotNull);
    });
  });

  group('BundlerHealthCheck.unhealthy factory', () {
    test('isHealthy is false', () {
      final hc = BundlerHealthCheck.unhealthy(
        url: 'https://dead.rpc',
        error: 'Connection refused',
      );
      expect(hc.isHealthy, isFalse);
    });

    test('stores error message', () {
      final hc = BundlerHealthCheck.unhealthy(
        url: 'https://dead.rpc',
        error: 'timeout',
      );
      expect(hc.error, 'timeout');
    });

    test('responseTimeMs defaults to 0', () {
      final hc = BundlerHealthCheck.unhealthy(
        url: 'https://dead.rpc',
        error: 'error',
      );
      expect(hc.responseTimeMs, 0);
    });

    test('can override responseTimeMs', () {
      final hc = BundlerHealthCheck.unhealthy(
        url: 'https://dead.rpc',
        error: 'error',
        responseTimeMs: 5000,
      );
      expect(hc.responseTimeMs, 5000);
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerHealthCheck.toString
  // ─────────────────────────────────────────────────

  group('BundlerHealthCheck.toString', () {
    test('healthy → contains url and "ms"', () {
      final hc = BundlerHealthCheck.healthy(
        url: 'https://bundler.rpc',
        responseTimeMs: 42,
      );
      final str = hc.toString();
      expect(str, contains('https://bundler.rpc'));
      expect(str, contains('42ms'));
      expect(str, contains('healthy'));
    });

    test('unhealthy → contains url and error', () {
      final hc = BundlerHealthCheck.unhealthy(
        url: 'https://dead.rpc',
        error: 'connection refused',
      );
      final str = hc.toString();
      expect(str, contains('https://dead.rpc'));
      expect(str, contains('connection refused'));
      expect(str, contains('unhealthy'));
    });
  });
}
