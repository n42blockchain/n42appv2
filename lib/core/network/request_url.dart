import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/config/rpc_config.dart';

part 'request_url_testnet.dart';
part 'request_url_mainnet.dart';

class RequestUrl {
  /// 是否已初始化 API keys
  static bool _initialized = false;

  /// 初始化 API keys 和 RPC URLs，在应用启动时调用一次
  static void initializeApiKeys() {
    if (_initialized) return;
    _initialized = true;

    // 更新 testnet URLs
    _requestUrlTest1['ETH']!['rpc'] = RpcConfig.ethSepoliaRpc;
    _requestUrlTest1['S']!['api'] = '${ProxyConfig.explorerSonic}?';

    final btcTestnetRpc = RpcConfig.btcTestnetRpc;
    for (final coin in _btcLikeCoins) {
      if (_requestUrlTest1.containsKey(coin)) {
        _requestUrlTest1[coin]!['rpc'] = btcTestnetRpc;
      }
    }

    // 更新 mainnet URLs — Explorer API 通过代理
    _requestUrlMain1['BNB']!['api'] = '${ProxyConfig.explorerTxlist('bnb')}?';
    _requestUrlMain1['ETH']!['api'] = '${ProxyConfig.explorerTxlist('eth')}?';
    _requestUrlMain1['ETH']!['rpc'] = ProxyConfig.ethRpc;
    _requestUrlMain1['BASE']!['api'] = '${ProxyConfig.explorerTxlist('base')}?';
    _requestUrlMain1['S']!['api'] = '${ProxyConfig.explorerSonic}?';

    final btcMainnetRpc = RpcConfig.btcMainnetRpc;
    for (final coin in _btcLikeCoins) {
      if (_requestUrlMain1.containsKey(coin)) {
        _requestUrlMain1[coin]!['rpc'] = btcMainnetRpc;
      }
    }
  }

  /// BTC-like 币种列表，testnet 和 mainnet 共用
  static const List<String> _btcLikeCoins = [
    'BTC', 'LTC', 'DOGE', 'DASH', 'VIA', 'DGB',
    'MONA', 'FIRO', 'BCH', 'BTG', 'RVN', 'QTUM', 'XEC',
  ];

  String getUrl2(String coinKey, String uriKey, {bool? isTest}) {
    initializeApiKeys();

    coinKey = coinKey.toUpperCase();
    isTest ??= false;

    if (isTest) {
      return requestUrlTest1[coinKey]?[uriKey] ?? '';
    } else {
      return requestUrlMain1[coinKey]?[uriKey] ?? '';
    }
  }

  /// Testnet URLs (getter 以支持动态更新)
  Map<String, dynamic> get requestUrlTest1 => _requestUrlTest1;

  /// Mainnet URLs (getter 以支持动态更新)
  Map<String, dynamic> get requestUrlMain1 => _requestUrlMain1;
}
