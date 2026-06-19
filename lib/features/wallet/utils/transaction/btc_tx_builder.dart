import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:web3dart/web3dart.dart';

import 'btc_tx_crypto.dart';
import 'btc_tx_script.dart';

/// BTC 原始交易构建器：SegWit 输入/输出序列化、签名预映像生成
class BtcTxBuilder {
  final BtcTxCrypto _crypto = BtcTxCrypto();
  final BtcTxScript _script = BtcTxScript();

  /// 将 txid（小端）+ vout 写入 ByteData，返回写入后的 offset
  int _writeTxidVout(ByteData data, int offset, Map<String, dynamic> input) {
    final txidBytes = Uint8List.fromList(
      hex.decode(input['txid']).reversed.toList(),
    );
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;
    data.setUint32(offset, input['vout'] as int, Endian.little);
    return offset + 4;
  }

  /// 构建 uint32 小端字节
  Uint8List _uint32LE(int value) {
    final bd = ByteData(4);
    bd.setUint32(0, value, Endian.little);
    return bd.buffer.asUint8List(0, 4);
  }

  /// 构建单字节
  Uint8List _uint8(int value) {
    final bd = ByteData(1);
    bd.setUint8(0, value);
    return bd.buffer.asUint8List(0, 1);
  }

  /// 构建 SegWit 标记字节 (0x00, 0x01)
  Uint8List _segwitTag() {
    final bd = ByteData(2);
    bd.setUint8(0, 0x00);
    bd.setUint8(1, 0x01);
    return bd.buffer.asUint8List(0, 2);
  }

  /// 将多个 Uint8List 拼接为一个
  Uint8List _concat(List<Uint8List> parts) {
    final totalLength = parts.fold<int>(0, (sum, p) => sum + p.length);
    final result = Uint8List(totalLength);
    int offset = 0;
    for (final part in parts) {
      result.setRange(offset, offset + part.length, part);
      offset += part.length;
    }
    return result;
  }

  /// 构建单个输入的序列化字节（不含 scriptSig，sequence=0xFFFFFFFF）
  Uint8List createRawInput(Map<String, dynamic> input) {
    final ByteData data = ByteData(180);
    int offset = _writeTxidVout(data, 0, input);

    // P2WPKH 输入不含 scriptSig
    data.setUint8(offset, 0x00);
    offset += 1;
    data.setUint32(offset, 0xffffffff, Endian.little);
    offset += 4;

    return data.buffer.asUint8List(0, offset);
  }

  /// 构建带 scriptPubKey 的输入序列化字节（用于签名预映像）
  Uint8List createRawInputAll(Map<String, dynamic> input) {
    final ByteData data = ByteData(180);
    int offset = _writeTxidVout(data, 0, input);

    final scriptBytes = Uint8List.fromList(hex.decode(input['scriptPubKey']));
    data.buffer.asUint8List().setRange(
      offset,
      offset + scriptBytes.length,
      scriptBytes,
    );
    offset += scriptBytes.length;

    data.setUint32(offset, 0xffffffff, Endian.little);
    offset += 4;

    return data.buffer.asUint8List(0, offset);
  }

