import 'dart:convert';

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'package:bech32/bech32.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:web3dart/crypto.dart';
class CreateBTCTX{
  create(String wifPrivateKey,String recipientAddress,double sendValue,List<dynamic> inputs,String fromAddress,Uint8List pubKey) async{

    print(jsonEncode(inputs));
    print(jsonEncode(pubKey));
    // 1️⃣ 发送方私钥（WIF 格式，需要解码） // 示例: 'cVbQ...53m15'
    BigInt privateKey = decodeWif(wifPrivateKey);

    // 2️⃣ 构造交易输入 (UTXO)
    //String txid = inputs[0]['txid'];//"上一笔交易的 TXID"; // UTXO 的 TXID
    //int vout = inputs[0]['vout']; // UTXO 的输出索引
    //int inputAmount = inputs[0]['value']; // 交易输入金额 (单位: satoshi)

    // 3️⃣ 构造交易输出
    //String recipientAddress = "目标比特币地址"; // 目标地址
    int sendAmount = ethToWeiString('${sendValue}', 8).toInt(); // 发送金额 (satoshi)
    int fee = 10000; // 手续费 (satoshi)
    int totalInputAmount = 0;
// 3️⃣ 选取足够的 UTXO
    List<Map<String, dynamic>> selectedUTXOs = [];
    for (Map utxo in inputs) {
      totalInputAmount += utxo['value']as int;
      MessageModel utxoTx=await getUTXOTxid(utxo['txid']);
      if(utxoTx.error==false){
        String scriptpk=utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey']??"";
        if(scriptpk!=""){
          selectedUTXOs.add({
            "txid": utxo['txid'],
            "vout": utxo['vout'],
            "amount": utxo['value'],
            "scriptPubKey": scriptpk,
          });
        }else{
          continue;
        }
      }else{
        continue;
      }

      if (totalInputAmount >= (sendAmount + fee)) {
        break;
      }
    }

    if (totalInputAmount < sendAmount + fee) {
      throw Exception("余额不足！");
    }

    // 4️⃣ 计算找零
    int changeAmount = totalInputAmount - sendAmount - fee;
    // 4️⃣ 创建原始交易
    //Uint8List rawTx = createRawTransaction(txid, vout, inputAmount, recipientAddress, sendAmount, fee);
    Uint8List rawTx = createRawTransaction(selectedUTXOs, recipientAddress, sendAmount, changeAmount, wifPrivateKey,privateKey,fromAddress,pubKey);

    // 6️⃣ 交易哈希（双重 SHA256）
    Uint8List txHash = doubleSha256(rawTx);

    // 7️⃣ 签名所有输入
    List<Uint8List> signatures = signAllInputs(txHash,selectedUTXOs,privateKey);

    // 7️⃣ 序列化 & 广播交易
    Uint8List signedTx = serializeTransaction(rawTx, signatures);
    return hex.encode(signedTx);
  }
  List<Uint8List> signAllInputs(Uint8List txHash, List<Map<String, dynamic>> inputs, BigInt privateKey) {
    List<Uint8List> signatures = [];
    for (var input in inputs) {
      Uint8List signature = signTransaction(txHash, privateKey);
      signatures.add(signature);
    }
    return signatures;
  }

  /// 📌 解码 WIF 私钥
  BigInt decodeWif(String wif) {
    Uint8List decoded = base58Decode(wif);
    return BigInt.parse(hex.encode(decoded.sublist(1, 33)), radix: 16);
  }

