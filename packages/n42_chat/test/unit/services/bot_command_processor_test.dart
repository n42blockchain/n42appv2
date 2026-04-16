import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/bot_command_registry.dart';
import 'package:n42_chat/src/core/services/bot_command_processor.dart';
import 'package:n42_chat/src/domain/entities/bot_command_entity.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';

class _ShortAddressWalletBridge extends NoOpWalletBridge {
  @override
  String? get walletAddress => 'abc123';
}

class _EchoBotHandler implements BotCommandHandler {
  @override
  List<BotCommandDefinition> get commands => const [
        BotCommandDefinition(
          command: 'echo',
          usage: '/echo <text>',
          description: 'Echo back custom integration payload',
        ),
      ];

  @override
  Future<BotCommandResult?> handle(BotCommandRequest request) async {
    return BotCommandResult.sendMessage('echo:${request.args.join(' ')}');
  }
}

void main() {
  group('BotCommandProcessor', () {
    final registry = BotCommandRegistry.instance;

    setUp(() {
      registry.clear();
    });

    test('routes /price through the proxy endpoint with bearer auth', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.path,
              'https://api.n42.ai/proxy/v1/market/simple_price',
            );
            expect(options.queryParameters['ids'], 'bitcoin');
            expect(options.queryParameters['vs_currencies'], 'usd');
            expect(options.headers['Authorization'], 'Bearer proxy-token');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'bitcoin': {
                    'usd': 123.45,
                    'usd_24h_change': 1.23,
                    'usd_market_cap': 1000000000,
                  },
                },
              ),
            );
          },
        ),
      );

      final processor = BotCommandProcessor(
        walletBridge: NoOpWalletBridge(),
        priceApiBase: 'https://api.n42.ai/proxy/v1/market',
        authToken: 'proxy-token',
        useProxyEndpoint: true,
        dio: dio,
      );

      final result = await processor.process(command: 'price', args: ['btc']);

      expect(result.type, BotCommandResultType.showPanel);
      expect(result.panelTitle, '💰 BTC Price');
      expect(result.panelContent, contains('\$123.45'));
      expect(result.panelContent, contains('via N42 Proxy'));
    });

    test('returns an error result when the proxy request fails', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(requestOptions: options, error: 'network down'),
            );
          },
        ),
      );

      final processor = BotCommandProcessor(
        walletBridge: NoOpWalletBridge(),
        priceApiBase: 'https://api.n42.ai/proxy/v1/market',
        authToken: 'proxy-token',
        useProxyEndpoint: true,
        dio: dio,
      );

      final result = await processor.process(command: 'price', args: ['btc']);

      expect(result.type, BotCommandResultType.error);
      expect(result.errorMessage, contains('Failed to fetch price'));
    });

    test('formats short wallet addresses without substring overflow', () async {
      final processor = BotCommandProcessor(
        walletBridge: _ShortAddressWalletBridge(),
      );

      final result = await processor.process(command: 'balance');

      expect(result.type, BotCommandResultType.showPanel);
      expect(result.panelContent, contains('Address: abc123'));
    });

    test('routes custom commands through the shared registry', () async {
      registry.registerHandler(_EchoBotHandler());
      final processor = BotCommandProcessor(
        walletBridge: NoOpWalletBridge(),
        registry: registry,
      );

      final result = await processor.processRaw('/echo hello world');

      expect(result.type, BotCommandResultType.sendMessage);
      expect(result.messageText, 'echo:hello world');
    });

    test('help output includes registered custom commands', () async {
      registry.registerHandler(_EchoBotHandler());
      final processor = BotCommandProcessor(
        walletBridge: NoOpWalletBridge(),
        registry: registry,
      );

      final result = await processor.process(command: 'help');

      expect(result.type, BotCommandResultType.showPanel);
      expect(result.panelContent, contains('/echo <text>'));
      expect(
        result.panelContent,
        contains('Echo back custom integration payload'),
      );
    });
  });
}