  /// 构建传统（非 SegWit）原始交易字节（含 SegWit 标记位）
  Uint8List createRawTransaction(
    List<Map<String, dynamic>> inputs,
    String recipient,
    int sendAmount,
    int changeAmount,
    String fromAddress,
    Uint8List publicKey,
    String pubKeyStr,
    String recipientScriptPubkey,
  ) {
    final int estimatedSize = 200 + (inputs.length * 180);
    final ByteData data = ByteData(estimatedSize);
    int offset = 0;

    // 版本号
    data.setUint32(offset, 1, Endian.little);
    offset += 4;

    // SegWit 标记
    data.setUint8(offset, 0x00);
    offset += 1;
    data.setUint8(offset, 0x01);
    offset += 1;
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输入数量
    data.setUint8(offset, inputs.length);
    offset += 1;
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输入列表
    for (var input in inputs) {
      offset = _writeTxidVout(data, offset, input);
      data.setUint8(offset, 0x00); // 空 scriptSig
      offset += 1;
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输出数量
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 接收方输出
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    final scriptPubKey = _script.getScriptPubKey(
      Uint8List.fromList(hex.decode(recipientScriptPubkey)),
    );
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));
    data.buffer.asUint8List().setRange(
      offset,
      offset + scriptPubKey.length,
      scriptPubKey,
    );
    offset += scriptPubKey.length;
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 找零输出
    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;
      final changeScript = _script.getP2WPKHScript(publicKey);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(
        offset,
        offset + changeScript.length,
        changeScript,
      );
      offset += changeScript.length;
    }
    AppLogger.d('BtcTxBuilder', bytesToHex(data.buffer.asUint8List(0, offset)));

    return data.buffer.asUint8List(0, offset);
  }

  /// 构建 SegWit 交易映射（含 txRow 和各输入的签名预映像 txRowAll）
  ///
  /// 用于多输入场景，每个输入独立生成签名预映像。
  Map<String, dynamic> createRawTransactionSegwit(
    List<Map<String, dynamic>> inputs,
    String recipient,
    int sendAmount,
    int changeAmount,
    String fromAddress,
    Uint8List publicKey,
    String pubKeyStr,
  ) {
    final trxMap = _buildSegwitBase(
      inputs: inputs,
      recipient: recipient,
      sendAmount: sendAmount,
      changeAmount: changeAmount,
      fromAddress: fromAddress,
      versionNum: 2,
    );

    // 拼接完整交易字节（txRow）
    final ips = _concat(trxMap['inputs'] as List<Uint8List>);
    final output2 = trxMap['output2'] as Uint8List? ?? Uint8List(0);
    trxMap['txRow'] = _concat([
      trxMap['version'] as Uint8List,
      trxMap['tag'] as Uint8List,
      trxMap['inputCount'] as Uint8List,
      ips,
      trxMap['outputCount'] as Uint8List,
      trxMap['output1'] as Uint8List,
      output2,
    ]);

    // 各输入的签名预映像（txRowAll）
    final locktime = _uint32LE(0);
    final sighashAll = _uint32LE(1);
    final inputsList = trxMap['inputs'] as List<Uint8List>;
    final inputsAllList = trxMap['inputsAll'] as List<Uint8List>;

    final List<Uint8List> txRawAll = [];
    for (int j = 0; j < inputsList.length; j++) {
      final parts = <Uint8List>[];
      for (int i = 0; i < inputsList.length; i++) {
        parts.add(i == j ? inputsAllList[i] : inputsList[i]);
      }
      final row = _concat([
        trxMap['version'] as Uint8List,
        trxMap['tag'] as Uint8List,
        trxMap['inputCount'] as Uint8List,
        _concat(parts),
        trxMap['outputCount'] as Uint8List,
        trxMap['output1'] as Uint8List,
        output2,
        locktime,
        sighashAll,
      ]);
      txRawAll.add(row);
    }
    trxMap['txRowAll'] = txRawAll;

    return trxMap;
  }

  /// 构建 Taproot/P2TR SegWit 交易映射（含 TapSighash 格式的签名预映像）
  ///
  /// 格式参考 BIP-341：TapSighash | Version | Locktime |
  /// HashPrevouts | HashAmounts | HashScriptPubKeys | HashSequences |
  /// HashOutputs | KeyVersion | SighashType
  Map<String, dynamic> createRawTransactionSegwitV2(
    List<Map<String, dynamic>> inputs,
    String recipient,
    int sendAmount,
    int changeAmount,
    String fromAddress,
    Uint8List publicKey,
    String pubKeyStr,
  ) {
    final trxMap = _buildSegwitBase(
      inputs: inputs,
      recipient: recipient,
      sendAmount: sendAmount,
      changeAmount: changeAmount,
      fromAddress: fromAddress,
      versionNum: 1,
    );

    // 拼接 txRow
    final ips = _concat(trxMap['inputs'] as List<Uint8List>);
    final output2 = trxMap['output2'] as Uint8List? ?? Uint8List(0);
    trxMap['txRow'] = _concat([
      trxMap['version'] as Uint8List,
      trxMap['tag'] as Uint8List,
      trxMap['inputCount'] as Uint8List,
      ips,
      trxMap['outputCount'] as Uint8List,
      trxMap['output1'] as Uint8List,
      output2,
    ]);

    // 构建 TapSighash 签名预映像（BIP-341）
    final tapSighash = _crypto.sha256s(utf8.encode('TapSighash'));
    final version = trxMap['version'] as Uint8List;
    final locktime = _uint32LE(0xffffffff);

    // HashPrevouts / HashAmounts / HashScriptPubKeys / HashSequences
    final hashPrevoutsData = ByteData(inputs.length * 36);
    final hashAmountsData = ByteData(inputs.length * 8);
    final hashScriptPubKeysData = ByteData(inputs.length * 100);
    final hashSequencesData = ByteData(inputs.length * 4);
    int off1 = 0, off2 = 0, off3 = 0, off4 = 0;

    for (var input in inputs) {
      final txidBytes = Uint8List.fromList(
        hex.decode(input['txid']).reversed.toList(),
      );
      hashPrevoutsData.buffer.asUint8List().setRange(
        off1,
        off1 + 32,
        txidBytes,
      );
      off1 += 32;
      hashPrevoutsData.setUint32(off1, input['vout'] as int, Endian.little);
      off1 += 4;

      hashAmountsData.setUint64(off2, changeAmount, Endian.little);
      off2 += 8;

      final scriptBytes = Uint8List.fromList(hex.decode(input['scriptPubKey']));
      hashScriptPubKeysData.buffer.asUint8List().setRange(
        off3,
        off3 + scriptBytes.length,
        scriptBytes,
      );
      off3 += scriptBytes.length;

      hashSequencesData.setUint32(off4, 0xffffffff, Endian.little);
      off4 += 4;
    }

    final inputData = _concat([
      _crypto.sha256s(hashPrevoutsData.buffer.asUint8List(0, off1)),
      _crypto.sha256s(hashAmountsData.buffer.asUint8List(0, off2)),
      _crypto.sha256s(hashScriptPubKeysData.buffer.asUint8List(0, off3)),
      _crypto.sha256s(hashSequencesData.buffer.asUint8List(0, off4)),
    ]);

    // HashOutputs
    final outputData = _concat([trxMap['output1'] as Uint8List, output2]);
    final outputDataHash = _crypto.sha256s(outputData);

    // KeyVersion（0x00）+ SighashType（SIGHASH_ALL = 0x00）
    trxMap['txRowAll'] = _concat([
      tapSighash,
      version,
      locktime,
      inputData,
      outputDataHash,
      _uint8(0), // KeyVersion
      _uint8(0), // SighashType
    ]);

    return trxMap;
  }

  /// 构建 SegWit 交易的公共部分（version/tag/inputs/outputs）
  Map<String, dynamic> _buildSegwitBase({
    required List<Map<String, dynamic>> inputs,
    required String recipient,
    required int sendAmount,
    required int changeAmount,
    required String fromAddress,
    required int versionNum,
  }) {
    final trxMap = <String, dynamic>{
      'version': _uint32LE(versionNum),
      'tag': _segwitTag(),
      'inputCount': _uint8(inputs.length),
      'inputs': inputs.map(createRawInput).toList(),
      'inputsAll': inputs.map(createRawInputAll).toList(),
      'outputCount': _uint8(changeAmount > 0 ? 2 : 1),
      'output1': _buildOutput(
        sendAmount,
        _script.getScriptPubKeyFromBech32(recipient),
      ),
    };

    if (changeAmount > 0) {
      trxMap['output2'] = _buildOutput(
        changeAmount,
        _script.getScriptPubKeyFromBech32(fromAddress),
      );
    }

    return trxMap;
  }

  /// 构建单个输出的序列化字节（金额 + scriptPubKey 长度前缀 + scriptPubKey）
  Uint8List _buildOutput(int amount, Uint8List scriptPubKey) {
    final ByteData data = ByteData(180);
    int offset = 0;
    data.setUint64(offset, amount, Endian.little);
    offset += 8;
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    data.buffer.asUint8List().setRange(
      offset,
      offset + scriptPubKey.length,
      scriptPubKey,
    );
    offset += scriptPubKey.length;
    return data.buffer.asUint8List(0, offset);
  }
}
