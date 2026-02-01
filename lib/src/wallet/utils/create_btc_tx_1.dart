import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/utils/bip340.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:crypto/crypto.dart';
//import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

class CreateBTCTXV1 {
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
    BigInt privateKey = decodeWif(wifPrivateKey);
    int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    int fee = 10000;
    int totalInputAmount = 0;

    List<Map<String, dynamic>> selectedUTXOs = [];
    for (Map utxo in inputs) {
      /*totalInputAmount += ethToWeiString(utxo['value'],8).toInt();
      selectedUTXOs.add({
        "txid": utxo['txid'],
        "vout": utxo['output_no'],//utxo['vout'],
        "amount": ethToWeiString(utxo['value'],8).toInt(),//utxo['value'],
        "scriptPubKey": utxo['hex'],
      });*/
      totalInputAmount += utxo['value'] as int;
      MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      if (utxoTx.error == false) {
        String scriptpk = utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk != "") {
          selectedUTXOs.add({
            "txid": utxo['txid'],
            "vout": utxo['vout'],
            "amount": utxo['value'],
            "scriptPubKey": scriptpk,
            "scriptpubkey_address":utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? ""
          });
        }
      }
      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    if (totalInputAmount < sendAmount + fee) {
      throw Exception("余额不足！");
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    Map<String,dynamic> rawTx = createRawTransactionSegwit(selectedUTXOs, recipientAddress, sendAmount, changeAmount, fromAddress, pubKey, pubKeyStr);

    String txHashStr=hex.encode(rawTx['txRow']);
    //ByteData data1=ByteData(4);
    //data1.setUint32(0, 1, Endian.little);
    //ByteData data2=ByteData(4);
    //data2.setUint32(0, 0xffffffff, Endian.little);
    //Uint8List rawTx2=Uint8List.fromList(rawTx+data2.buffer.asUint8List(0, 4)+data1.buffer.asUint8List(0, 4));
    if (kDebugMode) debugPrint("原始交易: $txHashStr");
    List<Uint8List> signs=[];
    for(int i=0;i<rawTx['txRowAll'].length;i++){
      Uint8List raw=rawTx['txRowAll'][i];
      if(selectedUTXOs[i]['scriptpubkey_address'].toString().substring(0,4)=="tb1p"){
        signs.add(Bip340().schnorrSign(raw,privateKey));
      }else{
        signs.add(signWithPrivateKey(raw,privateKey));
      }
    }
    rawTx['inputsSign']=signs;
    List<String> witness=[];
    for(Uint8List raw in rawTx['inputsSign']){
      ByteData data = ByteData(180);
      int offset1=0;
      data.setUint8(0, 0x01);
      offset1++;
      data.setUint8(offset1, raw.length);
      offset1++;
      data.buffer.asUint8List().setRange(offset1, offset1 + raw.length, raw);
      offset1+=raw.length;

      //data.setUint8(offset1, pubKey.length);
      //offset1++;
      //data.buffer.asUint8List().setRange(offset1, offset1 + pubKey.length, pubKey);
      //offset1+=pubKey.length;
      witness.add(bytesToHex(data.buffer.asUint8List(0, offset1)));
      //witness.add(bytesToHex(data.buffer.asUint8List(0, offset1))+pubKeyStr);
    }
    for(String sign in witness){
      txHashStr+=sign;
    }
    txHashStr+="00000000";
    return txHashStr;
    //Uint8List txHash=signWithPrivateKey(rawTx,privateKey);
    //String witness=bytesToHex(sha256s(scriptByte));
    //print(witness);
    //String witness=bytesToHex(txHash)+pubKeyStr+"00000000";
    //witness+=bytesToHex(txHash);
    //print(witness);
    //witness+=pubKeyStr;
    //print(witness);

    //Uint8List txHash = doubleSha256(rawTx);
    //List<Uint8List> signatures = signAllInputs(txHash, selectedUTXOs, privateKey);
    //Uint8List signedTx = serializeTransaction(rawTx, txHash, pubKey);
    //print("签名后的交易: ${hex.encode(signedTx)}");
    //return txHashStr+witness;
  }
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
    BigInt privateKey = decodeWif(wifPrivateKey);
    int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    int fee = 10000;
    int totalInputAmount = 0;

