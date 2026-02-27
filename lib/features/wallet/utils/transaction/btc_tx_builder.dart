import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

import 'btc_tx_crypto.dart';
import 'btc_tx_script.dart';

/// BTC 原始交易构建器：SegWit 输入/输出序列化、签名预映像生成
class BtcTxBuilder {
  final BtcTxCrypto _crypto = BtcTxCrypto();
  final BtcTxScript _script = BtcTxScript();

  /// 构建单个输入的序列化字节（不含 scriptSig，sequence=0xFFFFFFFF）
  Uint8List createRawInput(Map<String, dynamic> input) {
    final ByteData data = ByteData(180);
    int offset = 0;

    final Uint8List txidBytes =
        Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;
    data.setUint32(offset, input['vout'] as int, Endian.little);
    offset += 4;

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
    int offset = 0;

    final Uint8List txidBytes =
        Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;
    data.setUint32(offset, input['vout'] as int, Endian.little);
    offset += 4;

    final Uint8List scriptBytes =
        Uint8List.fromList(hex.decode(input['scriptPubKey']).toList());
    data.buffer.asUint8List().setRange(
        offset, offset + scriptBytes.length, scriptBytes);
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
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输入数量
    data.setUint8(offset, inputs.length);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输入列表
    for (var input in inputs) {
      final Uint8List txidBytes =
          Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
      offset += 32;
      data.setUint32(offset, input['vout'] as int, Endian.little);
      offset += 4;
      data.setUint8(offset, 0x00); // 空 scriptSig
      offset += 1;
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输出数量
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 接收方输出
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    final Uint8List scriptPubKey =
        _script.getScriptPubKey(Uint8List.fromList(hex.decode(recipientScriptPubkey)));
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    data.buffer.asUint8List().setRange(
        offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 找零输出
    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;
      final Uint8List changeScript = _script.getP2WPKHScript(publicKey);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(
          offset, offset + changeScript.length, changeScript);
      offset += changeScript.length;
    }
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

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
    final Map<String, dynamic> trxMap = {};

    // 版本号（version=2）
    final ByteData dataVersion = ByteData(4);
    dataVersion.setUint32(0, 2, Endian.little);
    trxMap['version'] = dataVersion.buffer.asUint8List(0, 4);

    // SegWit 标记
    final ByteData dataTag = ByteData(2);
    dataTag.setUint8(0, 0x00);
    dataTag.setUint8(1, 0x01);
    trxMap['tag'] = dataTag.buffer.asUint8List(0, 2);

    // 输入数量
    final ByteData dataInputCount = ByteData(1);
    dataInputCount.setUint8(0, inputs.length);
    trxMap['inputCount'] = dataInputCount.buffer.asUint8List(0, 1);

    // 普通输入序列化（不含 scriptPubKey）
    trxMap['inputs'] = inputs.map(createRawInput).toList();

    // 带 scriptPubKey 的输入序列化（用于签名）
    trxMap['inputsAll'] = inputs.map(createRawInputAll).toList();

    // 输出数量
    final ByteData dataOutputCount = ByteData(1);
    dataOutputCount.setUint8(0, changeAmount > 0 ? 2 : 1);
    trxMap['outputCount'] = dataOutputCount.buffer.asUint8List(0, 1);

    // 接收方输出
    trxMap['output1'] = _buildOutput(sendAmount,
        _script.getScriptPubKeyFromBech32(recipient));

    // 找零输出
    if (changeAmount > 0) {
      trxMap['output2'] = _buildOutput(changeAmount,
          _script.getScriptPubKeyFromBech32(fromAddress));
    }

    // 拼接完整交易字节（txRow）
    Uint8List ips = trxMap['inputs'][0] as Uint8List;
    for (int i = 1; i < (trxMap['inputs'] as List).length; i++) {
      ips = Uint8List.fromList(ips + (trxMap['inputs'][i] as Uint8List));
    }
    final Uint8List output2 = trxMap['output2'] as Uint8List? ?? Uint8List(0);
    trxMap['txRow'] = Uint8List.fromList(
        (trxMap['version'] as Uint8List) +
        (trxMap['tag'] as Uint8List) +
        (trxMap['inputCount'] as Uint8List) +
        ips +
        (trxMap['outputCount'] as Uint8List) +
        (trxMap['output1'] as Uint8List) +
        output2);

    // 各输入的签名预映像（txRowAll）
    final ByteData dataSignAll = ByteData(4);
    dataSignAll.setUint32(0, 1, Endian.little);
    final ByteData dataLocktime = ByteData(4);
    dataLocktime.setUint32(0, 0, Endian.little);

    final List<Uint8List> txRawAll = [];
    final int inputCount = (trxMap['inputs'] as List).length;
    for (int j = 0; j < inputCount; j++) {
      Uint8List ipsAll = Uint8List(0);
      for (int i = 0; i < inputCount; i++) {
        final Uint8List part = (i == j)
            ? trxMap['inputsAll'][i] as Uint8List
            : trxMap['inputs'][i] as Uint8List;
        ipsAll = Uint8List.fromList(ipsAll + part);
      }
      final Uint8List row = Uint8List.fromList(
          (trxMap['version'] as Uint8List) +
          (trxMap['tag'] as Uint8List) +
          (trxMap['inputCount'] as Uint8List) +
          ipsAll +
          (trxMap['outputCount'] as Uint8List) +
          (trxMap['output1'] as Uint8List) +
          output2);
      txRawAll.add(Uint8List.fromList(
          row +
          dataLocktime.buffer.asUint8List(0, 4) +
          dataSignAll.buffer.asUint8List(0, 4)));
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
    final Map<String, dynamic> trxMap = {};

    // 版本号（version=1，Taproot）
    final ByteData dataVersion = ByteData(4);
    dataVersion.setUint32(0, 1, Endian.little);
    trxMap['version'] = dataVersion.buffer.asUint8List(0, 4);

    // SegWit 标记
    final ByteData dataTag = ByteData(2);
    dataTag.setUint8(0, 0x00);
    dataTag.setUint8(1, 0x01);
    trxMap['tag'] = dataTag.buffer.asUint8List(0, 2);

    // 输入数量
    final ByteData dataInputCount = ByteData(1);
    dataInputCount.setUint8(0, inputs.length);
    trxMap['inputCount'] = dataInputCount.buffer.asUint8List(0, 1);

    // 输入序列化
    trxMap['inputs'] = inputs.map(createRawInput).toList();
    trxMap['inputsAll'] = inputs.map(createRawInputAll).toList();

    // 输出数量
    final ByteData dataOutputCount = ByteData(1);
    dataOutputCount.setUint8(0, changeAmount > 0 ? 2 : 1);
    trxMap['outputCount'] = dataOutputCount.buffer.asUint8List(0, 1);

    // 输出
    trxMap['output1'] = _buildOutput(sendAmount,
        _script.getScriptPubKeyFromBech32(recipient));
    if (changeAmount > 0) {
      trxMap['output2'] = _buildOutput(changeAmount,
          _script.getScriptPubKeyFromBech32(fromAddress));
    }

    // 拼接 txRow
    Uint8List ips = trxMap['inputs'][0] as Uint8List;
    for (int i = 1; i < (trxMap['inputs'] as List).length; i++) {
      ips = Uint8List.fromList(ips + (trxMap['inputs'][i] as Uint8List));
    }
    final Uint8List output2 = trxMap['output2'] as Uint8List? ?? Uint8List(0);
    trxMap['txRow'] = Uint8List.fromList(
        (trxMap['version'] as Uint8List) +
        (trxMap['tag'] as Uint8List) +
        (trxMap['inputCount'] as Uint8List) +
        ips +
        (trxMap['outputCount'] as Uint8List) +
        (trxMap['output1'] as Uint8List) +
        output2);

    // 构建 TapSighash 签名预映像（BIP-341）
    final Uint8List tapSighash =
        _crypto.sha256s(utf8.encode('TapSighash'));
    final Uint8List version = trxMap['version'] as Uint8List;

    final ByteData locktimeData = ByteData(4);
    locktimeData.setUint32(0, 0xffffffff, Endian.little);
    final Uint8List locktime = locktimeData.buffer.asUint8List(0, 4);

    // HashPrevouts / HashAmounts / HashScriptPubKeys / HashSequences
    final ByteData hashPrevoutsData = ByteData(inputs.length * 36);
    final ByteData hashAmountsData = ByteData(inputs.length * 8);
    final ByteData hashScriptPubKeysData = ByteData(inputs.length * 100);
    final ByteData hashSequencesData = ByteData(inputs.length * 4);
    int off1 = 0, off2 = 0, off3 = 0, off4 = 0;

    for (var input in inputs) {
      final Uint8List txidBytes =
          Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      hashPrevoutsData.buffer.asUint8List().setRange(off1, off1 + 32, txidBytes);
      off1 += 32;
      hashPrevoutsData.setUint32(off1, input['vout'] as int, Endian.little);
      off1 += 4;

      hashAmountsData.setUint64(off2, changeAmount, Endian.little);
      off2 += 8;

      final Uint8List scriptBytes =
          Uint8List.fromList(hex.decode(input['scriptPubKey']).toList());
      hashScriptPubKeysData.buffer.asUint8List().setRange(
          off3, off3 + scriptBytes.length, scriptBytes);
      off3 += scriptBytes.length;

      hashSequencesData.setUint32(off4, 0xffffffff, Endian.little);
      off4 += 4;
    }

    final Uint8List inputData = Uint8List.fromList(
      _crypto.sha256s(hashPrevoutsData.buffer.asUint8List(0, off1)) +
          _crypto.sha256s(hashAmountsData.buffer.asUint8List(0, off2)) +
          _crypto.sha256s(hashScriptPubKeysData.buffer.asUint8List(0, off3)) +
          _crypto.sha256s(hashSequencesData.buffer.asUint8List(0, off4)),
    );

    // HashOutputs
    final Uint8List outputData = Uint8List.fromList(
        (trxMap['output1'] as Uint8List) + output2);
    final Uint8List outputDataHash = _crypto.sha256s(outputData);

    // KeyVersion（0x00）
    final ByteData keyVersionData = ByteData(1);
    keyVersionData.setUint8(0, 0);

    // SighashType（SIGHASH_ALL = 0x00）
    final ByteData sighashData = ByteData(1);
    sighashData.setUint8(0, 0);

    trxMap['txRowAll'] = Uint8List.fromList(
        tapSighash +
        version +
        locktime +
        inputData +
        outputDataHash +
        keyVersionData.buffer.asUint8List(0, 1) +
        sighashData.buffer.asUint8List(0, 1));

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
        offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;
    return data.buffer.asUint8List(0, offset);
  }
}
