import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart'
    show selectedWalletIndexProvider;
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:eip712/eip712.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'package:wallet/wallet.dart' as wallet_types;

/// Callback to show a signing confirmation dialog.
/// Returns `true` if the user approved, `false` if rejected.
typedef DAppSigningCallback =
    Future<bool> Function({
      required String origin,
      required String method,
      required Map<String, dynamic> details,
    });

class DAppRequestHandler {
  final List<CoinModel> ethCoinModels;
  int _selectedChainIndex;
  final Trustdart _trustdart = Trustdart();

  web3.Web3Client? _web3client;

  /// Fallback origin when [handleRequest] is called without one.
  /// 多标签浏览器必须改用 handleRequest 的 origin 参数——该字段是共享可变
  /// 状态，等待用户确认期间会被另一标签的请求覆盖。
  String dappOrigin = 'DApp';

  DAppRequestHandler({required this.ethCoinModels, int initialChainIndex = 0})
    : _selectedChainIndex = initialChainIndex;

  /// Currently selected chain's hex chain ID (e.g. "0x1")
  String get chainIdHex {
    if (ethCoinModels.isEmpty) return '0x1';
    final cm = ethCoinModels[_selectedChainIndex];
    final id = cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'];
    return '0x${id.toRadixString(16)}';
  }

  /// Currently selected chain's integer chain ID
  int get chainIdInt {
    if (ethCoinModels.isEmpty) return 1;
    final cm = ethCoinModels[_selectedChainIndex];
    return cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'];
  }

  /// Current wallet address
  String get address {
    if (ethCoinModels.isEmpty) return '';
    return ethCoinModels[_selectedChainIndex].address.toString();
  }

  /// Current selected chain index
  int get selectedChainIndex => _selectedChainIndex;

  /// Get the RPC URL for the current chain
  String get _rpcUrl {
    final cm = ethCoinModels[_selectedChainIndex];
    return cm.isTest ? cm.coin['service_test'] : cm.coin['service'];
  }

  /// Callback for signing requests — set by BrowserPage
  DAppSigningCallback? onSigningRequest;

  /// Handle a DApp JSON-RPC request and return the result.
  /// Throws on error (caller converts to JSON-RPC error).
  ///
  /// [origin] 是发起请求页面的 origin；多标签场景每个请求都必须显式传入，
  /// 否则回落到共享的 [dappOrigin]（可能被并发请求覆盖）。
  Future<dynamic> handleRequest(
    String method,
    List<dynamic> params, {
    String? origin,
  }) async {
    final requestOrigin = origin ?? dappOrigin;
    switch (method) {
      case 'eth_requestAccounts':
      case 'eth_accounts':
        return [address];

      case 'eth_chainId':
        return chainIdHex;

      case 'net_version':
        return chainIdInt.toString();

      case 'eth_coinbase':
        return address;

      case 'wallet_switchEthereumChain':
        return _handleSwitchChain(params);

      case 'wallet_addEthereumChain':
        // Try to switch if we already support the chain; otherwise error
        return _handleSwitchChain(params);

      case 'personal_sign':
        return _handlePersonalSign(params, requestOrigin);

      case 'eth_sign':
        // eth_sign is dangerous (signs arbitrary data) — reject by default
        throw Exception(
          'eth_sign is disabled for security reasons. Use personal_sign instead.',
        );

      case 'eth_signTypedData':
      case 'eth_signTypedData_v3':
      case 'eth_signTypedData_v4':
        return _handleSignTypedData(method, params, requestOrigin);

      case 'eth_sendTransaction':
        return _handleSendTransaction(params, requestOrigin);

      case 'eth_signTransaction':
        return _handleSignTransaction(params, requestOrigin);

      // RPC pass-through methods
      case 'eth_call':
      case 'eth_getBalance':
      case 'eth_getTransactionCount':
      case 'eth_getTransactionReceipt':
      case 'eth_getTransactionByHash':
      case 'eth_blockNumber':
      case 'eth_getBlockByNumber':
      case 'eth_getBlockByHash':
      case 'eth_gasPrice':
      case 'eth_estimateGas':
      case 'eth_getCode':
      case 'eth_getLogs':
      case 'eth_getStorageAt':
      case 'eth_maxPriorityFeePerGas':
      case 'eth_feeHistory':
        return _forwardToRpc(method, params);

      default:
        // Reject unknown methods instead of blindly forwarding
        throw {'code': -32601, 'message': 'Method not supported: $method'};
    }
  }