  /// 📌 创建原始交易 (P2PKH)
  /*
  Uint8List createRawTransaction(String txid, int vout, int inputAmount, String recipientAddress, int sendAmount, int fee) {
    ByteData data = ByteData(200); // 预分配 200 字节
    int offset = 0;

    // 版本号
    data.setUint32(offset, 1, Endian.little);
    offset += 4;

    // 输入个数 (1 个)
    data.setUint8(offset, 1);
    offset += 1;

    // TXID (倒序)
    Uint8List txidBytes = Uint8List.fromList(hex.decode(txid).reversed.toList());
    data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
    offset += 32;

    // 输出索引
    data.setUint32(offset, vout, Endian.little);
    offset += 4;

    // 脚本长度 (占位)
    data.setUint8(offset, 0);
    offset += 1;

    // 序号
    data.setUint32(offset, 0xffffffff, Endian.little);
    offset += 4;

    // 输出个数 (1 个)
    data.setUint8(offset, 1);
    offset += 1;

    // 发送金额 (satoshi)
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;

    // 目标地址脚本 (P2PKH)
    Uint8List scriptPubKey = getP2WSHScript(recipientAddress);
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    data.buffer.asUint8List().setRange(offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;

    // 锁定时间
    data.setUint32(offset, 0, Endian.little);
    offset += 4;

    return data.buffer.asUint8List(0, offset);
  }

  Uint8List createRawTransaction(List<Map<String, dynamic>> inputs, String recipient, int sendAmount, int changeAmount, String wifPrivateKey,BigInt privateKey,String fromAddress,Uint8List publicKey) {
    int estimatedSize = 200 + (inputs.length * 180);
    ByteData data = ByteData(estimatedSize);
    int offset = 0;

    // 1️⃣ 版本号
    data.setUint32(offset, 1, Endian.little);
    offset += 4;

    // 2️⃣ 输入个数
    data.setUint8(offset, inputs.length);
    offset += 1;

    // 3️⃣ 遍历所有 UTXO，构造 `Vin`
    for (var input in inputs) {
      Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
      offset += 32;

      data.setUint32(offset, input['vout'], Endian.little);
      offset += 4;

      // 获取 scriptPubKey（需要从 UTXO 里解析出来）
      Uint8List scriptPubKey = Uint8List.fromList(hex.decode(input['scriptPubKey']));

      // 🔥 计算签名
      Uint8List txHash = doubleSha256(data.buffer.asUint8List(0, offset));  // 交易哈希
      Uint8List signature = signTransaction(txHash, privateKey);            // 使用私钥签名
      //Uint8List publicKey = getPublicKeyFromPrivateKey(privateKey);         // 获取公钥

      // 🔥 构造 scriptSig（解锁脚本）
      Uint8List scriptSig = Uint8List.fromList([
        signature.length, ...signature,
        publicKey.length, ...publicKey
      ]);

      // 📌 添加 scriptSig 长度
      data.setUint8(offset, scriptSig.length);
      offset += 1;

      // 📌 添加 scriptSig
      data.buffer.asUint8List().setRange(offset, offset + scriptSig.length, scriptSig);
      offset += scriptSig.length;

      // 序号
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }

    // 4️⃣ 输出个数 (1 发送地址 + 1 找零地址)
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;

    // 5️⃣ 发送金额 (satoshi)
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;

    // 6️⃣ 目标地址脚本 (P2PKH)
    Uint8List scriptPubKey = getP2WSHScript(recipient);
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    data.buffer.asUint8List().setRange(offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;

    // 7️⃣ 找零（如果有）
    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;

      // 找零地址
      Uint8List changeScript = getP2WSHScript(fromAddress);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + changeScript.length, changeScript);
      offset += changeScript.length;
    }

    // 8️⃣ 锁定时间
    data.setUint32(offset, 0, Endian.little);
    offset += 4;

    return data.buffer.asUint8List(0, offset);
  }
  */
  Uint8List createRawTransaction(List<Map<String, dynamic>> inputs, String recipient, int sendAmount, int changeAmount, String wifPrivateKey, BigInt privateKey, String fromAddress, Uint8List publicKey) {
    int estimatedSize = 200 + (inputs.length * 180);
    ByteData data = ByteData(estimatedSize);
    int offset = 0;

    data.setUint32(offset, 1, Endian.little);
    offset += 4;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    //隔离见证时
    data.setUint32(offset, 1, Endian.little);
    offset += 2;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));

    data.setUint8(offset, inputs.length);
    offset += 1;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));

    for (var input in inputs) {
      Uint8List txidBytes = Uint8List.fromList(hex.decode(input['txid']).reversed.toList());
      data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
      offset += 32;
      data.setUint32(offset, input['vout'], Endian.little);
      offset += 4;

      Uint8List scriptPubKey = Uint8List.fromList(hex.decode(input['scriptPubKey']));
      Uint8List txHash = doubleSha256(data.buffer.asUint8List(0, offset));
      Uint8List signature = signTransaction(txHash, privateKey);
      Uint8List scriptSig = Uint8List.fromList([signature.length, ...signature, publicKey.length, ...publicKey]);

      data.setUint8(offset, scriptSig.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + scriptSig.length, scriptSig);
      offset += scriptSig.length;
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }

    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    Uint8List scriptPubKey = getP2WSHScript(recipient);
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    data.buffer.asUint8List().setRange(offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;

    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;
      Uint8List changeScript = getP2WSHScript(fromAddress);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + changeScript.length, changeScript);
      offset += changeScript.length;
    }

    data.setUint32(offset, 0, Endian.little);
    offset += 4;
    return data.buffer.asUint8List(0, offset);
  }
  /// 📌 计算双 SHA256
  Uint8List doubleSha256(Uint8List data) {
    return Uint8List.fromList(sha256.convert(sha256.convert(data).bytes).bytes);
  }

  /// 📌 使用私钥签名交易
  Uint8List signTransaction(Uint8List txHash, BigInt privateKey) {
    final signer = ECDSASigner(SHA256Digest());
    final keyParams = ParametersWithRandom(
      PrivateKeyParameter<ECPrivateKey>(ECPrivateKey(privateKey, ECDomainParameters('secp256k1'))),
      getSecureRandom(), // ✅ 添加安全随机数
    );
    signer.init(true, keyParams);

    final ECSignature signature = signer.generateSignature(txHash) as ECSignature;
    Uint8List rBytes = bigIntToBytes(signature.r, 32);
    Uint8List sBytes = bigIntToBytes(signature.s, 32);
    print(hex.encode(Uint8List.fromList([...rBytes, ...sBytes])));
    return Uint8List.fromList([...rBytes, ...sBytes]);
    //return Uint8List.fromList([...signature.r.toBytes(), ...signature.s.toBytes()]);
  }
  SecureRandom getSecureRandom() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List.fromList(List.generate(32, (i) => i)); // 32 字节随机种子
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }
  /// 📌 BigInt 转 Uint8List（固定字节长度）
  Uint8List bigIntToBytes(BigInt number, int length) {
    Uint8List bytes = Uint8List(length);
    BigInt temp = number;

    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }
  /// 📌 序列化签名交易
  Uint8List serializeTransaction(Uint8List rawTx, List<Uint8List> signatures) {
    // 计算总签名大小
    int totalSignatureSize = signatures.fold(0, (sum, sig) => sum + sig.length + 1);

    ByteData data = ByteData(rawTx.length + totalSignatureSize);
    data.buffer.asUint8List().setRange(0, rawTx.length, rawTx);

    int offset = rawTx.length;

    // 遍历所有签名并添加到交易
    for (Uint8List signature in signatures) {
      data.setUint8(offset, signature.length); // 记录签名长度
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + signature.length, signature);
      offset += signature.length;
    }

    return data.buffer.asUint8List();
  }

  /// 📌 生成 P2PKH 脚本
  Uint8List getP2PKHScript(String address) {
    Uint8List decoded = base58Decode(address);

    if (decoded.length != 25) {
      throw ArgumentError("Invalid P2PKH address length");
    }

    return Uint8List.fromList([0x76, 0xa9, 0x14] + decoded.sublist(1, 21) + [0x88, 0xac]);
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
    while (bytes.length < 25) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }

  Uint8List getP2WPKHScript(String bech32Address) {
    Uint8List decoded = bech32Decode(bech32Address);

    if (decoded.length != 20) {
      throw ArgumentError("Invalid P2WPKH address length");
    }

    return Uint8List.fromList([0x00, 0x14] + decoded); // OP_0 + Push 20 字节公钥哈希
  }
  Uint8List getP2WSHScript(String bech32Address) {
    Uint8List hash = bech32Decode(bech32Address);
    return Uint8List.fromList([0x00, 0x20] + hash); // OP_0 + Push 32 字节 scriptHash
  }
  Uint8List bech32Decode(String address) {
    final bech32Codec = Bech32Codec();
    final decoded = bech32Codec.decode(address, address.length);

    return Uint8List.fromList(convertBits(decoded.data.sublist(1), 5, 8, false));
  }

  /// 5-bit 转 8-bit
  List<int> convertBits(List<int> data, int from, int to, bool pad) {
    int acc = 0;
    int bits = 0;
    List<int> result = [];
    int maxv = (1 << to) - 1;

    for (int value in data) {
      acc = (acc << from) | value;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad && bits > 0) {
      result.add((acc << (to - bits)) & maxv);
    }

    return result;
  }
  getUTXOTxid(String txid)async{
    try{
      String uri="https://mempool.space/testnet4/api/tx/$txid";
      var data= await BaseApi.RequestEmpty_h.get(uri,
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
