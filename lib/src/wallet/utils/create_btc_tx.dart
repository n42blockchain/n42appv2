import 'dart:typed_data';

import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:crypto/crypto.dart';
//import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'package:bech32/bech32.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:web3dart/crypto.dart';

class CreateBTCTX {
  create(
      String wifPrivateKey,
      String recipientAddress,
      double sendValue,
      List<dynamic> inputs,
      String fromAddress,
      Uint8List pubKey,
      String pubKeyStr,
      String recipientScriptPubkey,
      Uint8List scriptByte,
      ) async {
    BigInt privateKey = decodeWif(wifPrivateKey);
    int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    int fee = 10000;
    int totalInputAmount = 0;

    List<Map<String, dynamic>> selectedUTXOs = [];
    for (Map utxo in inputs) {
      totalInputAmount += utxo['value'] as int;
      MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      /*if (utxoTx.error == false) {
        String scriptpk = utxoTx.data['vout']?[utxo['vout']]?['scriptpubkey'] ?? "";
        if (scriptpk != "") {
          selectedUTXOs.add({
            "txid": utxo['txid'],
            "vout": utxo['vout'],
            "amount": utxo['value'],
            "scriptPubKey": scriptpk,
          });
        }
      }*/
      if (utxoTx.error == false) {
        selectedUTXOs.add({
          "txid": utxo['txid'],
          "vout": utxo['vout'],
          "amount": utxo['value'],
          //"scriptPubKey": scriptpk,
        });
      }
      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    if (totalInputAmount < sendAmount + fee) {
      throw Exception("余额不足！");
    }

    int changeAmount = totalInputAmount - sendAmount - fee;
    Uint8List rawTx = createRawTransaction(selectedUTXOs, recipientAddress, sendAmount, changeAmount, fromAddress, pubKey, pubKeyStr,recipientScriptPubkey);

    String txHashStr=hex.encode(rawTx);
    ByteData data1=ByteData(4);
    data1.setUint32(0, 1, Endian.little);
    ByteData data2=ByteData(4);
    data2.setUint32(0, 0xffffffff, Endian.little);
    Uint8List rawTx2=Uint8List.fromList(rawTx+data2.buffer.asUint8List(0, 4)+data1.buffer.asUint8List(0, 4));
    print("原始交易: ${txHashStr}");
    Uint8List txHash=signWithPrivateKey(rawTx2,privateKey);
    //String witness=bytesToHex(sha256s(scriptByte));
    //print(witness);
    String witness=bytesToHex(txHash)+pubKeyStr+"00000000";
    //witness+=bytesToHex(txHash);
    //print(witness);
    //witness+=pubKeyStr;
    //print(witness);

    //Uint8List txHash = doubleSha256(rawTx);
    //List<Uint8List> signatures = signAllInputs(txHash, selectedUTXOs, privateKey);
    //Uint8List signedTx = serializeTransaction(rawTx, txHash, pubKey);
    //print("签名后的交易: ${hex.encode(signedTx)}");
    return txHashStr+witness;
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
    while (bytes.length < 25) {
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
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 输入数量
    data.setUint8(offset, inputs.length);
    offset += 1;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
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
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 输出数量
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    // 发送金额和 scriptPubKey
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    Uint8List scriptPubKey = getScriptPubKey(Uint8List.fromList(hex.decode(recipientScriptPubkey)));
    //getP2WPKHScript(recipient);
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    data.buffer.asUint8List().setRange(offset, offset + scriptPubKey.length, scriptPubKey);
    offset += scriptPubKey.length;
    print(bytesToHex(data.buffer.asUint8List(0, offset)));

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
    print(bytesToHex(data.buffer.asUint8List(0, offset)));
    return data.buffer.asUint8List(0, offset);
    // locktime
    //data.setUint32(offset, 1800000000, Endian.little);
    //offset += 4;

    //return data.buffer.asUint8List(0, offset);
    //return Uint8List.fromList([...data.buffer.asUint8List(0, offset), 0x01]);
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

  Uint8List signWithPrivateKey(Uint8List txHash, BigInt privateKey) {
    // 1. 获取 Secp256k1 曲线参数
    final ECDomainParameters curve = ECDomainParameters('secp256k1');

    // 2. 生成 EC 私钥
    final ECPrivateKey ecPrivateKey = ECPrivateKey(privateKey, curve);

    // 3. 创建签名器
    final Signer signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64));
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(ecPrivateKey));

    // 4. 计算签名 (r, s)
    ECSignature signature = signer.generateSignature(txHash) as ECSignature;

    // 5. 进行低 `s` 值规范化 (Bitcoin 规定 `s` 必须小于 `n/2`)
    BigInt nDiv2 = curve.n >> 1;
    if (signature.s.compareTo(nDiv2) > 0) {
      signature = ECSignature(signature.r, curve.n - signature.s);
    }

    // 6. 转换为 DER 格式
    Uint8List derSignature = encodeDER(signature);
    // 7. 添加 SIGHASH_ALL (0x01) 后缀
    return Uint8List.fromList([...derSignature, 0x01]);
  }

  Uint8List encodeDER(ECSignature signature) {
    List<int> rBytes = _bigIntToBytes(signature.r);
    List<int> sBytes = _bigIntToBytes(signature.s);

    // 确保 `r` 和 `s` 都符合 DER 规范：如果最高位是 `1`，需要前置 `0x00`
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
    List<int> bytes = hex.decode(value.toRadixString(16).padLeft(64, '0'));
    return bytes;
  }

  getUTXOTxid(String txid)async{
    try{
      String uri="https://mempool.space/testnet4/api/tx/$txid";
      var data= await BaseApi.RequestEmpty_h.get(uri,
        params: {},
        defaultReutrn: false,
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
