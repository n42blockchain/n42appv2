import 'package:dio/dio.dart';

import 'bot_command_registry.dart';
import '../../domain/entities/bot_command_entity.dart';
import '../../integration/wallet_bridge.dart';
import '../utils/debug_log.dart';

/// Bot 命令处理器
///
/// 解析并执行聊天室内的斜杠命令（/price、/balance、/chains、/help 等）。
/// 纯本地处理，不需要外部服务器，结果通过 [BotCommandResult] 返回给 UI。
class BotCommandProcessor {
  final IWalletBridge _walletBridge;
  final Dio _dio;
  final BotCommandRegistry _registry;
  final String _priceApiBase;
  final String? _authToken;
  final bool _useProxyEndpoint;

  static final RegExp _whitespaceRegExp = RegExp(r'\s+');
  static final RegExp _numberFormatRegExp =
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  /// CoinGecko 免费公共 API（无需 API Key）
  static const _defaultPriceApiBase = 'https://api.coingecko.com/api/v3';

  /// N42 支持的链数量
  static const _chainCount = 236;

  /// N42 代表性链列表（用于 /chains 命令展示）
  static const _featuredChains = [
    'Ethereum',
    'BNB Smart Chain',
    'Polygon',
    'Arbitrum',
    'Optimism',
    'Avalanche',
    'Solana',
    'Base',
    'Fantom',
    'Cronos',
    'zkSync Era',
    'Linea',
    'Scroll',
    'Starknet',
    'Aptos',
    'Sui',
    'Near',
    'Cosmos',
    'Polkadot',
    'Tron',
    'Bitcoin (wrapped)',
    'Litecoin (wrapped)',
    'TON',
    '... and 213+ more',
  ];