    List<Map<String, dynamic>> selectedUTXOs = [];
    for (Map utxo in inputs) {
      /*totalInputAmount += ethToWeiString(utxo['value'],8).toInt();
      selectedUTXOs.add({
        "txid": utxo['txid'],
        "vout": utxo['output_no'],//utxo['vout'],
        "amount": ethToWeiString(utxo['value'],8).toInt(),//utxo['value'],
        "scriptPubKey": utxo['hex'],
      });*/
      totalInputAmount += utxo['value'] as int;
      MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      if (utxoTx.error == false) {
        String scriptpk = utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk != "") {
          selectedUTXOs.add({
            "txid": utxo['txid'],
            "vout": utxo['vout'],
            "amount": utxo['value'],
            "scriptPubKey": scriptpk,
            "scriptpubkey_address":utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey_address'] ?? ""
          });
        }
      }
      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    if (totalInputAmount < sendAmount + fee) {
      throw Exception("余额不足！");
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    Map<String,dynamic> rawTx = createRawTransactionSegwitV2(selectedUTXOs, recipientAddress, sendAmount, changeAmount, fromAddress, pubKey, pubKeyStr);

    String txHashStr=hex.encode(rawTx['txRow']);
    //ByteData data1=ByteData(4);
    //data1.setUint32(0, 1, Endian.little);
    //ByteData data2=ByteData(4);
    //data2.setUint32(0, 0xffffffff, Endian.little);
    //Uint8List rawTx2=Uint8List.fromList(rawTx+data2.buffer.asUint8List(0, 4)+data1.buffer.asUint8List(0, 4));
    if (kDebugMode) debugPrint("原始交易: $txHashStr");

    rawTx['inputsSign']=Bip340().schnorrSign(rawTx['txRowAll'],privateKey);
    String witness="";
    ByteData data = ByteData(180);
    int offset1=0;
    data.setUint8(0, 0x01);
    offset1++;
    data.setUint8(offset1, rawTx['inputsSign'].length);
    offset1++;
    data.buffer.asUint8List().setRange(offset1, offset1 + rawTx['inputsSign'].length as int, rawTx['inputsSign']);
    offset1+=rawTx['inputsSign'].length as int;
    witness=hex.encode(data.buffer.asUint8List(0, offset1));
    txHashStr+=witness;
    txHashStr+="00000000";
    return txHashStr;
    //Uint8List txHash=signWithPrivateKey(rawTx,privateKey);
    //String witness=bytesToHex(sha256s(scriptByte));
    //print(witness);
    //String witness=bytesToHex(txHash)+pubKeyStr+"00000000";
    //witness+=bytesToHex(txHash);
    //print(witness);
    //witness+=pubKeyStr;
    //print(witness);

    //Uint8List txHash = doubleSha256(rawTx);
    //List<Uint8List> signatures = signAllInputs(txHash, selectedUTXOs, privateKey);
    //Uint8List signedTx = serializeTransaction(rawTx, txHash, pubKey);
    //print("签名后的交易: ${hex.encode(signedTx)}");
    //return txHashStr+witness;
  }
  /// 📌 解码 WIF 私钥
  BigInt decodeWif(String wif) {
    Uint8List decoded = base58Decode(wif);
    return BigInt.parse(hex.encode(decoded.sublist(1, 33)), radix: 16);
  }
  /// 📌 Base58 解码
  Uint8List base58Decode(String input) {
    const String alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
    BigInt num = BigInt.zero;
    for (int i = 0; i < input.length; i++) {
      int charIndex = alphabet.indexOf(input[i]);
      if (charIndex == -1) {
        throw ArgumentError("Invalid Base58 character: ${input[i]}");
      }
      num = num * BigInt.from(58) + BigInt.from(charIndex);
    }

    // 结果转换为 Uint8List
    List<int> bytes = hex.decode(num.toRadixString(16).padLeft(50, '0'));

    // 确保长度正确
    while (bytes.length < 38) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }
  /// 📌 计算双 SHA256
  Uint8List doubleSha256(Uint8List data) {
    return Uint8List.fromList(sha256.convert(sha256.convert(data).bytes).bytes);
  }

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
    int estimatedSize = 200 + (inputs.length * 180);
    ByteData data = ByteData(estimatedSize);
    int offset = 0;

    // 版本号
    data.setUint32(offset, 1, Endian.little);
    offset += 4;