  // ── Chain switching ────────────────────────────────────────────────────────

  String? _handleSwitchChain(List<dynamic> params) {
    if (params.isEmpty) {
      throw {'code': -32602, 'message': 'Missing params'};
    }
    final chainParam = params[0];
    if (chainParam is! Map) {
      throw {'code': -32602, 'message': 'Invalid chain params'};
    }
    final chainIdRaw = chainParam['chainId'];
    if (chainIdRaw is! String) {
      throw {'code': -32602, 'message': 'Invalid chainId'};
    }
    // EIP-1193 hex quantity 的 "0x" 前缀大小写均合法，剥前缀需大小写不敏感
    // （十六进制数字本身 int.tryParse(radix:16) 已天然兼容大小写）
    final chainIdStripped =
        chainIdRaw.startsWith('0x') || chainIdRaw.startsWith('0X')
        ? chainIdRaw.substring(2)
        : chainIdRaw;
    final targetChainId = int.tryParse(chainIdStripped, radix: 16);
    if (targetChainId == null) {
      throw {'code': -32602, 'message': 'Invalid chainId format'};
    }

    for (int i = 0; i < ethCoinModels.length; i++) {
      final cm = ethCoinModels[i];
      final cmChainId = cm.isTest
          ? cm.coin['chainId_test']
          : cm.coin['chainId'];
      if (cmChainId == targetChainId) {
        _selectedChainIndex = i;
        _web3client?.dispose();
        _web3client = null;
        return null; // success (null means no error)
      }
    }
    throw {'code': 4902, 'message': 'Unrecognized chain ID'};
  }

  // ── Signing methods ────────────────────────────────────────────────────────

  Future<String> _handlePersonalSign(
    List<dynamic> params,
    String origin,
  ) async {
    // 裸字符串会被上层归一化为 -32603，参数校验失败按规范应报 -32602
    if (params.length < 2) {
      throw {'code': -32602, 'message': 'Invalid params'};
    }
    final rawData = params[0] as String;
    // Verify the requested address matches our wallet
    final requestedAddress = (params[1] as String).toLowerCase();
    if (requestedAddress != address.toLowerCase()) {
      throw {'code': -32602, 'message': 'Address mismatch'};
    }
    // Ask user for approval — show the actual DApp origin
    final approved = await _requestApproval(
      origin: origin,
      method: 'personal_sign',
      details: {'message': rawData},
    );
    if (!approved) throw {'code': 4001, 'message': 'User rejected'};

    final privateKey = await _getPrivateKey();
    final stripped = web3.strip0x(rawData);
    final encodedMessage = _isValidHex(stripped)
        ? web3.hexToBytes(stripped)
        : Uint8List.fromList(utf8.encode(rawData));
    final signedData = privateKey.signPersonalMessageToUint8List(
      encodedMessage,
    );
    return bytesToHex(signedData, include0x: true);
  }

  // eth_sign intentionally removed — dangerous method that signs arbitrary data.
  // DApps should use personal_sign or eth_signTypedData instead.

