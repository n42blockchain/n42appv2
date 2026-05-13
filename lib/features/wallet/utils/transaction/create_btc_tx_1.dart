import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/bip340.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:web3dart/web3dart.dart';

import 'btc_tx_builder.dart';
import 'btc_tx_crypto.dart';

/// BTC 交易创建器 V1：支持 SegWit P2WPKH 和 Taproot P2TR 两种签名路径
class CreateBTCTXV1 {
  final BtcTxCrypto _crypto = BtcTxCrypto();
  final BtcTxBuilder _builder = BtcTxBuilder();

  /// 创建多输入 SegWit 交易（P2WPKH 使用 ECDSA，Taproot tb1p 使用 Schnorr）
  Future<String> create(
    String wifPrivateKey,
    String recipientAddress,
    double sendValue,
    List<dynamic> inputs,
    String fromAddress,
    Uint8List pubKey,
    String pubKeyStr,
    String recipientScriptPubkey,
    Uint8List scriptByte,
    ECPrivate pk,
  ) async {
    final BigInt privateKey = _crypto.decodeWif(wifPrivateKey);
    final int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    const int fee = 10000;

    final (selectedUTXOs, totalInput) =
        await _selectUTXOs(inputs, sendAmount, fee);
    if (totalInput < sendAmount + fee) throw Exception("余额不足！");

    final int changeAmount = totalInput - sendAmount - fee;
    final Map<String, dynamic> rawTx = _builder.createRawTransactionSegwit(
        selectedUTXOs, recipientAddress, sendAmount, changeAmount,
        fromAddress, pubKey, pubKeyStr);

    String txHashStr = hex.encode(rawTx['txRow'] as Uint8List);
    AppLogger.d('CreateBTCTXV1', 'raw tx: $txHashStr');

    // 逐输入签名：Taproot 地址用 Schnorr，其余用 ECDSA
    final List<Uint8List> signs = [];
    final List<Uint8List> txRowAll =
        (rawTx['txRowAll'] as List).cast<Uint8List>();
    for (int i = 0; i < txRowAll.length; i++) {
      final String addr =
          selectedUTXOs[i]['scriptpubkey_address'].toString();
      if (addr.length >= 4 && addr.substring(0, 4) == "tb1p") {
        signs.add(Bip340().schnorrSign(txRowAll[i], privateKey));
      } else {
        signs.add(_crypto.signWithPrivateKey(txRowAll[i], privateKey));
      }
    }

    // 构建 witness 数据并拼接到交易
    for (final Uint8List sig in signs) {
      final ByteData data = ByteData(180);
      int offset = 0;
      data.setUint8(offset, 0x01);
      offset++;
      data.setUint8(offset, sig.length);
      offset++;
      data.buffer.asUint8List().setRange(offset, offset + sig.length, sig);
      offset += sig.length;
      txHashStr += bytesToHex(data.buffer.asUint8List(0, offset));
    }
    txHashStr += "00000000";
    return txHashStr;
  }

  /// 创建单输入 Taproot 交易（仅使用 Schnorr 签名）
  Future<String> createV2(
    String wifPrivateKey,
    String recipientAddress,
    double sendValue,
    List<dynamic> inputs,
    String fromAddress,
    Uint8List pubKey,
    String pubKeyStr,
    String recipientScriptPubkey,
    Uint8List scriptByte,
    ECPrivate pk,
  ) async {
    final BigInt privateKey = _crypto.decodeWif(wifPrivateKey);
    final int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    const int fee = 10000;

    final (selectedUTXOs, totalInput) =
        await _selectUTXOs(inputs, sendAmount, fee);
    if (totalInput < sendAmount + fee) throw Exception("余额不足！");

    final int changeAmount = totalInput - sendAmount - fee;
    final Map<String, dynamic> rawTx = _builder.createRawTransactionSegwitV2(
        selectedUTXOs, recipientAddress, sendAmount, changeAmount,
        fromAddress, pubKey, pubKeyStr);

    String txHashStr = hex.encode(rawTx['txRow'] as Uint8List);
    AppLogger.d('CreateBTCTXV1', 'raw tx: $txHashStr');

    final Uint8List signature =
        Bip340().schnorrSign(rawTx['txRowAll'] as Uint8List, privateKey);

    final ByteData data = ByteData(180);
    int offset = 0;
    data.setUint8(offset, 0x01);
    offset++;
    data.setUint8(offset, signature.length);
    offset++;
    data.buffer.asUint8List()
        .setRange(offset, offset + signature.length, signature);
    offset += signature.length;

    txHashStr += hex.encode(data.buffer.asUint8List(0, offset));
    txHashStr += "00000000";
    return txHashStr;
  }

  /// 从 UTXO 列表中选取足够金额的 UTXOs，返回已选列表与累计金额
  Future<(List<Map<String, dynamic>>, int)> _selectUTXOs(
    List<dynamic> inputs,
    int sendAmount,
    int fee,
  ) async {
    final List<Map<String, dynamic>> selectedUTXOs = [];
    int totalInputAmount = 0;

    for (final Map utxo in inputs) {
      totalInputAmount += utxo['value'] as int;
      final MessageModel utxoTx = await getUTXOTxid(utxo['txid'] as String);
      if (utxoTx.error == false) {
        final String scriptpk =
            utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk.isNotEmpty) {
          selectedUTXOs.add({
            "txid": utxo['txid'],
            "vout": utxo['vout'],
            "amount": utxo['value'],
            "scriptPubKey": scriptpk,
            "scriptpubkey_address":
                utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ??
                    "",
          });
        }
      }
      if (totalInputAmount >= sendAmount + fee) break;
    }

    return (selectedUTXOs, totalInputAmount);
  }

  /// 通过 mempool.space 查询 UTXO 所在交易的详情
  Future<MessageModel> getUTXOTxid(String txid) async {
    try {
      final String uri =
          "https://mempool.space/testnet4/api/tx/$txid";
      final data = await BaseApi.requestEmptyH.get(
        uri,
        params: {},
        defaultReturn: false,
        header: {"Content-Type": "application/json"},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }
}