    // 旗帜字节（用于SegWit）
    data.setUint8(offset, 0x00);
    offset += 1;
    data.setUint8(offset, 0x01);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 输入数量
    data.setUint8(offset, inputs.length);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 处理输入
    for (var input in inputs) {
      Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
      offset += 32;
      data.setUint32(offset, input['vout'], Endian.little);
      offset += 4;

      // P2WPKH 输入没有 scriptSig，所以长度为 0
      data.setUint8(offset, 0x00);
      offset += 1;

      // 序列号
      /*
序列号（sequence）	说明
0xFFFFFFFF（4294967295）	默认值，表示交易输入没有被时间锁（nLockTime）约束，交易可以立即被矿工打包。
0x00000000（0）	代表交易输入 必须 遵守 nLockTime 设定的时间锁，不能提前打包。
0xFFFFFFFE（4294967294）	在 BIP-125 可替换交易（RBF）中，表示 禁止 RBF（Replace-By-Fee），即该交易不能被更高费用的交易替换。
0x00000001 ~ 0xFFFFFFFD（1~4294967293）	用于交易时间锁（nLockTime）和部分确认功能，若 sequence < 0xFFFFFFFF，交易输入会受到 nLockTime 限制，且可以用于 相对时间锁（BIP-68）。*/
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 输出数量
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 发送金额和 scriptPubKey
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    Uint8List scriptPubKey = getScriptPubKey(Uint8List.fromList(hex.decode(recipientScriptPubkey)));
    //getP2WPKHScript(recipient);
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    data.buffer.asUint8List().setRange(offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));

