import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

class CreateBTCTX {
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
  ) async {
    final BigInt privateKey = decodeWif(wifPrivateKey);
    final int sendAmount = ethToWeiString('$sendValue', 8).toInt();
    const int fee = 10000;
    int totalInputAmount = 0;

    final List<Map<String, dynamic>> selectedUTXOs = [];
    for (Map utxo in inputs) {
      totalInputAmount += utxo['value'] as int;
      final MessageModel utxoTx = await getUTXOTxid(utxo['txid']);
      if (!utxoTx.error) {
        selectedUTXOs.add({
          'txid': utxo['txid'],
          'vout': utxo['vout'],
          'amount': utxo['value'],
        });
      }
      if (totalInputAmount >= (sendAmount + fee)) break;
    }

    if (totalInputAmount < sendAmount + fee) {
      throw Exception('余额不足！');
    }

    final int changeAmount = totalInputAmount - sendAmount - fee;
    final Uint8List rawTx = createRawTransaction(
      selectedUTXOs,
      recipientAddress,
      sendAmount,
      changeAmount,
      fromAddress,
      pubKey,
      pubKeyStr,
      recipientScriptPubkey,
    );

    final String txHashStr = hex.encode(rawTx);
    final ByteData data1 = ByteData(4)..setUint32(0, 1, Endian.little);
    final ByteData data2 = ByteData(4)..setUint32(0, 0xffffffff, Endian.little);
    final Uint8List rawTx2 = Uint8List.fromList(
      rawTx + data2.buffer.asUint8List(0, 4) + data1.buffer.asUint8List(0, 4),
    );

    AppLogger.d('CreateBTCTX', 'raw tx: $txHashStr');
    final Uint8List txHash = signWithPrivateKey(rawTx2, privateKey);
    final String witness = '${bytesToHex(txHash)}${pubKeyStr}00000000';
    return txHashStr + witness;
  }

  /// 解码 WIF 私钥
  BigInt decodeWif(String wif) {
    final Uint8List decoded = base58Decode(wif);
    return BigInt.parse(hex.encode(decoded.sublist(1, 33)), radix: 16);
  }

  /// Base58 解码
  Uint8List base58Decode(String input) {
    const String alphabet =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    BigInt num = BigInt.zero;

    for (int i = 0; i < input.length; i++) {
      final int charIndex = alphabet.indexOf(input[i]);
      if (charIndex == -1) {
        throw ArgumentError('Invalid Base58 character: ${input[i]}');
      }
      num = num * BigInt.from(58) + BigInt.from(charIndex);
    }

    List<int> bytes = hex.decode(num.toRadixString(16).padLeft(50, '0'));
    while (bytes.length < 25) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }

  /// 计算双 SHA256
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
    final int estimatedSize = 200 + (inputs.length * 180);
    final ByteData data = ByteData(estimatedSize);
    int offset = 0;

    // 版本号
    data.setUint32(offset, 1, Endian.little);
    offset += 4;

    // SegWit 旗帜字节
    data.setUint8(offset, 0x00);
    offset += 1;
    data.setUint8(offset, 0x01);
    offset += 1;
    AppLogger.d('CreateBTCTX', bytesToHex(data.buffer.asUint8List(0, offset)));

    // 输入数量
    data.setUint8(offset, inputs.length);
    offset += 1;

    // 处理输入
    for (var input in inputs) {
      final Uint8List txidBytes = Uint8List.fromList(
        hex.decode(input['txid']).reversed.toList(),
      );
      data.buffer.asUint8List().setRange(offset, offset + 32, txidBytes);
      offset += 32;
      data.setUint32(offset, input['vout'], Endian.little);
      offset += 4;

      // P2WPKH 输入的 scriptSig 长度为 0
      data.setUint8(offset, 0x00);
      offset += 1;

      // 序列号（默认值：无时间锁约束）
      data.setUint32(offset, 0xffffffff, Endian.little);
      offset += 4;
    }

    // 输出数量
    data.setUint8(offset, changeAmount > 0 ? 2 : 1);
    offset += 1;

    // 发送金额和 scriptPubKey
    data.setUint64(offset, sendAmount, Endian.little);
    offset += 8;
    final Uint8List scriptPubKey = getScriptPubKey(
      Uint8List.fromList(hex.decode(recipientScriptPubkey)),
    );
    data.setUint8(offset, scriptPubKey.length);
    offset += 1;
    data.buffer.asUint8List().setRange(
      offset,
      offset + scriptPubKey.length,
      scriptPubKey,
    );
    offset += scriptPubKey.length;

    // 找零
    if (changeAmount > 0) {
      data.setUint64(offset, changeAmount, Endian.little);
      offset += 8;
      final Uint8List changeScript = getP2WPKHScript(publicKey);
      data.setUint8(offset, changeScript.length);
      offset += 1;
      data.buffer.asUint8List().setRange(
        offset,
        offset + changeScript.length,
        changeScript,
      );
      offset += changeScript.length;
    }

    AppLogger.d('CreateBTCTX', bytesToHex(data.buffer.asUint8List(0, offset)));
    return data.buffer.asUint8List(0, offset);
  }

  /// SHA256 哈希计算
  Uint8List sha256s(Uint8List data) {
    return Uint8List.fromList(sha256.convert(data).bytes);
  }

  /// 计算 P2WSH scriptPubKey
  Uint8List getScriptPubKey(Uint8List redeemScript) {
    final Uint8List witnessScriptHash = doubleSha256(redeemScript);
    return Uint8List.fromList([0x00, 0x20, ...witnessScriptHash]);
  }

  Uint8List serializeTransaction(
    Uint8List rawTx,
    List<Uint8List> signatures,
    Uint8List publicKey,
  ) {
    final ByteData data = ByteData(rawTx.length + (signatures.length * 180));
    int offset = 0;

    data.buffer.asUint8List().setRange(0, rawTx.length, rawTx);
    offset += rawTx.length;

    // witness 数据
    data.setUint8(offset, signatures.length);
    offset += 1;

    for (var sig in signatures) {
      data.setUint8(offset, 2); // witness 包含两个元素
      offset += 1;

      data.setUint8(offset, sig.length);
      offset += 1;
      data.buffer.asUint8List().setRange(offset, offset + sig.length, sig);
      offset += sig.length;

      data.setUint8(offset, publicKey.length);
      offset += 1;
      data.buffer.asUint8List().setRange(
        offset,
        offset + publicKey.length,
        publicKey,
      );
      offset += publicKey.length;
    }

    return data.buffer.asUint8List(0, offset);
  }

  Uint8List ripemd160Hash(Uint8List data) {
    return RIPEMD160Digest().process(data);
  }

  Uint8List getP2WPKHScript(Uint8List publicKey) {
    // PubKeyHash = RIPEMD-160(SHA-256(PubKey))
    final Uint8List pubKeyHash = ripemd160Hash(sha256s(publicKey));
    // P2WPKH scriptPubKey: 0x00 + 0x14 + pubKeyHash
    return Uint8List.fromList([0x00, 0x14, ...pubKeyHash]);
  }

  Uint8List signWithPrivateKey(Uint8List txHash, BigInt privateKey) {
    final ECDomainParameters curve = ECDomainParameters('secp256k1');
    final ECPrivateKey ecPrivateKey = ECPrivateKey(privateKey, curve);

    final Signer signer = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64));
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(ecPrivateKey));

    ECSignature signature = signer.generateSignature(txHash) as ECSignature;

    // 低 s 值规范化（Bitcoin 规定 s 必须小于 n/2）
    final BigInt nDiv2 = curve.n >> 1;
    if (signature.s.compareTo(nDiv2) > 0) {
      signature = ECSignature(signature.r, curve.n - signature.s);
    }

    return Uint8List.fromList([...encodeDER(signature), 0x01]);
  }

  Uint8List encodeDER(ECSignature signature) {
    List<int> rBytes = _bigIntToBytes(signature.r);
    List<int> sBytes = _bigIntToBytes(signature.s);

    // DER 规范：最高位为 1 时前置 0x00
    if (rBytes[0] & 0x80 != 0) rBytes = [0x00, ...rBytes];
    if (sBytes[0] & 0x80 != 0) sBytes = [0x00, ...sBytes];

    // DER 格式: 0x30 | 总长度 | 0x02 | r 长度 | r | 0x02 | s 长度 | s
    return Uint8List.fromList([
      0x30,
      rBytes.length + sBytes.length + 4,
      0x02,
      rBytes.length,
      ...rBytes,
      0x02,
      sBytes.length,
      ...sBytes,
    ]);
  }

  List<int> _bigIntToBytes(BigInt value) {
    final bytes = hex.decode(value.toRadixString(16).padLeft(64, '0'));
    final result = bytes.skipWhile((b) => b == 0).toList();
    return result.isEmpty ? [0] : result;
  }

  Future<MessageModel> getUTXOTxid(String txid, {bool isTest = false}) async {
    try {
      final uri = isTest
          ? 'https://mempool.space/testnet4/api/tx/$txid'
          : 'https://mempool.space/api/tx/$txid';
      final data = await BaseApi.requestEmptyH.get(
        uri,
        params: {},
        defaultReturn: false,
        header: {'Content-Type': 'application/json'},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }
}