  BotCommandProcessor({
    required IWalletBridge walletBridge,
    String priceApiBase = _defaultPriceApiBase,
    String? authToken,
    bool useProxyEndpoint = false,
    Dio? dio,
    BotCommandRegistry? registry,
  }) : _walletBridge = walletBridge,
       _registry = registry ?? BotCommandRegistry.instance,
       _priceApiBase = priceApiBase.endsWith('/')
           ? priceApiBase.substring(0, priceApiBase.length - 1)
           : priceApiBase,
       _authToken = authToken,
       _useProxyEndpoint = useProxyEndpoint,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 5),
               receiveTimeout: const Duration(seconds: 5),
             ),
           );

  /// 解析命令字符串并执行
  ///
  /// [rawText] 是以 '/' 开头的原始输入文本，例如 "/price BTC"
  Future<BotCommandResult> processRaw(String rawText) async {
    final trimmed = rawText.trim();
    if (!trimmed.startsWith('/')) return const BotCommandResult.unknown();

    final parts = trimmed.substring(1).split(_whitespaceRegExp);
    final command = parts.first.toLowerCase();
    final args = parts.skip(1).toList();

    return process(command: command, args: args, rawText: trimmed);
  }

  /// 执行指定命令
  Future<BotCommandResult> process({
    required String command,
    List<String> args = const [],
    String? rawText,
  }) async {
    switch (command) {
      case 'help':
        return _handleHelp();
      case 'price':
        return _handlePrice(args);
      case 'balance':
        return _handleBalance();
      case 'chains':
        return _handleChains();
      case 'announce':
        return _handleAnnounce(args);
      default:
        final customResult = await _handleCustomCommand(
          command,
          args,
          rawText ?? '/$command ${args.join(' ')}'.trim(),
        );
        if (customResult != null) {
          return customResult;
        }
        // 未知命令
        final known = BuiltInBotCommands.find(command);
        if (known != null) {
          // 已知但需要特殊处理（poll/welcome 由 UI 层处理）
          return const BotCommandResult.dismiss();
        }
        return BotCommandResult.error(
          'Unknown command: /$command\nType /help to see available commands.',
        );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Command Handlers
  // ─────────────────────────────────────────────────────────────────────────

  BotCommandResult _handleHelp() {
    final buffer = StringBuffer();
    buffer.writeln('📋 Available Commands\n');
    final allCommands = [...BuiltInBotCommands.all, ..._registry.definitions]
      ..sort((a, b) => a.command.compareTo(b.command));
    for (final cmd in allCommands) {
      final adminTag = cmd.adminOnly ? ' 🔒' : '';
      buffer.writeln('/${cmd.usage.replaceFirst('/', '')}$adminTag');
      buffer.writeln('  ${cmd.description}\n');
    }
    buffer.writeln(
      '💡 N42 supports $_chainCount+ chains — more than any other chat platform.',
    );
    return BotCommandResult.showPanel(
      title: '🤖 Bot Commands',
      content: buffer.toString(),
    );
  }

  Future<BotCommandResult> _handlePrice(List<String> args) async {
    if (args.isEmpty) {
      return const BotCommandResult.error(
        'Usage: /price <token>\nExample: /price bitcoin',
      );
    }

    final symbol = args.first.toLowerCase();

    // 尝试映射常见符号到 CoinGecko ID
    final coinId = _symbolToId(symbol);

    try {
      final url = _useProxyEndpoint
          ? '$_priceApiBase/simple_price'
          : '$_priceApiBase/simple/price';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'ids': coinId,
          'vs_currencies': 'usd',
          'include_24hr_change': true,
          'include_market_cap': true,
        },
        options: Options(
          headers: {
            if (_useProxyEndpoint &&
                _authToken != null &&
                _authToken.isNotEmpty)
              'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey(coinId)) {
          final info = data[coinId] as Map<String, dynamic>;
          final price = info['usd'] as num?;
          final change = info['usd_24h_change'] as num?;
          final mcap = info['usd_market_cap'] as num?;

          if (price != null) {
            final changeStr = change != null
                ? (change >= 0
                      ? '📈 +${change.toStringAsFixed(2)}%'
                      : '📉 ${change.toStringAsFixed(2)}%')
                : '';

            final formattedPrice = price >= 1
                ? '\$${_formatNumber(price.toDouble())}'
                : '\$${price.toStringAsFixed(6)}';

            final mcapStr = mcap != null
                ? '\nMarket Cap: \$${_formatLargeNumber(mcap.toDouble())}'
                : '';
            final attribution = _useProxyEndpoint
                ? 'Powered by CoinGecko via N42 Proxy'
                : 'Powered by CoinGecko';

            return BotCommandResult.showPanel(
              title: '💰 ${symbol.toUpperCase()} Price',
              content:
                  'Price: $formattedPrice\n24h Change: $changeStr$mcapStr\n\n$attribution',
            );
          }
        }
        return BotCommandResult.error(
          'Token "$symbol" not found.\nTry using the full name (e.g., /price bitcoin)',
        );
      }
    } catch (e) {
      debugLog('BotCommandProcessor price error: $e');
      return const BotCommandResult.error(
        'Failed to fetch price. Please try again.',
      );
    }

    return const BotCommandResult.error('Could not retrieve price data.');
  }

  BotCommandResult _handleBalance() {
    final address = _walletBridge.walletAddress;
    if (address == null || address.isEmpty) {
      return const BotCommandResult.error(
        'No wallet connected.\nConnect your wallet to check balance.',
      );
    }

    final shortAddr = _formatWalletAddress(address);
    return BotCommandResult.showPanel(
      title: '👛 Wallet',
      content:
          'Address: $shortAddr\n\nOpen N42 Wallet to view full balances across $_chainCount+ chains.',
    );
  }

  BotCommandResult _handleChains() {
    final buffer = StringBuffer();
    buffer.writeln('⛓️ N42 supports $_chainCount+ chains\n');
    buffer.writeln('Featured networks:\n');
    for (final chain in _featuredChains) {
      buffer.writeln('• $chain');
    }
    buffer.writeln('\n🏆 More than Telegram TON (1 chain)\n');
    buffer.writeln('Use /balance to check your assets across all chains.');
    return BotCommandResult.showPanel(
      title: '⛓️ Supported Chains ($_chainCount+)',
      content: buffer.toString(),
    );
  }

  BotCommandResult _handleAnnounce(List<String> args) {
    if (args.isEmpty) {
      return const BotCommandResult.error('Usage: /announce <message>');
    }
    final message = args.join(' ');
    return BotCommandResult.sendMessage('📢 **Announcement**\n\n$message');
  }

  Future<BotCommandResult?> _handleCustomCommand(
    String command,
    List<String> args,
    String rawText,
  ) async {
    final handler = _registry.findHandler(command);
    if (handler == null) return null;
    try {
      return await handler.handle(
        BotCommandRequest(
          command: command,
          args: args,
          rawText: rawText,
        ),
      );
    } catch (e) {
      debugLog('BotCommandProcessor custom command error: $e');
      return BotCommandResult.error(
        'Command /$command failed. Please try again.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// 将常见 token 符号转换为 CoinGecko ID
  String _symbolToId(String symbol) {
    const map = {
      'btc': 'bitcoin',
      'eth': 'ethereum',
      'bnb': 'binancecoin',
      'sol': 'solana',
      'matic': 'matic-network',
      'avax': 'avalanche-2',
      'ton': 'the-open-network',
      'ada': 'cardano',
      'dot': 'polkadot',
      'link': 'chainlink',
      'uni': 'uniswap',
      'ltc': 'litecoin',
      'xlm': 'stellar',
      'atom': 'cosmos',
      'near': 'near',
      'apt': 'aptos',
      'sui': 'sui',
      'arb': 'arbitrum',
      'op': 'optimism',
      'ftm': 'fantom',
    };
    return map[symbol.toLowerCase()] ?? symbol.toLowerCase();
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return value
          .toStringAsFixed(2)
          .replaceAllMapped(
            _numberFormatRegExp,
            (m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }

  String _formatLargeNumber(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    return value.toStringAsFixed(0);
  }

  String _formatWalletAddress(String address) {
    if (address.length <= 10) {
      return address;
    }

    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