  Future<String> _handleSignTypedData(
    String method,
    List<dynamic> params,
    String origin,
  ) async {
    if (params.length < 2) {
      throw {'code': -32602, 'message': 'Invalid params'};
    }
    final requestedAddress = (params[0] as String).toLowerCase();
    if (requestedAddress != address.toLowerCase()) {
      throw {'code': -32602, 'message': 'Address mismatch'};
    }
    final jsonData = params[1] as String;

    final approved = await _requestApproval(
      origin: origin,
      method: method,
      details: {'data': jsonData},
    );
    if (!approved) throw {'code': 4001, 'message': 'User rejected'};

    final privateKey = await _getPrivateKey();

    final Map<String, dynamic> typedData = json.decode(jsonData);
    final typedMessage = TypedMessage.fromJson(typedData);

    final version = method.contains('v3')
        ? TypedDataVersion.v3
        : TypedDataVersion.v4;
    final hash = hashTypedData(typedData: typedMessage, version: version);
    final signature = web3.sign(hash, privateKey.privateKey);

    final r = signature.r.toRadixString(16).padLeft(64, '0');
    final s = signature.s.toRadixString(16).padLeft(64, '0');
    final v = signature.v.toRadixString(16).padLeft(2, '0');
    return '0x$r$s$v';
  }

  // ── Transaction methods ────────────────────────────────────────────────────

  Future<String> _handleSendTransaction(
    List<dynamic> params,
    String origin,
  ) async {
    if (params.isEmpty) {
      throw {'code': -32602, 'message': 'Invalid params'};
    }
    final txMap = params[0] as Map<String, dynamic>;

    // Validate the from address matches our wallet to prevent spoofing
    final txFrom = (txMap['from'] as String?)?.toLowerCase();
    if (txFrom != null &&
        txFrom.isNotEmpty &&
        txFrom != address.toLowerCase()) {
      throw {'code': -32602, 'message': 'From address does not match wallet'};
    }

    final approved = await _requestApproval(
      origin: origin,
      method: 'eth_sendTransaction',
      details: txMap,
    );
    if (!approved) throw {'code': 4001, 'message': 'User rejected'};

    final privateKey = await _getPrivateKey();
    final web3client = await _getWeb3Client();

    final transaction = _buildTransaction(txMap);
    final cm = ethCoinModels[_selectedChainIndex];
    return web3client.sendTransaction(
      privateKey,
      transaction,
      chainId: cm.isTest ? cm.coin['chainId_test'] : cm.coin['chainId'],
    );
  }

  Future<String> _handleSignTransaction(
    List<dynamic> params,
    String origin,
  ) async {
    if (params.isEmpty) {
      throw {'code': -32602, 'message': 'Invalid params'};
    }
    final txMap = params[0] as Map<String, dynamic>;

    // Validate the from address matches our wallet to prevent spoofing
    final txFrom = (txMap['from'] as String?)?.toLowerCase();
    if (txFrom != null &&
        txFrom.isNotEmpty &&
        txFrom != address.toLowerCase()) {
      throw {'code': -32602, 'message': 'From address does not match wallet'};
    }

    final approved = await _requestApproval(
      origin: origin,
      method: 'eth_signTransaction',
      details: txMap,
    );
    if (!approved) throw {'code': 4001, 'message': 'User rejected'};

    final privateKey = await _getPrivateKey();
    final web3client = await _getWeb3Client();

    final transaction = _buildTransaction(txMap);
    final signed = await web3client.signTransaction(privateKey, transaction);
    return bytesToHex(signed, include0x: true);
  }

  // ── RPC forwarding ─────────────────────────────────────────────────────────