    // 找零
    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;
      Uint8List changeScript = getP2WPKHScript(publicKey);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + changeScript.length, changeScript);
      offset += changeScript.length;
    }
    if (kDebugMode) debugPrint(bytesToHex(data.buffer.asUint8List(0, offset)));
    return data.buffer.asUint8List(0, offset);
    // locktime
    //data.setUint32(offset, 1800000000, Endian.little);
    //offset += 4;

    //return data.buffer.asUint8List(0, offset);
    //return Uint8List.fromList([...data.buffer.asUint8List(0, offset), 0x01]);
  }
  Uint8List createRawInput(Map<String, dynamic> input){
    ByteData data = ByteData(180);
    int offset = 0;
    Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;
    data.setUint32(offset, input['vout'], Endian.little);
    offset += 4;

    // P2WPKH 输入没有 scriptSig，所以长度为 0
    data.setUint8(offset, 0x00);
    offset += 1;

    // 序列号
    /*
序列号（sequence）	说明
0xFFFFFFFF（4294967295）	默认值，表示交易输入没有被时间锁（nLockTime）约束，交易可以立即被矿工打包。
0x00000000（0）	代表交易输入 必须 遵守 nLockTime 设定的时间锁，不能提前打包。
0xFFFFFFFE（4294967294）	在 BIP-125 可替换交易（RBF）中，表示 禁止 RBF（Replace-By-Fee），即该交易不能被更高费用的交易替换。
0x00000001 ~ 0xFFFFFFFD（1~4294967293）	用于交易时间锁（nLockTime）和部分确认功能，若 sequence < 0xFFFFFFFF，交易输入会受到 nLockTime 限制，且可以用于 相对时间锁（BIP-68）。*/
    data.setUint32(offset, 0xffffffff, Endian.little);
    offset += 4;
    return data.buffer.asUint8List(0,offset);
  }
  Uint8List createRawInputAll(Map<String, dynamic> input){
    ByteData data = ByteData(180);
    int offset = 0;
    Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;
    data.setUint32(offset, input['vout'], Endian.little);
    offset += 4;

    // P2WPKH 输入没有 scriptSig，所以长度为 0
    Uint8List scriptBytes = Uint8List.fromList(hex.decode(input['scriptPubKey']).toList());
    //data.setUint8(offset, scriptBytes.length);
    //offset += 1;
    data.buffer.asUint8List().setRange(offset, offset + scriptBytes.length, scriptBytes);
    offset += scriptBytes.length;

    // 序列号
    /*
序列号（sequence）	说明
0xFFFFFFFF（4294967295）	默认值，表示交易输入没有被时间锁（nLockTime）约束，交易可以立即被矿工打包。
0x00000000（0）	代表交易输入 必须 遵守 nLockTime 设定的时间锁，不能提前打包。
0xFFFFFFFE（4294967294）	在 BIP-125 可替换交易（RBF）中，表示 禁止 RBF（Replace-By-Fee），即该交易不能被更高费用的交易替换。
0x00000001 ~ 0xFFFFFFFD（1~4294967293）	用于交易时间锁（nLockTime）和部分确认功能，若 sequence < 0xFFFFFFFF，交易输入会受到 nLockTime 限制，且可以用于 相对时间锁（BIP-68）。*/
    data.setUint32(offset, 0xffffffff, Endian.little);
    offset += 4;
    return data.buffer.asUint8List(0,offset);
  }
  Map<String,dynamic> createRawTransactionSegwit(
      List<Map<String, dynamic>> inputs,
      String recipient,
      int sendAmount,
      int changeAmount,
      String fromAddress,
      Uint8List publicKey,
      String pubKeyStr,
      //String recipientScriptPubkey,
      ) {
    Map<String,dynamic> trxMap={};
    // 版本号
    ByteData dataVersion = ByteData(4);
    dataVersion.setUint32(0, 2, Endian.little);
    trxMap['version']=dataVersion.buffer.asUint8List(0,4);
    // 旗帜字节（用于SegWit）
    ByteData dataTag = ByteData(2);
    dataTag.setUint8(0, 0x00);
    dataTag.setUint8(1, 0x01);
    trxMap['tag']=dataTag.buffer.asUint8List(0,2);
    // 输入数量
    ByteData dataInputCount = ByteData(1);
    dataInputCount.setUint8(0, inputs.length);
    trxMap['inputCount']=dataInputCount.buffer.asUint8List(0,1);
    //输入项
    List<Uint8List> inputItems=[];
    for (var input in inputs) {
      inputItems.add(createRawInput(input));
    }
    trxMap['inputs']=inputItems;
    List<Uint8List> inputItemsAll=[];
    for (var input in inputs) {
      inputItemsAll.add(createRawInputAll(input));
    }
    trxMap['inputsAll']=inputItemsAll;
    //输出数量
    ByteData dataoutputCount = ByteData(1);
    dataoutputCount.setUint8(0, changeAmount > 0 ? 2 : 1);
    trxMap['outputCount']=dataoutputCount.buffer.asUint8List(0,1);
    //输出项
    // 发送金额和 scriptPubKey
    ByteData dataoutput1 = ByteData(180);
    int offset1=0;
    dataoutput1.setUint64(offset1, sendAmount, Endian.little);
    offset1 += 8;
    Uint8List scriptPubKey = getScriptPubKeyFromBech32(recipient);
    //getP2WPKHScript(recipient);
    dataoutput1.setUint8(offset1, scriptPubKey.length);
    offset1 += 1;
    //print(bytesToHex(data.buffer.asUint8List(0, offset)));
    dataoutput1.buffer.asUint8List().setRange(offset1, offset1 + scriptPubKey.length, scriptPubKey);
    offset1 += scriptPubKey.length;
    trxMap['output1']=dataoutput1.buffer.asUint8List(0,offset1);
    //print(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 找零
    if (changeAmount > 0) {
      ByteData dataoutput2 = ByteData(180);
      int offset2=0;
      dataoutput2.setUint64(offset2, changeAmount, Endian.little);
      offset2 += 8;
      Uint8List changeScript = getScriptPubKeyFromBech32(fromAddress);//getP2WPKHScript(publicKey);
      dataoutput2.setUint8(offset2, changeScript.length);
      offset2 += 1;
      dataoutput2.buffer.asUint8List().setRange(offset2, offset2 + changeScript.length, changeScript);
      offset2 += changeScript.length;
      trxMap['output2']=dataoutput2.buffer.asUint8List(0,offset2);
    }
    Uint8List ips=trxMap['inputs'][0];
    for(int i=1;i<trxMap['inputs'].length;i++){
      ips=Uint8List.fromList(ips+trxMap['inputs'][i]);
    }
    trxMap['txRow']=Uint8List.fromList(trxMap['version']+trxMap['tag']+trxMap['inputCount']+ips+trxMap['outputCount']+trxMap['output1']+trxMap['output2']??[]);

    ByteData dataSignAll = ByteData(4);
    dataSignAll.setUint32(0, 1, Endian.little);
    ByteData datalocktime = ByteData(4);
    datalocktime.setUint32(0, 0, Endian.little);

    List<Uint8List> txRaowAll=[];
    for(int j=0;j<trxMap['inputsAll'].length;j++){
      Uint8List ipsAll=Uint8List(0);
      for(int i=0;i<trxMap['inputsAll'].length;i++){
        if(j==i){
          ipsAll=Uint8List.fromList(ipsAll+trxMap['inputsAll'][i]);
        }else{
          ipsAll=Uint8List.fromList(ipsAll+trxMap['inputs'][i]);
        }
      }
      Uint8List locktime=datalocktime.buffer.asUint8List(0,4);
      Uint8List signAll=dataSignAll.buffer.asUint8List(0,4);
      Uint8List row=Uint8List.fromList(trxMap['version']+trxMap['tag']+trxMap['inputCount']+ipsAll+trxMap['outputCount']+trxMap['output1']+trxMap['output2']??[]);
      Uint8List row1=Uint8List.fromList(row+locktime+signAll);
      txRaowAll.add(row1);
    }
    trxMap['txRowAll']=txRaowAll;
    return trxMap;

  }
  /*"TapSighash"	32 字节	Tagged Hash 前缀（用于哈希防碰撞），固定为 SHA256("TapSighash")。
Version	4 字节	交易版本号（小端序），例如 0x00000001 或 0x00000002。
Locktime	4 字节	交易锁定时间（小端序），可以是 Unix 时间戳或区块高度。
HashPrevouts	32 字节	所有输入的前向输出（txid + vout）的哈希值。
HashAmounts	32 字节	所有输入的金额（amount）的哈希值。
HashScriptPubKeys	32 字节	所有输入的锁定脚本（scriptPubKey）的哈希值。
HashSequences	32 字节	所有输入的序列号（sequence）的哈希值。
HashOutputs	32 字节	所有输出的哈希值（value + scriptPubKey）。
Annex (可选)	32 字节	交易 Annex 数据的哈希值（如果有）。
KeyVersion	1 字节	公钥版本（通常为 0x00）。
SighashType	1 字节	签名哈希类型（例如 SIGHASH_ALL，默认值为 0x00）。*/
  Map<String,dynamic> createRawTransactionSegwitV2(
      List<Map<String, dynamic>> inputs,
      String recipient,
      int sendAmount,
      int changeAmount,
      String fromAddress,
      Uint8List publicKey,
      String pubKeyStr,
      //String recipientScriptPubkey,
      ) {
    Map<String,dynamic> trxMap={};
    // 版本号
    ByteData dataVersion = ByteData(4);
    dataVersion.setUint32(0, 1, Endian.little);
    trxMap['version']=dataVersion.buffer.asUint8List(0,4);
    // 旗帜字节（用于SegWit）
    ByteData dataTag = ByteData(2);
    dataTag.setUint8(0, 0x00);
    dataTag.setUint8(1, 0x01);
    trxMap['tag']=dataTag.buffer.asUint8List(0,2);
    // 输入数量
    ByteData dataInputCount = ByteData(1);
    dataInputCount.setUint8(0, inputs.length);
    trxMap['inputCount']=dataInputCount.buffer.asUint8List(0,1);
    //输入项
    List<Uint8List> inputItems=[];
    for (var input in inputs) {
      inputItems.add(createRawInput(input));
    }
    trxMap['inputs']=inputItems;
    List<Uint8List> inputItemsAll=[];
    for (var input in inputs) {
      inputItemsAll.add(createRawInputAll(input));
    }
    trxMap['inputsAll']=inputItemsAll;
    //输出数量
    ByteData dataoutputCount = ByteData(1);
    dataoutputCount.setUint8(0, changeAmount > 0 ? 2 : 1);
    trxMap['outputCount']=dataoutputCount.buffer.asUint8List(0,1);
    //输出项
    // 发送金额和 scriptPubKey
    ByteData dataoutput1 = ByteData(180);
    int offset1=0;
    dataoutput1.setUint64(offset1, sendAmount, Endian.little);
    offset1 += 8;
    Uint8List scriptPubKey = getScriptPubKeyFromBech32(recipient);
    //getP2WPKHScript(recipient);
    dataoutput1.setUint8(offset1, scriptPubKey.length);
    offset1 += 1;
    //print(bytesToHex(data.buffer.asUint8List(0, offset)));
    dataoutput1.buffer.asUint8List().setRange(offset1, offset1 + scriptPubKey.length, scriptPubKey);
    offset1 += scriptPubKey.length;
    trxMap['output1']=dataoutput1.buffer.asUint8List(0,offset1);
    //print(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 找零
    if (changeAmount > 0) {
      ByteData dataoutput2 = ByteData(180);
      int offset2=0;
      dataoutput2.setUint64(offset2, changeAmount, Endian.little);
      offset2 += 8;
      Uint8List changeScript = getScriptPubKeyFromBech32(fromAddress);//getP2WPKHScript(publicKey);
      dataoutput2.setUint8(offset2, changeScript.length);
      offset2 += 1;
      dataoutput2.buffer.asUint8List().setRange(offset2, offset2 + changeScript.length, changeScript);
      offset2 += changeScript.length;
      trxMap['output2']=dataoutput2.buffer.asUint8List(0,offset2);
    }
    Uint8List ips=trxMap['inputs'][0];
    for(int i=1;i<trxMap['inputs'].length;i++){
      ips=Uint8List.fromList(ips+trxMap['inputs'][i]);
    }
    trxMap['txRow']=Uint8List.fromList(trxMap['version']+trxMap['tag']+trxMap['inputCount']+ips+trxMap['outputCount']+trxMap['output1']+trxMap['output2']??[]);

    //TapSighash
    //这是一个 Tagged Hash 前缀，用于防止哈希碰撞。
    //
    // 固定值为 SHA256("TapSighash")
    Uint8List tapSighash=sha256s(utf8.encode('TapSighash'));
    //Version
    //交易的版本号，通常为 0x00000001 或 0x00000002。
    //
    // 小端序编码。
    Uint8List version=trxMap['version'];
    //Locktime
    //交易的锁定时间，可以是 Unix 时间戳或区块高度。
    //
    // 小端序编码。
    ByteData locktime=ByteData(4);
    locktime.setUint32(0, 0xffffffff, Endian.little);
    Uint8List locktimeHex=locktime.buffer.asUint8List(0,4);
    //HashPrevouts
    // 所有输入的前向输出（txid + vout）的哈希值。
    //
    // 计算方式：
    //
    // 将每个输入的 txid（小端序）和 vout（小端序）序列化。
    //
    // 对所有输入的序列化数据进行 SHA-256 哈希计算。
    //HashAmounts
    // 所有输入的金额（amount）的哈希值。
    //
    // 计算方式：
    //
    // 将每个输入的金额（8 字节，小端序）序列化。
    //
    // 对所有输入的序列化数据进行 SHA-256 哈希计算。
    //HashScriptPubKeys
    // 所有输入的锁定脚本（scriptPubKey）的哈希值。
    //
    // 计算方式：
    //
    // 将每个输入的 scriptPubKey（变长字节）序列化。
    //
    // 对所有输入的序列化数据进行 SHA-256 哈希计算。
    //HashSequences
    // 所有输入的序列号（sequence）的哈希值。
    //
    // 计算方式：
    //
    // 将每个输入的序列号（4 字节，小端序）序列化。
    //
    // 对所有输入的序列化数据进行 SHA-256 哈希计算。
    ByteData hashPrevoutsData=ByteData(inputs.length*36);
    int offset11=0;
    ByteData hashAmounts=ByteData(inputs.length*8);
    int offset12=0;
    ByteData hashScriptPubKeys=ByteData(inputs.length*100);
    int offset13=0;
    ByteData hashSequences=ByteData(inputs.length*4);
    int offset14=0;
    for (var input in inputs) {

      Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      hashPrevoutsData.buffer.asUint8List().setRange(offset11, offset11+32, txidBytes);
      offset11 += 32;
      hashPrevoutsData.setUint32(offset11, input['vout'], Endian.little);
      offset11 += 4;

      //amount
      hashAmounts.setUint64(offset12, changeAmount, Endian.little);
      offset12+=8;
      // P2WPKH 输入没有 scriptSig，所以长度为 0
      Uint8List scriptBytes = Uint8List.fromList(hex.decode(input['scriptPubKey']).toList());
      //data.setUint8(offset, scriptBytes.length);
      //offset += 1;
      hashScriptPubKeys.buffer.asUint8List().setRange(offset13, offset13 + scriptBytes.length, scriptBytes);
      offset13 += scriptBytes.length;

      hashSequences.setUint32(offset14, 0xffffffff, Endian.little);
      offset14 += 4;
    }
    Uint8List inputData=Uint8List.fromList(
      sha256s(hashPrevoutsData.buffer.asUint8List(0,offset11)) +
          sha256s(hashAmounts.buffer.asUint8List(0,offset12))  +
          sha256s(hashScriptPubKeys.buffer.asUint8List(0,offset13)) +
          sha256s(hashSequences.buffer.asUint8List(0,offset14)),
    );
    //String inputDataHex=hex.encode(inputData);
    //HashOutputs
    // 所有输出的哈希值（value + scriptPubKey）。
    //
    // 计算方式：
    //
    // 将每个输出的金额（8 字节，小端序）和 scriptPubKey（变长字节）序列化。
    //
    // 对所有输出的序列化数据进行 SHA-256 哈希计算。
    Uint8List outputData=Uint8List.fromList(trxMap['output1']+trxMap['output2']??[]);
    Uint8List outputDataHex=sha256s(outputData);
    //KeyVersion
    // 公钥版本，通常为 0x00。
    ByteData keyVersion = ByteData(1);
    keyVersion.setUint8(0, 0);
    Uint8List keyVersionHex=Uint8List.fromList(keyVersion.buffer.asUint8List(0,1));
    //SighashType
    // 签名哈希类型，例如：
    //
    // SIGHASH_ALL（默认值，0x00）：签名覆盖所有输入和输出。
    //
    // SIGHASH_NONE（0x01）：签名不覆盖任何输出。
    //
    // SIGHASH_SINGLE（0x02）：签名仅覆盖与输入索引对应的输出。
    ByteData sighashData = ByteData(1);
    sighashData.setUint8(0, 0);
    Uint8List sighashDataHex=Uint8List.fromList(sighashData.buffer.asUint8List(0,1));

    trxMap['txRowAll']=Uint8List.fromList(tapSighash+version+locktimeHex+inputData+outputDataHex+keyVersionHex+sighashDataHex);
    return trxMap;

  }
  /// SHA256 哈希计算
  Uint8List sha256s(Uint8List data) {
    return Uint8List.fromList(sha256.convert(data).bytes);
  }

  /// 计算 P2WSH `scriptPubKey`
  Uint8List getScriptPubKey(Uint8List redeemScript) {
    Uint8List witnessScriptHash = doubleSha256(redeemScript);
    return Uint8List.fromList([0x00, 0x20] + witnessScriptHash);
  }
  /// 解析 Bech32 (bc1...) 地址，并返回对应的 scriptPubKey
  Uint8List getScriptPubKeyFromBech32(String bech32Address) {
    P2wpkhAddress p2wpkhAddress=P2wpkhAddress.fromAddress(address: bech32Address, network: BitcoinNetwork.testnet);
    p2wpkhAddress.toScriptPubKey().toBytes();
    return Uint8List.fromList(p2wpkhAddress.toScriptPubKey().toBytes());
  }

  Uint8List serializeTransaction(Uint8List rawTx, List<Uint8List> signatures, Uint8List publicKey) {
    ByteData data = ByteData(rawTx.length + (signatures.length * 180));
    int offset = 0;

    data.buffer.asUint8List().setRange(0, rawTx.length, rawTx);
    offset += rawTx.length;

    // witness数据
    data.setUint8(offset, signatures.length);
    offset += 1;

    for (var sig in signatures) {
      data.setUint8(offset, 2); // witness包含两个元素
      offset += 1;

      data.setUint8(offset, sig.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + sig.length, sig);
      offset += sig.length;

      data.setUint8(offset, publicKey.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + publicKey.length, publicKey);
      offset += publicKey.length;
    }

    return data.buffer.asUint8List(0, offset);
  }

  Uint8List ripemd160Hash(Uint8List data) {
    var digest = RIPEMD160Digest();
    return digest.process(data);
  }
  Uint8List getP2WPKHScript(Uint8List publicKey) {
    // 1. 计算公钥哈希 (PubKeyHash) = RIPEMD-160(SHA-256(PubKey))
    Uint8List sha256Hash = Uint8List.fromList(sha256.convert(publicKey).bytes);
    Uint8List pubKeyHash = ripemd160Hash(sha256Hash);

    // 2. 构造 P2WPKH scriptPubKey: 0x00 + 0x14 + pubKeyHash
    BytesBuilder script = BytesBuilder();
    script.add([0x00]); // Witness version 0
    script.add([0x14]); // 20-byte length
    script.add(pubKeyHash);

    return script.toBytes();
    /*// 解码 Bech32 地址
    Bech32 decoded = Bech32Codec().decode(address);

    // 检查地址前缀
    if (decoded.hrp != "tb" && decoded.hrp != "bc") {
      throw ArgumentError("Invalid Bech32 address prefix: ${decoded.hrp}");
    }

    // 检查数据长度并确定脚本类型
    if (decoded.data.length == 21) {
      // P2WPKH 脚本格式: 0014<20-byte-hash>
      return Uint8List.fromList([0x00, 0x14, ...decoded.data]);
    } else if (decoded.data.length == 33) {
      // P2WSH 脚本格式: 0020<32-byte-hash>
      return Uint8List.fromList([0x00, 0x20, ...decoded.data]);
    } else {
      throw ArgumentError("Invalid Bech32 data length: ${decoded.data.length}");
    }*/
  }

  //传统签名方法
  Uint8List signWithPrivateKey(Uint8List txHash, BigInt privateKey) {
    // 1. 获取 Secp256k1 曲线参数
    final ECDomainParameters curve = ECDomainParameters('secp256k1');

    // 2. 生成 EC 私钥
    final ECPrivateKey ecPrivateKey = ECPrivateKey(privateKey, curve);
// 解决 SecureRandom 未注册的问题
    final SecureRandom secureRandom = _secureRandom();

    final ParametersWithRandom privateKeyParams =
    ParametersWithRandom(PrivateKeyParameter<ECPrivateKey>(ecPrivateKey), secureRandom);

    // 3. 创建签名器（不使用 HMAC，避免额外计算）
    final Signer signer = ECDSASigner(SHA256Digest());
    signer.init(true, privateKeyParams);

    // 4. 计算签名 (r, s)
    ECSignature signature = signer.generateSignature(txHash) as ECSignature;

    // 5. 进行低 `s` 值规范化 (Bitcoin 规定 `s` 必须小于 `n/2`)
    BigInt nDiv2 = curve.n >> 1;
    if (signature.s.compareTo(nDiv2) > 0) {
      signature = ECSignature(signature.r, curve.n - signature.s);
    }

    // 6. 转换为 DER 格式
    Uint8List derSignature = encodeDER(signature);
    //return derSignature;
    // 7. 添加 SIGHASH_ALL (0x01) 后缀
    return Uint8List.fromList([...derSignature, 0x01]);
  }

  SecureRandom _secureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));
    return secureRandom;
  }
  Uint8List encodeDER(ECSignature signature) {
    List<int> rBytes = _bigIntToBytes(signature.r);
    List<int> sBytes = _bigIntToBytes(signature.s);

    // DER 规范：如果最高位是 `1`（即最高 bit 为 1），需要前置 `0x00`
    if (rBytes[0] & 0x80 != 0) {
      rBytes = [0x00] + rBytes;
    }
    if (sBytes[0] & 0x80 != 0) {
      sBytes = [0x00] + sBytes;
    }

    // DER 格式: 0x30 | 总长度 | 0x02 | r 长度 | r 值 | 0x02 | s 长度 | s 值
    return Uint8List.fromList([
      0x30,
      rBytes.length + sBytes.length + 4, // 总长度
      0x02,
      rBytes.length, // r 长度
      ...rBytes, // r 值
      0x02,
      sBytes.length, // s 长度
      ...sBytes // s 值
    ]);
  }

  List<int> _bigIntToBytes(BigInt value) {
    // 确保值转换成最少字节数
    Uint8List bytes = Uint8List.fromList(hex.decode(value.toRadixString(16).padLeft(64, '0')));
    return bytes.skipWhile((b) => b == 0).toList(); // 去除前导 0
  }

  Future<MessageModel> getUTXOTxid(String txid)async{
    try{
      String uri="https://mempool.space/testnet4/api/tx/$txid";
      var data= await BaseApi.requestEmptyH.get(uri,
        params: {},
        defaultReturn: false,
        header: {
          "Content-Type":"application/json",
          //"x-api-key":"bc0a6024-148a-4c6e-8188-0a0523f3f713",
        },
      );
      MessageModel mm=MessageModel();
      mm.data=data;
      return mm;

    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e;
      return mm;
    }
  }

}
