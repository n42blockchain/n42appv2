import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';

class DexSwapApi {
  final String _base;
  final Map<String, String> _header;

  DexSwapApi()
      : _base = AppConfig.getApiUrlOnline('exchangeHost'),
        _header = const {'content-type': 'application/json'};

  /// GET /v1/dex/tokens?chain=ETH[&q=usdc]
  ///
  /// [q] 可选搜索词，后端按 symbol/name/address 模糊过滤。
  /// 传入完整合约地址时可精确查找未预加载的代币。
  Future<MessageModel> getTokens(String chain, {String? q}) async {
    final params = <String, dynamic>{'chain': chain};
    if (q != null && q.isNotEmpty) params['q'] = q;
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_base/v1/dex/tokens',
        params: params,
        header: _header,
      );
      return MessageModel()..data = data['data'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// POST /v1/dex/quote
  ///
  /// [slippageBps] is baked into the returned [calldata] and determines the
  /// minimum output the router will accept on-chain.  Changing it after the
  /// fact has no effect, so always pass the user's current setting.
  Future<MessageModel> getQuote({
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required String userAddr,
    int slippageBps = 50,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$_base/v1/dex/quote',
        params: {},
        data: {
          'chain': chain,
          'token_in': tokenIn,
          'token_out': tokenOut,
          'amount_in': amountIn,
          'user_addr': userAddr,
          'slippage_bps': slippageBps,
        },
        header: _header,
      );
      if (data['code'] == 200) return MessageModel()..data = data['data'];
      return MessageModel.error()
        ..data = data['msg'] ?? data['err'] ?? 'Quote failed';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// POST /v1/dex/commit
  Future<MessageModel> commit(
      String uuid, String orderId, String txHash) async {
    try {
      await BaseApi.requestEmptyH.post(
        '$_base/v1/dex/commit',
        params: {},
        data: {'uuid': uuid, 'order_id': orderId, 'tx_hash': txHash},
        header: _header,
      );
      return MessageModel()..data = true;
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// GET /v1/dex/history?user={uuid}&page=&size=
  Future<MessageModel> getHistory(String uuid,
      {int page = 1, int size = 20}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_base/v1/dex/history',
        params: {'user': uuid, 'page': page, 'size': size},
        header: _header,
      );
      return MessageModel()..data = data['data']['list'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ── ERC-20 approval helpers ───────────────────────────────────────────────

  /// Check current ERC-20 token allowance via `eth_call`.
  ///
  /// Returns the allowance as [BigInt], or [BigInt.zero] on any error.
  ///
  /// [coinType]   — app-internal coin type (ETH, BNB, MATIC, ARB, OP, BASE…)
  /// [tokenAddr]  — ERC-20 contract address
  /// [owner]      — wallet address
  /// [spender]    — router / spender address
  static Future<BigInt> checkAllowance({
    required String coinType,
    required String tokenAddr,
    required String owner,
    required String spender,
  }) async {
    try {
      // allowance(address owner, address spender) → uint256
      // selector: 0xdd62ed3e
      final data = '0xdd62ed3e${_pad32(owner)}${_pad32(spender)}';

      final result = await EthAPI()
          .baseRPCEth(
            'eth_call',
            [
              {'to': tokenAddr, 'data': data},
              'latest',
            ],
            coinType: coinType,
            enableRetry: false,
          )
          .timeout(const Duration(seconds: 6));

      if (result.isSuccess) {
        final hex = result.valueOrNull?.toString() ?? '';
        if (hex.startsWith('0x') && hex.length > 2) {
          return BigInt.parse(hex.substring(2), radix: 16);
        }
      }
      return BigInt.zero;
    } catch (_) {
      return BigInt.zero;
    }
  }

  /// Build ERC-20 `approve(spender, amount)` calldata.
  ///
  /// Passing [amount] = null sets unlimited approval (uint256.max).
  static String buildApproveCalldata(String spender, {BigInt? amount}) {
    // approve(address,uint256) selector: 0x095ea7b3
    final amountHex =
        (amount ?? _maxUint256).toRadixString(16).padLeft(64, '0');
    return '0x095ea7b3${_pad32(spender)}$amountHex';
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Pad an Ethereum address to a 32-byte (64 hex char) ABI word.
  static String _pad32(String addr) {
    final clean = addr.toLowerCase().startsWith('0x')
        ? addr.substring(2).toLowerCase()
        : addr.toLowerCase();
    return clean.padLeft(64, '0');
  }

  static final BigInt _maxUint256 = BigInt.parse(
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    radix: 16,
  );
}