  Future<dynamic> _forwardToRpc(String method, List<dynamic> params) async {
    final client = Client();
    try {
      final response = await client.post(
        Uri.parse(_rpcUrl),
        headers: ProxyConfig.mergeAuthHeaders(_rpcUrl, {
          'Content-Type': 'application/json',
        }),
        body: json.encode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': method,
          'params': params,
        }),
      );
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body.containsKey('error')) {
        throw body['error'];
      }
      return body['result'];
    } finally {
      client.close();
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  Future<bool> _requestApproval({
    required String origin,
    required String method,
    required Map<String, dynamic> details,
  }) {
    if (onSigningRequest == null) return Future.value(false);
    return onSigningRequest!(origin: origin, method: method, details: details);
  }

  Future<web3.EthPrivateKey> _getPrivateKey() async {
    final walletService = globalProviderContainer.read(walletServiceProvider);
    if (walletService == null) throw 'Wallet service not available';

    // 私钥必须来自与对外 address 同一账户。address 用 ethCoinModels(=当前
    // 活跃钱包 selectedWalletIndex);此前却用 miningWalletIndex 取私钥——用户
    // 切换过挖矿钱包(miningIndex≠selectedIndex)时会用 A 账户私钥签、却以 B
    // 账户地址报给 DApp(接线复审第二轮 P1 安全)。
    final selectedIndex = globalProviderContainer.read(
      selectedWalletIndexProvider,
    );
    final currentIndex = selectedIndex >= 0 ? selectedIndex : 0;
    String? pKey = await walletService.getPrivateKeyForWallet(currentIndex);

    if (pKey == null) {
      final mnemonic = await walletService.getMnemonicForWallet(currentIndex);
      if (mnemonic != null) {
        final cm = ethCoinModels[_selectedChainIndex];
        pKey = await _trustdart.getPrivateKey(
          mnemonic,
          cm.coin['coinType'],
          getPathWithIndex(cm.coin['path']['legacy'], cm.pathIndex),
        );
      }
    }

    if (pKey == null) throw 'Could not get private key';

    final decodedKey = base64Decode(pKey);
    if (decodedKey.length != 32) throw 'Invalid private key length';
    return web3.EthPrivateKey(decodedKey);
  }

  Future<web3.Web3Client> _getWeb3Client() async {
    _web3client ??= web3.Web3Client(_rpcUrl, Client());
    return _web3client!;
  }

  /// Parse a hex or decimal string to BigInt.
  /// DApps send values as hex (e.g. "0xde0b6b3a7640000") per JSON-RPC spec.
  static BigInt _parseBigInt(String s) {
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return BigInt.parse(s.substring(2), radix: 16);
    }
    return BigInt.tryParse(s) ?? BigInt.zero;
  }

  /// Parse a hex or decimal string to int.
  static int? _parseInt(String s) {
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return int.tryParse(s.substring(2), radix: 16);
    }
    return int.tryParse(s);
  }

  web3.Transaction _buildTransaction(Map<String, dynamic> txMap) {
    final from = txMap['from'] as String?;
    final to = txMap['to'] as String?;
    final value = txMap['value'] as String?;
    final data = txMap['data'] as String?;
    final gasLimit = txMap['gas'] as String? ?? txMap['gasLimit'] as String?;
    final gasPrice = txMap['gasPrice'] as String?;
    final maxFeePerGas = txMap['maxFeePerGas'] as String?;
    final maxPriorityFeePerGas = txMap['maxPriorityFeePerGas'] as String?;
    final nonce = txMap['nonce'] as String?;

    return web3.Transaction(
      from: from != null ? wallet_types.EthereumAddress.fromHex(from) : null,
      to: to != null ? wallet_types.EthereumAddress.fromHex(to) : null,
      value: value != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei,
              _parseBigInt(value),
            )
          : null,
      gasPrice: gasPrice != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei,
              _parseBigInt(gasPrice),
            )
          : null,
      maxFeePerGas: maxFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei,
              _parseBigInt(maxFeePerGas),
            )
          : null,
      maxPriorityFeePerGas: maxPriorityFeePerGas != null
          ? wallet_types.EtherAmount.fromBigInt(
              wallet_types.EtherUnit.wei,
              _parseBigInt(maxPriorityFeePerGas),
            )
          : null,
      maxGas: gasLimit != null ? _parseInt(gasLimit) : null,
      nonce: nonce != null ? _parseInt(nonce) : null,
      data: (data != null && data != '0x') ? web3.hexToBytes(data) : null,
    );
  }

  static final RegExp _hexRegExp = RegExp(r'^[0-9a-fA-F]+$');

  static bool _isValidHex(String s) {
    if (s.isEmpty) return false;
    return _hexRegExp.hasMatch(s);
  }

  void dispose() {
    _web3client?.dispose();
    _web3client = null;
  }
}
