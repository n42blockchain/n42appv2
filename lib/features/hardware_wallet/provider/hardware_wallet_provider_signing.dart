// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'hardware_wallet_provider.dart';

/// 签名操作 + RLP 编码 mixin
mixin _HardwareWalletSigningMixin on ChangeNotifier {
  LedgerService get _ledgerService;
  TrezorService get _trezorService;
  HardwareWalletDevice? get _currentDevice;
  bool get isConnected;

  // ============ 签名方法 ============

  /// Executes a signing operation with connection guard and error handling.
  Future<HardwareWalletSignResponse> _guardedSign(
    Future<HardwareWalletSignResponse> Function() action,
  ) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }
    try {
      return await action();
    } on HardwareWalletError catch (e) {
      return HardwareWalletSignResponse.error(e.userFriendlyMessage);
    }
  }

  /// 签名以太坊交易
  Future<HardwareWalletSignResponse> signEthereumTransaction({
    required String derivationPath,
    required Uint8List rawTx,
  }) {
    return _guardedSign(
      () => _ledgerService.signEthereumTransaction(
        derivationPath: derivationPath,
        rawTx: rawTx,
      ),
    );
  }

  /// 签名以太坊消息
  Future<HardwareWalletSignResponse> signEthereumMessage({
    required String derivationPath,
    required String message,
  }) {
    return _guardedSign(
      () => _ledgerService.signEthereumMessage(
        derivationPath: derivationPath,
        message: message,
      ),
    );
  }

  /// 签名比特币交易
  Future<HardwareWalletSignResponse> signBitcoinTransaction({
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) {
    return _guardedSign(
      () => _ledgerService.signBitcoinTransaction(
        derivationPath: derivationPath,
        txData: txData,
      ),
    );
  }

  /// 通用签名方法
  ///
  /// 根据当前设备类型和 coinType 路由到对应的签名实现：
  ///
  /// **Trezor 设备**：
  /// - EVM / BTC / SOL / ATOM / DOT / TRX -> Trezor 平台通道
  ///
  /// **Ledger 设备**：
  /// - EVM 链 -> signEthereumTransaction / signEthereumMessage
  /// - BTC/LTC/DOGE/BCH -> signBitcoinTransaction
  /// - SOL/ATOM/DOT/TRX -> signChainTransaction（native 实现）
  ///
  /// **Keystone 设备**：
  /// - 返回 [HardwareWalletSignResponse] 标记为需要 QR 签名。
  ///   调用方需检测 [needsKeystoneQr] == true，然后导航至 KeystoneSignPage。
  Future<HardwareWalletSignResponse> signTransaction(
    HardwareWalletSignRequest request,
  ) async {
    if (!isConnected) {
      return HardwareWalletSignResponse.error('No device connected');
    }

    final coinType = request.coinType.toUpperCase();

    // ── Trezor ──────────────────────────────────────────────────
    if (_currentDevice?.isTrezor ?? false) {
      return _signWithTrezor(request, coinType);
    }

    // ── Keystone ────────────────────────────────────────────────
    if (_currentDevice?.isKeystone ?? false) {
      return HardwareWalletSignResponse(
        success: false,
        error: null,
        needsKeystoneQr: true,
        rawTxForQr: _isEvmChain(coinType)
            ? _serializeEthTransaction(request.transactionData)
            : null,
      );
    }

    // ── Ledger ──────────────────────────────────────────────────
    return _signWithLedger(request, coinType);
  }

  Future<HardwareWalletSignResponse> _signWithLedger(
    HardwareWalletSignRequest request,
    String coinType,
  ) async {
    if (_isEvmChain(coinType)) {
      if (request.signType == HardwareWalletSignType.message) {
        return signEthereumMessage(
          derivationPath: request.derivationPath,
          message: request.message ?? '',
        );
      }
      final rawTx = _serializeEthTransaction(request.transactionData);
      return signEthereumTransaction(
        derivationPath: request.derivationPath,
        rawTx: rawTx,
      );
    }

    if (_isBitcoinLikeChain(coinType)) {
      return signBitcoinTransaction(
        derivationPath: request.derivationPath,
        txData: request.transactionData,
      );
    }

    // SOL / ATOM / DOT / TRX -- 通过 native 实现
    switch (coinType) {
      case 'SOL':
      case 'ATOM':
      case 'DOT':
      case 'TRX':
        return _ledgerService.signChainTransaction(
          coinType: coinType,
          derivationPath: request.derivationPath,
          txData: request.transactionData,
        );
      default:
        return HardwareWalletSignResponse.error(
          'Unsupported coin type: $coinType',
        );
    }
  }

  Future<HardwareWalletSignResponse> _signWithTrezor(
    HardwareWalletSignRequest request,
    String coinType,
  ) async {
    if (_isEvmChain(coinType)) {
      if (request.signType == HardwareWalletSignType.message) {
        return _trezorService.signMessage(
          derivationPath: request.derivationPath,
          messageBytes: Uint8List.fromList((request.message ?? '').codeUnits),
        );
      }
      if (request.signType == HardwareWalletSignType.typedData) {
        return _trezorService.signTypedData(
          derivationPath: request.derivationPath,
          typedDataJson: request.message ?? '{}',
        );
      }
      return _trezorService.signEthTransaction(
        derivationPath: request.derivationPath,
        txData: request.transactionData,
      );
    }

    if (_isBitcoinLikeChain(coinType)) {
      final psbtHex = request.transactionData['psbtHex'] as String? ?? '';
      return _trezorService.signBtcTransaction(
        derivationPath: request.derivationPath,
        psbtHex: psbtHex,
      );
    }

    // SOL / other via generic channel
    return _trezorService.signChainTransaction(
      coinType: coinType,
      derivationPath: request.derivationPath,
      txData: request.transactionData,
    );
  }

  // ============ RLP 编码 ============

  /// 序列化以太坊交易为 RLP 编码字节
  Uint8List _serializeEthTransaction(Map<String, dynamic> txData) {
    final isEip1559 =
        txData.containsKey('maxFeePerGas') ||
        txData.containsKey('maxPriorityFeePerGas');

    if (isEip1559) {
      return _serializeEip1559Transaction(txData);
    }
    return _serializeLegacyTransaction(txData);
  }

  /// 序列化 EIP-1559 (type 2) 交易
  Uint8List _serializeEip1559Transaction(Map<String, dynamic> txData) {
    final items = <List<int>>[
      _rlpEncode(txData['chainId'] ?? 1),
      _rlpEncode(txData['nonce'] ?? 0),
      _rlpEncode(txData['maxPriorityFeePerGas'] ?? '0x0'),
      _rlpEncode(txData['maxFeePerGas'] ?? '0x0'),
      _rlpEncode(txData['gasLimit'] ?? txData['gas'] ?? '0x0'),
      _rlpEncode(txData['to'] ?? ''),
      _rlpEncode(txData['value'] ?? '0x0'),
      _rlpEncode(txData['data'] ?? '0x'),
      _rlpEncodeList([]),
    ];

    final payload = items.expand((e) => e).toList();
    final rlpList = _rlpEncodeList(payload);

    return Uint8List.fromList([0x02, ...rlpList]);
  }

  /// 序列化 Legacy (type 0) 交易，含 EIP-155 重放保护
  Uint8List _serializeLegacyTransaction(Map<String, dynamic> txData) {
    final chainId = txData['chainId'] ?? 1;

    final items = <List<int>>[
      _rlpEncode(txData['nonce'] ?? 0),
      _rlpEncode(txData['gasPrice'] ?? '0x0'),
      _rlpEncode(txData['gasLimit'] ?? txData['gas'] ?? '0x0'),
      _rlpEncode(txData['to'] ?? ''),
      _rlpEncode(txData['value'] ?? '0x0'),
      _rlpEncode(txData['data'] ?? '0x'),
      _rlpEncode(chainId),
      [0x80],
      [0x80],
    ];

    final payload = items.expand((e) => e).toList();
    return Uint8List.fromList(_rlpEncodeList(payload));
  }

  /// RLP 编码单个值
  List<int> _rlpEncode(dynamic value) {
    if (value is int) {
      if (value == 0) return [0x80];
      if (value < 0x80) return [value];
      final bytes = _intToMinBytes(value);
      return [0x80 + bytes.length, ...bytes];
    }

    if (value is String) {
      final hexStr = value.startsWith('0x') ? value.substring(2) : value;
      if (hexStr.isEmpty) return [0x80];

      final bytes = _hexToBytes(hexStr);

      // Address (20 bytes) -- encode without stripping leading zeros
      if (bytes.length == 20) {
        return _rlpEncodeBytes(bytes);
      }

      final stripped = _stripLeadingZeroBytes(bytes);
      if (stripped.isEmpty) return [0x80];
      if (stripped.length == 1 && stripped[0] < 0x80) return stripped;
      return _rlpEncodeBytes(stripped);
    }

    return [0x80];
  }

  /// RLP 编码字节序列
  List<int> _rlpEncodeBytes(List<int> bytes) {
    if (bytes.length < 56) return [0x80 + bytes.length, ...bytes];
    final lenBytes = _intToMinBytes(bytes.length);
    return [0xb7 + lenBytes.length, ...lenBytes, ...bytes];
  }

  /// RLP 编码列表（已编码的各字段拼接在一起）
  List<int> _rlpEncodeList(List<int> encodedItems) {
    if (encodedItems.isEmpty) return [0xc0];
    if (encodedItems.length < 56) {
      return [0xc0 + encodedItems.length, ...encodedItems];
    }
    final lenBytes = _intToMinBytes(encodedItems.length);
    return [0xf7 + lenBytes.length, ...lenBytes, ...encodedItems];
  }

  /// 将整数转换为最小表示的字节列表（大端序，无前导零）
  List<int> _intToMinBytes(int value) {
    if (value == 0) return [];
    final bytes = <int>[];
    while (value > 0) {
      bytes.add(value & 0xff);
      value >>= 8;
    }
    return bytes.reversed.toList();
  }

  /// 十六进制字符串转字节列表
  List<int> _hexToBytes(String hex) {
    final normalized = hex.length % 2 != 0 ? '0$hex' : hex;
    return [
      for (var i = 0; i < normalized.length; i += 2)
        int.parse(normalized.substring(i, i + 2), radix: 16),
    ];
  }

  /// 去除字节列表前导零
  List<int> _stripLeadingZeroBytes(List<int> bytes) {
    var start = 0;
    while (start < bytes.length && bytes[start] == 0) {
      start++;
    }
    return bytes.sublist(start);
  }
}
