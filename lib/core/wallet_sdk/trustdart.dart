import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

class Trustdart {
  final MethodChannel _channel = const MethodChannel('trustdart');

  // 生成助记词：128=12词 160=15词 192=18词 228=21词 256=24词
  Future<String> generateMnemonic({String passphrase = '', int length = 128}) async {
    try {
      return await _channel.invokeMethod(
        'generateMnemonic',
        <String, dynamic>{'passphrase': passphrase, 'length': length},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'generateMnemonic: $e');
      return '';
    }
  }

  Future<bool> checkMnemonic(String mnemonic, {String passphrase = ''}) async {
    try {
      return await _channel.invokeMethod(
        'checkMnemonic',
        <String, String>{'mnemonic': mnemonic, 'passphrase': passphrase},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'checkMnemonic: $e');
      return false;
    }
  }

  /// generates an address for a particular coin
  Future<Map> generateAddress(
    String coin,
    String path,
    String addressType, {
    String mnemonic = '',
    String passphrase = '',
    String pk = '',
    bool isImport = false,
    bool isTest = false,
  }) async {
    try {
      return await _channel.invokeMethod(
        'generateAddress',
        <String, String>{
          'coin': coin,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'addressType': addressType,
          'pk': pk,
          'isImport': '$isImport',
          'isTest': '$isTest',
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'generateAddress: $e');
      return {'legacy': ''};
    }
  }

  /// validates address belonging to a particular crypto
  Future<bool> validateAddress(String coin, String address) async {
    try {
      return await _channel.invokeMethod(
        'validateAddress',
        <String, String>{'coin': coin, 'address': address},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'validateAddress: $e');
      return false;
    }
  }

  /// Returns the hex string format of the public key.
  Future<String> getPublicKey(
    String coin,
    String path, {
    String passphrase = '',
    String mnemonic = '',
    String pk = '',
  }) async {
    try {
      return await _channel.invokeMethod(
        'getPublicKey',
        <String, String>{
          'coin': coin,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'pk': pk,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getPublicKey: $e');
      return '';
    }
  }

  /// Returns the hex string format of the private key.
  Future<String> getPrivateKey(
    String mnemonic,
    String coin,
    String path, {
    String passphrase = '',
  }) async {
    try {
      return await _channel.invokeMethod(
        'getPrivateKey',
        <String, String>{
          'coin': coin,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getPrivateKey: $e');
      return '';
    }
  }

  Future<String> getPrivateKeyAndPublicKeyPair(
    String coin,
    String path, {
    String pk = '',
    String mnemonic = '',
    String passphrase = '',
  }) async {
    try {
      return await _channel.invokeMethod(
        'getPrivateKeyAndPublicKey',
        <String, String>{
          'coin': coin,
          'path': path,
          'mnemonic': mnemonic,
          'privateKey': pk,
          'passphrase': passphrase,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getPrivateKeyAndPublicKeyPair: $e');
      return '';
    }
  }

  /// 返回最大交易金额
  Future<String> signTransactionMaxValue(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) => _invokeSignTx('getTransactionMaxValue', coin, path, txData,
      mnemonic: mnemonic, pk: pk, passphrase: passphrase);

  /// signs a transaction
  Future<String> signTransaction(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) => _invokeSignTx('signTransaction', coin, path, txData,
      mnemonic: mnemonic, pk: pk, passphrase: passphrase);

  Future<String> signTransactionG(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) => _invokeSignTx('signTransaction_g', coin, path, txData,
      mnemonic: mnemonic, pk: pk, passphrase: passphrase);

  Future<String> signTransactionBtcP2wsh(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) => _invokeSignTx('signTransaction_btc_p2wsh', coin, path, txData,
      mnemonic: mnemonic, pk: pk, passphrase: passphrase);

  Future<Map> signTransactionByteArray(
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    try {
      final String raw = await _channel.invokeMethod(
        'signTransaction_byteArray',
        <String, dynamic>{
          'coin': coin,
          'txData': txData,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'pk': pk,
        },
      );
      return json.decode(raw);
    } catch (e) {
      AppLogger.w('Trustdart', 'signTransactionByteArray: $e');
      return {'result': false, 'signHash': ''};
    }
  }

  Future<String> signMessage(
    String coin,
    String path,
    String txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    try {
      return await _channel.invokeMethod(
        'signMessage',
        <String, dynamic>{
          'coin': coin,
          'txData': txData,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'pk': pk,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'signMessage: $e');
      return '';
    }
  }

  /// 内部辅助：统一的签名交易 invokeMethod 调用模板（返回 txHash 字符串）
  Future<String> _invokeSignTx(
    String method,
    String coin,
    String path,
    Map txData, {
    String mnemonic = '',
    String pk = '',
    String passphrase = '',
  }) async {
    try {
      final String txHash = await _channel.invokeMethod(
        method,
        <String, dynamic>{
          'coin': coin,
          'txData': txData,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'pk': pk,
        },
      );
      return txHash;
    } catch (e) {
      AppLogger.w('Trustdart', '$method: $e');
      return '';
    }
  }

  /// Signs a TonConnect ton_proof challenge with the TON Ed25519 private key.
  /// Returns a JSON string with timestamp, domain, payload, and signature,
  /// or null on failure.
  Future<String?> signTonProof({
    required String mnemonic,
    required String path,
    required String domain,
    required int timestamp,
    required String payload,
    required String address,
  }) async {
    try {
      return await _channel.invokeMethod(
        'signTonProof',
        <String, dynamic>{
          'mnemonic': mnemonic,
          'path': path,
          'domain': domain,
          'timestamp': timestamp,
          'payload': payload,
          'address': address,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'signTonProof: $e');
      return null;
    }
  }

  /// Returns the base64-encoded TON v4R2 wallet StateInit BOC for the given
  /// mnemonic and derivation path.  Used for TonConnect 2.0 sessionProperties.
  Future<String?> getTonWalletStateInit(String mnemonic, String path) async {
    try {
      return await _channel.invokeMethod(
        'getTonWalletStateInit',
        <String, String>{'mnemonic': mnemonic, 'path': path},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getTonWalletStateInit: $e');
      return null;
    }
  }

  // 返回 keystore
  Future<String> getKeyStore(
    String coin,
    String path,
    String addressType,
    String passphrase, {
    String mnemonic = '',
    String pk = '',
  }) async {
    try {
      return await _channel.invokeMethod(
        'getKeyStore',
        <String, dynamic>{
          'coin': coin,
          'path': path,
          'mnemonic': mnemonic,
          'passphrase': passphrase,
          'addressType': addressType,
          'pk': pk,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getKeyStore: $e');
      return '';
    }
  }

  // 根据 keystore 返回 privateKey、address 等信息
  Future<Map> getWalletInfoWithKeyStore(
    String keyStore,
    String coin,
    String passphrase,
  ) async {
    try {
      return await _channel.invokeMethod(
        'getWalletInfoWithKeyStore',
        <String, dynamic>{
          'keyStore': keyStore,
          'coin': coin,
          'passphrase': passphrase,
        },
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getWalletInfoWithKeyStore: $e');
      return {'address': '', 'privateKey': ''};
    }
  }

  // 返回 Solana token account
  Future<String> getPubKeySOL(String address, String mintAddress) async {
    try {
      return await _channel.invokeMethod(
        'getPubKeySOL',
        <String, dynamic>{'address': address, 'mintAddress': mintAddress},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getPubKeySOL: $e');
      return '';
    }
  }

  // 获取权限（暂时只支持 iOS）
  Future<String> getPermissions(String pType) async {
    try {
      return await _channel.invokeMethod(
        'Permissions',
        <String, dynamic>{'pName': pType},
      );
    } catch (e) {
      AppLogger.w('Trustdart', 'getPermissions: $e');
      return '';
    }
  }

  // evm
  Future<Map<String, dynamic>?> evmEmit(Map<String, dynamic> params) async {
    try {
      final String raw = await _channel.invokeMethod('EvmEmit', params);
      return jsonDecode(raw);
    } catch (e) {
      AppLogger.w('Trustdart', 'evmEmit: $e');
      return null;
    }
  }
}
